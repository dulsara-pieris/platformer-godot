extends Node

var health = 300
var have_weapon = true
var inventory
var ability = 10
var experience = 0
var skin = "girl"
var skin_scale
var can_climb = false
var animation

func _ready():
	inventory = InventoryManager.new()
	can_climb = false


func take_damage(amount: int) -> void:
	health -= amount
	print("HIT! Health:", health)

	if health <= 0:
		die()

func die() -> void:
	print("Player died")
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()
