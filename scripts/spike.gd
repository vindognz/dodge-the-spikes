extends Node2D

const SPEED = 100
@onready var collision_main: CollisionPolygon2D = $SpikeCol/CollisionPolygon2D
@onready var collision_secondary: CollisionPolygon2D = $SpikeCol/CollisionPolygon2D2
@export var moves: bool = true

var scored: bool = false
var direction: int = 1
var half_width: float = 0.0

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
	var tip_color = Color(1.0, 0.25, 0.35)      # bright red
	var base_color = Color(0.36, 0.05, 0.1)     # dark near-black red

	# main spike — tip is index 2 (Vector2(-3, -8)), base is 0 and 1
	draw_polygon(main_points, PackedColorArray([
		base_color,
		base_color,
		tip_color
	]))

	# secondary spike — tip is index 2 (Vector2(4, -3)), base is 0 and 1
	draw_polygon(secondary_points, PackedColorArray([
		base_color,
		base_color,
		tip_color
	]))

func _ready() -> void:
	collision_main.polygon = main_points
	collision_secondary.polygon = secondary_points

func _process(delta: float) -> void:
	if not Global.running: return
	if not moves: return
	
	var current_speed = (SPEED + Global.score * 2) * direction
	position.x += current_speed * delta
	
	if not scored:
		var player = get_parent().get_node("Player")
		if direction == 1 and position.x > player.position.x:
			scored = true
			Global.score += 1
		elif direction == -1 and position.x < player.position.x:
			scored = true
			Global.score += 1
	
	# despawn off the far edge
	if half_width > 0:
		if position.x > half_width + 20 or position.x < -half_width - 20:
			queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		Global.running = false
