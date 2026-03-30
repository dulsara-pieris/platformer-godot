extends Area2D
#
#@onready var text: CanvasModulate = $"../UI/CanvasModulate"
#@onready var label: Label = $"../UI/CanvasModulate/Panel2/Label"
#@onready var sword: Sprite2D = $"../UI/CanvasModulate/Sword"
#
#var got_weapon = false
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
#
#
#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Player") and !got_weapon:
		#text.show()
		#if GameManager.health > 250:
			#label.text = "Amazing still got " + str(GameManager.health)
			#label.modulate.a = 0.0
#
			#var tween = create_tween()
			#tween.tween_property(label, "modulate:a", 1.0, 0.5)
#
			#await get_tree().create_timer(2.0).timeout
#
			#GameManager.ability *= 1.5
			#label.text = "What about more attack bounce"
			#label.modulate.a = 0.0
#
			#tween = create_tween()
			#tween.tween_property(label, "modulate:a", 1.0, 0.5)
#
			#await get_tree().create_timer(2.0).timeout
#
			#label.text = "of 1.5X that means 15"
			#label.modulate.a = 0.0
#
			#tween = create_tween()
			#tween.tween_property(label, "modulate:a", 1.0, 0.5)
#
			#await get_tree().create_timer(2.0).timeout
		#GameManager.have_weapon = true
		#got_weapon = true
#
#
		## Fade in
		#label.text = "Unlocked attacking"
		#label.modulate.a = 0.0
#
		#var tween = create_tween()
		#tween.tween_property(label, "modulate:a", 1.0, 0.5)
#
		#await get_tree().create_timer(2.0).timeout
#
		## Change text (quick fade out → in)
		#var tween_out = create_tween()
		#tween_out.tween_property(label, "modulate:a", 0.0, 0.3)
		#await tween_out.finished
#
		#label.text = "Press 'E' to attack"
#
		#var tween_in = create_tween()
		#tween_in.tween_property(label, "modulate:a", 1.0, 0.5)
#
		#await get_tree().create_timer(2.0).timeout
#
		## Final message
		#var tween_out2 = create_tween()
		#tween_out2.tween_property(label, "modulate:a", 0.0, 0.3)
		#await tween_out2.finished
#
		#label.text = "Congratulations!"
		#sword.show()
		#var tween_in2 = create_tween()
		#tween_in2.tween_property(label, "modulate:a", 1.0, 0.5)
#
		#await get_tree().create_timer(1.5).timeout
#
		## Fade out and hide
		#var tween_out3 = create_tween()
		#tween_out3.tween_property(label, "modulate:a", 0.0, 0.5)
		#await tween_out3.finished
#
		#text.hide()
