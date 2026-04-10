extends CharacterBody2D

# ═══════════════════════════════════════════════════════════
#  NODES
# ═══════════════════════════════════════════════════════════
@onready var character:       AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_dust:       AnimatedSprite2D = $JumpDust
@onready var camera:          Camera2D         = $Camera
@onready var attack_area:     Area2D           = $AttackArea
@onready var collision_shape: CollisionShape2D = $AttackArea/CollisionShape2D

# ═══════════════════════════════════════════════════════════
#  STATS
# ═══════════════════════════════════════════════════════════
var ability:    int   = 0
var experience: int   = 0
var skin:       String = ""
var skin_scale: float  = 0.5

# ═══════════════════════════════════════════════════════════
#  MOVEMENT
# ═══════════════════════════════════════════════════════════
const SPEED:        float = 330.0
const AIR_CONTROL:  float = 0.82
const GROUND_STOP:  float = 3800.0
const AIR_STOP:     float = 460.0
const TERMINAL_VEL: float = 1050.0

# ── double-tap dash (no extra button) ──────────────────────
const DTAP_WINDOW: float = 0.18
var dtap_timer:    float = 0.0
var dtap_last_dir: float = 0.0
var dtap_armed:    bool  = false

const DASH_SPEED:  float = 800.0
const DASH_DUR:    float = 0.11
const DASH_FREEZE: float = 0.035
var is_dashing:       bool    = false
var dash_timer:       float   = 0.0
var dash_dir:         Vector2 = Vector2.ZERO
var can_dash:         bool    = true
var is_dash_frozen:   bool    = false
var dash_freeze_timer:float   = 0.0

# ── momentum ───────────────────────────────────────────────
var momentum:     float = 1.0
const MOM_MAX:    float = 1.38
const MOM_UP:     float = 0.22
const MOM_DOWN:   float = 3.8

# ── slide ──────────────────────────────────────────────────
const SLIDE_SPEED: float = 640.0
const SLIDE_DUR:   float = 0.36
const SLIDE_DRAG:  float = 1300.0
var is_sliding:    bool  = false
var slide_timer:   float = 0.0
var slide_dir:     float = 1.0

# ═══════════════════════════════════════════════════════════
#  JUMP
# ═══════════════════════════════════════════════════════════
const JUMP_VEL:       float   = -540.0
const JUMP_HOLD:      float   = -2200.0
const JUMP_HOLD_TIME: float   = 0.15
const JUMP_CUT:       float   = 0.46
const WALL_JUMP_VEL:  Vector2 = Vector2(370.0, -510.0)
const WALL_SLIDE_SPD: float   = 52.0
const COYOTE:         float   = 0.14
const J_BUFFER:       float   = 0.14
const MAX_JUMPS:      int     = 2
const BUNNY_WINDOW:   float   = 0.13
const BUNNY_BOOST:    float   = 1.22

var jump_hold_timer: float = 0.0
var is_jumping:      bool  = false
var jumps_left:      int   = 0
var coyote_timer:    float = 0.0
var j_buffer_timer:  float = 0.0
var wall_lock:       float = 0.0
var air_stall_used:  bool  = false
var bunny_timer:     float = 0.0

# ═══════════════════════════════════════════════════════════
#  GRAVITY
# ═══════════════════════════════════════════════════════════
const G_NORMAL:   float = 2.5
const G_RISE:     float = 1.25
const G_APEX:     float = 0.38
const G_FASTFALL: float = 5.2
const G_WALL:     float = 0.1
const APEX_RANGE: float = 78.0
var grav:         float = 2.5

# ═══════════════════════════════════════════════════════════
#  WALL GRIP / STAMINA (Celeste-style)
# ═══════════════════════════════════════════════════════════
const GRIP_MAX:               float = 1.0
const GRIP_DRAIN:             float = 0.20   # /s while holding
const GRIP_CLIMB_DRAIN:       float = 0.38   # /s extra while climbing UP
const GRIP_WALL_JUMP_RESTORE: float = 0.28   # refund on wall-jump

const WALL_CLIMB_UP_SPD: float = 115.0
const WALL_CLIMB_DN_SPD: float = 65.0

var grip:           float = 1.0
var grip_exhausted: bool  = false

# ═══════════════════════════════════════════════════════════
#  GROUND POUND
# ═══════════════════════════════════════════════════════════
const POUND_SPD:    float = 1150.0
const POUND_BOUNCE: float = -200.0
var is_pounding:    bool  = false

# ═══════════════════════════════════════════════════════════
#  ATTACK
# ═══════════════════════════════════════════════════════════
var is_attacking: bool  = false
var can_attack:   bool  = true

var combo:             int   = 0
var combo_timer:       float = 0.0
const COMBO_WINDOW:    float = 0.52
const COMBO_MAX:       int   = 3

var atk_hold:          float = 0.0
var is_charging:       bool  = false
var charge_ready:      bool  = false
var charge_dmg_ready:  bool  = false
const CHARGE_TIME:     float = 0.38

var heat:              float = 0.0
const HEAT_PER_HIT:    float = 24.0
const HEAT_DECAY:      float = 8.5
const HEAT_ATK_BONUS:  float = 0.32

