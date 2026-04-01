class_name JumpState extends State


func enter() -> void:
    character.play_animation("jump")
    # 从地面进来但还没跳时，补一次跳跃
    if character.is_on_floor():
        character.movement.try_jump()


func physics_update(delta: float) -> void:
    # 空中水平微调
    var dir_x := Input.get_axis("move_left", "move_right")
    character.movement.move_horizontal(dir_x, delta)
    character.movement.physics_tick(delta)
    if dir_x != 0.0:
        character.update_facing(dir_x)

    # 松开跳跃键 → 截断上升（短按矮跳）
    if Input.is_action_just_released("jump"):
        character.movement.cut_jump()

    # 二段跳
    if Input.is_action_just_pressed("jump"):
        var double_jump = character.get_ability("DoubleJumpAbility") as DoubleJumpAbility
        if double_jump and double_jump.can_activate():
            double_jump.activate()
            transitioned.emit("JumpState")
            return


    # 速度变为向下 → 进入 FallState
    if character.velocity.y >= 0.0 and not character.is_on_floor():
        transitioned.emit("FallState")
        return

    # 意外落地（撞到天花板弹回来等）
    if character.is_on_floor():
        transitioned.emit("IdleState")
        return

    # 贴墙 → 蹬墙滑行（如果有能力）
    if character.is_on_wall() and not character.is_on_floor():
        _try_ability_transition("WallSlideState") 

    # 能力：冲刺
    if Input.is_action_just_pressed("dash"):
        _try_ability_transition("DashState")
