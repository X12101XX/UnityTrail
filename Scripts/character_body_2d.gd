extends "res://Scripts/Characters/CharacterBase.gd"

func use_skill(skill_name: String):
	var skill = $Skills.get_node_or_null(skill_name)
	if skill:
		skill.activate(self)

func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		use_skill("DashSkill")
