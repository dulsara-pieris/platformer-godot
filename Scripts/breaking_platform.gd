## BreakingPlatform.gd
## Single TileMapLayer breaking platforms — no external assets needed.
## Crack states are shown via color modulation + shake.
## Assign in Inspector: tile_map, player.

extends Node2D

# ── Inspector ─────────────────────────────────────────────────────────────────
@export var tile_map:      TileMapLayer
@export var player:        CharacterBody2D

@export var crack1_delay:  float = 0.5   ## seconds on tile → first crack
@export var crack2_delay:  float = 0.4   ## first crack → second crack
@export var break_delay:   float = 0.3   ## second crack → break
@export var respawn_delay: float = 3.0   ## broken → respawn
@export var shake_amount:  float = 3.0   ## shake pixels

# ── Crack colour tints (no sprites needed) ────────────────────────────────────
const COLOR_NORMAL  := Color(1.00, 1.00, 1.00, 1.0)   # white  = untouched
const COLOR_CRACK1  := Color(1.00, 0.80, 0.60, 1.0)   # warm orange tint
const COLOR_CRACK2  := Color(0.80, 0.45, 0.25, 1.0)   # dark brown tint
const COLOR_RESPAWN := Color(1.00, 1.00, 1.00, 0.0)   # invisible → fade in

# ── Internal ──────────────────────────────────────────────────────────────────
enum TileState { SOLID, CRACK1, CRACK2, BROKEN }

var _tile_state:   Dictionary = {}   # Vector2i → TileState
var _tile_timers:  Dictionary = {}   # Vector2i → Timer
var _tile_tweens:  Dictionary = {}   # Vector2i → Tween
var _original_src: Dictionary = {}   # Vector2i → int
var _original_atl: Dictionary = {}   # Vector2i → Vector2i
var _shake_tween:  Tween               # single shared shake tween

# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	if not tile_map:
		push_error("BreakingPlatform: assign 'tile_map' in the Inspector."); return
	if not player:
		push_error("BreakingPlatform: assign 'player' in the Inspector."); return

	for cell: Vector2i in tile_map.get_used_cells():
		_original_src[cell] = tile_map.get_cell_source_id(cell)
		_original_atl[cell] = tile_map.get_cell_atlas_coords(cell)
		_tile_state[cell]   = TileState.SOLID

func _physics_process(_delta: float) -> void:
	if not player:
		return
	for tile: Vector2i in _get_standing_tiles():
		if _tile_state.get(tile, TileState.BROKEN) == TileState.SOLID:
			_begin_breaking(tile)

# ── Foot detection ────────────────────────────────────────────────────────────
func _get_standing_tiles() -> Array:
	if not player.is_on_floor():
		return []

	var tiles: Array = []
	var col: CollisionShape2D = player.get_node_or_null("CollisionShape2D")

	if col == null:
		var t: Vector2i = tile_map.local_to_map(
			tile_map.to_local(player.global_position + Vector2(0.0, 4.0)))
		tiles.append(t)
		return tiles

	var shape: Shape2D = col.shape
	var half_w: float  = 0.0
	var half_h: float  = 0.0

	if shape is RectangleShape2D:
		half_w = (shape as RectangleShape2D).size.x * 0.5
		half_h = (shape as RectangleShape2D).size.y * 0.5
	elif shape is CapsuleShape2D:
		half_w = (shape as CapsuleShape2D).radius
		half_h = (shape as CapsuleShape2D).height * 0.5

	var foot_y: float = player.global_position.y + col.position.y + half_h

	for i: int in range(4):
		var x: float      = player.global_position.x - half_w + (2.0 * half_w * float(i) / 3.0)
		var tc: Vector2i  = tile_map.local_to_map(tile_map.to_local(Vector2(x, foot_y + 2.0)))
		if tc not in tiles and _tile_state.get(tc) != null:
			tiles.append(tc)

	return tiles

# ── Break sequence ────────────────────────────────────────────────────────────
func _begin_breaking(tile: Vector2i) -> void:
	_tile_state[tile] = TileState.CRACK1
	_tint(tile, COLOR_CRACK1, 0.15)
	_start_shake()
	_schedule(tile, crack1_delay, _apply_crack2)

func _apply_crack2(tile: Vector2i) -> void:
	if _tile_state.get(tile) != TileState.CRACK1:
		return
	_tile_state[tile] = TileState.CRACK2
	_tint(tile, COLOR_CRACK2, 0.15)
	_schedule(tile, crack2_delay, _do_break)