var parry_timer:       float = 0.0
const PARRY_WINDOW:    float = 0.11

# ═══════════════════════════════════════════════════════════
#  DAMAGE
# ═══════════════════════════════════════════════════════════
var knockback:    Vector2 = Vector2.ZERO
var damaged:      bool    = false
var iframe_timer: float   = 0.0
const IFRAME_TIME:float   = 0.75

# ═══════════════════════════════════════════════════════════
#  DEATH / MISC
# ═══════════════════════════════════════════════════════════
var is_dead:    bool  = false
var is_climbing:bool  = false

# ═══════════════════════════════════════════════════════════
#  SLOW MOTION
# ═══════════════════════════════════════════════════════════
var slowmo_timer:       float = 0.0
const SLOWMO_SCALE:     float = 0.2
const SLOWMO_RESTORE:   float = 18.0

# ═══════════════════════════════════════════════════════════
#  TRAUMA SHAKE
# ═══════════════════════════════════════════════════════════
var trauma:          float   = 0.0
const TRAUMA_DECAY:  float   = 2.2
var shake_dir:       Vector2 = Vector2.ZERO
var shake_t:         float   = 0.0

func _hit(t: float) -> void:
	trauma = minf(trauma + t, 1.0)

func _hit_dir(t: float, d: Vector2) -> void:
	trauma    = minf(trauma + t, 1.0)
	shake_dir = d.normalized()

# ═══════════════════════════════════════════════════════════
#  CAMERA  — critically-damped spring + predictive lead
# ═══════════════════════════════════════════════════════════

# ── spring ────────────────────────────────────────────────
const CAM_FREQ_X:     float = 7.0
const CAM_FREQ_Y:     float = 4.5
const CAM_DAMP_X:     float = 1.0
const CAM_DAMP_Y:     float = 1.0

# ── lookahead ─────────────────────────────────────────────
const LEAD_X:         float = 120.0
const LEAD_Y_FALL:    float = 80.0
const LEAD_Y_RISE:    float = 28.0
const LEAD_SPD_X:     float = 8.0
const LEAD_SPD_Y:     float = 2.8
const CAM_BIAS_Y:     float = -28.0

# ── deadzones ─────────────────────────────────────────────
const DEAD_X:         float = 0.08
const DEAD_Y:         float = 48.0

# ── manual peek ───────────────────────────────────────────
const PEEK_DIST:      float = 80.0
const PEEK_SPD_IN:    float = 2.0
const PEEK_SPD_OUT:   float = 7.0
var cam_peek:         float = 0.0

# ── wall peek ─────────────────────────────────────────────
const WALL_PEEK:      float = 50.0
const WALL_PEEK_SPD:  float = 5.0
var cam_wall_peek:    float = 0.0

# ── land impact dip ───────────────────────────────────────
const IMPACT_DIP_MAX: float = 16.0
const IMPACT_FREQ:    float = 6.0
const IMPACT_DAMP:    float = 1.0
var cam_impact:       float = 0.0
var cam_impact_vel:   float = 0.0

# ── zoom ──────────────────────────────────────────────────
const ZOOM_BASE:      float = 1.0
const ZOOM_FAST:      float = 0.82
const ZOOM_IDLE:      float = 1.12
const ZOOM_WALL:      float = 0.94
const ZOOM_FALL:      float = 0.86
const ZOOM_POUND:     float = 0.72
const ZOOM_SPD_OUT:   float = 4.5
const ZOOM_SPD_IN:    float = 1.5
const ZOOM_SPEED_THR: float = 0.45
var zoom_tgt:         float = 1.0
var zoom_cur:         float = 1.0
var idle_timer:       float = 0.0
const IDLE_ZOOM_WAIT: float = 2.0

# ── shake ─────────────────────────────────────────────────
const SHAKE_RATE:     float = 7.0
const SHAKE_XY:       float = 10.0
const SHAKE_ROT:      float = 0.010

# ── zoom punch ────────────────────────────────────────────
var zpunch_timer: float = 0.0
var zpunch_amt:   float = 0.0
const ZPUNCH_DUR: float = 0.07

func _zpunch(s: float) -> void:
	zpunch_amt   = s
	zpunch_timer = ZPUNCH_DUR

# ── spring state ──────────────────────────────────────────
var cam_vel:  Vector2 = Vector2.ZERO
var cam_pos:  Vector2 = Vector2.ZERO
var cam_lead: Vector2 = Vector2.ZERO

# ═══════════════════════════════════════════════════════════
#  SQUASH & STRETCH
# ═══════════════════════════════════════════════════════════
var sx: float = 0.5
var sy: float = 0.5
var tx: float = 0.5
var ty: float = 0.5
const SX_SPD: float = 40.0
const SY_SPD: float = 20.0

var tilt_tgt:  float = 0.0
var was_floor: bool  = false
var land_freeze:float = 0.0
const FREEZE_HEAVY: float = 0.05
var spd_ratio:  float = 0.0

func _squash(qx: float, qy: float) -> void:
	sx = qx * 0.5
	sy = qy * 0.5

