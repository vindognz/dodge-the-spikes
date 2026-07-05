extends Node2D

var half_width: float = 0.0
var full_height: float = 0.0
var radius: float = 2.0
var glow_color: Color

var pulse_speed: float = 0.0
var pulse_offset: float = 0.0

var target_position: Vector2 = Vector2.ZERO
var zip_timer: float = 0.0
var zip_interval: float = 0.0

func _ready() -> void:
	glow_color = Color(
		randf_range(0.6, 1.0),
		randf_range(0.6, 1.0),
		randf_range(0.2, 0.5),
		1.0
	)
	radius = randf_range(1.5, 3.0)
	pulse_speed = randf_range(0.5, 1.5)
	pulse_offset = randf_range(0.0, TAU)
	target_position = position
	_new_interval()

func _new_interval() -> void:
	zip_interval = randf_range(2.0, 5.0)
	zip_timer = 0.0
	var new_target = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	new_target.x = clamp(new_target.x, -half_width, half_width)
	new_target.y = clamp(new_target.y, -full_height, 0)
	target_position = new_target

func _process(delta: float) -> void:
	if not Global.running: return
	
	zip_timer += delta
	if zip_timer >= zip_interval:
		_new_interval()
	
	position = position.lerp(target_position, delta * 2.0)
	
	if half_width > 0 and full_height > 0:
		var pre_wrap = position
		position.x = fmod(position.x + half_width, half_width * 2) - half_width
		position.y = -fmod(-position.y, full_height)
		if position.distance_to(pre_wrap) > 10.0:
			target_position = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	
	queue_redraw()

func _draw() -> void:
	var alpha = (sin(Time.get_ticks_msec() * 0.001 * pulse_speed + pulse_offset) + 1.0) / 2.0
	alpha = lerp(0.1, 1.0, alpha)
	draw_circle(Vector2.ZERO, radius, Color(glow_color.r, glow_color.g, glow_color.b, alpha))
	draw_circle(Vector2.ZERO, radius * 2.5, Color(glow_color.r, glow_color.g, glow_color.b, alpha * 0.15))
