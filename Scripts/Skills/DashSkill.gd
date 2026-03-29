extends "res://Scripts/Skills/SkillBase.gd"

@export var dash_speed := 1500.0
@export var dash_time := 0.18
@export var cooldown := 0.2

var _cooling := false
# false -> 未冷却
# true -> 冷却中

func activate(user: CharacterBody2D):
	if _cooling or user.last_direction == 0:
		return

	_cooling = true
	user.is_dashing = true

	# 设置冲刺方向和冲刺计时器
	var dash_dir = user.last_direction
	var dash_timer = dash_time

	# 获取角色贴图
	var sprite:Sprite2D = user.get_node("Sprite2D")

	while dash_timer > 0:
		# 在贴图位置生成 trail
		var trail := Sprite2D.new()
		
		# 设置特效采用的贴图，生成尾迹
		trail.texture = sprite.texture
		trail.global_position = sprite.global_position
		trail.offset = Vector2.ZERO
		user.get_parent().add_child(trail)
		
		# 补间动画
		var tw = trail.create_tween()
		tw.tween_property(trail, "modulate:a", 0.0, 0.15)
		tw.tween_callback(trail.queue_free)
		
		# 设置冲刺速度
		user.velocity.x = dash_dir * dash_speed
		user.velocity.y = 0

		dash_timer -= get_physics_process_delta_time()
		await get_tree().process_frame

	# 冲刺后硬直
	user.velocity = Vector2(0, 0)

	user.is_dashing = false

	# 冷却
	await get_tree().create_timer(cooldown).timeout
	_cooling = false
