extends Node

var health = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(amount: int) -> void:
	health -= amount
	print("HIT! Health:", health)

	if health <= 0:
		die()
	

func die() -> void:
	print("Player died")
	get_tree().reload_current_scene()
