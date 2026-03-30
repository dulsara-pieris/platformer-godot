extends AnimatedSprite2D

@export var lifetime: float = 1.5       # total visible time
@export var fade_duration: float = 0.5  # last part fades out

var age := 0.0

func _ready():
	play("default")
	frame = randi() % sprite_frames.get_frame_count("default")
	modulate.a = 1.0  # fully visible

func _process(delta):
	age += delta

	# Fade out near end
	if age > lifetime - fade_duration:
		var t = (age - (lifetime - fade_duration)) / fade_duration
		modulate.a = lerp(1.0, 0.0, t)

	# Free after lifetime
	if age >= lifetime:
		queue_free()
