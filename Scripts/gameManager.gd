extends Node

var health = 300
var have_weapon = false
var inventory
var ability = 10
func _ready():
	inventory = InventoryManager.new()


func take_damage(amount: int) -> void:
	health -= amount
	print("HIT! Health:", health)

	if health <= 0:
		die()

func die() -> void:
	print("Player died")
	get_tree().reload_current_scene()
