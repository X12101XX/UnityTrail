class_name DashAbility extends AbilityBase

@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

var _cooldown_timer: float = 0.0


func _inject_states() -> void:
    var dash_state = DashState.new();
    dash_state.name = "DashState"
    dash_state.ability = self
    inject_state(dash_state)


func _physics_process(delta: float) -> void:
    if _cooldown_timer > 0.0:
        _cooldown_timer -= delta


func can_activate() -> bool:
    return _cooldown_timer <= 0.0


func start_cooldown() -> void:
    _cooldown_timer = dash_cooldown