func _do_break(tile: Vector2i) -> void:
	if _tile_state.get(tile) != TileState.CRACK2:
		return
	_tile_state[tile] = TileState.BROKEN
	_stop_shake()
	_burst_particles(tile)
	tile_map.erase_cell(tile)
	_schedule(tile, respawn_delay, _respawn_tile)

func _respawn_tile(tile: Vector2i) -> void:
	# Restore cell then fade it in from transparent → opaque
	var src:   int      = _original_src.get(tile, 0)
	var atlas: Vector2i = _original_atl.get(tile, Vector2i.ZERO)
	tile_map.set_cell(tile, src, atlas)
	_tile_state[tile] = TileState.SOLID
	_tint(tile, COLOR_RESPAWN, 0.0)       # start invisible
	_tint(tile, COLOR_NORMAL,  0.4)        # fade to normal over 0.4 s

# ── Colour tint per-tile via TileMap modulate (layer-wide fallback) ───────────
# TileMapLayer has no per-cell modulate, so we tween the layer's own modulate.
# This works perfectly when all non-broken tiles share the same state.
# For truly independent per-tile colour, a CanvasGroup per tile would be needed —
# this lightweight approach is sufficient for most platformers.
func _tint(tile: Vector2i, target: Color, duration: float) -> void:
	if tile in _tile_tweens:
		(_tile_tweens[tile] as Tween).kill()
		_tile_tweens.erase(tile)

	# We modulate the whole layer; last write wins which is fine for sequential breaks
	var tw: Tween = create_tween()
	tw.tween_property(tile_map, "modulate", target, duration)
	_tile_tweens[tile] = tw
	# Reset to normal after reaching target (unless broken state)
	if target != COLOR_RESPAWN:
		tw.tween_property(tile_map, "modulate", COLOR_NORMAL, duration * 0.5)

# ── Shake (layer-level) ───────────────────────────────────────────────────────
func _start_shake() -> void:
	if _shake_tween and _shake_tween.is_running():
		return
	_shake_tween = create_tween().set_loops()
	_shake_tween.tween_property(tile_map, "position:x",  shake_amount, 0.04)
	_shake_tween.tween_property(tile_map, "position:x", -shake_amount, 0.04)
	_shake_tween.tween_property(tile_map, "position:x",  0.0,          0.04)

func _stop_shake() -> void:
	# Only stop if no tile is still cracking
	for state: int in _tile_state.values():
		if state == TileState.CRACK1 or state == TileState.CRACK2:
			return
	if _shake_tween:
		_shake_tween.kill()
	tile_map.position.x = 0.0

# ── Timer helper ──────────────────────────────────────────────────────────────
func _schedule(tile: Vector2i, delay: float, callback: Callable) -> void:
	if tile in _tile_timers:
		var old: Timer = _tile_timers[tile]
		old.stop()
		old.queue_free()
		_tile_timers.erase(tile)

	var t: Timer = Timer.new()
	t.wait_time  = delay
	t.one_shot   = true
	add_child(t)
	t.timeout.connect(func() -> void:
		_tile_timers.erase(tile)
		t.queue_free()
		callback.call(tile)
	)
	_tile_timers[tile] = t
	t.start()

# ── Particle burst (code-only, no asset) ─────────────────────────────────────
func _burst_particles(tile: Vector2i) -> void:
	var world_pos: Vector2 = tile_map.to_global(tile_map.map_to_local(tile))
	var p: CPUParticles2D  = CPUParticles2D.new()
	p.position             = world_pos
	p.emitting             = true
	p.one_shot             = true
	p.explosiveness        = 1.0
	p.amount               = 14
	p.lifetime             = 0.55
	p.direction            = Vector2(0.0, -1.0)
	p.spread               = 70.0
	p.initial_velocity_min = 50.0
	p.initial_velocity_max = 130.0
	p.gravity              = Vector2(0.0, 350.0)
	p.scale_amount_min     = 3.0
	p.scale_amount_max     = 7.0
	p.color                = Color(0.65, 0.42, 0.22)
	get_tree().root.add_child(p)

	var cleanup: Timer = Timer.new()
	cleanup.wait_time   = 1.4
	cleanup.one_shot    = true
	get_tree().root.add_child(cleanup)
	cleanup.timeout.connect(func() -> void:
		p.queue_free()
		cleanup.queue_free()
	)
	cleanup.start()
