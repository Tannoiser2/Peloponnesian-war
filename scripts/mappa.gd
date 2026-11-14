## La mappa: disegna il tabellone originale con pedine e segnalini, e gestisce
## spostamento e zoom con mouse, rotella e tocco (un dito trascina, due dita pizzicano).
class_name Mappa
extends Control

signal spazio_toccato(id: String)

const R_SPAZIO := 52.0
const LATO_PEDINA := 46.0

var partita: Partita
var tex_mappa: Texture2D
var tex := {}
var font_num: Font
var font_testo: Font

var zoom := 0.5
var origine := Vector2.ZERO          # punto della mappa nell'angolo in alto a sinistra
var selezionato := ""
var evidenziati := {}                # id -> Color (spazi scelti o proponibili)
var obiettivo := ""
var mostra_zoi := ""
var scena_centro := ""             # per le illustrazioni del tutorial: spazio da inquadrare
var scena_zoom := 0.0

var _tocchi := {}
var _premuto := false
var _trascinato := 0.0
var _ultimo_mouse := Vector2.ZERO
var _dist_pizzico := 0.0
var _tempo := 0.0
var _ultimo_tocco := -10.0     # per ignorare il mouse emulato dal tocco

func _ready() -> void:
	Dati.carica()
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	tex_mappa = load("res://assets/mappa/mappa.webp")
	for k in Dati.CHIAVI:
		if k != "SG":
			tex[k] = load("res://assets/pedine/fig_%s.png" % k)
	tex["SG"] = tex["SH"]
	for n in ["rivolta", "devastato", "assedio", "obiettivo", "iloti"]:
		tex[n] = load("res://assets/pedine/%s.png" % n)
	for c in Dati.CAPI:
		tex["capo_" + c] = load("res://assets/pedine/capo_%s.png" % c)
	font_num = load("res://assets/font/Titoli.ttf")
	font_testo = load("res://assets/font/TestoGrassetto.ttf")
	resized.connect(_ridimensionata)
	call_deferred("centra_tutto")

func _process(dt: float) -> void:
	_tempo += dt
	if obiettivo != "" or not evidenziati.is_empty() or (partita != null and not partita.s.percorso.is_empty()):
		queue_redraw()

func zoom_minimo() -> float:
	return max(size.x / Dati.larghezza, size.y / Dati.altezza) * 0.82

func _ridimensionata() -> void:
	if scena_centro != "":
		centra_tutto()
	else:
		_limita()

func centra_tutto() -> void:
	if scena_centro != "":
		zoom = scena_zoom
		centra_su(pos(scena_centro))
		return
	zoom = max(zoom_minimo(), min(size.x / 2100.0, 1.2))
	centra_su(Vector2(2100, 1550))

## Porta uno spazio al centro della parte di schermo non coperta dai pannelli.
func centra_nel_libero(id: String, sinistra: float, destra: float) -> void:
	var libero := Vector2((sinistra + size.x - destra) / 2.0, size.y * 0.45)
	origine = pos(id) - libero / zoom
	_limita()

func centra_su(p: Vector2) -> void:
	origine = p - size / (2.0 * zoom)
	_limita()

func centra_spazio(id: String) -> void:
	if Dati.spazi.has(id):
		centra_su(pos(id))

func pos(id: String) -> Vector2:
	return Vector2(Dati.spazi[id].x, Dati.spazi[id].y)

func _limita() -> void:
	zoom = clampf(zoom, zoom_minimo(), 2.2)
	var vista := size / zoom
	var m := 120.0
	origine.x = clampf(origine.x, -m, max(-m, Dati.larghezza + m - vista.x))
	origine.y = clampf(origine.y, -m, max(-m, Dati.altezza + m - vista.y))
	queue_redraw()

func a_schermo(p: Vector2) -> Vector2:
	return (p - origine) * zoom

func a_mappa(p: Vector2) -> Vector2:
	return p / zoom + origine

func _zoom_su(punto_schermo: Vector2, fattore: float) -> void:
	var prima := a_mappa(punto_schermo)
	zoom = clampf(zoom * fattore, zoom_minimo(), 2.2)
	origine = prima - punto_schermo / zoom
	_limita()

