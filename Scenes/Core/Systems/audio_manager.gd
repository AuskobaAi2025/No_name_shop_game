extends Node
class_name GameAudioManager

var bgm_player: AudioStreamPlayer
var se_players: Array[AudioStreamPlayer] = []

const SE_PLAYER_COUNT: int = 3


# AudioBus名（プロジェクト側で作成しておく）
const BGM_BUS := "BGM"
const SE_BUS := "SE"

# BGM定義
var bgm_table: Dictionary = {
	"shop": preload("res://MusicAndSe/time_for_adventure.mp3")
}

# SE定義
var se_table: Dictionary = {
	"coin": preload("res://MusicAndSe/coin.wav"),
	"exit": preload("res://MusicAndSe/exit.wav")
}


func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	
	# --- BGM設定 ---
	bgm_player.bus = BGM_BUS

	# --- SEプレイヤー収集 ---
	for i in SE_PLAYER_COUNT:
		var player := AudioStreamPlayer.new()
		player.bus = SE_BUS
		add_child(player)
		se_players.append(player)


# ------------------------
# BGM
# ------------------------

func play_bgm(bgm_id: String) -> void:
	if not bgm_table.has(bgm_id):
		push_error("Unknown BGM id: %s" % bgm_id)
		return

	var stream: AudioStream = bgm_table[bgm_id]

	# 同じ曲なら再生し直さない
	if bgm_player.stream == stream and bgm_player.playing:
		return

	bgm_player.stream = stream
	bgm_player.play()


func stop_bgm() -> void:
	bgm_player.stop()


# ------------------------
# SE
# ------------------------

func play_se(se_id: String) -> void:
	if not se_table.has(se_id):
		push_error("Unknown SE id: %s" % se_id)
		return

	var player := _get_available_se_player()
	if player == null:
		# 全て使用中なら鳴らさない（または上書き方式にしてもOK）
		return

	player.stream = se_table[se_id]
	player.play()


func _get_available_se_player() -> AudioStreamPlayer:
	for player in se_players:
		if not player.playing:
			return player

	return null
