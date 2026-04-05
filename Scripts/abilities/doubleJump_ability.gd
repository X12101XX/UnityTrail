class_name DoubleJumpAbility extends AbilityBase

@export var jump_force: float = 700.0
var has_used: bool = false

# 复用 MovementComponent 下的 force_jump，无需注册状态
# 如需更改，请注册状态

func _inject_states() -> void:
	if movement:
		movement.landed.connect(on_landed)
	else:
		push_error("Movement component not found when injecting states.")

func can_activate() -> bool:
	if has_used:
		return false
	# 必须在空中（Jump / Fall）才能二段跳
	var current_state_name := state_machine.current_state.name
	return current_state_name in [&"JumpState", &"FallState"]

func activate() -> void:
	has_used = true
	if character and character.movement:
		character.movement.force_jump(jump_force)
	else:
		push_error("Character or movement component not found during double jump activation.")

# 重置：落地时由外部（MovementComponent 或 State）调用
func on_landed() -> void:
	has_used = false
