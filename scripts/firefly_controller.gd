extends Node2D

@export var firefly_scene: PackedScene
@export var firefly_count: int = 20

@onready var camera: Camera2D = get_parent().get_node("Camera")

func _ready() -> void:
	var half_width = get_viewport_rect().size.x / camera.zoom.x / 2
	var full_height = get_viewport_rect().size.y / camera.zoom.y
	
	for i in firefly_count:
		var firefly = firefly_scene.instantiate()
		firefly.half_width = half_width
		firefly.full_height = full_height
		firefly.position = Vector2(
			randf_range(-half_width, half_width),
			randf_range(-full_height, 0)
		)
		add_child(firefly)