# ═══════════════════════════════════════════════════════════
#  AFTERIMAGE
# ═══════════════════════════════════════════════════════════
var ghost_timer: float        = 0.0
const GHOST_INTERVAL: float   = 0.028

# ═══════════════════════════════════════════════════════════
#  WIND
# ═══════════════════════════════════════════════════════════
@export var wind_strength: float = 200.0
@export var wind_change:   float = 0.3
@export var wind_sway:     float = 0.032

var wind_vel:      Vector2 = Vector2.ZERO
var wind_tgt:      Vector2 = Vector2.ZERO
var wind_tick:     float   = 0.0
var wind_interval: float   = 3.5

func set_wind(f: Vector2) -> void:
	wind_tgt = f

func _new_wind() -> void:
	var a: float = randf_range(-PI * 0.3, PI * 0.3)
	var s: float = randf_range(wind_strength * 0.18, wind_strength)
	wind_tgt = Vector2(cos(a), sin(a) * 0.22) * s
	if randf() > 0.5:
		wind_tgt.x *= -1.0
	wind_interval = randf_range(1.8, 5.0)

# ═══════════════════════════════════════════════════════════
#  READY
# ═══════════════════════════════════════════════════════════
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	ability    = GameManager.ability
	experience = GameManager.experience
	skin       = GameManager.skin
	GameManager.health     = 300
	GameManager.experience = experience
	collision_shape.disabled = true
	GameManager.have_weapon  = false
	jumps_left = MAX_JUMPS
	sx = 0.5; sy = 0.5
	tx = 0.5; ty = 0.5
	grip           = GRIP_MAX
	grip_exhausted = false
	cam_pos        = Vector2.ZERO
	cam_vel        = Vector2.ZERO
	cam_lead       = Vector2.ZERO
	cam_peek       = 0.0
	cam_wall_peek  = 0.0
	cam_impact     = 0.0
	cam_impact_vel = 0.0
	zoom_cur       = ZOOM_BASE
	zoom_tgt       = ZOOM_BASE
	idle_timer     = 0.0
	shake_t        = 0.0
	_new_wind()

