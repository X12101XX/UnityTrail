class_name StateMachine extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}
var _ability_guards: Dictionary = {}


func _ready() -> void:
    for child in get_children():
        if child is State:
            _register_state(child)

    if initial_state:
        current_state = initial_state
        current_state.enter()


func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)


func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)


func register_state(state: State) -> void:
    _register_state(state)


func unregister_state(state_name: StringName) -> void:
    states.erase(state_name)


func has_state(state_name: StringName) -> bool:
    return states.has(state_name)


# 能力守卫：注册能力和状态的对应关系
func register_ability_guard(state_name: StringName, ability) -> void:
    _ability_guards[state_name] = ability


func unregister_ability_guard(state_name: StringName) -> void:
    _ability_guards.erase(state_name)


# 检查能否转换到某个能力状态（状态存在 + 能力允许激活）
func can_transition_to(state_name: StringName) -> bool:
    if not states.has(state_name):
        return false
    var guard = _ability_guards.get(state_name)
    if guard and not guard.can_activate():
        return false
    return true


func transition_to(new_state_name: StringName) -> void:
    _on_state_transitioned(new_state_name)


func _register_state(state: State) -> void:
    states[state.name] = state
    state.character = owner as CharacterBody2D
    state.transitioned.connect(_on_state_transitioned)


func _on_state_transitioned(new_state_name: StringName) -> void:
    var new_state = states.get(new_state_name)
    if new_state == null or new_state == current_state:
        return
    if current_state:
        current_state.exit()
    current_state = new_state
    current_state.enter()
