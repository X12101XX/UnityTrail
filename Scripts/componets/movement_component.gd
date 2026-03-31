class_name MovementComponent extends Node

# 信号
signal jumped
signal landed

# 依赖
var character: CharacterBody2D
var data: CharacterData

# 能力钩子
# 重力
var gravity_override: float = -1.0
# Buff 系统用：速度倍率，1.0 = 正常
var speed_multiplier: float = 1.0

# 内部状态
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false


func _ready() -> void:
	character = owner as CharacterBody2D
	assert(character != null, "MovementComponent 必须挂在 CharacterBody2D 下")


# 水平移动：传入方向 (-1, 0, 1)，内部处理加速/摩擦
func move_horizontal(direction_x: float, delta: float) -> void:
	var target_speed = direction_x * data.move_speed * speed_multiplier
	var current_vx = character.velocity.x

	if direction_x != 0.0:
		# 加速
		var accel = data.acceleration * delta
		character.velocity.x = move_toward(current_vx, target_speed, accel)
	else:
		# 减速（地面摩擦 / 空中摩擦）
		var fric: float
		if character.is_on_floor():
			fric = data.friction * delta
		else:
			fric = data.air_friction * delta
		character.velocity.x = move_toward(current_vx, 0.0, fric)


# 尝试跳跃：消耗土狼时间，成功返回 true
func try_jump() -> bool:
	if _coyote_timer > 0.0:
		_do_jump(data.jump_force)
		_coyote_timer = 0.0
		return true
	else:
		# 不在地面，记录跳跃缓冲
		_jump_buffer_timer = data.jump_buffer_time
		return false


# 松开跳跃键的时候阶段速度
func cut_jump() -> void:
	if character.velocity.y < 0.0:
		character.velocity.y *= 0.5


# 强制跳跃：能力专用，无视土狼时间
func force_jump(force: float) -> void:
	_do_jump(force)

#  物理帧调用

func physics_tick(delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	_check_jump_buffer()
	
	character.move_and_slide()
	
	_detect_landing()


#  内部实现
func _do_jump(force: float) -> void:
	character.velocity.y = -force
	_jump_buffer_timer = 0.0
	jumped.emit()


func _apply_gravity(delta: float) -> void:
	if character.is_on_floor():
		return
	
	var grav: float
	if gravity_override >= 0.0:
		# 能力覆盖重力（如滑翔时 gravity_override = 200）
		grav = gravity_override
	elif character.velocity.y > 0.0:
		# 下落时加重力
		grav = data.gravity * data.fall_gravity_multiplier
	else:
		# 上升时正常重力
		grav = data.gravity
	
	character.velocity.y = min(
		character.velocity.y + grav * delta,
		data.max_fall_speed
	)


func _update_timers(delta: float) -> void:
	# 狼跳
	if character.is_on_floor():
		_coyote_timer = data.coyote_time
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)
	
	# 跳跃缓冲倒计时
	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)


func _check_jump_buffer() -> void:
	# 落地瞬间如果有缓冲的跳跃输入，自动跳
	if character.is_on_floor() and _jump_buffer_timer > 0.0:
		_do_jump(data.jump_force)


func _detect_landing() -> void:
	var on_floor_now = character.is_on_floor()
	if on_floor_now and not _was_on_floor:
		landed.emit()
	_was_on_floor = on_floor_now
