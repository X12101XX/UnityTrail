extends Node

enum  Bus{ MASTER=0,SFX=1,BGM=2 }
@onready var sfx: Node = $SFX
@onready var bgm_sfx:AudioStreamPlayer=$SFX/BGM/BGM
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

# 通用播放音效函数，支持路径调用
func play_sfx(path: String) -> void:
	var audio = sfx.get_node_or_null(path) as AudioStreamPlayer
	if audio:
		audio.play()
	else:
		print("⚠️ 音效不存在，请检查路径：", path)
func play_bgm(stream: AudioStream) -> void:
	# 防止重复播放同一首BGM，避免爆音和卡顿
	if bgm_sfx.stream == stream and bgm_sfx.playing:
		return
	bgm_sfx.stream = stream
	bgm_sfx.play()

# 给玩家自动绑定动作音效
func setup_player_sounds(player: Node) -> void:
	# 跳跃
	if player.has_signal("jumped"):
		player.jumped.connect(func():
			play_sfx("Player/Jump")
		)
	# 落地
	if player.has_signal("landed"):
		player.landed.connect(func():
			play_sfx("Player/land")
		)
	# 二段跳
	if player.has_signal("double_jumped"):
		player.double_jumped.connect(func():
			play_sfx("Skill/doublejump")
		)
	# 墙跳
	if player.has_signal("wall_jumped"):
		player.wall_jumped.connect(func():
			play_sfx("Skill/wall_jump")
		)
	# 冲刺
	if player.has_signal("dashed"):
		player.dashed.connect(func():
			play_sfx("Skill/dash")
		)
	# 技能闪光
	if player.has_signal("flashed"):
		player.flashed.connect(func():
			play_sfx("Skill/flash")
		)
	# 备用闪光
	if player.has_signal("flashed_alt"):
		player.flashed_alt.connect(func():
			play_sfx("Skill/flash2")
		)

# 给UI控件自动绑定点击音效
func setup_ui_sounds(ui_control: Control) -> void:
	for child in ui_control.get_children():
		if child is Button:
			child.pressed.connect(func():
				play_sfx("UI/click")
			) 
# 获取指定音频总线的音量（返回0~1的线性值）
func get_volume(bus_index: int) -> float:
	var db := AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)

# 设置指定音频总线的音量（传入0~1的线性值）
func set_volume(bus_index: int, v: float) -> void:
	var db =linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)
