class_name WallSlideState extends State

var ability: WallJumpAbility


func enter() -> void:
	character.play_animation("fall")
	character.movement.gravity_override = ability.wall_slide_gravity
	# 清掉上升速度，避免从 Jump 上升阶段切入墙滑时出现异常上飞
	if character.velocity.y < 0.0:
		character.velocity.y = 0.0


func exit() -> void:
	character.movement.gravity_override = -1.0


func physics_update(delta: float) -> void:
	var dir_x := Input.get_axis("move_left", "move_right")
	character.movement.move_horizontal(dir_x, delta)
	character.movement.physics_tick(delta)

	if character.is_on_floor():
		if dir_x != 0.0:
			transitioned.emit("RunState")
		else:
			transitioned.emit("IdleState")
		return
		
	if not character.is_on_wall():
		transitioned.emit("FallState")
		return

	if Input.is_action_just_pressed("jump"):
		if not ability.consume_wall_jump():
			return
		var jump_dir = _get_wall_jump_direction()
		character.velocity.x = jump_dir * ability.wall_jump_horizontal_force
		character.update_facing(jump_dir)
		character.movement.force_jump(ability.wall_jump_vertical_force)
		transitioned.emit("JumpState")
		return

	if Input.is_action_just_pressed("dash"):
		_try_ability_transition("DashState")


func _get_wall_jump_direction() -> float:
	var wall_normal := character.get_wall_normal()
	if wall_normal.x != 0.0:
		return wall_normal.x

	var dir_x := Input.get_axis("move_left", "move_right")
	if dir_x != 0.0:
		return -sign(dir_x)

	var facing_x = character.facing_direction.x
	if facing_x != 0.0:
		return -sign(facing_x)

	return 1.0
