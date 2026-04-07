extends Camera2D

class_name CameraController

## 跟随目标
@export var target: Node2D:
	set(value):
		target = value
		if is_node_ready() and target:
			set_position_immediate(target.global_position + Vector2(0.0, vertical_offset))

## 水平跟随速度（值越大越快；推荐 4~10）
@export var horizontal_follow_speed: float = 6.0

## 垂直跟随速度（略快于水平，减少跳跃时的视觉错乱；推荐 6~12）
@export var vertical_follow_speed: float = 9.0

## 垂直偏移：正值摄像机下移（看到更多上方），负值上移（看到更多下方）
@export var vertical_offset: float = -30.0

## 是否启用向前看效果
@export var enable_look_ahead: bool = true

## 水平向前看距离（像素）
@export var look_ahead_distance: float = 80.0

## 垂直向前看距离（下落速度超过阈值时向下预览）
@export var vertical_look_ahead_distance: float = 60.0

## 垂直触发向前看的速度阈值
@export var vertical_look_ahead_threshold: float = 200.0

## 向前看效果本身的跟随速度
@export var look_ahead_speed: float = 4.0

## 触发水平向前看所需的最低水平速度（低于此值时使用 facing_direction 回退）
@export var look_ahead_velocity_threshold: float = 10.0

## 待机状态下向前看距离的缩放比例（facing_direction 回退时使用，通常小于运动时）
@export var look_ahead_idle_scale: float = 0.5

## 是否启用死区（角色在死区内时摄像机不移动，减少抖动）
@export var enable_deadzone: bool = true

## 水平死区大小（像素）
@export var deadzone_h: float = 10.0

## 垂直死区大小（像素）
@export var deadzone_v: float = 8.0

## 是否限制摄像机边界
@export var enable_bounds: bool = true

## 摄像机边界（left, top, width, height）
@export var camera_bounds: Rect2 = Rect2(-500, -500, 2000, 1500)

## 摄像机抖动强度（通过 shake() 设置；每秒自动衰减）
@export var shake_intensity: float = 0.0

## 抖动衰减速率（每秒减少的抖动强度）
@export var shake_decay_rate: float = 50.0

var _current_position: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _look_ahead_offset: Vector2 = Vector2.ZERO
var _shake_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	if not target:
		var found = get_tree().get_first_node_in_group("player")
		if found:
			target = found

	if target:
		set_position_immediate(target.global_position + Vector2(0.0, vertical_offset))


func _process(delta: float) -> void:
	if not target:
		return

	_update_look_ahead(delta)
	_update_target_position()
	_apply_easing(delta)
	_apply_bounds()
	_apply_shake(delta)

	global_position = _current_position + _shake_offset


# ──────────────────────────────────────────────────────────── internal ──────

func _update_look_ahead(delta: float) -> void:
	var desired := Vector2.ZERO

	if enable_look_ahead:
		# 水平：优先使用速度（更平滑），回退到 facing_direction 属性
		if target is CharacterBody2D and absf(target.velocity.x) > look_ahead_velocity_threshold:
			desired.x = signf(target.velocity.x) * look_ahead_distance
		elif "facing_direction" in target:
			desired.x = (target.facing_direction as Vector2).x * look_ahead_distance * look_ahead_idle_scale

		# 垂直：快速下落时向下预览
		if target is CharacterBody2D and target.velocity.y > vertical_look_ahead_threshold:
			desired.y = vertical_look_ahead_distance

	_look_ahead_offset = _look_ahead_offset.lerp(
		desired,
		1.0 - exp(-look_ahead_speed * delta)
	)


func _update_target_position() -> void:
	var base := target.global_position + Vector2(0.0, vertical_offset) + _look_ahead_offset

	if enable_deadzone:
		var diff := base - _current_position
		if absf(diff.x) < deadzone_h:
			base.x = _current_position.x
		if absf(diff.y) < deadzone_v:
			base.y = _current_position.y

	_target_position = base


func _apply_easing(delta: float) -> void:
	# 指数衰减插值：帧率无关，速度值直观（秒为单位的响应速度）
	_current_position.x = lerpf(
		_current_position.x,
		_target_position.x,
		1.0 - exp(-horizontal_follow_speed * delta)
	)
	_current_position.y = lerpf(
		_current_position.y,
		_target_position.y,
		1.0 - exp(-vertical_follow_speed * delta)
	)


func _apply_bounds() -> void:
	if not enable_bounds:
		return

	var half := get_viewport_rect().size * 0.5
	_current_position.x = clamp(
		_current_position.x,
		camera_bounds.position.x + half.x,
		camera_bounds.position.x + camera_bounds.size.x - half.x
	)
	_current_position.y = clamp(
		_current_position.y,
		camera_bounds.position.y + half.y,
		camera_bounds.position.y + camera_bounds.size.y - half.y
	)


func _apply_shake(delta: float) -> void:
	if shake_intensity <= 0.0:
		_shake_offset = Vector2.ZERO
		return

	_shake_offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	shake_intensity = move_toward(shake_intensity, 0.0, delta * shake_decay_rate)


# ──────────────────────────────────────────────────────────── public API ────

## 触发摄像机抖动（多次调用取最大值）
func shake(intensity: float) -> void:
	shake_intensity = maxf(shake_intensity, intensity)


## 立即将摄像机传送到指定位置（跳过缓动，适合场景切换）
func set_position_immediate(pos: Vector2) -> void:
	_current_position = pos
	_target_position = pos
	_look_ahead_offset = Vector2.ZERO
	global_position = pos


## 设置水平跟随速度
func set_horizontal_follow_speed(speed: float) -> void:
	horizontal_follow_speed = clampf(speed, 0.1, 50.0)


## 设置垂直跟随速度
func set_vertical_follow_speed(speed: float) -> void:
	vertical_follow_speed = clampf(speed, 0.1, 50.0)
