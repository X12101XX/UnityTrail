extends Node
class_name SkillBase

@export var skill_name := ""
@export var enabled := true


func activate(user) -> void:
	# 实际技能的实现
	pass


func can_activate(user) -> bool:
	# 默认允许，子类可重写
	return enabled
