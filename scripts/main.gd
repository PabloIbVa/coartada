extends Control

const Contexts := preload("res://scripts/contexts.gd")
const Scoring := preload("res://scripts/scoring.gd")

const MAX_LIVES := 3
const MIN_SECONDS := 8.0
const MIN_WORDS := 14
const SETTINGS_PATH := "user://coartada.cfg"

## Pega aquí tu enlace de apoyo (Ko-fi, PayPal, Buy Me a Coffee...).
const SUPPORT_URL := ""

const LIME := Color(0.796078, 1.0, 0.239216)
const CYAN := Color(0.223529, 0.882353, 1.0)
const MAGENTA := Color(1.0, 0.239216, 0.545098)
const INK := Color(0.956863, 0.956863, 0.964706)
const MUTED := Color(0.54902, 0.54902, 0.603922)
const DIM := Color(0.415686, 0.415686, 0.470588)
const NIGHT := Color(0.031373, 0.031373, 0.039216)
const SURFACE := Color(0.062745, 0.062745, 0.082353)
const EMPTY_CELL := Color(0.129412, 0.129412, 0.156863)

const DIFFICULTY := {
	"facil": {
		"label": "FÁCIL", "time": 1.3, "words": 4, "shrink": 1.4,
		"restrict_from": 4, "both_from": 99,
		"hint": "~47 S · HASTA 32 PALABRAS · RESTRICCIONES EN R4",
	},
	"normal": {
		"label": "NORMAL", "time": 1.0, "words": 0, "shrink": 2.0,
		"restrict_from": 3, "both_from": 8,
		"hint": "~36 S · HASTA 28 PALABRAS · RESTRICCIONES EN R3",
	},
	"duro": {
		"label": "DURO", "time": 0.78, "words": -3, "shrink": 2.6,
		"restrict_from": 2, "both_from": 5,
		"hint": "~28 S · HASTA 25 PALABRAS · RESTRICCIONES EN R2",
	},
}

const TIPS: Array = [
	"// EL JURADO QUIERE UNA CAUSA: «PORQUE» NO ES LA ÚNICA",
	"// UNA HORA EXACTA SUENA MÁS REAL QUE «HACE RATO»",
	"// SI REPITES TRES PALABRAS, SE NOTA",
	"// LAS PALABRAS PROHIBIDAS SE PUEDEN RODEAR",
	"// «SE ME OLVIDÓ» TAMBIÉN ES UNA CAUSA",
]

@onready var home: Control = $UI/Screens/Home
@onready var round_screen: Control = $UI/Screens/Round
@onready var result_screen: Control = $UI/Screens/Result
@onready var over_screen: Control = $UI/Screens/Over
@onready var confirm_layer: Control = $Confirm

@onready var diff_facil: Button = $UI/Screens/Home/Box/DiffRow/DiffFacil
@onready var diff_normal: Button = $UI/Screens/Home/Box/DiffRow/DiffNormal
@onready var diff_duro: Button = $UI/Screens/Home/Box/DiffRow/DiffDuro
@onready var diff_hint: Label = $UI/Screens/Home/Box/DiffHint
@onready var play_button: Button = $UI/Screens/Home/Box/PlayButton
@onready var support_button: Button = $UI/Screens/Home/Box/SupportCard/SupportPad/SupportBox/SupportButton
@onready var support_line: Label = $UI/Screens/Home/Box/SupportCard/SupportPad/SupportBox/SupportText/SupportLine
@onready var tip_label: Label = $UI/Screens/Home/Box/TipCard/TipPad/Tip

