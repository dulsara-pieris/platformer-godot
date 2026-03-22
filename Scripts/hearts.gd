extends Panel

@onready var heart: Sprite2D = $HBoxContainer/Heart
@onready var heart_2: Sprite2D = $HBoxContainer/Heart2
@onready var heart_3: Sprite2D = $HBoxContainer/Heart3

func _process(delta: float) -> void:
	var health = GameManager.health
	if health>200:
		heart.show()
		heart_2.show()
		heart_3.show()
	elif health > 100:
		heart.show()
		heart_2.show()
		heart_3.hide()
	elif health > 0:
		heart.show()
		heart_2.hide()
		heart_3.hide()
	else:
		heart.hide()
		heart_2.hide()
		heart_3.hide()
