class_name IdleState extends State


func enter() -> void:
    character.velocity.x = 0.0
    character.play_animation("idle")


func physics_update(delta: float) -> void:
    character.movement.physics_tick(delta)

    # 掉落
    if not character.is_on_floor():
        transitioned.emit("FallState")
        return

    # 跑
    var dir_x := Input.get_axis("move_left", "move_right")
    if dir_x != 0.0:
        transitioned.emit("RunState")
        return

    # 跳
    if Input.is_action_just_pressed("jump"):
        if character.movement.try_jump():
            transitioned.emit("JumpState")

    # 冲刺
    if Input.is_action_just_pressed("dash"):
        _try_ability_transition("DashState")

    # 交互
    if Input.is_action_just_pressed("interact"):
        if character.has_node("InteractionComponent"):
            character.interaction.try_interact()

