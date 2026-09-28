extends Camera2D

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var shake_horizontal: bool = false

func shake(intensity: float, duration: float, horizonal: bool = false) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
	shake_horizontal = horizonal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		var t = shake_timer / shake_duration
		var offset_y = randf_range(-shake_intensity, shake_intensity) * t
		var offset_x = randf_range(-shake_intensity, shake_intensity) * t if shake_horizontal else 0.0
		offset = Vector2(offset_x, offset_y)
	else:
		offset = Vector2.ZERO
