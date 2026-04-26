extends Node

const CONFIG_PATH := "user://config.ini"

func _ready() -> void:
	# 游戏启动时自动读取音量配置
	load_config()

func save_config() -> void:
	var config := ConfigFile.new()
	# 读取sound_manager里的音量设置，保存到配置文件
	config.set_value("audio", "master", $"/root/sound_manager".get_volume(0))
	config.set_value("audio", "sfx", $"/root/sound_manager".get_volume(1))
	config.set_value("audio", "bgm", $"/root/sound_manager".get_volume(2))
	config.save(CONFIG_PATH)

func load_config() -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	# 从配置文件读取音量，设置给sound_manager（默认值：master 0.8，sfx 1.0，bgm 0.7）
	$"/root/sound_manager".set_volume(0, config.get_value("audio", "master", 0.8))
	$"/root/sound_manager".set_volume(1, config.get_value("audio", "sfx", 1.0))
	$"/root/sound_manager".set_volume(2, config.get_value("audio", "bgm", 0.7))
