class_name CharacterData extends Resource

@export_group("基本信息")
@export var display_name: String = ""
@export var portrait: Texture2D
@export var character_id: StringName = ""

@export_group("移动")
@export var move_speed: float = 200.0
@export var acceleration: float = 1200.0
@export var friction: float = 1600.0
@export var air_friction: float = 400.0

@export_group("跳跃")
@export var jump_force: float = 400.0
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.5
@export var max_fall_speed: float = 600.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.12

@export_group("战斗")
@export var max_hp: int = 100
@export var attack: float = 10.0
@export var defense: float = 5.0

@export_group("能力")
@export var ability_scenes: Array[PackedScene] = []

@export_group("解谜特性")
@export var weight: float = 1.0
@export var can_push_blocks: bool = false
@export var can_activate_magic_runes: bool = false
