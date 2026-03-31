class_name AbilityBase extends Node

var character: CharacterBody2D


# 由 player_base._ready() 自动调用
func setup(p_character: CharacterBody2D) -> void:
    character = p_character
    _inject_states()


# 子类重写：在这里创建并注入自己的状态
func _inject_states() -> void:
    pass


# 把状态注入到状态机中（加入节点树 + 注册 + 绑定守卫）
func inject_state(state: State) -> void:
    var sm = character.get_node("StateMachine") as StateMachine
    sm.add_child(state)
    sm.register_state(state)
    sm.register_ability_guard(state.name, self)


# 移除状态（角色切换能力时用）
func remove_state(state_name: StringName) -> void:
    var sm = character.get_node("StateMachine") as StateMachine
    var state_node = sm.states.get(state_name)
    sm.unregister_state(state_name)
    sm.unregister_ability_guard(state_name)
    if state_node:
        state_node.queue_free()


# 子类重写：冷却中返回 false，守卫机制自动拦截转换
func can_activate() -> bool:
    return true
