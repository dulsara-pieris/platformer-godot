extends CharacterBody2D

@export var speed: float = 130.0
@export var gravity: float = 900.0
@export var jump_force: float = -350.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea

var player: Node2D = null
var facing_right: bool = true
var health: int = 50

enum State { IDLE, CHASE, HURT, PAUSE_AFTER_ATTACK }
var state: State = State.IDLE

var knockback: Vector2 = Vector2.ZERO

# -------------------------
# Pause after attacking
# -------------------------
var pause_timer: float = 0.0
var pause_count: int = 0
var max_pauses: int = 3
var pause_interval: float = 2.0  # seconds per pause

func _ready() -> void:
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	# Handle pause after attack
	if state == State.PAUSE_AFTER_ATTACK:
		pause_timer -= delta
		if pause_timer <= 0:
			pause_count += 1
			if pause_count < max_pauses:
				pause_timer = pause_interval  # next pause
			else:
				state = State.IDLE  # done pausing

	match state:
		State.IDLE:
			velocity.x = 0
			if player:
				state = State.CHASE

		State.CHASE:
			if not is_instance_valid(player):
				state = State.IDLE
			else:
				chase_player()

		State.HURT:
			velocity = knockback
			knockback = knockback.move_toward(Vector2.ZERO, 800 * delta)
			if knockback.length() < 10:
				# Start pause after attack
				pause_count = 0
				pause_timer = pause_interval
				state = State.PAUSE_AFTER_ATTACK

	move_and_slide()
	update_animation()

# -------------------------
# Movement
# -------------------------
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func chase_player() -> void:
	var dx := player.global_position.x - global_position.x
	if abs(dx) < 20:
		velocity.x = 0
		return
	if dx > 0:
		velocity.x = speed
		facing_right = true
	else:
		velocity.x = -speed
		facing_right = false

# -------------------------
# Animation
# -------------------------
func update_animation() -> void:
	anim.flip_h = not facing_right
	match state:
		State.HURT:
			pass

# -------------------------
# Detection
# -------------------------
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body as Node2D

func _on_body_exited(body: Node) -> void:
	if body == player:
		player = null

# -------------------------
# Damage system
# -------------------------
func take_damage(amount: int, from_position: Vector2) -> void:
	health -= amount
	print("Enemy took damage:", amount, "Remaining:", health)

	var direction = (global_position - from_position).normalized()
	knockback = direction * 250
	knockback.y = -200
	state = State.HURT

	if health <= 0:
		die()

func die() -> void:
	queue_free()
