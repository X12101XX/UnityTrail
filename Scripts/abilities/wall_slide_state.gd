class_name WallSlideState extends State

var ability: WallJumpAbility
var _wall_direction: float = 0.0


func enter() -> void:
	_wall_direction = _get_wall_direction()
	character.play_animation("fall")
	character.movement.gravity_override = ability.wall_slide_gravity


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
		var jump_dir = _wall_direction
		if jump_dir == 0.0:
			jump_dir = -sign(character.facing_direction.x)
			if jump_dir == 0.0:
				jump_dir = 1.0
		character.velocity.x = jump_dir * ability.wall_jump_horizontal_force
		character.update_facing(jump_dir)
		character.movement.force_jump(ability.wall_jump_vertical_force)
		transitioned.emit("JumpState")
		return

	if Input.is_action_just_pressed("dash"):
		_try_ability_transition("DashState")


func _get_wall_direction() -> float:
	var wall_normal := character.get_wall_normal()
	if wall_normal.x != 0.0:
		return wall_normal.x

	var dir_x := Input.get_axis("move_left", "move_right")
	if dir_x != 0.0:
		return -sign(dir_x)

	return -sign(character.facing_direction.x)