# ═══════════════════════════════════════════════════════════
#  PHYSICS
# ═══════════════════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# ── SLOW MOTION ───────────────────────────────────────
	if slowmo_timer > 0.0:
		slowmo_timer -= delta
		Engine.time_scale = lerp(Engine.time_scale, SLOWMO_SCALE, 22.0 * delta)
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, SLOWMO_RESTORE * delta)

	# ── LAND FREEZE ───────────────────────────────────────
	if land_freeze > 0.0:
		land_freeze -= delta
		move_and_slide()
		return

	# ── DASH FREEZE ───────────────────────────────────────
	if is_dash_frozen:
		dash_freeze_timer -= delta
		if dash_freeze_timer <= 0.0:
			is_dash_frozen = false
			_fire_dash()
		move_and_slide()
		return

	GameManager.skin_scale = skin_scale
	skin    = GameManager.skin
	ability = GameManager.ability

	var dir:      float = Input.get_axis("ui_left", "ui_right")
	var on_floor: bool  = is_on_floor()
	var on_wall:  bool  = is_on_wall_only()

	# ── IFRAME FLICKER ────────────────────────────────────
	if iframe_timer > 0.0:
		iframe_timer -= delta
		character.modulate.a = 0.3 if fmod(iframe_timer, 0.09) > 0.045 else 1.0
	else:
		character.modulate.a = 1.0

	# ── HEAT DECAY ────────────────────────────────────────
	heat = maxf(heat - HEAT_DECAY * delta, 0.0)

	# ── PARRY WINDOW ──────────────────────────────────────
	if parry_timer > 0.0:
		parry_timer -= delta

	# ── BUNNY HOP TIMER ───────────────────────────────────
	if bunny_timer > 0.0:
		bunny_timer -= delta

	# ── LAND DETECT ───────────────────────────────────────
	if on_floor and not was_floor:
		_land()
	was_floor = on_floor

	# ── FLOOR RESETS ──────────────────────────────────────
	if on_floor:
		jumps_left     = MAX_JUMPS
		can_dash       = true
		is_pounding    = false
		air_stall_used = false
		grip           = GRIP_MAX
		grip_exhausted = false
		if not is_sliding:
			momentum = minf(momentum + MOM_UP * delta, MOM_MAX)
	else:
		momentum = maxf(momentum - MOM_DOWN * delta, 1.0)

	# ── WIND ──────────────────────────────────────────────
	wind_tick -= delta
	if wind_tick <= 0.0:
		_new_wind()
		wind_tick = wind_interval
	wind_vel = wind_vel.lerp(wind_tgt, wind_change * delta)

	# ── DOUBLE-TAP DASH ───────────────────────────────────
	if dtap_timer > 0.0:
		dtap_timer -= delta
		if dtap_timer <= 0.0:
			dtap_armed    = false
			dtap_last_dir = 0.0

	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		var tap_dir: float = -1.0 if Input.is_action_just_pressed("ui_left") else 1.0
		if dtap_armed and tap_dir == dtap_last_dir and can_dash and not is_dashing and not is_dash_frozen:
			_queue_dash(tap_dir)
			dtap_armed    = false
			dtap_last_dir = 0.0
			dtap_timer    = 0.0
		else:
			dtap_last_dir = tap_dir
			dtap_armed    = true
			dtap_timer    = DTAP_WINDOW

	# ── DASH ACTIVE ───────────────────────────────────────
	if is_dashing:
		dash_timer -= delta
		ghost_timer -= delta
		if ghost_timer <= 0.0:
			ghost_timer = GHOST_INTERVAL
			_ghost()
		velocity = dash_dir * DASH_SPEED
		if dash_dir.y >= 0.0:
			velocity.y += get_gravity().y * delta * 0.22
		if dash_timer <= 0.0:
			is_dashing = false
			velocity  *= 0.28
		move_and_slide()
		return

	# ── CHARGE ATTACK ─────────────────────────────────────
	if Input.is_action_pressed("attack") and can_attack and not is_attacking:
		atk_hold += delta
		if atk_hold >= CHARGE_TIME and not is_charging:
			is_charging = true
			tx = 0.4; ty = 0.62
	else:
		if is_charging and atk_hold >= CHARGE_TIME:
			is_charging  = false
			charge_ready = true
			atk_hold     = 0.0
			_attack()
		elif not Input.is_action_pressed("attack"):
			atk_hold    = 0.0
			is_charging = false

	# ── SLIDE: down + running on floor ────────────────────
	if Input.is_action_just_pressed("ui_down") and on_floor and absf(velocity.x) > 70.0 and not is_sliding:
		_slide()

	if is_sliding:
		slide_timer -= delta
		velocity.x   = move_toward(velocity.x, 0.0, SLIDE_DRAG * delta)
		if slide_timer <= 0.0 or absf(velocity.x) < 35.0:
			is_sliding = false
			tx = 0.5; ty = 0.5

	# ── GROUND POUND: down in air ─────────────────────────
	if Input.is_action_just_pressed("ui_down") and not on_floor and not is_pounding and not is_climbing:
		_pound_start()
	if is_pounding and on_floor:
		_pound_end()

	# ── COMBO RESET ───────────────────────────────────────
	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo = 0

	# ── ATTACK ────────────────────────────────────────────
	if Input.is_action_just_pressed("attack") and not is_charging:
		_attack()

	# ── JUMP BUFFER ───────────────────────────────────────
	if Input.is_action_just_pressed("ui_accept"):
		j_buffer_timer = J_BUFFER
		parry_timer    = PARRY_WINDOW
	else:
		j_buffer_timer -= delta

	# ── COYOTE ────────────────────────────────────────────
	if on_floor or is_climbing:
		coyote_timer = COYOTE
	else:
		coyote_timer -= delta

	# ── WALL GRIP / CLIMB (Celeste-style) ─────────────────
	var can_grip: bool = (
		on_wall
		and GameManager.can_climb
		and dir != 0.0
		and grip > 0.0
		and not grip_exhausted
	)
	is_climbing = can_grip

	if is_climbing:
		var climb_input: float = Input.get_axis("ui_up", "ui_down")
		var drain: float = GRIP_DRAIN * delta
		if climb_input < -0.3:
			velocity.y  = -WALL_CLIMB_UP_SPD
			drain      += GRIP_CLIMB_DRAIN * delta
		elif climb_input > 0.3:
			velocity.y  = WALL_CLIMB_DN_SPD
		else:
			velocity.y  = 0.0

		grip -= drain
		if grip <= 0.0:
			grip           = 0.0
			grip_exhausted = true
			is_climbing    = false
	else:
		var wall_sliding: bool = (
			on_wall
			and not on_floor
			and velocity.y > 0.0
			and dir != 0.0
		)
		if wall_sliding:
			velocity.y = minf(velocity.y, WALL_SLIDE_SPD)

	if wall_lock > 0.0:
		wall_lock -= delta

	# ── GRAVITY ───────────────────────────────────────────
	var at_apex:   bool = absf(velocity.y) < APEX_RANGE and not on_floor and not is_climbing \
						  and not Input.is_action_pressed("ui_down")
	var fast_fall: bool = Input.is_action_pressed("ui_down") and not on_floor and not is_pounding and velocity.y > 0.0

	if is_pounding:        grav = 0.0
	elif is_climbing:      grav = 0.0
	elif fast_fall:        grav = G_FASTFALL
	elif velocity.y > 0.0 and on_wall and not grip_exhausted and dir != 0.0:
		grav = G_WALL
	elif at_apex:          grav = G_APEX
	elif velocity.y < 0.0: grav = G_RISE
	else:                  grav = G_NORMAL

	# ── AIR STALL ─────────────────────────────────────────
	if Input.is_action_just_pressed("ui_accept") and at_apex and not air_stall_used and jumps_left == 0:
		velocity.y     = -175.0
		air_stall_used = true
		_squash(1.18, 0.74)

	# ── JUMP ──────────────────────────────────────────────
	var wall_dir: float = 0.0
	if on_wall:
		var wn: Vector2 = get_wall_normal()
		wall_dir = 1.0 if wn.x > 0.0 else -1.0

	var pressing_into_wall: bool = (on_wall or is_climbing) and dir != 0.0 and dir == -wall_dir

	var can_wall_j:  bool = (on_wall or is_climbing) and GameManager.can_climb and wall_dir != 0.0
	var can_floor_j: bool = coyote_timer > 0.0 or is_climbing

	if j_buffer_timer > 0.0:
		if can_floor_j and not on_wall:
			_jump(JUMP_VEL, false)
		elif can_wall_j:
			if pressing_into_wall:
				_wall_hop()
			else:
				_wall_jump(wall_dir)
		elif jumps_left > 0:
			_jump(JUMP_VEL * 0.84, true)

	# ── HOLD JUMP ─────────────────────────────────────────
	if is_jumping and Input.is_action_pressed("ui_down"):
		jump_hold_timer = 0.0
		is_jumping      = false

	if is_jumping and Input.is_action_pressed("ui_accept"):
		if jump_hold_timer > 0.0:
			velocity.y      += JUMP_HOLD * delta
			jump_hold_timer -= delta
		else:
			is_jumping = false

	if Input.is_action_just_released("ui_accept"):
		is_jumping = false
		if velocity.y < -80.0:
			velocity.y *= JUMP_CUT

	if velocity.y > 0.0:
		is_jumping = false

	# ── TERMINAL VELOCITY ─────────────────────────────────
	velocity.y = minf(velocity.y, TERMINAL_VEL)

	# ── APPLY GRAVITY ─────────────────────────────────────
	if not on_floor and not is_climbing:
		velocity += get_gravity() * delta * grav

	# ── WIND ──────────────────────────────────────────────
	var wind_inf: float = 1.0 if not on_floor else 0.09
	velocity += wind_vel * wind_inf * delta

	# ── HORIZONTAL ────────────────────────────────────────
	if not is_sliding:
		var spd: float = SPEED * momentum
		if wall_lock > 0.0:
			pass
		elif on_floor or on_wall:
			if dir != 0.0:
				velocity.x = dir * spd
				if not is_attacking:
					character.speed_scale = lerp(0.85, 1.75, absf(velocity.x) / SPEED)
					character.play(skin + "_run")
				character.flip_h    = dir < 0.0
				attack_area.scale.x = -1.0 if dir < 0.0 else 1.0
			else:
				velocity.x = move_toward(velocity.x, 0.0, GROUND_STOP * delta)
				character.speed_scale = 1.0
				if not is_attacking:
					character.play(skin + "_idle")
		else:
			if dir != 0.0:
				velocity.x = move_toward(velocity.x, dir * spd * AIR_CONTROL, spd * 8.0 * delta)
				character.flip_h = dir < 0.0
			else:
				velocity.x = move_toward(velocity.x, 0.0, AIR_STOP * delta)
			if not is_climbing:
				character.play(skin + "_jump")

	# ── TILT ──────────────────────────────────────────────
	spd_ratio = absf(velocity.x) / SPEED
	tilt_tgt  = (velocity.x / SPEED) * 0.11 * spd_ratio
	tilt_tgt += clampf(velocity.y / 1100.0, -0.05, 0.07)
	tilt_tgt += wind_vel.x / wind_strength * wind_sway
	character.rotation = lerp(character.rotation, tilt_tgt, 16.0 * delta)

	# ── SQUASH ────────────────────────────────────────────
	if not is_sliding and not is_charging:
		var sq: float = 1.0 - spd_ratio * 0.065
		tx = 0.5 / sq
		ty = 0.5 * sq

	sx = lerp(sx, tx, SX_SPD * delta)
	sy = lerp(sy, ty, SY_SPD * delta)
	character.scale = Vector2(sx, sy)

	# ── IDLE TIMER ────────────────────────────────────────
	if absf(velocity.x) < 18.0 and on_floor:
		idle_timer += delta
	else:
		idle_timer = 0.0

	# ── SHAKE (layered sine) ──────────────────────────────
	trauma  = maxf(trauma - TRAUMA_DECAY * delta, 0.0)
	shake_t += delta * SHAKE_RATE
	var t2:  float   = trauma * trauma
	var shk: Vector2 = Vector2.ZERO
	if t2 > 0.004:
		var nx: float = sin(shake_t * 1.0) * 0.6 + sin(shake_t * 2.3) * 0.3 + sin(shake_t * 3.7) * 0.1
		var ny: float = sin(shake_t * 1.4) * 0.6 + sin(shake_t * 2.7) * 0.3 + sin(shake_t * 4.1) * 0.1
		shk.x = nx * SHAKE_XY * t2 + shake_dir.x * SHAKE_XY * 0.3 * t2
		shk.y = ny * SHAKE_XY * t2 + shake_dir.y * SHAKE_XY * 0.3 * t2
		camera.rotation = sin(shake_t * 0.9) * SHAKE_ROT * t2
	else:
		shake_dir       = Vector2.ZERO
		camera.rotation = lerp(camera.rotation, 0.0, 14.0 * delta)

	# ── LAND IMPACT DIP ───────────────────────────────────
	var imp_omega: float = 2.0 * PI * IMPACT_FREQ
	var imp_k:     float = imp_omega * imp_omega
	var imp_c:     float = 2.0 * IMPACT_DAMP * imp_omega
	cam_impact_vel += (-imp_k * cam_impact - imp_c * cam_impact_vel) * delta
	cam_impact     += cam_impact_vel * delta
	if absf(cam_impact) < 0.1 and absf(cam_impact_vel) < 0.1:
		cam_impact     = 0.0
		cam_impact_vel = 0.0

	# ── ZOOM ──────────────────────────────────────────────
	if zpunch_timer > 0.0:
		zpunch_timer -= delta
		var zt: float = zpunch_timer / ZPUNCH_DUR
		camera.zoom   = Vector2(zoom_cur + zpunch_amt * zt, zoom_cur + zpunch_amt * zt)
	else:
		if is_pounding:
			zoom_tgt = ZOOM_POUND
		elif not on_floor and velocity.y > 280.0:
			zoom_tgt = lerp(ZOOM_BASE, ZOOM_FALL, clampf(velocity.y / TERMINAL_VEL, 0.0, 1.0))
		elif is_climbing:
			zoom_tgt = ZOOM_WALL
		elif idle_timer > IDLE_ZOOM_WAIT:
			zoom_tgt = ZOOM_IDLE
		else:
			var zr: float = clampf((spd_ratio - ZOOM_SPEED_THR) / (1.0 - ZOOM_SPEED_THR), 0.0, 1.0)
			zoom_tgt = lerp(ZOOM_BASE, ZOOM_FAST, zr)
		var zspd: float = ZOOM_SPD_OUT if zoom_tgt < zoom_cur else ZOOM_SPD_IN
		zoom_cur = lerp(zoom_cur, zoom_tgt, zspd * delta)
		camera.zoom = Vector2(zoom_cur, zoom_cur)

	# ── LEAD TARGET ───────────────────────────────────────
	var input_dir:  float = Input.get_axis("ui_left", "ui_right")
	var lead_x_tgt: float = 0.0
	if absf(input_dir) > DEAD_X:
		lead_x_tgt = input_dir * LEAD_X
	elif absf(velocity.x / SPEED) > DEAD_X:
		lead_x_tgt = signf(velocity.x) * LEAD_X * clampf(absf(velocity.x / SPEED), 0.0, 1.0)

	var lead_y_tgt: float = CAM_BIAS_Y
	if velocity.y > DEAD_Y:
		lead_y_tgt += clampf(velocity.y / TERMINAL_VEL, 0.0, 1.0) * LEAD_Y_FALL
	elif velocity.y < -DEAD_Y:
		lead_y_tgt -= clampf(-velocity.y / 560.0, 0.0, 1.0) * LEAD_Y_RISE

	var peek_input: float = Input.get_axis("ui_up", "ui_down")
	if idle_timer > 0.2:
		cam_peek = lerp(cam_peek, peek_input * PEEK_DIST, PEEK_SPD_IN * delta)
	else:
		cam_peek = lerp(cam_peek, 0.0, PEEK_SPD_OUT * delta)

	# FIX 6: use is_on_wall_only() to match the on_wall variable — was is_on_wall()
	var wall_peek_tgt: float = 0.0
	if is_climbing and is_on_wall_only():
		var wn: Vector2 = get_wall_normal()
		wall_peek_tgt   = wn.x * WALL_PEEK
	cam_wall_peek = lerp(cam_wall_peek, wall_peek_tgt, WALL_PEEK_SPD * delta)

	cam_lead.x = lerp(cam_lead.x, lead_x_tgt + cam_wall_peek, LEAD_SPD_X * delta)
	cam_lead.y = lerp(cam_lead.y, lead_y_tgt + cam_peek,      LEAD_SPD_Y * delta)

	# ── CRITICALLY-DAMPED SPRING ──────────────────────────
	var kx: float = pow(2.0 * PI * CAM_FREQ_X, 2.0)
	var cx: float = 2.0 * CAM_DAMP_X * (2.0 * PI * CAM_FREQ_X)
	var ky: float = pow(2.0 * PI * CAM_FREQ_Y, 2.0)
	var cy: float = 2.0 * CAM_DAMP_Y * (2.0 * PI * CAM_FREQ_Y)
	var sp: Vector2
	sp.x     = -kx * (cam_pos.x - cam_lead.x) - cx * cam_vel.x
	sp.y     = -ky * (cam_pos.y - cam_lead.y) - cy * cam_vel.y
	cam_vel += sp * delta
	cam_vel.x = clampf(cam_vel.x, -700.0, 700.0)
	cam_vel.y = clampf(cam_vel.y, -500.0, 500.0)
	cam_pos  += cam_vel * delta

	camera.offset = cam_pos + Vector2(0.0, cam_impact) + shk

	# ── KNOCKBACK ─────────────────────────────────────────
	if knockback.length() > 0.0:
		velocity += knockback
		knockback  = knockback.move_toward(Vector2.ZERO, 1300.0 * delta)

	# ── GRIP HUD ──────────────────────────────────────────
	GameManager.grip = grip

	# ── ANIM STATES ───────────────────────────────────────
	if GameManager.health <= 0:
		die()
	elif damaged:
		character.play(skin + "_hit")
		damaged = false

	# FIX 2: passive wall-slide gets its own distinct animation
	if on_wall and is_climbing:
		character.play(skin + "_grab")
	elif on_wall:
		character.play(skin + "_wallslide")

	# FIX 1: removed broken count variable — power anim now triggers correctly every time
	if GameManager.animation == "power":
		character.play(skin + "_power")
		GameManager.animation = null

	move_and_slide()

