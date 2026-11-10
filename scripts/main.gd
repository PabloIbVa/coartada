extends Control

const Contexts := preload("res://scripts/contexts.gd")
const Scoring := preload("res://scripts/scoring.gd")

const MAX_LIVES := 3
const MIN_SECONDS := 8.0
const ROUND_SHRINK := 2.0

const NAVY := Color(0.133333, 0.188235, 0.360784)
const CORAL := Color(0.937255, 0.482353, 0.423529)
const TEAL := Color(0.172549, 0.478431, 0.470588)
const MUTED := Color(0.45098, 0.478431, 0.54902)

@onready var home: Control = $UI/Screens/Home
@onready var round_screen: Control = $UI/Screens/Round
@onready var result_screen: Control = $UI/Screens/Result
@onready var over_screen: Control = $UI/Screens/Over

@onready var play_button: Button = $UI/Screens/Home/Box/PlayButton

@onready var round_label: Label = $UI/Screens/Round/Box/TopBar/RoundLabel
@onready var lives_row = $UI/Screens/Round/Box/TopBar/Lives
@onready var timer_label: Label = $UI/Screens/Round/Box/TimerRow/TimerLabel
@onready var word_limit_label: Label = $UI/Screens/Round/Box/TimerRow/WordLimit
@onready var timer_bar: ProgressBar = $UI/Screens/Round/Box/TimerBar
@onready var art: TextureRect = $UI/Screens/Round/Box/Card/CardPad/CardBox/Art
@onready var title_label: Label = $UI/Screens/Round/Box/Card/CardPad/CardBox/Title
@onready var situation_label: Label = $UI/Screens/Round/Box/Card/CardPad/CardBox/Situation
@onready var excuse_input: TextEdit = $UI/Screens/Round/Box/Input
@onready var word_count_label: Label = $UI/Screens/Round/Box/Footer/WordCount
@onready var send_button: Button = $UI/Screens/Round/Box/Footer/SendButton

@onready var verdict_kicker: Label = $UI/Screens/Result/Box/VerdictKicker
@onready var verdict_label: Label = $UI/Screens/Result/Box/Card/Pad/CardBox/Verdict
@onready var score_label: Label = $UI/Screens/Result/Box/Card/Pad/CardBox/ScoreRow/ScoreValue
@onready var reason_label: Label = $UI/Screens/Result/Box/Card/Pad/CardBox/Reason
@onready var quote_label: Label = $UI/Screens/Result/Box/Card/Pad/CardBox/Quote
@onready var result_lives_caption: Label = $UI/Screens/Result/Box/LivesCaption
@onready var result_lives_row = $UI/Screens/Result/Box/Lives
@onready var next_button: Button = $UI/Screens/Result/Box/NextButton

@onready var over_title: Label = $UI/Screens/Over/Box/OverTitle
@onready var over_sub: Label = $UI/Screens/Over/Box/OverSub
@onready var over_stats: Label = $UI/Screens/Over/Box/OverStats
@onready var again_button: Button = $UI/Screens/Over/Box/AgainButton

var lives_left: int = MAX_LIVES
var round_number: int = 0
var rounds_passed: int = 0
var best_score: int = 0
var deck: Array = []
var current: Dictionary = {}
var time_left: float = 0.0
var time_total: float = 1.0
var running: bool = false
var word_limit: int = 30
var last_result: Dictionary = {}
var enforcing_limit: bool = false


func _ready() -> void:
	play_button.pressed.connect(_start_run)
	again_button.pressed.connect(_start_run)
	send_button.pressed.connect(_submit)
	next_button.pressed.connect(_on_next)
	excuse_input.text_changed.connect(_on_text_changed)
	art.resized.connect(_sync_art_mask)
	set_process(false)
	_show_screen(home)


func _sync_art_mask() -> void:
	var mat: ShaderMaterial = art.material as ShaderMaterial
	if mat != null and art.size.x > 1.0:
		mat.set_shader_parameter("rect_size", art.size)


func _process(delta: float) -> void:
	if not running:
		return
	time_left = maxf(0.0, time_left - delta)
	_paint_timer()
	if time_left <= 0.0:
		_submit()


func _start_run() -> void:
	lives_left = MAX_LIVES
	round_number = 0
	rounds_passed = 0
	best_score = 0
	deck.clear()
	_next_round()


func _next_round() -> void:
	if deck.is_empty():
		deck = Contexts.LIST.duplicate(true)
		deck.shuffle()
	current = deck.pop_back()
	round_number += 1

	word_limit = int(current.words)
	time_total = maxf(MIN_SECONDS, float(current.seconds) - float(round_number - 1) * ROUND_SHRINK)
	time_left = time_total

	var tex: Texture2D = load(String(current.art))
	art.texture = tex
	if tex != null and float(tex.get_width()) > float(tex.get_height()) * 1.3:
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.custom_minimum_size = Vector2(0, 232)
	else:
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.custom_minimum_size = Vector2(0, 286)

	title_label.text = String(current.title)
	situation_label.text = String(current.text)
	round_label.text = "RONDA %d" % round_number
	word_limit_label.text = "máx. %d palabras" % word_limit

	excuse_input.text = ""
	excuse_input.editable = true
	enforcing_limit = false
	_paint_counter(0)
	lives_row.max_lives = MAX_LIVES
	lives_row.lives = lives_left

	timer_bar.value = 1.0
	timer_label.text = str(int(ceil(time_total)))
	timer_label.add_theme_color_override("font_color", NAVY)
	timer_bar.modulate = Color(1, 1, 1, 1)

	_show_screen(round_screen)
	running = true
	set_process(true)
	await get_tree().process_frame
	_sync_art_mask()
	if excuse_input.is_inside_tree():
		excuse_input.grab_focus()


