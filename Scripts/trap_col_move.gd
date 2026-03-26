extends Area2D

@export var min_angle := 135
@export var max_angle := 225
@export var speed := 60

var direction := 1

func _process(delta):
	rotation_degrees += speed * direction * delta
	
	if rotation_degrees >= max_angle:
		rotation_degrees = max_angle
		direction = -1
	
	elif rotation_degrees <= min_angle:
		rotation_degrees = min_angle
		direction = 1
