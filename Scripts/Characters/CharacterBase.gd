extends CharacterBody2D

@export var max_speed := 300.0
@export var accel_ground := 3000
@export var decel_ground := 5000

@export var accel_air := 2000
@export var decel_air := 3000

@export var jump_velocity = -400.0

@export var down_velocity = 100.0

var last_direction: Vector2 = Vector2.ZERO
# -1 -> 左
# 1 -> 右
# 0 -> 不动

var is_dashing := false

var down: bool = false
# true -> 加速下落
# false -> 正常下落


func _physics_process(delta: float) -> void:

	if is_dashing:
		move_and_slide()
		return

	# 下落逻辑
	if not is_on_floor():
		velocity += get_gravity() * delta
		# 加速下落
		if down :
			velocity.y += down_velocity * delta

	# 跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 左右移动 
	var target = last_direction.x * max_speed
	
	if last_direction.x != 0:
		if is_on_floor() :
			velocity.x = move_toward(velocity.x, target, accel_ground * delta) 
		else: 
			velocity.x = move_toward(velocity.x, target, accel_air * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, decel_ground * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, decel_air * delta)



	move_and_slide()

func _input(event: InputEvent) -> void:

	# 左右控制
	if event.is_action_pressed("ui_left"):
		last_direction.x = -1
	if event.is_action_pressed("ui_right"):
		last_direction.x  = 1

	if event.is_action_released("ui_right") and last_direction.x == 1:
		if Input.is_action_pressed("ui_left"):
			last_direction.x = -1
		else :
			last_direction.x = 0

	if event.is_action_released("ui_left") and last_direction.x == -1:
		if Input.is_action_pressed("ui_right"):
			last_direction.x = 1
		else :
			last_direction.x = 0
	
	# 上下控制
	if event.is_action_pressed("ui_up"):
		last_direction.y = -1
	if event.is_action_pressed("ui_down"):
		last_direction.y = 1

	if event.is_action_released("ui_up") and last_direction.y == 1:
		if Input.is_action_pressed("ui_down"):
			last_direction.y = -1
		else :
			last_direction.y = 0

	if event.is_action_released("ui_left") and last_direction.y == -1:
		if Input.is_action_pressed("ui_right"):
			last_direction.y = 1
		else :
			last_direction.y = 0
		

	# 加速下落
	if event.is_action_pressed("ui_down"):
		down = true
	if event.is_action_released("ui_down"):
		down = false
