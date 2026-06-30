extends Node2D

const SPEED = 100
@onready var camera: Camera2D = get_parent().get_node("Camera")
var screen_width: float

# Called once upon instantiation
func _ready() -> void:
	screen_width = get_viewport_rect().size.x / camera.zoom.x

# Called every frame.
func _process(delta: float) -> void:
	position.x += SPEED * delta
	
	if position.x > screen_width/2:
		position.x = -screen_width/2

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("COLLISION")
