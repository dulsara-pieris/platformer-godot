extends CanvasModulate


func _on_main_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/help.tscn")


func _on_main_pressed_backed() -> void:
	get_tree().change_scene_to_file("res://UI/ui.tscn")
