class_name RunState extends State


func enter() -> void:
    character.play_animation("run")


func physics_update(delta: float) -> void:
    var dir_x := Input.get_axis("move_left", "move_right")

    # 没输入 → 回到待机
    if dir_x == 0.0:
        transitioned.emit("IdleState")
        return

    # 让 MovementComponent 处理加速/摩擦
    character.movement.move_horizontal(dir_x, delta)
    character.movement.physics_tick(delta)
    character.update_facing(dir_x)

    # 脚下踩空 → 掉落
    if not character.is_on_floor():
        transitioned.emit("FallState")
        return

    # 跳跃
    if Input.is_action_just_pressed("jump"):
        if character.movement.try_jump():
            transitioned.emit("JumpState")

    # 能力：冲刺
    if Input.is_action_just_pressed("dash"):
        _try_ability_transition("DashState")
