extends Node2D

const SPEED = 100;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var camera = get_parent().get_node("Camera")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_width = get_viewport_rect().size.x / camera.zoom.x
	position.x += SPEED * delta
	
	if position.x > screen_width/2:
		position.x = -screen_width/2

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("COLLISION")