# ═══════════════════════════════════════════════════════════
#  AFTERIMAGE
# ═══════════════════════════════════════════════════════════
func _ghost() -> void:
	var g: Sprite2D = Sprite2D.new()
	g.texture = character.sprite_frames.get_frame_texture(character.animation, character.frame)
	# FIX 5: copy full transform so child offset, scale, and rotation are all preserved
	g.global_transform = character.global_transform
	g.flip_h           = character.flip_h
	g.modulate         = Color(0.5, 0.75, 1.0, 0.5)
	g.z_index          = character.z_index - 1
	get_parent().add_child(g)
	var tw: Tween = create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.13)
	tw.tween_callback(g.queue_free)

# ═══════════════════════════════════════════════════════════
#  JUMP
# ═══════════════════════════════════════════════════════════
func _jump(vel: float, is_dbl: bool) -> void:
	if bunny_timer > 0.0:
		velocity.x *= BUNNY_BOOST
		_hit(0.1)

	velocity.y      = vel
	velocity.x     += wind_vel.x * 0.16
	is_jumping       = true
	jump_hold_timer  = JUMP_HOLD_TIME
	coyote_timer     = 0.0
	j_buffer_timer   = 0.0
	jumps_left      -= 1

	if is_dbl:
		_squash(1.4, 0.5)
		_hit(0.1)
	else:
		_squash(0.44, 1.72)
		_hit(0.16)

	jump_dust.visible = true
	jump_dust.play("default")
	character.play(skin + "_jump")

