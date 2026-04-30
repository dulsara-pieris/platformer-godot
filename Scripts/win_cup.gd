extends Area2D

@onready var win: Panel = $"../../UI/won/won"

func _ready():
	win.hide()
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		win.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
