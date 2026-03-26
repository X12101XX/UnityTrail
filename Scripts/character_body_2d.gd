extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ACCELERATION := 6000.0
const DECELERATION := 6000.0

var last_direction := 0
# -1 -> left 
# 1 -> right 
# 0 -> null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var target = last_direction * SPEED

	if last_direction != 0:
		velocity.x = move_toward(velocity.x, target, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		

	move_and_slide()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		last_direction = -1
	if event.is_action_pressed("ui_right"):
		last_direction = 1
	if event.is_action_released("ui_right") and last_direction == 1:
		if Input.is_action_pressed("ui_left"):
			last_direction = -1
		else :
			last_direction = 0
	if event.is_action_released("ui_left") and last_direction == -1:
		if Input.is_action_pressed("ui_right"):
			last_direction = 1
		else :
			last_direction = 0
