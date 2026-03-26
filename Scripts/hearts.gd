extends Panel

@onready var heart: AnimatedSprite2D = $HBoxContainer/Heart
@onready var heart_2: AnimatedSprite2D = $HBoxContainer/Heart2
@onready var heart_3: AnimatedSprite2D = $HBoxContainer/Heart3

var last_health := -1
var health

func _ready() -> void:
	last_health = GameManager.health
	
	if last_health > 200:
		heart.play("default")
		heart_2.play("default")
		heart_3.play("default")
	elif last_health > 100:
		heart.play("default")
		heart_2.play("default")
		heart_3.play("no_heart")
	elif last_health > 0:
		heart.play("default")
		heart_2.play("no_heart")
		heart_3.play("no_heart")
	else:
		heart.play("no_heart")
		heart_2.play("no_heart")
		heart_3.play("no_heart")


func _process(delta: float) -> void:
	health = GameManager.health
	if health == last_health:
		return
	
	# DAMAGE detected
	if health < last_health:
		
		# Heart 3 breaks
		if health <= 200 and last_health > 200:
			heart_3.play("pop")
			await heart_3.animation_finished
			heart_3.play("no_heart")
		
		# Heart 2 breaks
		if health <= 100 and last_health > 100:
			heart_2.play("pop")
			await heart_2.animation_finished
			heart_2.play("no_heart")
		
		# Heart 1 breaks
		if health <= 0 and last_health > 0:
			heart.play("pop")
			await heart.animation_finished
			heart.play("no_heart")
	
	else:
		# Healing / reset
		if health > 200:
			heart.play("default")
			heart_2.play("default")
			heart_3.play("default")
		elif health > 100:
			heart.play("default")
			heart_2.play("default")
			heart_3.play("no_heart")
		elif health > 0:
			heart.play("default")
			heart_2.play("no_heart")
			heart_3.play("no_heart")
		else:
			heart.play("no_heart")
			heart_2.play("no_heart")
			heart_3.play("no_heart")
	
	last_health = health
