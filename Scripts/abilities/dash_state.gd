class_name DashState extends State

var ability: DashAbility
var _timer: float = 0.0
var _dash_direction: float = 1.0


func enter() -> void:
	_timer = ability.dash_duration
	_dash_direction = character.facing_direction.x
	if _dash_direction == 0.0:
		_dash_direction = 1.0
	character.play_animation("dash")
	# 冲刺期间关闭重力
	character.movement.gravity_override = 0.0
	# 启动冷却
	ability.start_cooldown()


func exit() -> void:
	# 恢复重力
	character.movement.gravity_override = -1.0


func physics_update(delta: float) -> void:
	_timer -= delta
	# 每帧强制设定速度：水平恒速，垂直归零
	character.velocity = Vector2(_dash_direction * ability.dash_speed, 0.0)
	character.movement.physics_tick(delta)

	# 计时结束 → 根据当前情况转到合适的状态
	if _timer <= 0.0:
		if character.is_on_floor():
			var dir_x := Input.get_axis("move_left", "move_right")
			if dir_x != 0.0:
				transitioned.emit("RunState")
			else:
				transitioned.emit("IdleState")
		else:
			transitioned.emit("FallState")