@onready var back_button: Button = $UI/Screens/Round/Box/TopBar/BackButton
@onready var round_label: Label = $UI/Screens/Round/Box/TopBar/RoundLabel
@onready var pips_row = $UI/Screens/Round/Box/TopBar/Pips
@onready var timer_value: Label = $UI/Screens/Round/Box/TimerRow/TimerValue
@onready var word_limit_label: Label = $UI/Screens/Round/Box/TimerRow/WordLimit
@onready var seg_bar = $UI/Screens/Round/Box/SegBar
@onready var title_label: Label = $UI/Screens/Round/Box/Card/Row/CardPad/CardBox/Title
@onready var subtitle_label: Label = $UI/Screens/Round/Box/Card/Row/CardPad/CardBox/Subtitle
@onready var chips_row: HBoxContainer = $UI/Screens/Round/Box/Chips
@onready var chip_include: PanelContainer = $UI/Screens/Round/Box/Chips/ChipInclude
@onready var chip_include_label: Label = $UI/Screens/Round/Box/Chips/ChipInclude/ChipIncludeLabel
@onready var chip_exclude: PanelContainer = $UI/Screens/Round/Box/Chips/ChipExclude
@onready var chip_exclude_label: Label = $UI/Screens/Round/Box/Chips/ChipExclude/ChipExcludeLabel
@onready var excuse_input: TextEdit = $UI/Screens/Round/Box/Input
@onready var word_count_label: Label = $UI/Screens/Round/Box/Footer/WordCount
@onready var send_button: Button = $UI/Screens/Round/Box/Footer/SendButton

@onready var result_back: Button = $UI/Screens/Result/TopBar/BackButton
@onready var result_round_label: Label = $UI/Screens/Result/TopBar/RoundLabel
@onready var stamp: PanelContainer = $UI/Screens/Result/Box/Stamp
@onready var stamp_label: Label = $UI/Screens/Result/Box/Stamp/StampPad/StampLabel
@onready var score_label: Label = $UI/Screens/Result/Box/ScoreRow/ScoreValue
@onready var reasons_label: Label = $UI/Screens/Result/Box/ReasonsCard/ReasonsPad/Reasons
@onready var result_lives_caption: Label = $UI/Screens/Result/Box/LivesCaption
@onready var result_pips = $UI/Screens/Result/Box/Pips
@onready var next_button: Button = $UI/Screens/Result/Box/Buttons/NextButton
@onready var result_menu: Button = $UI/Screens/Result/Box/Buttons/MenuButton

@onready var over_title: Label = $UI/Screens/Over/Box/OverTitle
@onready var over_sub: Label = $UI/Screens/Over/Box/OverSub
@onready var over_stats: Label = $UI/Screens/Over/Box/OverStats
@onready var again_button: Button = $UI/Screens/Over/Box/AgainButton
@onready var over_menu: Button = $UI/Screens/Over/Box/MenuButton

@onready var confirm_yes: Button = $Confirm/Center/Panel/Pad/Box/ConfirmRow/ConfirmYes
@onready var confirm_no: Button = $Confirm/Center/Panel/Pad/Box/ConfirmRow/ConfirmNo
@onready var audio = $Audio

var difficulty: String = "normal"
var lives_left: int = MAX_LIVES
var round_number: int = 0
var rounds_passed: int = 0
var best_score: int = 0
var deck: Array = []
var current: Dictionary = {}
var restriction: Dictionary = {}
var time_left: float = 0.0
var time_total: float = 1.0
var running: bool = false
var word_limit: int = 28
var last_result: Dictionary = {}
var enforcing_limit: bool = false
var last_tick_second: int = -1
var include_was_met: bool = false
var exclude_was_used: bool = false
var ghost_normal: StyleBoxFlat
var ghost_hover: StyleBoxFlat
var ghost_pressed: StyleBoxFlat


func _ready() -> void:
	_style_ghosts()
	_load_settings()

	play_button.pressed.connect(_start_run)
	again_button.pressed.connect(_start_run)
	send_button.pressed.connect(_submit)
	next_button.pressed.connect(_on_next)
	excuse_input.text_changed.connect(_on_text_changed)
	support_button.pressed.connect(_on_support)

	diff_facil.pressed.connect(_set_difficulty.bind("facil"))
	diff_normal.pressed.connect(_set_difficulty.bind("normal"))
	diff_duro.pressed.connect(_set_difficulty.bind("duro"))

	back_button.pressed.connect(_ask_abandon)
	result_back.pressed.connect(_go_home)
	over_menu.pressed.connect(_go_home)
	result_menu.pressed.connect(_go_home)
	confirm_yes.pressed.connect(_confirm_abandon)
	confirm_no.pressed.connect(_cancel_abandon)

	chips_row.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_layer.visible = false
	_paint_difficulty()
	_fix_ghost_focus()
	_hook_sounds()
	set_process(false)
	_show_screen(home)