func _paint_timer() -> void:
	var ratio: float = clampf(time_left / time_total, 0.0, 1.0)
	timer_bar.value = ratio
	timer_label.text = str(int(ceil(time_left)))
	var urgent: bool = time_left <= 8.0
	timer_label.add_theme_color_override("font_color", CORAL if urgent else NAVY)
	if urgent:
		var pulse: float = 0.72 + 0.28 * absf(sin(Time.get_ticks_msec() / 140.0))
		timer_bar.modulate = Color(1, 1, 1, pulse)
	else:
		timer_bar.modulate = Color(1, 1, 1, 1)


func _on_text_changed() -> void:
	if enforcing_limit:
		return
	var words: int = Scoring.word_count(excuse_input.text)
	if words > word_limit:
		enforcing_limit = true
		excuse_input.text = _cut_to_words(excuse_input.text, word_limit)
		var last_line: int = excuse_input.get_line_count() - 1
		excuse_input.set_caret_line(last_line)
		excuse_input.set_caret_column(excuse_input.get_line(last_line).length())
		enforcing_limit = false
		words = Scoring.word_count(excuse_input.text)
	_paint_counter(words)


func _paint_counter(words: int) -> void:
	word_count_label.text = "%d / %d palabras" % [words, word_limit]
	word_count_label.add_theme_color_override("font_color", CORAL if words >= word_limit else MUTED)


func _cut_to_words(text: String, limit: int) -> String:
	var words: int = 0
	var in_word: bool = false
	var cut: int = text.length()
	for i in text.length():
		var is_word: bool = _is_word_char(text.unicode_at(i))
		if is_word and not in_word:
			words += 1
			if words > limit:
				cut = i
				break
			in_word = true
		elif not is_word:
			in_word = false
	return text.substr(0, cut).strip_edges()


func _is_word_char(cp: int) -> bool:
	return (cp >= 48 and cp <= 57) or (cp >= 65 and cp <= 90) \
		or (cp >= 97 and cp <= 122) or (cp >= 192 and cp <= 591)


func _submit() -> void:
	if not running:
		return
	running = false
	set_process(false)
	excuse_input.editable = false
	last_result = Scoring.evaluate(excuse_input.text, word_limit)

	if bool(last_result.passed):
		rounds_passed += 1
		best_score = maxi(best_score, int(last_result.score))
	else:
		lives_left = maxi(0, lives_left - 1)

	_paint_result()
	_show_screen(result_screen)


func _paint_result() -> void:
	var passed: bool = bool(last_result.passed)
	var score: int = int(last_result.score)
	verdict_label.text = "PASASTE" if passed else "NO CUELAS"
	verdict_label.add_theme_color_override("font_color", TEAL if passed else CORAL)
	score_label.text = str(score)
	score_label.add_theme_color_override("font_color", TEAL if passed else CORAL)
	verdict_kicker.text = "VEREDICTO · RONDA %d" % round_number

	var written: String = excuse_input.text.strip_edges()
	if written.length() > 150:
		written = written.substr(0, 150).strip_edges() + "…"
	if written.is_empty():
		quote_label.text = "No escribiste nada."
	else:
		quote_label.text = "«%s»" % written

	var notes: Array = last_result.notes
	var lines: Array = []
	for i in mini(2, notes.size()):
		lines.append(String(notes[i]))
	reason_label.text = "\n".join(PackedStringArray(lines))

	result_lives_row.max_lives = MAX_LIVES
	result_lives_row.lives = lives_left
	match lives_left:
		3:
			result_lives_caption.text = "Tienes 3 vidas"
		2:
			result_lives_caption.text = "Te quedan 2 vidas"
		1:
			result_lives_caption.text = "Última vida"
		_:
			result_lives_caption.text = "Sin vidas"

	if not passed and lives_left <= 0:
		next_button.text = "CONTINUAR"
	elif passed:
		next_button.text = "SIGUIENTE"
	else:
		next_button.text = "OTRA COARTADA"


func _on_next() -> void:
	if lives_left <= 0:
		_paint_over()
		_show_screen(over_screen)
	else:
		_next_round()


func _paint_over() -> void:
	over_title.text = "SE ACABÓ"
	over_sub.text = "Se te acabaron las vidas. Nadie te creyó tres veces."
	var stats: Array = []
	stats.append("Pasaste %d de %d rondas" % [rounds_passed, round_number])
	if best_score > 0:
		stats.append("Tu mejor excusa: %d pts" % best_score)
	over_stats.text = "\n".join(PackedStringArray(stats))


func _show_screen(target: Control) -> void:
	for screen in [home, round_screen, result_screen, over_screen]:
		screen.visible = (screen == target)
	target.modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(target, "modulate:a", 1.0, 0.2)
