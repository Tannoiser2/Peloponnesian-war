## Fregio a greca (meandro), come sui vasi attici.
class_name Greca
extends Control

var colore := Color("a5451f")

func _draw() -> void:
	var h := size.y
	var passo := h * 1.5
	var sp: float = max(2.0, h / 7.0)
	var n := int(size.x / passo)
	if n <= 0:
		return
	var x0 := (size.x - n * passo) / 2.0
	draw_line(Vector2(x0, sp / 2.0), Vector2(x0 + n * passo, sp / 2.0), colore, sp)
	draw_line(Vector2(x0, h - sp / 2.0), Vector2(x0 + n * passo, h - sp / 2.0), colore, sp)
	for i in n:
		var x := x0 + i * passo
		var a := h * 0.28
		var punti := PackedVector2Array([
			Vector2(x + passo * 0.15, h - sp), Vector2(x + passo * 0.15, a), Vector2(x + passo * 0.85, a),
			Vector2(x + passo * 0.85, h - a), Vector2(x + passo * 0.45, h - a), Vector2(x + passo * 0.45, h * 0.52)])
		draw_polyline(punti, colore, sp)