func _wall_hop() -> void:
	velocity.y       = JUMP_VEL * 0.88
	velocity.x      *= 0.15
	is_jumping       = true
	jump_hold_timer  = JUMP_HOLD_TIME * 0.7
	j_buffer_timer   = 0.0
	grip = maxf(grip - 0.22, 0.0)
	if grip <= 0.0:
		grip_exhausted = true
	_squash(0.42, 1.82)
	_hit(0.10)
	jump_dust.visible = true
	jump_dust.play("default")
	character.play(skin + "_jump")

func _wall_jump(wd: float) -> void:
	velocity         = Vector2(wd * WALL_JUMP_VEL.x, WALL_JUMP_VEL.y)
	is_jumping       = true
	jump_hold_timer  = JUMP_HOLD_TIME * 0.6
	j_buffer_timer   = 0.0
	wall_lock        = 0.15
	grip = minf(grip + GRIP_WALL_JUMP_RESTORE, GRIP_MAX)
	_squash(0.38, 1.78)
	_hit(0.22)
	_zpunch(0.05)
	jump_dust.visible = true
	jump_dust.play("default")
	character.play(skin + "_jump")
	character.flip_h = wd < 0.0

# ═══════════════════════════════════════════════════════════
#  SLIDE
# ═══════════════════════════════════════════════════════════
func _slide() -> void:
	is_sliding  = true
	slide_timer = SLIDE_DUR
	slide_dir   = signf(velocity.x)
	velocity.x  = slide_dir * SLIDE_SPEED * momentum
	_squash(1.62, 0.34)
	_hit(0.12)

