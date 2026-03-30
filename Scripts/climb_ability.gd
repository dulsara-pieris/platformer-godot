extends Area2D

@export var float_height: float = 10.0
@export var float_speed: float = 2.0

var start_y: float
var time_passed: float = 0.0

func _ready():
	start_y = position.y

func _process(delta):
	time_passed += delta
	position.y = start_y + sin(time_passed * float_speed) * float_height

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameManager.can_climb = true
		print(GameManager.can_climb)
		queue_free()
