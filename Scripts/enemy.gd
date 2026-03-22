extends CharacterBody2D

@export var speed: float = 120.0
@export var gravity: float = 900.0

var player: Node2D = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea

func _ready() -> void:
		scale = Vector2(1, 1)
		rotation = 0
		detect_area.body_entered.connect(_on_body_entered)
		detect_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
		if not is_on_floor():
				velocity.y += gravity * delta
		else:
				velocity.y = 0

		if player != null:
				var dx := player.global_position.x - global_position.x
				velocity.x = speed if dx > 0 else -speed
				anim.flip_h = velocity.x > 0
				anim.play("run")
		else:
				velocity.x = 0
				anim.play("idle")

		move_and_slide()

func _on_body_entered(body: Node) -> void:
		if body.is_in_group("player"):
				player = body as Node2D

func _on_body_exited(body: Node) -> void:
		if body == player:
				player = null
