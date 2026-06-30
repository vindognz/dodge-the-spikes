extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = 400.0

func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