# ═══════════════════════════════════════════════════════════
#  GROUND POUND
# ═══════════════════════════════════════════════════════════
func _pound_start() -> void:
	is_pounding  = true
	is_jumping   = false
	velocity     = Vector2(0.0, POUND_SPD)
	_squash(1.68, 0.3)
	_hit(0.12)
	slowmo_timer = 0.22

func _pound_end() -> void:
	is_pounding       = false
	slowmo_timer      = 0.0
	Engine.time_scale = 1.0
	_squash(0.38, 1.2)
	_hit(1.0)
	_zpunch(0.13)
	land_freeze = 0.07
	jump_dust.visible = true
	jump_dust.play("default")
	velocity.y  = POUND_BOUNCE

# ═══════════════════════════════════════════════════════════
#  DASH QUEUE / FIRE
# ═══════════════════════════════════════════════════════════
func _queue_dash(h: float) -> void:
	can_dash          = false
	is_dash_frozen    = true
	dash_freeze_timer = DASH_FREEZE
	var v: float = Input.get_axis("ui_up", "ui_down")
	dash_dir = Vector2(h, v)
	if dash_dir == Vector2.ZERO:
		dash_dir = Vector2(-1.0 if character.flip_h else 1.0, 0.0)
	else:
		dash_dir = dash_dir.normalized()
	velocity    = Vector2.ZERO
	parry_timer = PARRY_WINDOW

func _fire_dash() -> void:
	is_dashing = true
	dash_timer = DASH_DUR
	velocity   = Vector2.ZERO
	_squash(1.7, 0.28)
	_hit(0.18)