func _hook_sounds() -> void:
	var buttons: Array = [
		play_button, again_button, send_button, next_button, support_button,
		diff_facil, diff_normal, diff_duro, back_button, result_back,
		result_menu, over_menu, confirm_yes, confirm_no,
	]
	for button in buttons:
		button.pressed.connect(_on_ui_click)


func _on_ui_click() -> void:
	audio.play("click", 1.0, -15.0)


func _fix_ghost_focus() -> void:
	for button in [back_button, result_back, result_menu, over_menu, support_button, confirm_yes]:
		var color: Color = button.get_theme_color("font_color")
		button.add_theme_color_override("font_focus_color", color)


func _style_ghosts() -> void:
	ghost_normal = StyleBoxFlat.new()
	ghost_normal.bg_color = Color(0, 0, 0, 0)
	ghost_normal.border_color = Color(0.168627, 0.168627, 0.211765)
	ghost_normal.set_border_width_all(2)
	ghost_normal.set_content_margin_all(12)

	ghost_hover = StyleBoxFlat.new()
	ghost_hover.bg_color = Color(LIME.r, LIME.g, LIME.b, 0.12)
	ghost_hover.border_color = LIME
	ghost_hover.set_border_width_all(2)
	ghost_hover.set_content_margin_all(12)

	ghost_pressed = StyleBoxFlat.new()
	ghost_pressed.bg_color = Color(LIME.r, LIME.g, LIME.b, 0.2)
	ghost_pressed.border_color = LIME
	ghost_pressed.set_border_width_all(2)
	ghost_pressed.set_content_margin_all(12)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	var stored: String = String(cfg.get_value("game", "difficulty", "normal"))
	if DIFFICULTY.has(stored):
		difficulty = stored


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "difficulty", difficulty)
	cfg.save(SETTINGS_PATH)


func _set_difficulty(key: String) -> void:
	if not DIFFICULTY.has(key):
		return
	difficulty = key
	_paint_difficulty()
	_save_settings()


func _paint_difficulty() -> void:
	var buttons: Dictionary = {"facil": diff_facil, "normal": diff_normal, "duro": diff_duro}
	for key in buttons:
		var button: Button = buttons[key]
		if key == difficulty:
			for slot in ["normal", "hover", "pressed"]:
				button.remove_theme_stylebox_override(slot)
			button.remove_theme_color_override("font_color")
			button.remove_theme_color_override("font_hover_color")
			button.remove_theme_color_override("font_pressed_color")
			button.remove_theme_color_override("font_focus_color")
		else:
			button.add_theme_stylebox_override("normal", ghost_normal)
			button.add_theme_stylebox_override("hover", ghost_hover)
			button.add_theme_stylebox_override("pressed", ghost_pressed)
			button.add_theme_color_override("font_color", INK)
			button.add_theme_color_override("font_hover_color", LIME)
			button.add_theme_color_override("font_pressed_color", LIME)
			button.add_theme_color_override("font_focus_color", INK)
	var conf: Dictionary = DIFFICULTY[difficulty]
	diff_hint.text = String(conf.hint)


func _on_support() -> void:
	if SUPPORT_URL.is_empty():
		support_line.text = "Pronto: aquí irá el enlace de apoyo del creador."
		var tw: Tween = create_tween()
		tw.tween_interval(3.0)
		tw.tween_callback(func() -> void:
			support_line.text = "Si te sacó una risa, invítale un café al que lo hizo.")
		return
	OS.shell_open(SUPPORT_URL)


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
	confirm_layer.visible = false
	_next_round()


