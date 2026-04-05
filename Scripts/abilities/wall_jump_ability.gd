class_name WallJumpAbility extends AbilityBase

@export var wall_slide_gravity: float = 220.0
@export var wall_jump_vertical_force: float = 500.0
@export var wall_jump_horizontal_force: float = 260.0


func _inject_states() -> void:
	var wall_slide_state = WallSlideState.new()
	wall_slide_state.name = "WallSlideState"
	wall_slide_state.ability = self
	inject_state(wall_slide_state)
