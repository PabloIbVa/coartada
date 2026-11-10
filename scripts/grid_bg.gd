extends Control

const SPACING := 54.0
const LINE := Color(1, 1, 1, 0.035)
const LIME := Color(0.796078, 1.0, 0.239216, 0.45)
const CYAN := Color(0.223529, 0.882353, 1.0, 0.45)


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var x: float = SPACING
	while x < w:
		draw_line(Vector2(x, 0.0), Vector2(x, h), LINE, 1.0)
		x += SPACING
	var y: float = SPACING
	while y < h:
		draw_line(Vector2(0.0, y), Vector2(w, y), LINE, 1.0)
		y += SPACING

	var arm: float = 38.0
	draw_line(Vector2(16.0, 16.0), Vector2(16.0 + arm, 16.0), LIME, 2.0)
	draw_line(Vector2(16.0, 16.0), Vector2(16.0, 16.0 + arm), LIME, 2.0)
	draw_line(Vector2(w - 16.0, h - 16.0), Vector2(w - 16.0 - arm, h - 16.0), CYAN, 2.0)
	draw_line(Vector2(w - 16.0, h - 16.0), Vector2(w - 16.0, h - 16.0 - arm), CYAN, 2.0)
