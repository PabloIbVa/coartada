extends Control

const FILLED := Color(0.796078, 1.0, 0.239216, 1)
const EMPTY := Color(0.098039, 0.098039, 0.121569, 1)
const LINE := Color(0.243137, 0.243137, 0.286275, 1)

var lives: int = 3:
	set(value):
		lives = value
		queue_redraw()

var max_lives: int = 3:
	set(value):
		max_lives = value
		queue_redraw()

@export var align_mode: int = 1:
	set(value):
		align_mode = value
		queue_redraw()


func _draw() -> void:
	var h: float = size.y
	var gap: float = 7.0
	var w: float = h
	var total: float = float(max_lives) * w + float(max_lives - 1) * gap
	var x0: float = 0.0
	if align_mode == 2:
		x0 = maxf(0.0, size.x - total)
	elif align_mode == 1:
		x0 = maxf(0.0, (size.x - total) * 0.5)
	for i in max_lives:
		var rect := Rect2(Vector2(x0 + float(i) * (w + gap), 0.0), Vector2(w, h))
		draw_rect(rect, FILLED if i < lives else EMPTY)
		draw_rect(rect, LINE, false, 2.0)
