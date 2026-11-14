## Prova del tocco sulla mappa (trascinare, pizzicare, toccare uno spazio) e dei pulsanti:
##   PW_AVVIO=gioco xvfb-run -a godot --path . --script res://tests/tocco.gd
extends SceneTree

var n := 0
var main
var errori := 0
var zoom0 := 0.0
var orig0 := Vector2.ZERO

func _initialize() -> void:
	root.size = Vector2i(1440, 900)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)

func tocco(i: int, p: Vector2, giu: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = i
	e.position = p
	e.pressed = giu
	root.push_input(e)

func trascina(i: int, da: Vector2, a: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = i
	e.position = a
	e.relative = a - da
	root.push_input(e)

func vero(c: bool, cosa: String) -> void:
	if not c:
		errori += 1
		printerr("FALLITA: ", cosa)
	else:
		print("ok: ", cosa)

func _process(_d: float) -> bool:
	n += 1
	var m: Mappa = main.mappa
	if n == 30:
		zoom0 = m.zoom
		orig0 = m.origine
		tocco(0, Vector2(500, 500), true)
	if n == 31:
		trascina(0, Vector2(500, 500), Vector2(440, 470))
	if n == 32:
		tocco(0, Vector2(440, 470), false)
	if n == 34:
		vero(m.origine.distance_to(orig0) > 20.0, "un dito trascina la mappa")
		orig0 = m.origine
		tocco(0, Vector2(500, 500), true)
		tocco(1, Vector2(600, 500), true)
	if n == 35:
		trascina(1, Vector2(600, 500), Vector2(700, 500))
	if n == 36:
		tocco(0, Vector2(500, 500), false)
		tocco(1, Vector2(700, 500), false)
	if n == 38:
		vero(m.zoom > zoom0 * 1.3, "due dita ingrandiscono (zoom da %.2f a %.2f)" % [zoom0, m.zoom])
		var p := m.a_schermo(m.pos("Megara")) + m.global_position
		m.centra_spazio("Megara")
	if n == 40:
		var p2 := m.a_schermo(m.pos("Megara")) + m.global_position
		tocco(0, p2, true)
	if n == 41:
		var p3 := m.a_schermo(m.pos("Megara")) + m.global_position
		tocco(0, p3, false)
	if n == 43:
		vero(m.selezionato == "Megara", "un tocco seleziona lo spazio (selezionato: %s)" % m.selezionato)
		print("tocco: ", "tutto bene" if errori == 0 else "%d prove fallite" % errori)
		return true
	return false
