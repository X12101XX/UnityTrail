class_name State extends Node

signal transitioned(new_state_name: StringName)

var character: CharacterBody2D


func enter() -> void:
    pass


func exit() -> void:
    pass


func update(_delta: float) -> void:
    pass


func physics_update(_delta: float) -> void:
    pass


# 尝试转换到能力状态（没有该能力 或 冷却中 → 自动跳过）
func _try_ability_transition(state_name: StringName) -> bool:
    var sm = character.get_node("StateMachine") as StateMachine
    if sm.can_transition_to(state_name):
        transitioned.emit(state_name)
        return true
    return false