func _next_round() -> void:
	if deck.is_empty():
		deck = Contexts.LIST.duplicate(true)
		deck.shuffle()
	current = deck.pop_back()
	round_number += 1

	var conf: Dictionary = DIFFICULTY[difficulty]
	word_limit = maxi(MIN_WORDS, int(current.words) + int(conf.words))
	time_total = maxf(MIN_SECONDS, float(current.seconds) * float(conf.time) - float(round_number - 1) * float(conf.shrink))
	time_left = time_total

	title_label.text = String(current.title).to_upper()
	subtitle_label.text = String(current.subtitle)
	round_label.text = "RONDA %02d" % round_number
	word_limit_label.text = "MÁX %d" % word_limit

	restriction = _pick_restriction()
	include_was_met = false
	exclude_was_used = false

	excuse_input.text = ""
	excuse_input.editable = true
	enforcing_limit = false
	_paint_counter(0)
	_refresh_chips()

	pips_row.max_lives = MAX_LIVES
	pips_row.lives = lives_left

	seg_bar.ratio = 1.0
	seg_bar.fill_color = LIME
	timer_value.text = str(int(ceil(time_total)))
	timer_value.add_theme_color_override("font_color", LIME)
	last_tick_second = -1

	_show_screen(round_screen)
	running = true
	set_process(true)
	audio.play("start", 1.3, -13.0)
	audio.start_bed()
	await get_tree().process_frame
	if excuse_input.is_inside_tree():
		excuse_input.grab_focus()


func _pick_restriction() -> Dictionary:
	var picked: Dictionary = {"include": "", "exclude": ""}
	var conf: Dictionary = DIFFICULTY[difficulty]
	if round_number < int(conf.restrict_from):
		return picked

	var include_pool: Array = current.get("include", [])
	var exclude_pool: Array = current.get("exclude", [])
	var both: bool = round_number >= int(conf.both_from)

	if both and not include_pool.is_empty() and not exclude_pool.is_empty():
		picked.include = String(include_pool.pick_random())
		picked.exclude = String(exclude_pool.pick_random())
		return picked

	if randf() < 0.5 and not include_pool.is_empty():
		picked.include = String(include_pool.pick_random())
	elif not exclude_pool.is_empty():
		picked.exclude = String(exclude_pool.pick_random())
	else:
		picked.include = String(include_pool.pick_random()) if not include_pool.is_empty() else ""
	return picked


func _refresh_chips() -> void:
	var include_word: String = String(restriction.get("include", ""))
	var exclude_word: String = String(restriction.get("exclude", ""))
	var written: String = excuse_input.text

	if include_word.is_empty() and exclude_word.is_empty():
		chip_include.visible = true
		chip_exclude.visible = false
		chip_include_label.text = "SIN RESTRICCIONES"
		_style_chip(chip_include, chip_include_label, Color(0.168627, 0.168627, 0.211765), SURFACE, DIM)
		return

	chip_include.visible = not include_word.is_empty()
	chip_exclude.visible = not exclude_word.is_empty()

	if not include_word.is_empty():
		var met: bool = Scoring.uses_word(written, include_word)
		if met != include_was_met:
			include_was_met = met
			if met:
				audio.play("click", 1.9, -18.0)
		chip_include_label.text = ("✓ USA «%s»" if met else "USA «%s»") % include_word.to_upper()
		if met:
			_style_chip(chip_include, chip_include_label, CYAN, CYAN, NIGHT)
		else:
			_style_chip(chip_include, chip_include_label, CYAN, Color(0.039216, 0.101961, 0.12549), CYAN)

	if not exclude_word.is_empty():
		var used: bool = Scoring.uses_word(written, exclude_word)
		if used != exclude_was_used:
			exclude_was_used = used
			if used:
				audio.play("fail", 0.55, -15.0)
		chip_exclude_label.text = ("✗ USASTE «%s»" if used else "NO USES «%s»") % exclude_word.to_upper()
		if used:
			_style_chip(chip_exclude, chip_exclude_label, MAGENTA, MAGENTA, NIGHT)
		else:
			_style_chip(chip_exclude, chip_exclude_label, MAGENTA, Color(0.12549, 0.039216, 0.070588), MAGENTA)


func _style_chip(chip: PanelContainer, label: Label, border: Color, fill: Color, text_color: Color) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = border
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	chip.add_theme_stylebox_override("panel", sb)
	label.add_theme_color_override("font_color", text_color)


func _paint_timer() -> void:
	var ratio: float = clampf(time_left / time_total, 0.0, 1.0)
	seg_bar.ratio = ratio
	timer_value.text = str(int(ceil(time_left)))
	var urgent: bool = time_left <= 8.0
	seg_bar.fill_color = MAGENTA if urgent else LIME
	timer_value.add_theme_color_override("font_color", MAGENTA if urgent else LIME)
	audio.set_tension(ratio)
	var seconds: int = int(ceil(time_left))
	if seconds <= 10 and seconds > 0 and seconds != last_tick_second:
		last_tick_second = seconds
		audio.play("tick", 1.3 + float(10 - seconds) * 0.05, -14.0)


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
	_refresh_chips()