# ═══════════════════════════════════════════════════════════
#  LAND
# ═══════════════════════════════════════════════════════════
func _land() -> void:
	var spd: float = absf(velocity.y)
	bunny_timer = BUNNY_WINDOW

	if spd < 55.0:
		return

	var intensity: float = clampf(spd / 780.0, 0.07, 1.0)
	_squash(0.44 - intensity * 0.1, 1.6 + intensity * 0.3)
	_hit(intensity * 0.48)

	cam_impact_vel += intensity * IMPACT_DIP_MAX * 2.5

	if spd > 420.0:
		land_freeze = FREEZE_HEAVY
		_zpunch(0.07)

	if spd > 150.0:
		jump_dust.visible = true
		jump_dust.play("default")

	if absf(velocity.x) > SPEED * 0.75:
		_slide()

# ═══════════════════════════════════════════════════════════
#  ATTACK
# ═══════════════════════════════════════════════════════════
func _attack() -> void:
	if is_attacking or not can_attack:
		return
	is_attacking = true
	can_attack   = false

	var heat_r:  float = heat / 100.0
	var spd_mul: float = 1.0 + heat_r * HEAT_ATK_BONUS
	var fwd:     float = 1.0 if not character.flip_h else -1.0

	# ── CHARGED FINISHER ──────────────────────────────────
	if charge_ready:
		charge_dmg_ready = true
		charge_ready     = false
		_squash(0.28, 1.95)
		velocity.x += fwd * 280.0
		velocity.y  = -130.0
		_hit(0.32)
		_zpunch(0.11)

		await get_tree().create_timer(0.06 / spd_mul, true).timeout
		collision_shape.disabled = false
		await get_tree().create_timer(0.2 / spd_mul, true).timeout
		collision_shape.disabled = true
		await get_tree().create_timer(0.3 / spd_mul, true).timeout
		charge_dmg_ready = false
		is_attacking     = false
		can_attack       = true
		return

	# ── DIRECTIONAL AIR ATTACKS ───────────────────────────
	if not is_on_floor():
		var vdir: float = Input.get_axis("ui_up", "ui_down")
		if vdir > 0.5:
			velocity.y  = 350.0
			velocity.x *= 0.35
			_squash(0.52, 1.7)
		elif vdir < -0.5:
			velocity.y = -230.0
			_squash(0.48, 1.72)

	# ── COMBO ─────────────────────────────────────────────
	combo       = (combo % COMBO_MAX) + 1
	combo_timer = COMBO_WINDOW

	match combo:
		1:
			_squash(0.44, 1.62)
			velocity.x += fwd * 90.0
		2:
			_squash(1.52, 0.46)
			velocity.x += fwd * 70.0
		3:
			_squash(0.34, 1.82)
			velocity.x += fwd * 170.0
			_hit(0.22)
			_zpunch(0.08)
			slowmo_timer = 0.06

	var dur_a: float = (0.048 if combo < 3 else 0.075) / spd_mul
	var dur_b: float = (0.12  if combo < 3 else 0.26)  / spd_mul

	await get_tree().create_timer(dur_a, true).timeout
	collision_shape.disabled = false
	await get_tree().create_timer(0.09 / spd_mul, true).timeout
	collision_shape.disabled = true
	await get_tree().create_timer(dur_b, true).timeout
	is_attacking = false
	can_attack   = true

# ═══════════════════════════════════════════════════════════
#  SIGNALS
# ═══════════════════════════════════════════════════════════
func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemy"):
		return

	Engine.time_scale = 0.03
	await get_tree().create_timer(0.032, true).timeout
	Engine.time_scale = 1.0

	var dmg: int = ability
	if charge_dmg_ready:
		dmg = int(float(ability) * 3.2)
	elif combo == 3:
		dmg = int(float(ability) * 2.5)

	heat = minf(heat + HEAT_PER_HIT, 100.0)
	_hit(0.28)
	_zpunch(0.09)
	body.take_damage(dmg, global_position)

	# FIX 3: sync experience back to GameManager so it isn't lost on scene change
	experience += dmg
	GameManager.experience = experience

	# stomp bounce
	if global_position.y < body.global_position.y - 8.0:
		velocity.y = -430.0
		_squash(1.38, 0.56)
		jumps_left = MAX_JUMPS

# FIX 4: removed unreachable `body == self` check — CharacterBody2D cannot enter its own child Area2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("death"):
		die()

func _on_jump_dust_animation_finished() -> void:
	jump_dust.visible = false

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemy") or iframe_timer > 0.0:
		return

	# perfect parry
	if parry_timer > 0.0:
		parry_timer  = 0.0
		slowmo_timer = 0.42
		can_dash     = true
		jumps_left   = MAX_JUMPS
		velocity.y   = -300.0
		_squash(1.45, 0.52)
		_hit(0.14)
		_zpunch(0.09)
		return

	GameManager.take_damage(5)
	iframe_timer = IFRAME_TIME
	var d: Vector2 = (global_position - body.global_position).normalized()
	_hit_dir(0.58, -d)
	_zpunch(0.11)
	damaged     = true
	knockback   = d * 320.0
	knockback.y = clamp(knockback.y, -170.0, 260.0)

# ═══════════════════════════════════════════════════════════
#  DEATH
# ═══════════════════════════════════════════════════════════
func die() -> void:
	if is_dead:
		return
	is_dead = true
	get_tree().reload_current_scene()
