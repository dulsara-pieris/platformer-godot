extends CharacterBody2D

@onready var character: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_dust: AnimatedSprite2D = $JumpDust
@onready var camera: Camera2D = $Camera
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape: CollisionShape2D = $AttackArea/CollisionShape2D

var ability = GameManager.ability
var shake_strength = 0.0
const SPEED = 230.0
const JUMP_VELOCITY = -400.0
const gravity = 1.3

# coyote
var coyote_timer = 0.15
const coyote_time = 0.15

# jump buffer
var jump_buffer_time = 0.15
var jump_buffer_timer = 0.0

# movement accel
var run = 1
# attack system
var is_attacking = false
var can_attack = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	GameManager.health = 300
	
	# IMPORTANT: disable hitbox at start
	collision_shape.disabled = true
	GameManager.have_weapon = false

func _physics_process(delta: float) -> void:
	ability = GameManager.ability
	# =========================
	# ATTACK INPUT (separate!)
	# =========================
	if Input.is_action_just_pressed("attack"):
		if GameManager.have_weapon == true:
			attack()

	# =========================
	# MOVEMENT
	# =========================
	var direction := Input.get_axis("left", "right")

	if direction:
		run += delta
		character.play("run")
		velocity.x = direction * SPEED * run / 1.3
		
		# flip sprite + attack direction
		if direction < 0:
			character.flip_h = true
			attack_area.scale.x = -1
		else:
			character.flip_h = false
			attack_area.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_attacking:
			character.play("idle")
		run = 1

	# =========================
	# JUMP BUFFER
	# =========================
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# =========================
	# JUMP
	# =========================
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0
		
		shake_strength = 10
		character.play("jump")
		
		jump_dust.visible = true
		jump_dust.play("default")

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
	# GRAVITY + COYOTE
	# =========================
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		velocity += get_gravity() * delta * gravity
		coyote_timer -= delta

	# limit accel
	if run > 1.8:
		run = 1.8

	move_and_slide()


# =========================
# ⚔️ ATTACK FUNCTION
# =========================
func attack():
	if is_attacking or not can_attack:
		return

	is_attacking = true
	can_attack = false

	# play animation
	#character.play("attack")

	# small delay (wind-up)
	await get_tree().create_timer(0.05).timeout

	# enable hitbox
	collision_shape.disabled = false

	# active frames
	await get_tree().create_timer(0.1).timeout

	# disable hitbox
	collision_shape.disabled = true

	# slight cooldown
	await get_tree().create_timer(0.2).timeout

	is_attacking = false
	can_attack = true


# =========================
# 💥 HIT DETECTION
# =========================
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		shake_strength = 8
		body.take_damage(ability, global_position)


# =========================
# OTHER STUFF (unchanged)
# =========================
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().reload_current_scene()

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _on_jump_dust_animation_finished() -> void:
	jump_dust.visible = false

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		GameManager.take_damage(5)
		shake_strength = 15
