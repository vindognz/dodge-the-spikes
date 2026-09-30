extends ColorRect

var shader_time: float = 0.0

func _ready() -> void:
	resized.connect(_update_aspect)
	_update_aspect()

func _update_aspect() -> void:
	if size.y > 0.0:
		material.set_shader_parameter("aspect", size.x / size.y)

func _process(delta: float) -> void:
	if not Global.running: return
	
	shader_time += delta
	material.set_shader_parameter("shader_time", shader_time)
