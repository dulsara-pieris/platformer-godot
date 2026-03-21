extends Area2D
@onready var enemy: CharacterBody2D = $".."


func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		var y_delta = position.y - body.position.y
		print(y_delta)
		if(y_delta > -100):
			enemy.queue_free()
		else:
			print("dead")
