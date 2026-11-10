extends Control

const SEGMENTS := 20
const GAP := 4.0

var ratio: float = 1.0:
	set(value):
		ratio = value
		queue_redraw()

var fill_color: Color = Color(0.796078, 1.0, 0.239216, 1):
	set(value):
		fill_color = value
		queue_redraw()

var empty_color: Color = Color(0.129412, 0.129412, 0.156863, 1):
	set(value):
		empty_color = value
		queue_redraw()


func _draw() -> void:
	var w: float = (size.x - GAP * float(SEGMENTS - 1)) / float(SEGMENTS)
	var filled: int = int(ceil(clampf(ratio, 0.0, 1.0) * float(SEGMENTS)))
	for i in SEGMENTS:
		var rect := Rect2(Vector2(float(i) * (w + GAP), 0.0), Vector2(w, size.y))
		draw_rect(rect, fill_color if i < filled else empty_color)
