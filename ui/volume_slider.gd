extends HSlider

# 控制的音频总线名称，比如"Master"、"SFX"、"BGM"
@export var bus: StringName = "Master"

# 自动获取总线索引
@onready var bus_index := AudioServer.get_bus_index(bus)

func _ready() -> void:
	# 初始化滑块数值，读取当前总线音量
	value = $"/root/sound_manager".get_volume(bus_index)
	
	# 绑定滑块变化事件：滑动时同步更新音量并保存配置
	value_changed.connect(func(v: float):
		$"/root/sound_manager".set_volume(bus_index, v)
		$"/root/Game".save_config()
	)
	sound_manager.play_bgm(preload("res://asset/BGM/BGM.mp3"))
