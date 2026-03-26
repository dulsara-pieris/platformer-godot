extends CharacterBody2D

@export var speed: float = 120.0
@export var gravity: float = 900.0
@export var jump_force: float = -350.0

@onready var enemy: AnimatedSprite2D = $AnimatedSprite2D


var player: Node2D = null
var facing_right: bool = true
var is_hurt = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea

func _ready() -> void:
		detect_area.body_entered.connect(_on_body_entered)
		detect_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
		apply_gravity(delta)

		if is_instance_valid(player):
				chase_player()
		else:
				velocity.x = 0

		auto_jump()

		move_and_slide()
		update_animation()

func apply_gravity(delta: float) -> void:
		if not is_on_floor():
				velocity.y += gravity * delta
		else:
				velocity.y = 0

func chase_player() -> void:
		var dx := player.global_position.x - global_position.x

		if dx > 0:
				velocity.x = speed
				facing_right = true
		else:
				velocity.x = -speed
				facing_right = false

func auto_jump() -> void:
		if is_on_floor() and abs(velocity.x) > 0:
				if randi() % 120 == 0:
						velocity.y = jump_force

func update_animation() -> void:
		anim.flip_h = not facing_right

		if is_hurt:
			enemy.play("hit")
			velocity.y = -400
			velocity.x = 200
		elif velocity.x != 0:
				anim.play("run")
		else:
				anim.play("idle")

func _on_body_entered(body: Node) -> void:
		if body.name == "Player":
				player = body as Node2D

func _on_body_exited(body: Node) -> void:
		if body == player:
				player = null

var health = 50

func take_damage(amount: int, from_position: Vector2) -> void:
	health -= amount
	print("Enemy took damage:", amount, "Remaining:", health)

	# Optional: knockback
	var direction = (global_position - from_position).normalized()
	velocity = direction * 200
	velocity.y = -150

	if has_node("AnimatedSprite2D"):
		is_hurt = true
		await get_tree().create_timer(0.2).timeout
		is_hurt = false
	# Death
	if health <= 0:
		queue_free()
