extends CharacterBody2D

@onready var character: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_dust: AnimatedSprite2D = $JumpDust
@onready var camera: Camera2D = $Camera
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var target_scale: Vector2 = Vector2(0.5, 0.5)
var scale_speed: float = 20.0

var ability = GameManager.ability
var shake_strength = 0.0

const SPEED = 230.0

@export var jump_velocity := -350.0
@export var jump_hold_force := -1800.0
@export var jump_hold_time := 0.2

var jump_hold_timer := 0.0
var is_jumping := false

var gravity := 1.3

var experience = GameManager.experience
var skin = GameManager.skin

# coyote
const coyote_time := 0.15
var coyote_timer := 0.0

var count = 0

# jump buffer
const jump_buffer_time := 0.15
var jump_buffer_timer := 0.0

# movement accel
var run := 1.0

# attack system
var is_attacking := false
var can_attack := true

# knockback
var knockback: Vector2 = Vector2.ZERO
var skin_scale := 0.5
var damaged := false

# climbing
var is_climbing := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	GameManager.health = 300
	GameManager.experience = experience

	collision_shape.disabled = true
	GameManager.have_weapon = false


func _physics_process(delta: float) -> void:

	GameManager.skin_scale = skin_scale
	skin = GameManager.skin
	ability = GameManager.ability

	# =========================
	# INPUT
	# =========================
	var direction := Input.get_axis("left", "right")

	# =========================
	# ATTACK
	# =========================
	if Input.is_action_just_pressed("attack"):
		attack()

	# =========================
	# JUMP BUFFER
	# =========================
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# =========================
	# COYOTE TIME
	# =========================
	if is_on_floor() or is_climbing:
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# =========================
	# CLIMB CHECK (FIXED)
	# =========================
	is_climbing = is_on_wall_only() and GameManager.can_climb

	if is_climbing:
		velocity.y = 0
		gravity = 0
	else:
		gravity = 1.3

	# =========================
	# JUMP
	# =========================
	if jump_buffer_timer > 0 and (coyote_timer > 0 or is_climbing or (is_on_wall()) and GameManager.can_climb):
		velocity.y = jump_velocity

		is_jumping = true
		jump_hold_timer = jump_hold_time

		coyote_timer = 0
		jump_buffer_timer = 0

		character.play(skin + "_jump")

		shake_strength = 10
		jump_dust.visible = true
		jump_dust.play("default")

	# =========================
	# HOLD JUMP
	# =========================
	if is_jumping and Input.is_action_pressed("jump"):
		if jump_hold_timer > 0:
			velocity.y += jump_hold_force * delta
			jump_hold_timer -= delta
		else:
			is_jumping = false

	if Input.is_action_just_released("jump"):
		is_jumping = false

	if velocity.y > 0:
		is_jumping = false

	# =========================
	# GRAVITY
	# =========================
	if not is_on_floor() and not is_climbing:
		velocity += get_gravity() * delta * gravity

	# =========================
	# MOVEMENT
	# =========================
	if is_on_floor() or is_on_wall_only():

		if direction != 0:
			run += delta
			velocity.x = direction * SPEED * run / 1.3

			if not is_attacking:
				character.play(skin + "_run")

			character.flip_h = direction < 0
			attack_area.scale.x = -1 if direction < 0 else 1

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

			if not is_attacking:
				character.play(skin + "_idle")

			run = 1.0

	else:
		# air control
		velocity.x = direction * SPEED

		if not is_climbing:
			character.play(skin + "_jump")

	# clamp run accel
	run = min(run, 2.0)

	# =========================
	# CAMERA SHAKE
	# =========================
	if shake_strength > 0:
		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength *= 0.9
	else:
		camera.offset = Vector2.ZERO

	# =========================
	# SQUASH / SCALE
	# =========================
	character.scale = character.scale.lerp(target_scale, scale_speed * delta)

	# =========================
	# KNOCKBACK
	# =========================
	if knockback.length() > 0:
		velocity += knockback
		knockback = knockback.move_toward(Vector2.ZERO, 800 * delta)

	# =========================
	# STATES
	# =========================
	if GameManager.health <= 0:
		character.play(skin + "_dead")

	elif damaged:
		character.play(skin + "_hit")
		damaged = false

	if is_on_wall_only():
		character.play(skin + "_grab")

	if GameManager.animation == "power":
		count += 1
		if count == 1:
			character.play(skin + "_power")
			GameManager.animation = null
		print(count)
	move_and_slide()


# =========================
# ATTACK
# =========================
func attack():
	if is_attacking or not can_attack:
		return

	is_attacking = true
	can_attack = false

	await get_tree().create_timer(0.05).timeout
	collision_shape.disabled = false

	await get_tree().create_timer(0.1).timeout
	collision_shape.disabled = true

	await get_tree().create_timer(0.2).timeout

	is_attacking = false
	can_attack = true


# =========================
# HIT ENEMY
# =========================
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		shake_strength = 8
		body.take_damage(ability, global_position)
		experience += ability
		print(experience)

# =========================
# RESET SCENE
# =========================
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().reload_current_scene()


func _enter_tree():
	set_multiplayer_authority(name.to_int())


# =========================
# JUMP DUST FIX
# =========================
func _on_jump_dust_animation_finished() -> void:
	jump_dust.visible = false


# =========================
# DAMAGE
# =========================
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		GameManager.take_damage(5)

		shake_strength = 15
		damaged = true

		var direction = (global_position - body.global_position).normalized()
		knockback = direction * 200
		knockback.y = clamp(knockback.y, -100, 200)
