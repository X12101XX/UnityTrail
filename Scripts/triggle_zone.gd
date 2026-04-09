extends Area2D
class_name TriggerZone

signal triggered(by: Node)

@export var target_group: String = "Player" # 只对玩家触发
@export var one_shot: bool = false          # 只触发一次
@export var enabled: bool = true

var _used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not enabled:
		return
	if one_shot and _used:
		return
	if target_group != "" and not body.is_in_group(target_group):
		return

	triggered.emit(body)

	if one_shot:
		_used = true

func reset_trigger() -> void:
	_used = false