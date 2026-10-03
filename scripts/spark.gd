extends Node2D

var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 0.5
var timer: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	velocity *= 0.95 # drag / air resistance idk bro
	position += velocity * delta / 1.5
	
	queue_redraw()
	
	if timer >= lifetime:
		queue_free()

func _draw() -> void:
	var t = timer / lifetime
	var alpha = 1.0 - t
	draw_circle(Vector2.ZERO, 1.0, Color(1.0, 0.2, 0.2, alpha))
