extends Node2D

@onready var trigger: TriggerZone = $TriggerZone
@export var bounce_speed_x: float = 500.0
@export var bounce_speed_y: float = 120.0

func _ready() -> void:
	trigger.triggered.connect(_on_triggered)

func _on_triggered(target: Node) -> void:
	if "velocity" in target:
		target.velocity.x = -bounce_speed_x   # 直接往左
		target.velocity.y = -bounce_speed_y   # 可选：略微向上
		print("bounce left -> ", target.name)