# ------------------------------------------------------------------ ingresso
func _gui_input(ev: InputEvent) -> void:
	if ev is InputEventScreenTouch or ev is InputEventScreenDrag:
		_ultimo_tocco = _tempo
	elif (ev is InputEventMouseButton or ev is InputEventMouseMotion) and (not _tocchi.is_empty() or _tempo - _ultimo_tocco < 0.6):
		accept_event()
		return
	if ev is InputEventScreenTouch:
		if ev.pressed:
			_tocchi[ev.index] = ev.position
			if _tocchi.size() == 1:
				_trascinato = 0.0
			elif _tocchi.size() == 2:
				_dist_pizzico = _distanza_tocchi()
				_trascinato = 999.0
		else:
			if _tocchi.size() == 1 and _trascinato < 14.0:
				_tocco_su(ev.position)
			_tocchi.erase(ev.index)
		accept_event()
	elif ev is InputEventScreenDrag:
		if not _tocchi.has(ev.index):
			return
		if _tocchi.size() == 1:
			_trascinato += ev.relative.length()
			origine -= ev.relative / zoom
			_tocchi[ev.index] = ev.position
			_limita()
		elif _tocchi.size() >= 2:
			var centro_prima := _centro_tocchi()
			_tocchi[ev.index] = ev.position
			var centro := _centro_tocchi()
			var d := _distanza_tocchi()
			origine -= (centro - centro_prima) / zoom
			if _dist_pizzico > 10.0 and d > 10.0:
				_zoom_su(centro, d / _dist_pizzico)
			_dist_pizzico = d
			_limita()
		accept_event()
	elif ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP and ev.pressed:
			_zoom_su(ev.position, 1.12)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN and ev.pressed:
			_zoom_su(ev.position, 1.0 / 1.12)
		elif ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				_premuto = true
				_trascinato = 0.0
				_ultimo_mouse = ev.position
			else:
				if _premuto and _trascinato < 8.0:
					_tocco_su(ev.position)
				_premuto = false
		accept_event()
	elif ev is InputEventMouseMotion:
		if _premuto:
			_trascinato += ev.relative.length()
			origine -= ev.relative / zoom
			_limita()
	elif ev is InputEventMagnifyGesture:
		_zoom_su(ev.position, ev.factor)
	elif ev is InputEventPanGesture:
		origine += ev.delta * 12.0 / zoom
		_limita()

func _centro_tocchi() -> Vector2:
	var c := Vector2.ZERO
	for i in _tocchi:
		c += _tocchi[i]
	return c / max(1, _tocchi.size())

func _distanza_tocchi() -> float:
	var v := _tocchi.values()
	return (v[0] as Vector2).distance_to(v[1]) if v.size() >= 2 else 0.0

func spazio_a(p_schermo: Vector2) -> String:
	var p := a_mappa(p_schermo)
	var meglio := ""
	var dm := 74.0
	for id in Dati.spazi:
		var d := p.distance_to(pos(id))
		if d < dm:
			dm = d
			meglio = id
	return meglio

func _tocco_su(p: Vector2) -> void:
	var id := spazio_a(p)
	if id != "":
		spazio_toccato.emit(id)

# ------------------------------------------------------------------ disegno
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.10, 0.16, 0.22))
	draw_set_transform(-origine * zoom, 0.0, Vector2(zoom, zoom))
	draw_texture_rect(tex_mappa, Rect2(0, 0, Dati.larghezza, Dati.altezza), false)
	if partita == null:
		return
	var s: Dictionary = partita.s
	var battito := 0.5 + 0.5 * sin(_tempo * 4.0)
	# percorso dell'ultima spedizione
	var pr: Array = s.percorso
	if pr.size() >= 2:
		for i in pr.size() - 1:
			var a := pos(pr[i])
			var b := pos(pr[i + 1])
			draw_line(a, b, Color(0.1, 0.05, 0.02, 0.55), 22.0, true)
			draw_line(a, b, Color(1.0, 0.86, 0.35, 0.9), 12.0, true)
		var ultimo := pos(pr[pr.size() - 1])
		draw_circle(ultimo, 20.0, Color(1.0, 0.86, 0.35, 0.9))
	if mostra_zoi != "":
		for lato in ["A", "S"]:
			if partita.presenti(mostra_zoi, lato) > 0:
				var z := partita.zoi_da(mostra_zoi, lato, false)
				for id in z:
					draw_arc(pos(id), R_SPAZIO + 20.0, 0, TAU, 40, Color(0.2, 0.6, 1.0, 0.75) if lato == "A" else Color(1.0, 0.25, 0.2, 0.75), 7.0, true)
	for id in evidenziati:
		var c: Color = evidenziati[id]
		draw_arc(pos(id), R_SPAZIO + 8.0 + 6.0 * battito, 0, TAU, 40, c, 9.0, true)
	if selezionato != "":
		draw_arc(pos(selezionato), R_SPAZIO + 6.0, 0, TAU, 48, Color(1, 1, 1, 0.95), 8.0, true)
	var ob: String = obiettivo if obiettivo != "" else s.ultimo_ob
	if ob != "" and Dati.spazi.has(ob):
		var po := pos(ob)
		draw_arc(po, R_SPAZIO + 18.0 + 8.0 * battito, 0, TAU, 48, Color(0.75, 0.08, 0.08, 0.95), 10.0, true)
		draw_texture_rect(tex["obiettivo"], Rect2(po + Vector2(-27, -R_SPAZIO - 70), Vector2(54, 54)), false)
	for id in s.sp:
		_disegna_spazio(id, s.sp[id])
	for c in s.capi:
		if s.capi[c].stato == "consigliere":
			var pc := pos(s.capi[c].pos) + Vector2(R_SPAZIO + 6, -R_SPAZIO - 10)
			draw_texture_rect(tex["capo_" + c], Rect2(pc, Vector2(50, 50)), false)
	if s.iloti:
		draw_texture_rect(tex["iloti"], Rect2(pos("Sparta") + Vector2(-140, 20), Vector2(64, 64)), false)

