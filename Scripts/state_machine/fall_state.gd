class_name FallState extends State


func enter() -> void:
	character.play_animation("fall")


func physics_update(delta: float) -> void:
	var dir_x := Input.get_axis("move_left", "move_right")
	character.movement.move_horizontal(dir_x, delta)
	character.movement.physics_tick(delta)
	if dir_x != 0.0:
		character.update_facing(dir_x)

	# 落地 → 待机
	if character.is_on_floor():
		var land_dir := Input.get_axis("move_left", "move_right")
		if land_dir != 0.0:
			transitioned.emit("RunState")
		else:
			transitioned.emit("IdleState")
		return


	# 按跳跃：按优先级尝试
	if Input.is_action_just_pressed("jump"):
		# 1. 狼跳（刚离开平台还能跳）
		if character.movement.try_jump():
			transitioned.emit("JumpState")
			return
		# 2. 二段跳（如果有这个能力）
		var double_jump = character.get_ability("DoubleJumpAbility") as DoubleJumpAbility
		if double_jump and double_jump.can_activate():
			double_jump.activate()
			transitioned.emit("JumpState")
			return

	# 按住跳跃 → 滑翔（如果有）
	if Input.is_action_pressed("jump"):
		_try_ability_transition("GlideState")

	# 贴墙 + 推方向 → 蹬墙滑行（如果有）
	if character.is_on_wall() and not character.is_on_floor():
		if dir_x != 0.0:
			_try_ability_transition("WallSlideState")	

	# 能力：冲刺
	if Input.is_action_just_pressed("dash"):
		_try_ability_transition("DashState")
