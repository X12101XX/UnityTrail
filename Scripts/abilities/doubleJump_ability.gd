class_name DoubleJumpAbility extends AbilityBase

@export var jump_force: float = 700.0
var _has_used: bool = false

# 目前实现为复用 MovementComponent 下的 force_jump
# 所以并不需要注册状态
# 如果需要更改，请注册状态

func _inject_states() -> void:
	movement.landed.connect(on_landed)

func can_activate() -> bool:
	if _has_used:
		return false
	# 必须在空中（Jump / Fall）才能二段跳
	var current := state_machine.current_state.name
	return current in [&"JumpState", &"FallState"]


func activate() -> void:
	_has_used = true
	character.movement.force_jump(jump_force)

	# 如果有独立的 DoubleJumpState，就在这里转换：
	# state_machine.transition_to(&"DoubleJump")


# 重置
# 落地时由外部（MovementComponent 或 State）调用
func on_landed() -> void:
	_has_used = false
