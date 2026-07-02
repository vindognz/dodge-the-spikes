extends Node2D

@export var spike_scene: PackedScene
@onready var camera: Camera2D = get_parent().get_node("Camera")

var screen_width: float
var cooldown: float = 1.5
var timer: float = 0.0
var last_side: String = ""
var same_side_count: int = 0
var max_same_side: int = 3

func _ready() -> void:
	screen_width = get_viewport_rect().size.x / camera.zoom.x

func _process(delta: float) -> void:
	if not Global.running: return
	timer += delta
	if timer >= cooldown:
		timer = 0.0
		spawn_spike()

func pick_side() -> String:
	var side = "left" if randf() < 0.5 else "right"
	if side == last_side:
		same_side_count += 1
	else:
		same_side_count = 0
	if same_side_count >= max_same_side:
		side = "right" if last_side == "left" else "left"
		same_side_count = 0
	last_side = side
	return side

func spawn_spike() -> void:
	var spike = spike_scene.instantiate()
	var side = pick_side()
	var half = screen_width / 2
	
	if side == "left":
		spike.position = Vector2(-half - 8, -32)  # -144 - 8 = -152
		spike.direction = 1
	else:
		spike.position = Vector2(half + 8, -32)   # 144 + 8 = 152
		spike.direction = -1
	
	spike.half_width = half
	get_parent().add_child(spike)
