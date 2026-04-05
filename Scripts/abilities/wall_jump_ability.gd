class_name WallJumpAbility extends AbilityBase

@export var wall_slide_gravity: float = 220.0
@export var wall_jump_vertical_force: float = 500.0
@export var wall_jump_horizontal_force: float = 1000.0
@export_range(0, 99, 1) var max_wall_jumps: int = 1

var _remaining_wall_jumps: int = 0


func _inject_states() -> void:
	movement.landed.connect(_on_landed)
	_reset_wall_jumps()

	var wall_slide_state = WallSlideState.new()
	wall_slide_state.name = "WallSlideState"
	wall_slide_state.ability = self
	inject_state(wall_slide_state)


func consume_wall_jump() -> bool:
	if _remaining_wall_jumps <= 0:
		return false
	_remaining_wall_jumps -= 1
	return true


func _on_landed() -> void:
	_reset_wall_jumps()


func _reset_wall_jumps() -> void:
	_remaining_wall_jumps = max_wall_jumps
