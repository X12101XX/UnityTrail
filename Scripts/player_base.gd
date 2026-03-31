extends CharacterBody2D

@export var data: CharacterData

@onready var movement: MovementComponent = $MovementComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

# 角色面朝方向
var facing_direction: Vector2 = Vector2.RIGHT
var is_active: bool = true
var _abilities: Dictionary = {}

func _ready() -> void:
	if movement and data:
		movement.data = data

	# 初始化所有能力
	if has_node("Abilities"):
		for child in $Abilities.get_children():
			if child.has_method("setup"):
				child.setup(self)
				_abilities[child.get_script().get_global_name()] = child

func play_animation(anim_name: String) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)


func update_facing(dir_x: float) -> void:
	if dir_x != 0.0:
		facing_direction = Vector2(sign(dir_x), 0.0)
		sprite.flip_h = dir_x < 0.0


func get_ability(ability_class_name: String):
	return _abilities.get(ability_class_name)


func get_weight() -> float:
	return data.weight
