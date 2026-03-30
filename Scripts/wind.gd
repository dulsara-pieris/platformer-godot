extends Node2D

@export var sprite_scene: PackedScene
@export var spawn_area: Vector2 = Vector2(800, 600)
@export var spawn_interval: float = 1.0  # time between each particle

var timer := 0.0

func _process(delta):
	timer -= delta
	if timer <= 0:
		spawn_particle()
		timer = spawn_interval

func spawn_particle():
	if sprite_scene == null:
		push_error("sprite_scene not assigned!")
		return

	var p = sprite_scene.instantiate()
	add_child(p)

	p.position = Vector2(
		randf_range(0, spawn_area.x),
		randf_range(0, spawn_area.y)
	)