func _disegna_spazio(id: String, x: Dictionary) -> void:
	var p := pos(id)
	var seg := []
	if x.riv:
		seg.append("rivolta")
	if x.dev:
		seg.append("devastato")
	if x.ass != "":
		seg.append("assedio")
	for i in seg.size():
		draw_texture_rect(tex[seg[i]], Rect2(p + Vector2(R_SPAZIO - 22 + i * 40, -R_SPAZIO - 14), Vector2(40, 40)), false)
	for lato in ["A", "S"]:
		var gruppi := []
		for t in ["H", "C", "N"]:
			var n := 0
			var fig := ""
			var att := 0
			for k in x.u:
				if Dati.lato_di(k) == lato and Dati.tipo_di(k) == t:
					n += x.u[k]
					att += x.a.get(k, 0)
					if fig == "" or not Dati.alleata(k):
						fig = k
			if n > 0:
				gruppi.append([fig, n, att >= n])
		var larg := gruppi.size() * (LATO_PEDINA + 4)
		var x0 := (-larg - 3.0) if lato == "A" else 3.0
		if presenti_due(x):
			x0 = (-larg - 3.0) if lato == "A" else 3.0
		elif not gruppi.is_empty():
			x0 = -larg / 2.0
		for i in gruppi.size():
			_pedina(p + Vector2(x0 + i * (LATO_PEDINA + 4), R_SPAZIO - 30), gruppi[i][0], gruppi[i][1], gruppi[i][2])
	var capi_qui := []
	for c in partita.s.capi:
		if partita.s.capi[c].stato == "mappa" and partita.s.capi[c].pos == id:
			capi_qui.append(c)
	for i in capi_qui.size():
		var pc := p + Vector2(-R_SPAZIO - 34 + i * 50, -R_SPAZIO - 22)
		draw_rect(Rect2(pc + Vector2(3, 3), Vector2(50, 50)), Color(0, 0, 0, 0.45))
		draw_texture_rect(tex["capo_" + capi_qui[i]], Rect2(pc, Vector2(50, 50)), false)
		draw_rect(Rect2(pc, Vector2(50, 50)), Color(0.08, 0.05, 0.03), false, 2.0)

func presenti_due(x: Dictionary) -> bool:
	var a := false
	var b := false
	for k in x.u:
		if Dati.lato_di(k) == "A":
			a = true
		else:
			b = true
	return a and b

func _pedina(p: Vector2, k: String, n: int, attivata: bool) -> void:
	var r := Rect2(p, Vector2(LATO_PEDINA, LATO_PEDINA))
	draw_rect(Rect2(p + Vector2(3, 3), r.size), Color(0, 0, 0, 0.45))
	var base := Color(Dati.colori.get("SH" if k == "SG" else k, "#888888"))
	draw_rect(r, base)
	var t: Texture2D = tex[k]
	if Dati.tipo_di(k) == "N":
		draw_texture_rect(t, Rect2(p + Vector2(0, 3), Vector2(LATO_PEDINA, LATO_PEDINA * 0.5)), false)
	else:
		draw_texture_rect(t, Rect2(p + Vector2(LATO_PEDINA * 0.26, 0), Vector2(LATO_PEDINA * 0.72, LATO_PEDINA)), false)
	if attivata:
		draw_rect(r, Color(0, 0, 0, 0.28))
	draw_rect(r, Color(0.08, 0.05, 0.03), false, 2.0)
	var testo := str(n)
	var c := p + Vector2(11, LATO_PEDINA - 11)
	draw_circle(c, 12.0, Color(0.08, 0.05, 0.03))
	draw_circle(c, 10.0, Color(0.97, 0.93, 0.82))
	var ts := font_num.get_string_size(testo, HORIZONTAL_ALIGNMENT_CENTER, -1, 15)
	draw_string(font_num, c + Vector2(-ts.x / 2.0, 5.5), testo, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.08, 0.05, 0.03))
