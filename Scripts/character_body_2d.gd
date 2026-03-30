extends "res://Scripts/Characters/CharacterBase.gd"

# Dash（该角色专属）
@export var dash_speed := 1200
@export var dash_time := 0.03
@export var max_dash := 1

# Dash 状态
var remain_dash := max_dash
var is_dashing := false
var dash_dir := Vector2.ZERO
var dash_timer := 0.0


func _ready() -> void:
	remain_dash = max_dash


# 技能调用
func use_skill(skill_name: String) -> void:
	var skill = $Skills.get_node_or_null(skill_name)
	if skill:
		skill.activate(self)


# 输入触发
func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		use_skill("DashSkill")


# Dash 执行
func _process_extra(delta: float) -> void:
	if not is_dashing:
		return

	# Dash 中按跳跃 → 立刻取消 Dash
	if Input.is_action_just_pressed("ui_accept"):
		is_dashing = false
		velocity.y = jump_velocity
		return

	velocity = dash_dir * dash_speed
	dash_timer -= delta

	if dash_timer <= 0.0:
		is_dashing = false
		if is_on_floor():
			remain_dash = max_dash


# 检查此时是否可以dash
# 由于这个角色实际上继承的是CharactarBase这个基类
# 而不是SkillBase这个基类，所以不能直接实现 can_active
func can_dash() -> bool:
	return (remain_dash > 0) and not is_dashing


func start_dash(direction: Vector2) -> void:
	if not can_dash():
		return

	remain_dash -= 1
	is_dashing = true
	dash_dir = direction.normalized()
	dash_timer = dash_time

# 落地刷新dash
func _on_landed() -> void:
	remain_dash = max_dash
