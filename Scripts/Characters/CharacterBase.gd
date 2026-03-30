extends CharacterBody2D
class_name CharacterBase

# 最大速度
@export var max_speed := 300.0

# 地上加速度
@export var accel_ground := 3000.0
@export var decel_ground := 5000.0

# 空中加速度
@export var accel_air := 2000.0
@export var decel_air := 3000.0

# 跳跃速度
@export var jump_velocity := -400.0

# 加速下落
var down := false
@export var down_velocity := 100.0

# 最后的移动速度
var last_direction: Vector2 = Vector2.ZERO

#states
var _was_on_floor = false

func _physics_process(delta: float) -> void:
	_process_common(delta)
	_process_extra(delta)
	move_and_slide()
	
	# 落地检测
	if not _was_on_floor and is_on_floor():
		_on_landed()
	_was_on_floor = is_on_floor()

# 落地后行为
func _on_landed() -> void:
	pass

# 通用行为
func _process_common(delta: float) -> void:
	# 下落
	if not is_on_floor():
		velocity += get_gravity() * delta
		if down:
			velocity.y += down_velocity * delta

	# 跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 左右移动
	var target_x := last_direction.x * max_speed

	if last_direction.x != 0:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, target_x, accel_ground * delta)
		else:
			velocity.x = move_toward(velocity.x, target_x, accel_air * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, decel_ground * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, decel_air * delta)


# 子类的扩展行为
func _process_extra(delta: float) -> void:
	pass


# 通用的方向输入
func _input(event: InputEvent) -> void:
	# 左右
	if event.is_action_pressed("ui_left"):
		last_direction.x = -1
	elif event.is_action_pressed("ui_right"):
		last_direction.x = 1

	if event.is_action_released("ui_left") and last_direction.x == -1:
		last_direction.x = 1 if Input.is_action_pressed("ui_right") else 0

	if event.is_action_released("ui_right") and last_direction.x == 1:
		last_direction.x = -1 if Input.is_action_pressed("ui_left") else 0

	# 上下
	if event.is_action_pressed("ui_up"):
		last_direction.y = -1
	elif event.is_action_pressed("ui_down"):
		last_direction.y = 1

	if event.is_action_released("ui_up") and last_direction.y == -1:
		last_direction.y = 1 if Input.is_action_pressed("ui_down") else 0

	if event.is_action_released("ui_down") and last_direction.y == 1:
		last_direction.y = -1 if Input.is_action_pressed("ui_up") else  0

	# 加速下落
	if event.is_action_pressed("ui_down"):
		down = true
	elif event.is_action_released("ui_down"):
		down = false
