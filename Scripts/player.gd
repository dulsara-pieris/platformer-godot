extends CharacterBody2D

@onready var character: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_dust: AnimatedSprite2D = $JumpDust
@onready var camera: Camera2D = $Camera

var shake_strength = 0.0

const SPEED = 230.0
const JUMP_VELOCITY = -400.0
const gravity = 1.3

#coyote stuff
var coyote_timer = 0.15
const coyote_time = 0.15

var run = 1 #for accelaration
func _physics_process(delta: float) -> void:
	#moving stuff
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		run += delta
		character.play("run")
		velocity.x = direction * SPEED * run / 1.3
		if direction < 0:
			character.flip_h = true
		else:
			character.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		character.play("idle")
		run = 1

	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0
		character.play("jump")
		jump_dust.visible = true
		jump_dust.play("default")
		shake_strength = 3

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		velocity += get_gravity() * delta * gravity
		coyote_timer -= delta

	#max acceleration
	if run > 1.8:
		run = 1.8
	
	if shake_strength > 0:
		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength *= 0.9
	else:
		camera.offset = Vector2.ZERO
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://Scenes/game.tscn")
 
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	


func _on_jump_dust_animation_finished() -> void:
	jump_dust.visible = false
