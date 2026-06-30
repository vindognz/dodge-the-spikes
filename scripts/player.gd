extends CharacterBody2D

const SPEED = 80.0
const JUMP_VELOCITY = 350.0
const GRAVITY = Vector2(0, 1200) #Vector2(0, 980.0)

func _draw():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 1.0) # your purple
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.0, 0.0, 0.0, 1.0) # white
	draw_style_box(style, Rect2(-8, -8, 16, 16))

func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		velocity += GRAVITY * delta

	# Handle jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
