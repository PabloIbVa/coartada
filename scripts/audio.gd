extends Node

## Sonidos del juego: efectos de la librería con variaciones de tono
## y un drone de tensión sintetizado (sin archivo de música).

const SOUND_DIR := "res://library/sounds/rpg-sound-effects/"

const FILES := {
	"click": "confirmation_002.ogg",
	"tick": "impactWood_light_003.ogg",
	"submit": "impactWood_light_002.ogg",
	"pass": "confirmation_002.ogg",
	"fail": "error_006.ogg",
	"start": "drop_002.ogg",
	"over": "error_006.ogg",
}

var players: Array[AudioStreamPlayer] = []
var cache: Dictionary = {}
var next_player: int = 0
var bed: AudioStreamPlayer


func _ready() -> void:
	for i in 6:
		var player := AudioStreamPlayer.new()
		add_child(player)
		players.append(player)

	bed = AudioStreamPlayer.new()
	add_child(bed)
	bed.stream = make_bed()
	bed.volume_db = -30.0


func play(sound: String, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	var stream: AudioStream = stream_for(sound)
	if stream == null:
		return
	var player: AudioStreamPlayer = players[next_player]
	next_player = (next_player + 1) % players.size()
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.play()


func stream_for(sound: String) -> AudioStream:
	if cache.has(sound):
		return cache[sound]
	if not FILES.has(sound):
		return null
	var loaded: AudioStream = load(SOUND_DIR + String(FILES[sound]))
	cache[sound] = loaded
	return loaded


func start_bed() -> void:
	if bed.playing:
		return
	bed.pitch_scale = 1.0
	bed.volume_db = -30.0
	bed.play()


func stop_bed() -> void:
	bed.stop()


func set_tension(ratio: float) -> void:
	var stress: float = 1.0 - clampf(ratio, 0.0, 1.0)
	bed.pitch_scale = 1.0 + stress * 0.4
	bed.volume_db = -30.0 + stress * 11.0


## Drone: dos senos graves con pulso lento. Ciclos enteros para que el bucle no chasque.
func make_bed() -> AudioStreamWAV:
	var rate: int = 22050
	var seconds: float = 4.0
	var count: int = int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t: float = float(i) / float(rate)
		var pulse: float = 0.55 + 0.45 * sin(TAU * 0.5 * t)
		var tone: float = sin(TAU * 55.0 * t) * 0.55 + sin(TAU * 82.5 * t) * 0.28 + sin(TAU * 110.0 * t) * 0.12
		var value: float = tone * pulse * 0.3
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = count
	return wav
