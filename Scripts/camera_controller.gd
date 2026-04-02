extends Camera2D

class_name CameraController

## 跟随目标
@export var target: Node2D:
	set(value):
		target = value
		if is_node_ready():
			_update_camera_position()

## 缓动速度（0-1，数值越低越缓）
@export var easing_speed: float = 0.1

## 是否启用向前看效果（基于角色移动方向）
@export var enable_look_ahead: bool = true

## 向前看的距离
@export var look_ahead_distance: float = 100.0

## 是否限制摄像机边界
@export var enable_bounds: bool = true

## 摄像机边界（left, top, right, bottom）
@export var camera_bounds: Rect2 = Rect2(-500, -500, 2000, 1500)

## 摄像机抖动强度
@export var shake_intensity: float = 0.0

@onready var player: CharacterBody2D = target

var _target_position: Vector2 = Vector2.ZERO
var _current_position: Vector2 = Vector2.ZERO
var _shake_offset: Vector2 = Vector2.ZERO
var _is_shaking: bool = false


func _ready() -> void:
	if not target:
		var temp_target = get_tree().get_first_node_in_group("player")
		if temp_target:
			target = temp_target
	
	if target:
		_update_camera_position()


func _process(delta: float) -> void:
	if not target:
		return
	
	_update_camera_position()
	_apply_shake(delta)


func _update_camera_position() -> void:
	if not target:
		return
	
	_calculate_target_position()
	_apply_easing()
	_apply_bounds()
	
	if _is_shaking:
		global_position = _current_position + _shake_offset
	else:
		global_position = _current_position


func _calculate_target_position() -> void:
	_target_position = target.global_position
	
	if enable_look_ahead and target.has_method("get_facing_direction"):
		var facing = target.facing_direction
		_target_position += facing * look_ahead_distance

func _apply_easing() -> void:
	_current_position = _current_position.lerp(
		_target_position,
		easing_speed
	)

func _apply_bounds() -> void:
	if not enable_bounds:
		return
	
	_current_position.x = clamp(
		_current_position.x,
		camera_bounds.position.x + get_viewport_rect().size.x / 2,
		camera_bounds.position.x + camera_bounds.size.x - get_viewport_rect().size.x / 2
	)
	
	_current_position.y = clamp(
		_current_position.y,
		camera_bounds.position.y + get_viewport_rect().size.y / 2,
		camera_bounds.position.y + camera_bounds.size.y - get_viewport_rect().size.y / 2
	)


func _apply_shake(delta: float) -> void:
	if shake_intensity <= 0:
		_is_shaking = false
		_shake_offset = Vector2.ZERO
		return
	
	_is_shaking = true
	_shake_offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	
	# 逐帧减少抖动强度
	shake_intensity = move_toward(shake_intensity, 0.0, delta * 50)


## 添加摄像机抖动效果
func shake(intensity: float) -> void:
	shake_intensity = max(shake_intensity, intensity)


## 立即设置摄像机位置（不使用缓动）
func set_position_immediate(pos: Vector2) -> void:
	_current_position = pos
	_target_position = pos
	global_position = pos


## 调整缓动速度
func set_easing_speed(speed: float) -> void:
	easing_speed = clamp(speed, 0.01, 1.0)


## 获取当前缓动速度
func get_easing_speed() -> float:
	return easing_speed
