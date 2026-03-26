extends Node

@onready var pause: Panel = %PausePanel

var screen_size = DisplayServer.screen_get_size()
var window_size = DisplayServer.window_get_size()
var position = (screen_size - window_size) / 2

func _process(delta: float) -> void:
	var esc_pressed = Input.is_action_just_pressed("Pause")
	if esc_pressed:
		get_tree().paused = true
		pause.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 648))
		DisplayServer.window_set_position(position)


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_main_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
