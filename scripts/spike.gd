extends Node2D

const SPEED = 100
@onready var camera: Camera2D = get_parent().get_node("Camera")
@onready var collision_main: CollisionPolygon2D = $Area2D/CollisionPolygon2D
@onready var collision_secondary: CollisionPolygon2D = $Area2D/CollisionPolygon2D2

var screen_width: float

var main_points = PackedVector2Array([
	Vector2(-8, 8),
	Vector2(2, 8),
	Vector2(-3, -8)
])

var secondary_points = PackedVector2Array([
	Vector2(0, 8),
	Vector2(8, 8),
	Vector2(4, -3)
])

func _draw():
	var color = Color(0.9, 0.1, 0.2)
	draw_polygon(main_points, PackedColorArray([color]))
	draw_polygon(secondary_points, PackedColorArray([color]))
	
# Called once upon instantiation
func _ready() -> void:
	screen_width = get_viewport_rect().size.x / camera.zoom.x
	collision_main.polygon = main_points
	collision_secondary.polygon = secondary_points

# Called every frame.
func _process(delta: float) -> void:
	position.x += SPEED * delta
	if position.x > screen_width/2:
		position.x = -screen_width/2

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("COLLISION")
