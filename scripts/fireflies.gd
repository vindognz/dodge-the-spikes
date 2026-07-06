extends ColorRect

var shader_time: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Global.running: return
	
	shader_time += delta
	material.set_shader_parameter("shader_time", shader_time)
