extends Control

const PX: float = 2.5
const GAP: float = 1.0 # quiet time after a spike leaves the screen
const JUMP_VELOCITY: float = 400.0
const GRAVITY: float = 1400.0
const BALL_RADIUS: float = 8.0
const BALL_X: float = 150.0 # px from the edge of this control
const BASE_SPIKE_SPEED: float = 75.0
const FLOOR_MARGIN: float = 8.0
const AIRTIME: float = 2.0 * JUMP_VELOCITY / GRAVITY

var main_points = PackedVector2Array([Vector2(-8, 8), Vector2(2, 8), Vector2(-3, -8)])
var secondary_points = PackedVector2Array([Vector2(0, 8), Vector2(8, 8), Vector2(4, -3)])
var spike_colors = PackedColorArray([Color(0.36, 0.05, 0.1), Color(0.36, 0.05, 0.1), Color(1.0, 0.25, 0.35)])

var ball_height: float = 0.0
var ball_velocity: float = 0.0
var grounded: bool = true
var draw_scale: Vector2 = Vector2.ONE

var spike_dir: int = 1
var spike_x: float = 0.0
var spike_speed: float = 0.0
var jump_distance: float = 0.0
var gap_timer: float = 0.5
var spike_active: bool = false
var jumped: bool = false

func _process(delta: float) -> void:
	if spike_active:
		spike_x += spike_dir * spike_speed * PX * delta
		if grounded and not jumped and (BALL_X - spike_x) * spike_dir <= jump_distance:
			jump()
		var gone: bool = (spike_x > size.x + 8.0 * PX) if spike_dir == 1 else (spike_x < -8.0 * PX)
		if gone:
			spike_active = false
			gap_timer = GAP
	else:
		gap_timer -= delta
		if gap_timer <= 0.0:
			spawn_spike()
	
	update_ball(delta)
	queue_redraw()

func spawn_spike() -> void:
	spike_active = true
	jumped = false
	spike_dir = 1 if randf() < 0.5 else -1
	spike_x = -8.0 * PX if spike_dir == 1 else size.x + 8.0 * PX
	spike_speed = BASE_SPIKE_SPEED * randf_range(0.9, 1.2)
	# jump so the spike is right under the ball at the top of the jump, +/- a little "human" error
	var jitter = randf_range(-0.03, 0.03)
	jump_distance = spike_speed * PX * (AIRTIME / 2.0 + jitter)

func jump() -> void:
	jumped = true
	grounded = false
	ball_velocity = JUMP_VELOCITY
	draw_scale = Vector2(1.15, 0.85)

func update_ball(delta: float) -> void:
	if grounded:
		return
	ball_velocity -= GRAVITY * delta
	ball_height += ball_velocity * delta
	draw_scale = draw_scale.lerp(Vector2(0.9, 1.1), delta * 12.0)
	if ball_height <= 0.0:
		ball_height = 0.0
		ball_velocity = 0.0
		grounded = true
		land()

func land() -> void:
	var tween = create_tween()
	tween.tween_property(self, "draw_scale", Vector2(1.35, 0.65), 0.05)
	tween.tween_property(self, "draw_scale", Vector2(0.85, 1.15), 0.06)
	tween.tween_property(self, "draw_scale", Vector2.ONE, 0.08)

func _draw() -> void:
	var floor_y: float = size.y - FLOOR_MARGIN
	draw_line(Vector2(0, floor_y), Vector2(size.x, floor_y), Color(1, 1, 1, 0.15), 2.0)
	
	if spike_active:
		draw_set_transform(Vector2(spike_x, floor_y - 8.0 * PX), 0.0, Vector2(PX, PX))
		draw_polygon(main_points, spike_colors)
		draw_polygon(secondary_points, spike_colors)
	
	# ball bottom stays glued to the floor while it deforms
	var radius: float = BALL_RADIUS * PX
	var center = Vector2(BALL_X, floor_y - radius - ball_height * PX)
	var offset = Vector2(0, radius * (1.0 - draw_scale.y))
	draw_set_transform(center + offset, 0.0, draw_scale)
	draw_circle(Vector2.ZERO, radius, Color.WHITE)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color.BLACK, PX)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
