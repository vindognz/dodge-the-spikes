extends CharacterBody2D

@onready var camera: Camera2D = $"../Camera"
@onready var sparks_controller: Node2D = $SparksController
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var thud_sound: AudioStreamPlayer2D = $ThudSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

const SPEED: float = 80.0
const JUMP_VELOCITY: float = 400.0
const GRAVITY: Vector2 = Vector2(0, 1400) # Vector2(0, 980.0)

var draw_scale: Vector2 = Vector2(1.0, 1.0)
var target_scale: Vector2 = Vector2(1.0, 1.0)
var splat_timer: float = 0.0
var was_on_floor: bool = true

func _draw():
	var offset = Vector2(0, 8.0 * (1.0 - draw_scale.y))
	draw_set_transform(offset, 0.0, draw_scale)
	
	draw_circle(Vector2.ZERO, 8.0, Color(1.0, 1.0, 1.0, 1.0))
	draw_arc(Vector2.ZERO, 8.0, 0.0, TAU, 32, Color.BLACK, 1.0)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _physics_process(delta: float) -> void:
	if not Global.running:
		return

	if not is_on_floor():
		velocity += GRAVITY * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
		target_scale = Vector2(1.15, 0.85)
		if not Global.mute_sfx: jump_sound.play()
	
	if Input.is_action_just_pressed("mute-sfx"):
		Global.mute_sfx = !Global.mute_sfx

	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	var just_landed := is_on_floor() and not was_on_floor
	was_on_floor = is_on_floor()

	if just_landed:
		camera.shake(7.0, 0.1)
		thud_sound.pitch_scale = randf_range(0.5, 1.5)
		if not Global.mute_sfx: thud_sound.play()
		var tween = create_tween()
		tween.tween_property(self, "draw_scale", Vector2(1.35, 0.65), 0.05)
		tween.tween_property(self, "draw_scale", Vector2(0.85, 1.15), 0.06)
		tween.tween_property(self, "draw_scale", Vector2.ONE, 0.08)

	elif not is_on_floor():
		target_scale = Vector2(0.9, 1.1)
		draw_scale = draw_scale.lerp(target_scale, delta * 12.0)

	else:
		target_scale = Vector2.ONE
		draw_scale = draw_scale.lerp(target_scale, delta * 12.0)

	queue_redraw()

func on_death() -> void:
	Global.running = false
	if not Global.mute_sfx: death_sound.play()
	sparks_controller.burst()
	camera.shake(10.5, 0.25)
