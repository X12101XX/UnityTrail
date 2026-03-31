extends SkillBase
class_name DashSkill


func activate(user) -> void:
	if not can_activate(user):
		return

	if not user.has_method("can_dash") or not user.has_method("start_dash"):
		return

	if not user.can_dash():
		return

	if user.last_direction == Vector2.ZERO:
		return

	user.start_dash(user.last_direction)
