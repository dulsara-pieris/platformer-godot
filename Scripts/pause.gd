extends Node

@onready var pause: Panel = %PausePanel

func _process(delta: float) -> void:
	var esc_pressed = Input.is_action_just_pressed("Pause")
	if esc_pressed:
		get_tree().paused = true
		pause.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_main_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
