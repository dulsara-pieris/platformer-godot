extends CharacterBody2D
@onready var target: CharacterBody2D = $Player

var speed := 150
var direction := -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.x = direction*speed
	velocity.y += 20
	move_and_slide()
