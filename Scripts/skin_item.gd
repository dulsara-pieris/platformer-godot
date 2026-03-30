extends Area2D

@export var float_height: float = 10.0
@export var float_speed: float = 2.0

var start_y: float
var time_passed: float = 0.0
var skin_scale = GameManager.skin_scale

func _ready():
	start_y = position.y

func _process(delta):
	skin_scale = GameManager.skin_scale
	GameManager.skin_scale = skin_scale
	time_passed += delta
	position.y = start_y + sin(time_passed * float_speed) * float_height

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.skin = "boy"
		GameManager.skin_scale
		queue_free()
