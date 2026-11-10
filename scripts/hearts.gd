extends Control

const FILLED := Color(0.937255, 0.482353, 0.423529, 1)
const EMPTY := Color(0.87, 0.851, 0.804, 1)

var lives: int = 3:
	set(value):
		lives = value
		queue_redraw()

var max_lives: int = 3:
	set(value):
		max_lives = value
		queue_redraw()


func _draw() -> void:
	var h: float = size.y
	var gap: float = h * 0.3
	var w: float = h
	var total: float = float(max_lives) * w + float(max_lives - 1) * gap
	var x0: float = maxf(0.0, (size.x - total) * 0.5)
	for i in max_lives:
		var color: Color = FILLED if i < lives else EMPTY
		_draw_heart(Vector2(x0 + float(i) * (w + gap), 0.0), w, h, color)


func _draw_heart(origin: Vector2, w: float, h: float, color: Color) -> void:
	var points := PackedVector2Array()
	var steps: int = 44
	for k in steps:
		var t: float = TAU * float(k) / float(steps)
		var x: float = 16.0 * pow(sin(t), 3)
		var y: float = 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
		points.append(Vector2(
			origin.x + (x / 32.0 + 0.5) * w,
			origin.y + (12.0 - y) / 29.0 * h
		))
	draw_colored_polygon(points, color)