func _paint_counter(words: int) -> void:
	word_count_label.text = "%d / %d" % [words, word_limit]
	word_count_label.add_theme_color_override("font_color", MAGENTA if words >= word_limit else MUTED)


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
	audio.stop_bed()
	audio.play("submit", 0.92, -7.0)
	last_result = Scoring.evaluate(
		excuse_input.text,
		word_limit,
		String(restriction.get("include", "")),
		String(restriction.get("exclude", ""))
	)

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
	var accent: Color = LIME if passed else MAGENTA

	stamp_label.text = "PASASTE" if passed else "NO CUELAS"
	stamp_label.add_theme_color_override("font_color", accent)
	var sb := StyleBoxFlat.new()
	sb.bg_color = SURFACE
	sb.border_color = accent
	sb.set_border_width_all(3)
	sb.content_margin_left = 0
	sb.content_margin_right = 0
	stamp.add_theme_stylebox_override("panel", sb)

	score_label.text = str(score)
	score_label.add_theme_color_override("font_color", accent)
	result_round_label.text = "RONDA %02d" % round_number

	var notes: Array = last_result.notes
	var lines: Array = []
	for i in mini(2, notes.size()):
		lines.append(String(notes[i]))
	reasons_label.text = "\n".join(PackedStringArray(lines))

	result_pips.max_lives = MAX_LIVES
	result_pips.lives = lives_left
	match lives_left:
		3:
			result_lives_caption.text = "TIENES 3 VIDAS"
		2:
			result_lives_caption.text = "TE QUEDAN 2 VIDAS"
		1:
			result_lives_caption.text = "ÚLTIMA VIDA"
		_:
			result_lives_caption.text = "SIN VIDAS"

	if not passed and lives_left <= 0:
		next_button.text = "CONTINUAR"
	elif passed:
		next_button.text = "SIGUIENTE"
	else:
		next_button.text = "OTRA COARTADA"

	if passed:
		audio.play("pass", 1.28, -10.0)
		get_tree().create_timer(0.09).timeout.connect(_play_pass_tail)
	else:
		audio.play("fail", 0.95, -6.0)


func _play_pass_tail() -> void:
	audio.play("pass", 1.6, -13.0)


func _on_next() -> void:
	if lives_left <= 0:
		_paint_over()
		_show_screen(over_screen)
	else:
		_next_round()


func _paint_over() -> void:
	over_title.text = "SE ACABÓ"
	over_sub.text = "Nadie te creyó tres veces."
	audio.play("over", 0.55, -6.0)
	get_tree().create_timer(0.26).timeout.connect(_play_over_tail)
	var stats: Array = []
	stats.append("PASASTE %d DE %d RONDAS" % [rounds_passed, round_number])
	if best_score > 0:
		stats.append("MEJOR EXCUSA: %d PTS" % best_score)
	stats.append("DIFICULTAD: %s" % String(DIFFICULTY[difficulty].label))
	over_stats.text = "\n".join(PackedStringArray(stats))


func _play_over_tail() -> void:
	audio.play("over", 0.42, -8.0)


func _ask_abandon() -> void:
	if not running:
		return
	running = false
	audio.stop_bed()
	confirm_layer.visible = true
	confirm_yes.grab_focus()


func _cancel_abandon() -> void:
	confirm_layer.visible = false
	if round_screen.visible:
		running = true
		audio.start_bed()
		excuse_input.grab_focus()


func _confirm_abandon() -> void:
	confirm_layer.visible = false
	_go_home()


func _go_home() -> void:
	running = false
	set_process(false)
	audio.stop_bed()
	_show_screen(home)


func _show_screen(target: Control) -> void:
	for screen in [home, round_screen, result_screen, over_screen]:
		screen.visible = (screen == target)
	if target == home:
		tip_label.text = String(TIPS.pick_random())
	target.modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(target, "modulate:a", 1.0, 0.16)
