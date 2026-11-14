## Interfaccia di Peloponnesian War: menu, mappa, pannelli dei due contendenti, pannello delle azioni,
## diario, tabelle, regole, salvataggi sul dispositivo e su Firebase.
extends Control

const PERGAMENA := Color("efe3c4")
const PERGAMENA_SCURA := Color("dfcfa6")
const INCHIOSTRO := Color("2a1d12")
const TERRACOTTA := Color("a5451f")
const TERRACOTTA_CHIARA := Color("c9683a")
const ORO := Color("e2bd62")
const NERO := Color("17110c")
const VERDE := Color("3f6b2b")
const ROSSO := Color("9c1f24")
const COLORE_LATO := {"A": Color("3f6b2b"), "S": Color("9c1f24")}
const SALVATAGGIO := "user://pw_partita.json"
const FASI := [["politica", "Politica"], ["strategia", "Strategia"], ["operazioni", "Operazioni"], ["combattimento", "Combattimento"], ["rivolte", "Rivolte"], ["amministrazione", "Amministrazione"], ["tregua", "Tregua e resa"]]

var f_titoli: Font
var f_testo: Font
var f_grassetto: Font
var f_corsivo: Font
var f_decorato: Font

var partita: Partita
var net: Node
var bot := Bot.new()
var codice := ""
var mappa: Mappa
var schermo_gioco: Control
var schermo_menu: Control
var barra_titolo: Label
var barra_comando: Label
var barra_pv: Label
var chip_fasi := {}
var pannelli_lato := {}
var azione: VBoxContainer
var azione_cornice: PanelContainer
var info: VBoxContainer
var info_cornice: PanelContainer
var velo: Control
var stato_rete: Label

# scelte in corso del giocatore
var ob_scelto := ""
var rib_scelta := false
var capo_scelto := ""
var raduno_spazio := ""
var raduno_q := {}
var costruzione_q := {}
var _salvataggio_in_corso := false
var _da_salvare := false

func _ready() -> void:
	Dati.carica()
	f_titoli = load("res://assets/font/Titoli.ttf")
	f_testo = load("res://assets/font/Testo.ttf")
	f_grassetto = load("res://assets/font/TestoGrassetto.ttf")
	f_corsivo = load("res://assets/font/Corsivo.ttf")
	f_decorato = load("res://assets/font/Decorato.ttf")
	theme = _tema()
	net = load("res://scripts/net.gd").new()
	add_child(net)
	_costruisci_menu()
	var auto := OS.get_environment("PW_AVVIO")
	if auto != "":
		call_deferred("_avvio_prova", auto)

# ------------------------------------------------------------------ tema
func _scatola(sfondo: Color, bordo: Color, spessore: int = 2, raggio: int = 6, margine: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = sfondo
	sb.border_color = bordo
	sb.set_border_width_all(spessore)
	sb.set_corner_radius_all(raggio)
	sb.set_content_margin_all(margine)
	return sb

func _tema() -> Theme:
	var t := Theme.new()
	t.default_font = f_testo
	t.default_font_size = 21
	t.set_color("font_color", "Label", INCHIOSTRO)
	t.set_stylebox("panel", "PanelContainer", _scatola(PERGAMENA, TERRACOTTA, 3, 8, 14))
	for stato in ["normal", "hover", "pressed", "disabled", "focus"]:
		var c := TERRACOTTA
		if stato == "hover":
			c = TERRACOTTA_CHIARA
		elif stato == "pressed":
			c = Color("7d3214")
		elif stato == "disabled":
			c = Color("9a8f7c")
		var sb := _scatola(c, NERO, 2, 6, 10)
		sb.content_margin_left = 16
		sb.content_margin_right = 16
		if stato == "focus":
			sb = _scatola(Color(0, 0, 0, 0), ORO, 2, 6, 10)
		t.set_stylebox(stato, "Button", sb)
	t.set_font("font", "Button", f_titoli)
	t.set_font_size("font_size", "Button", 18)
	for nome in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(nome, "Button", PERGAMENA)
	t.set_color("font_disabled_color", "Button", Color("d8d0c0"))
	t.set_font("normal_font", "RichTextLabel", f_testo)
	t.set_font("bold_font", "RichTextLabel", f_grassetto)
	t.set_font("italics_font", "RichTextLabel", f_corsivo)
	t.set_font_size("normal_font_size", "RichTextLabel", 20)
	t.set_font_size("bold_font_size", "RichTextLabel", 20)
	t.set_font_size("italics_font_size", "RichTextLabel", 20)
	t.set_color("default_color", "RichTextLabel", INCHIOSTRO)
	t.set_stylebox("normal", "LineEdit", _scatola(Color("fbf5e2"), TERRACOTTA, 2, 4, 8))
	t.set_stylebox("focus", "LineEdit", _scatola(Color("fbf5e2"), ORO, 3, 4, 8))
	t.set_color("font_color", "LineEdit", INCHIOSTRO)
	t.set_color("caret_color", "LineEdit", INCHIOSTRO)
	t.set_font_size("font_size", "LineEdit", 24)
	t.set_color("font_color", "CheckBox", INCHIOSTRO)
	t.set_color("font_hover_color", "CheckBox", TERRACOTTA)
	t.set_color("font_pressed_color", "CheckBox", INCHIOSTRO)
	t.set_font("font", "CheckBox", f_grassetto)
	for stato in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
		t.set_stylebox(stato, "CheckBox", StyleBoxEmpty.new())
	var sv := _scatola(PERGAMENA_SCURA, PERGAMENA_SCURA, 0, 4, 0)
	sv.content_margin_left = 5
	sv.content_margin_right = 5
	t.set_stylebox("scroll", "VScrollBar", sv)
	t.set_stylebox("grabber", "VScrollBar", _scatola(TERRACOTTA, TERRACOTTA, 0, 4, 0))
	t.set_stylebox("grabber_highlight", "VScrollBar", _scatola(TERRACOTTA_CHIARA, TERRACOTTA, 0, 4, 0))
	t.set_stylebox("grabber_pressed", "VScrollBar", _scatola(TERRACOTTA_CHIARA, TERRACOTTA, 0, 4, 0))
	return t

func etichetta(testo: String, px: int = 21, colore: Color = INCHIOSTRO, font: Font = null, larghezza: float = 0.0) -> Label:
	var l := Label.new()
	l.text = Dati.eufonia(testo)
	l.add_theme_font_size_override("font_size", px)
	l.add_theme_color_override("font_color", colore)
	if font != null:
		l.add_theme_font_override("font", font)
	if larghezza > 0.0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = larghezza
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

func bottone(testo: String, azione_b: Callable, px: int = 18) -> Button:
	var b := Button.new()
	b.text = testo
	b.add_theme_font_size_override("font_size", px)
	b.custom_minimum_size = Vector2(0, 46)
	b.pressed.connect(azione_b)
	b.focus_mode = Control.FOCUS_NONE
	return b

func testo_ricco(bb: String, larghezza: float, altezza: float = 0.0) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.text = bb
	r.custom_minimum_size = Vector2(larghezza, altezza)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if altezza <= 0.0:
		r.fit_content = true
		r.scroll_active = false
	else:
		r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return r

func _svuota(c: Node) -> void:
	for x in c.get_children():
		c.remove_child(x)
		x.queue_free()

# ------------------------------------------------------------------ menu
func _costruisci_menu() -> void:
	if schermo_menu != null:
		schermo_menu.queue_free()
	schermo_menu = Control.new()
	schermo_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(schermo_menu)
	var sfondo := TextureRect.new()
	sfondo.texture = load("res://assets/mappa/mappa.webp")
	sfondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	sfondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sfondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	schermo_menu.add_child(sfondo)
	var ombra := ColorRect.new()
	ombra.color = Color(0.09, 0.06, 0.04, 0.62)
	ombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	schermo_menu.add_child(ombra)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	schermo_menu.add_child(centro)
	var cornice := PanelContainer.new()
	cornice.add_theme_stylebox_override("panel", _scatola(PERGAMENA, TERRACOTTA, 5, 10, 30))
	cornice.custom_minimum_size = Vector2(720, 0)
	centro.add_child(cornice)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	cornice.add_child(v)
	var g1 := Greca.new()
	g1.custom_minimum_size = Vector2(660, 22)
	v.add_child(g1)
	var t1 := etichetta("PELOPONNESIAN WAR", 50, TERRACOTTA, f_decorato)
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t1)
	var t2 := etichetta("La guerra del Peloponneso, 431-404 a.C.", 26, INCHIOSTRO, f_corsivo)
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t2)
	var t3 := etichetta("Solitario di Mark Herman (GMT Games). Atene contro Sparta: comandi una delle due leghe, il gioco guida l'altra, e la sorte può farti cambiare schieramento.", 20, INCHIOSTRO, null, 640)
	t3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t3)
	var g2 := Greca.new()
	g2.custom_minimum_size = Vector2(660, 22)
	v.add_child(g2)
	if FileAccess.file_exists(SALVATAGGIO):
		v.add_child(bottone("Continua la partita", _continua_partita, 22))
	v.add_child(bottone("Nuova campagna (10 turni)", _nuova.bind("campagna"), 22))
	v.add_child(bottone("Guerra archidamica (3 turni)", _nuova.bind("archidamo"), 22))
	var riga := HBoxContainer.new()
	riga.add_theme_constant_override("separation", 10)
	v.add_child(riga)
	var campo := LineEdit.new()
	campo.placeholder_text = "Codice della partita"
	campo.max_length = 6
	campo.custom_minimum_size = Vector2(300, 48)
	campo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(campo)
	var bc := bottone("Carica dal codice", func(): _carica_online(campo.text))
	bc.custom_minimum_size = Vector2(260, 48)
	riga.add_child(bc)
	stato_rete = etichetta("I salvataggi restano su questo dispositivo e, con il codice, anche online.", 18, Color("5b4a36"), f_corsivo, 640)
	stato_rete.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(stato_rete)
	v.add_child(bottone("Regole in breve", func(): _finestra_testo("Regole in breve", Aiuto.REGOLE)))
	var crediti := etichetta("Versione digitale per uso personale. Mappa e pedine: GMT Games, 2019.", 16, Color("5b4a36"), null, 640)
	crediti.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(crediti)

func _codice_nuovo() -> String:
	var lettere := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var c := ""
	for i in 6:
		c += lettere[randi() % lettere.length()]
	return c

func _nuova(scenario: String) -> void:
	partita = Partita.new()
	partita.nuova(scenario)
	codice = _codice_nuovo()
	_apri_gioco()
	_salva()

func _continua_partita() -> void:
	var d = JSON.parse_string(FileAccess.get_file_as_string(SALVATAGGIO))
	if not (d is Dictionary) or not d.has("stato"):
		stato_rete.text = "Il salvataggio su questo dispositivo non è leggibile."
		return
	partita = Partita.new()
	partita.importa(d.stato)
	codice = str(d.get("codice", _codice_nuovo()))
	_apri_gioco()

func _carica_online(c: String) -> void:
	c = c.strip_edges().to_upper()
	if c.length() != 6:
		stato_rete.text = "Il codice è di 6 caratteri."
		return
	stato_rete.text = "Cerco la partita %s..." % c
	var d = await net.carica_partita(c)
	if d == null or not d.has("stato"):
		if net.ultimo_errore.begins_with("errore 401"):
			stato_rete.text = "Firebase non ha ancora le regole per questo gioco: vanno incollate nella console (firebase/database.rules.json della ludoteca)."
		else:
			stato_rete.text = "Partita non trovata, o rete non raggiungibile."
		return
	partita = Partita.new()
	partita.importa(d.stato)
	codice = c
	_apri_gioco()
	_salva_locale()

# ------------------------------------------------------------------ salvataggi
func _dati_salvataggio() -> Dictionary:
	var s: Dictionary = partita.s
	return {"stato": partita.esporta(), "codice": codice, "nome": "%s, turno %d" % [Dati.NOME_LATO[s.lato_g], s.turno], "turno": s.turno, "aggiornata": int(Time.get_unix_time_from_system())}

func _salva_locale() -> void:
	var f := FileAccess.open(SALVATAGGIO, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(_dati_salvataggio()))
		f.close()

func _salva(forza: bool = false) -> void:
	_salva_locale()
	if _rete_negata and not forza:
		return
	_da_salvare = true
	if not _salvataggio_in_corso:
		_salva_online()

func _salva_online() -> void:
	_salvataggio_in_corso = true
	while _da_salvare:
		_da_salvare = false
		var ok: bool = await net.salva_partita(codice, _dati_salvataggio())
		_rete_esito = "online" if ok else ("locale" if net.offline else "non riuscito")
		if not ok and net.ultimo_errore.begins_with("errore 401"):
			_rete_negata = true      # mancano le regole: inutile riprovare a ogni mossa
		elif ok:
			_rete_negata = false
	_salvataggio_in_corso = false

var _rete_esito := ""
var _rete_negata := false

# ------------------------------------------------------------------ schermo di gioco
func _apri_gioco() -> void:
	if schermo_menu != null:
		schermo_menu.queue_free()
		schermo_menu = null
	if schermo_gioco != null:
		schermo_gioco.queue_free()
	schermo_gioco = Control.new()
	schermo_gioco.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(schermo_gioco)
	mappa = Mappa.new()
	mappa.partita = partita
	mappa.set_anchors_preset(Control.PRESET_FULL_RECT)
	mappa.offset_top = 96
	schermo_gioco.add_child(mappa)
	mappa.spazio_toccato.connect(_spazio_toccato)
	# barra in alto
	var barra := PanelContainer.new()
	barra.add_theme_stylebox_override("panel", _scatola(NERO, ORO, 0, 0, 6))
	barra.set_anchors_preset(Control.PRESET_TOP_WIDE)
	barra.custom_minimum_size = Vector2(0, 96)
	schermo_gioco.add_child(barra)
	var bv := VBoxContainer.new()
	bv.add_theme_constant_override("separation", 4)
	barra.add_child(bv)
	var r1 := HBoxContainer.new()
	r1.add_theme_constant_override("separation", 14)
	bv.add_child(r1)
	var civ := TextureRect.new()
	civ.texture = load("res://assets/pedine/civetta.png")
	civ.custom_minimum_size = Vector2(44, 44)
	civ.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	civ.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r1.add_child(civ)
	barra_titolo = etichetta("", 24, ORO, f_titoli)
	barra_titolo.custom_minimum_size = Vector2(300, 0)
	r1.add_child(barra_titolo)
	barra_comando = etichetta("", 20, PERGAMENA, f_grassetto)
	barra_comando.custom_minimum_size = Vector2(190, 0)
	r1.add_child(barra_comando)
	barra_pv = etichetta("", 19, ORO, f_titoli)
	barra_pv.custom_minimum_size = Vector2(200, 0)
	barra_pv.clip_text = true
	barra_pv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r1.add_child(barra_pv)
	for voce in [["Diario", _apri_diario], ["Tabelle", _apri_tabelle], ["Regole", func(): _finestra_testo("Regole in breve", Aiuto.REGOLE)], ["Salva", _apri_salva], ["Menu", _torna_menu]]:
		var b := bottone(voce[0], voce[1], 16)
		b.custom_minimum_size = Vector2(88, 42)
		r1.add_child(b)
	var r2 := HBoxContainer.new()
	r2.add_theme_constant_override("separation", 6)
	bv.add_child(r2)
	chip_fasi = {}
	for f in FASI:
		var c := Label.new()
		c.text = f[1]
		c.add_theme_font_override("font", f_titoli)
		c.add_theme_font_size_override("font_size", 15)
		c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		c.custom_minimum_size = Vector2(120, 30)
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r2.add_child(c)
		chip_fasi[f[0]] = c
	# pannelli dei due contendenti
	pannelli_lato = {}
	for lato in ["A", "S"]:
		var pc := PanelContainer.new()
		pc.add_theme_stylebox_override("panel", _scatola(Color(PERGAMENA, 0.95), COLORE_LATO[lato], 4, 8, 10))
		pc.custom_minimum_size = Vector2(290, 0)
		if lato == "A":
			pc.set_anchors_preset(Control.PRESET_TOP_LEFT)
			pc.position = Vector2(10, 106)
		else:
			pc.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			pc.offset_left = -300
			pc.offset_right = -10
			pc.offset_top = 106
			pc.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		schermo_gioco.add_child(pc)
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 3)
		pc.add_child(vb)
		pannelli_lato[lato] = vb
	# informazioni sullo spazio (in basso a sinistra)
	info_cornice = PanelContainer.new()
	info_cornice.add_theme_stylebox_override("panel", _scatola(Color(PERGAMENA, 0.96), TERRACOTTA, 3, 8, 12))
	info_cornice.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	info_cornice.custom_minimum_size = Vector2(400, 0)
	info_cornice.position = Vector2(10, 0)
	info_cornice.grow_vertical = Control.GROW_DIRECTION_BEGIN
	info_cornice.offset_bottom = -10
	info_cornice.offset_top = -10
	schermo_gioco.add_child(info_cornice)
	info = VBoxContainer.new()
	info.add_theme_constant_override("separation", 4)
	info_cornice.add_child(info)
	info_cornice.visible = false
	# pannello delle azioni (in basso a destra)
	azione_cornice = PanelContainer.new()
	azione_cornice.add_theme_stylebox_override("panel", _scatola(Color(PERGAMENA, 0.97), TERRACOTTA, 4, 8, 14))
	azione_cornice.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	azione_cornice.custom_minimum_size = Vector2(540, 0)
	azione_cornice.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	azione_cornice.grow_vertical = Control.GROW_DIRECTION_BEGIN
	azione_cornice.offset_right = -10
	azione_cornice.offset_bottom = -10
	azione_cornice.offset_left = -10
	azione_cornice.offset_top = -10
	schermo_gioco.add_child(azione_cornice)
	azione = VBoxContainer.new()
	azione.add_theme_constant_override("separation", 8)
	azione_cornice.add_child(azione)
	velo = Control.new()
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	schermo_gioco.add_child(velo)
	ob_scelto = ""
	raduno_spazio = ""
	if partita.s.attesa.is_empty() and not partita.s.finita:
		partita.avanza()
	aggiorna()
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(mappa):
		mappa.centra_tutto()
		_metti_a_fuoco()

func _torna_menu() -> void:
	if partita != null:
		_salva_locale()
	if schermo_gioco != null:
		schermo_gioco.queue_free()
		schermo_gioco = null
	_costruisci_menu()

func _fase_corrente() -> String:
	var s: Dictionary = partita.s
	var t: String = s.attesa.get("tipo", "")
	if t in ["operazione", "raduno"]:
		return "operazioni"
	if t == "costruzione":
		return "tregua" if s.attesa.get("tregua", false) else "amministrazione"
	var f: String = s.get("fase", s.passo)
	if f.begins_with("op_"):
		return "operazioni"
	if f in ["amministrazione", "costruzione_np"]:
		return "amministrazione"
	if f in ["tregua", "fine_turno"]:
		return "tregua"
	return f

func aggiorna() -> void:
	if partita == null or schermo_gioco == null:
		return
	var s: Dictionary = partita.s
	barra_titolo.text = "Turno %d  %s a.C." % [min(s.turno, 10), Dati.ANNI[min(s.turno, 10) - 1]]
	barra_comando.text = "Comandi %s" % Dati.NOME_LATO[s.lato_g]
	barra_comando.add_theme_color_override("font_color", Color("a9d68a") if s.lato_g == "A" else Color("f0928d"))
	barra_pv.text = "Punti vittoria %d su %s" % [s.pv, "40" if s.scenario == "archidamo" else "150"]
	var fc := _fase_corrente()
	for k in chip_fasi:
		var c: Label = chip_fasi[k]
		var attiva: bool = k == fc
		c.add_theme_color_override("font_color", NERO if attiva else Color("b9a98a"))
		c.add_theme_stylebox_override("normal", _scatola(ORO if attiva else Color("2c2118"), ORO if attiva else Color("5a4a34"), 1, 4, 3))
	for lato in ["A", "S"]:
		_pannello_lato(lato)
	_pannello_azione()
	_pannello_info()
	mappa.queue_redraw()

func _riga_valore(nome: String, valore: String, colore: Color = INCHIOSTRO) -> HBoxContainer:
	var h := HBoxContainer.new()
	var a := etichetta(nome, 18, Color("5b4a36"))
	a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(a)
	h.add_child(etichetta(valore, 20, colore, f_grassetto))
	return h

func _pannello_lato(lato: String) -> void:
	var vb: VBoxContainer = pannelli_lato[lato]
	_svuota(vb)
	var s: Dictionary = partita.s
	var testa := HBoxContainer.new()
	testa.add_theme_constant_override("separation", 8)
	vb.add_child(testa)
	var elmo := TextureRect.new()
	elmo.texture = load("res://assets/pedine/elmo_%s.png" % lato)
	elmo.custom_minimum_size = Vector2(34, 34)
	elmo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	elmo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	elmo.modulate = COLORE_LATO[lato] if lato == "S" else Color.WHITE
	testa.add_child(elmo)
	var nome := etichetta(Dati.NOME_LATO[lato].to_upper(), 24, COLORE_LATO[lato], f_titoli)
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	testa.add_child(nome)
	testa.add_child(etichetta("tu" if lato == s.lato_g else "gioco", 17, Color("5b4a36"), f_corsivo))
	vb.add_child(_riga_valore("Tesoro", "%d talenti" % s.tes[lato]))
	vb.add_child(_riga_valore("Bellicosità", "%d su 12" % s.bel[lato], ROSSO if s.bel[lato] <= 3 else INCHIOSTRO))
	vb.add_child(_riga_valore("Fiducia strategica", ("%+d" % s.sci[lato]) if s.sci[lato] != 0 else "0", ROSSO if s.sci[lato] < 0 else (VERDE if s.sci[lato] > 0 else INCHIOSTRO)))
	if lato != s.lato_g:
		var st := etichetta("Strategia: %s" % Dati.NOME_STRATEGIA[s.strategia[lato]], 18, INCHIOSTRO, f_corsivo, 260)
		vb.add_child(st)
	var capi := []
	for c in partita.capi_casa(lato):
		capi.append("%s %d/%d" % [Dati.capo_nome(c), Dati.CAPI[c][1], Dati.CAPI[c][2]])
	vb.add_child(etichetta("Nella capitale: %s" % (", ".join(capi) if not capi.is_empty() else "nessun condottiero"), 18, INCHIOSTRO, null, 260))
	var note := []
	note.append("%d nella coppa" % partita.coppa(lato).size())
	if s.ostaggi[lato]:
		note.append("ha degli ostaggi")
	if s.passato[lato]:
		note.append("ha passato")
	if lato == "S" and s.iloti:
		note.append("iloti in rivolta")
	vb.add_child(etichetta(", ".join(note), 17, Color("5b4a36"), f_corsivo, 260))

# ------------------------------------------------------------------ pannello delle azioni
func _titolo_azione(t: String) -> void:
	azione.add_child(etichetta(t, 22, TERRACOTTA, f_titoli, 500))

func _riepilogo_bb(voci: Array) -> String:
	var colori := {"fase": "#8a2a1c", "batt": "#7a1418", "ev": "#4a3a78", "pv": "#2f5a1f", "op": "#2a1d12"}
	var righe := []
	for v in voci:
		var t: String = v[1]
		if v[0] == "fase":
			t = "[b]" + t + "[/b]"
		righe.append("[color=%s]%s[/color]" % [colori.get(v[0], "#2a1d12"), t])
	return "\n".join(righe)

func _pannello_azione() -> void:
	_svuota(azione)
	var s: Dictionary = partita.s
	var tipo: String = s.attesa.get("tipo", "")
	mappa.evidenziati = {}
	mappa.obiettivo = ""
	match tipo:
		"continua":
			_titolo_azione(s.attesa.get("titolo", "Avanti"))
			var alt: float = clampf(40.0 * s.riepilogo.size(), 70.0, 290.0)
			var r := testo_ricco(_riepilogo_bb(s.riepilogo), 500, alt)
			r.add_theme_font_size_override("normal_font_size", 18)
			r.add_theme_font_size_override("bold_font_size", 18)
			r.scroll_following = false
			azione.add_child(r)
			azione.add_child(bottone("Continua", _continua, 20))
		"operazione":
			_azione_operazione()
		"raduno":
			_azione_raduno()
		"costruzione":
			_azione_costruzione()
		"fine":
			_titolo_azione("Vittoria" if s.vittoria else "La guerra è finita")
			azione.add_child(etichetta(s.esito, 21, INCHIOSTRO, null, 500))
			azione.add_child(bottone("Torna al menu", _torna_menu, 20))
		_:
			_titolo_azione("Avanti")
			azione.add_child(bottone("Continua", _continua, 20))

func _metti_a_fuoco() -> void:
	var s: Dictionary = partita.s
	if s.attesa.get("tipo", "") != "continua":
		return
	var id: String = s.ultimo_ob
	if not s.percorso.is_empty():
		id = s.percorso[s.percorso.size() - 1]
	if id != "" and Dati.spazi.has(id):
		mappa.centra_nel_libero(id, 310.0, 570.0)

func _continua() -> void:
	partita.avanza()
	_metti_a_fuoco()
	ob_scelto = ""
	raduno_spazio = ""
	costruzione_q = {}
	_salva()
	aggiorna()

func _azione_operazione() -> void:
	var s: Dictionary = partita.s
	var g: String = s.lato_g
	_titolo_azione("Operazione di %s" % Dati.NOME_LATO[g])
	var capi := partita.capi_casa(g)
	if capo_scelto == "" or not capi.has(capo_scelto):
		capo_scelto = capi[0] if not capi.is_empty() else ""
	if ob_scelto == "":
		azione.add_child(etichetta("Tocca sulla mappa lo spazio che vuoi come obiettivo. Poi radunerai le truppe e la spedizione marcerà per la via più breve.", 20, INCHIOSTRO, null, 500))
	else:
		mappa.obiettivo = ob_scelto
		var d: Dictionary = Dati.spazi[ob_scelto]
		azione.add_child(etichetta("Obiettivo: %s (%s%s)" % [d.nome, Dati.tipo_spazio_nome(d.t), ", fortezza" if d.f == 1 else ""], 22, INCHIOSTRO, f_grassetto, 500))
		var cb := CheckBox.new()
		cb.text = "Fomenta la rivolta (100 talenti, riesce con 6)"
		cb.button_pressed = rib_scelta
		cb.add_theme_font_size_override("font_size", 19)
		cb.custom_minimum_size = Vector2(480, 40)
		cb.focus_mode = Control.FOCUS_NONE
		cb.toggled.connect(func(v): rib_scelta = v; aggiorna())
		azione.add_child(cb)
		var err := partita.obiettivo_valido(ob_scelto, rib_scelta)
		if err != "":
			azione.add_child(etichetta(err, 19, ROSSO, f_grassetto, 500))
	if capi.size() > 1:
		var hc := HBoxContainer.new()
		hc.add_theme_constant_override("separation", 6)
		azione.add_child(hc)
		for c in capi:
			var bcapo := bottone("%s %d/%d" % [Dati.capo_nome(c), Dati.CAPI[c][1], Dati.CAPI[c][2]], func(): capo_scelto = c; aggiorna(), 16)
			bcapo.modulate = Color.WHITE if c == capo_scelto else Color(1, 1, 1, 0.55)
			bcapo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hc.add_child(bcapo)
	elif capo_scelto != "":
		azione.add_child(etichetta("Condottiero: %s (tattico %d, strategico %d)" % [Dati.capo_nome(capo_scelto), Dati.CAPI[capo_scelto][1], Dati.CAPI[capo_scelto][2]], 19, INCHIOSTRO, null, 500))
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	azione.add_child(h)
	var parti := bottone("Parti", _g_parti, 20)
	parti.disabled = ob_scelto == "" or partita.obiettivo_valido(ob_scelto, rib_scelta) != "" or capo_scelto == ""
	parti.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(parti)
	var sugg := bottone("Suggerisci", _suggerisci, 18)
	sugg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(sugg)
	var passa := bottone("Passa", _g_passa, 18)
	passa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(passa)

func _suggerisci() -> void:
	var p := bot.proponi(partita)
	if p.is_empty():
		_avviso("Nessun obiettivo conviene davvero: puoi passare.")
		return
	ob_scelto = p.ob
	rib_scelta = false
	mappa.centra_spazio(ob_scelto)
	aggiorna()

func _g_parti() -> void:
	var e := partita.g_inizia(ob_scelto, rib_scelta, capo_scelto)
	if e != "":
		_avviso(e)
		return
	ob_scelto = ""
	rib_scelta = false
	raduno_spazio = ""
	_salva()
	aggiorna()

func _g_passa() -> void:
	partita.g_passa()
	ob_scelto = ""
	_salva()
	aggiorna()

func _figura(k: String, lato: float = 40.0) -> Control:
	var c := ColorRect.new()
	c.color = Color(Dati.colori.get("SH" if k == "SG" else k, "#888888"))
	c.custom_minimum_size = Vector2(lato, lato)
	var t := TextureRect.new()
	t.texture = mappa.tex[k]
	t.set_anchors_preset(Control.PRESET_FULL_RECT)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c.add_child(t)
	return c

func _contatore(k: String, sotto: String, valore: int, cambia: Callable) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	h.add_child(_figura(k))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.custom_minimum_size = Vector2(210, 0)
	v.add_child(etichetta(Dati.maiuscola(Dati.NOME_UNITA[k]), 19, INCHIOSTRO, f_grassetto))
	v.add_child(etichetta(sotto, 16, Color("5b4a36")))
	h.add_child(v)
	var meno := bottone("-", func(): cambia.call(-1), 24)
	meno.custom_minimum_size = Vector2(52, 46)
	h.add_child(meno)
	var n := etichetta(str(valore), 26, INCHIOSTRO, f_titoli)
	n.custom_minimum_size = Vector2(44, 0)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_child(n)
	var piu := bottone("+", func(): cambia.call(1), 24)
	piu.custom_minimum_size = Vector2(52, 46)
	h.add_child(piu)
	return h

func _azione_raduno() -> void:
	var s: Dictionary = partita.s
	var o: Dictionary = partita.op
	mappa.obiettivo = o.ob
	_titolo_azione("Spedizione verso %s" % Dati.nome(o.ob))
	azione.add_child(etichetta("%s è a %s con: %s." % [Dati.capo_nome(o.capo), Dati.nome(o.pos), partita.descrivi(o.u)], 20, INCHIOSTRO, null, 500))
	var riserva := " (di cui 1000 di riserva intoccabile)" if o.lato == "A" and not partita.fondo_emergenza_sospeso() else ""
	azione.add_child(etichetta("Tesoro: %d talenti%s." % [s.tes[o.lato], riserva], 18, Color("5b4a36"), null, 500))
	for id in partita.raduni_possibili():
		mappa.evidenziati[id] = Color(0.25, 0.85, 0.3, 0.9)
	if raduno_spazio != "" and partita.disponibili(raduno_spazio, o.lato).is_empty():
		raduno_spazio = ""
	if raduno_spazio == "":
		azione.add_child(etichetta("Tocca uno spazio cerchiato di verde per unire alla spedizione le truppe che vi si trovano; il condottiero lo raggiunge per la via più breve. Quando sei pronto, marcia.", 19, INCHIOSTRO, null, 500))
	else:
		mappa.evidenziati[raduno_spazio] = Color(1.0, 0.9, 0.3, 1.0)
		azione.add_child(etichetta("Truppe a %s" % Dati.nome(raduno_spazio), 21, TERRACOTTA, f_titoli))
		var disp := partita.disponibili(raduno_spazio, o.lato)
		var costo := 0
		for k in Dati.CHIAVI:
			if disp.has(k):
				var q: int = raduno_q.get(k, 0)
				costo += partita._costo(k) * q
				var prezzo := partita._costo(k)
				azione.add_child(_contatore(k, "disponibili %d, %s" % [disp[k], ("%d talenti l'uno" % prezzo) if prezzo > 0 else "gratuiti"], q, func(d): raduno_q[k] = clampi(raduno_q.get(k, 0) + d, 0, disp[k]); aggiorna()))
		var hu := HBoxContainer.new()
		hu.add_theme_constant_override("separation", 8)
		azione.add_child(hu)
		var unisci := bottone("Unisci (%d talenti)" % costo, _g_unisci, 18)
		unisci.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hu.add_child(unisci)
		var tutte := bottone("Tutte", func(): raduno_q = disp.duplicate(); aggiorna(), 18)
		hu.add_child(tutte)
		var ann := bottone("Chiudi", func(): raduno_spazio = ""; aggiorna(), 18)
		hu.add_child(ann)
	var hm := HBoxContainer.new()
	hm.add_theme_constant_override("separation", 8)
	azione.add_child(hm)
	var marcia := bottone("Marcia su %s" % Dati.nome(o.ob), _g_marcia, 20)
	marcia.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hm.add_child(marcia)
	hm.add_child(bottone("Rinuncia", func(): partita.g_rinuncia(); raduno_spazio = ""; _salva(); aggiorna(), 16))

func _g_unisci() -> void:
	var u := {}
	for k in raduno_q:
		if raduno_q[k] > 0:
			u[k] = raduno_q[k]
	var e := partita.g_attiva(raduno_spazio, u)
	if e != "":
		_avviso(e)
		return
	raduno_q = {}
	raduno_spazio = ""
	_salva()
	aggiorna()

func _g_marcia() -> void:
	var e := partita.g_marcia()
	if e != "":
		_avviso(e)
		return
	raduno_spazio = ""
	_salva()
	aggiorna()

func _azione_costruzione() -> void:
	var s: Dictionary = partita.s
	var g: String = s.lato_g
	var mx: int = s.attesa.max
	_titolo_azione("Nuove unità per %s" % Dati.NOME_LATO[g])
	azione.add_child(etichetta("Puoi costruire fino a %d punti forza, 200 talenti l'uno. Tesoro: %d talenti. Vanno nelle basi previste dalla tabella dei ritorni." % [mx, s.tes[g]], 19, INCHIOSTRO, null, 500))
	var tot := 0
	for k in costruzione_q:
		tot += costruzione_q[k]
	for k in partita.costruibili(g):
		var libere: int = Dati.LIMITE[k] - partita.in_gioco(k)
		azione.add_child(_contatore(k, "pedine libere %d" % libere, costruzione_q.get(k, 0), func(d):
			var ora: int = costruzione_q.get(k, 0)
			var somma := 0
			for kk in costruzione_q:
				somma += costruzione_q[kk]
			if d > 0 and (somma >= mx or ora >= libere):
				return
			costruzione_q[k] = max(0, ora + d)
			aggiorna()))
	azione.add_child(bottone("Costruisci %d punti (%d talenti)" % [tot, tot * 200] if tot > 0 else "Non costruire nulla", _g_costruisci, 20))

func _g_costruisci() -> void:
	var lista := []
	for k in costruzione_q:
		for i in costruzione_q[k]:
			lista.append(k)
	var e := partita.g_costruisci(lista)
	if e != "":
		_avviso(e)
		return
	costruzione_q = {}
	partita.avanza()
	_salva()
	aggiorna()

# ------------------------------------------------------------------ mappa e informazioni
func _spazio_toccato(id: String) -> void:
	var tipo: String = partita.s.attesa.get("tipo", "")
	mappa.selezionato = id
	if tipo == "operazione":
		ob_scelto = id
	elif tipo == "raduno":
		if partita.ctrl(id) == partita.op.lato and not partita.disponibili(id, partita.op.lato).is_empty():
			raduno_spazio = id
			raduno_q = {}
	aggiorna()

func _pannello_info() -> void:
	_svuota(info)
	var id: String = mappa.selezionato
	info_cornice.visible = id != ""
	if id == "":
		return
	var d: Dictionary = Dati.spazi[id]
	var testa := HBoxContainer.new()
	info.add_child(testa)
	var n := etichetta(d.nome, 24, TERRACOTTA, f_titoli)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	n.custom_minimum_size = Vector2(280, 0)
	testa.add_child(n)
	var chiudi := bottone("Chiudi", func(): mappa.selezionato = ""; mappa.mostra_zoi = ""; aggiorna(), 15)
	chiudi.custom_minimum_size = Vector2(84, 38)
	testa.add_child(chiudi)
	var colore := partita.colore(id)
	var lega: String = {"G": "Lega delio-attica", "R": "Lega del Peloponneso", "Y": "neutrale"}[colore]
	info.add_child(etichetta("Spazio di %s%s, %s." % [Dati.tipo_spazio_nome(d.t), " con fortezza" if d.f == 1 else "", lega], 18, INCHIOSTRO, null, 370))
	var c := partita.ctrl(id)
	var stato := []
	stato.append("Controllo: %s" % (Dati.NOME_LATO[c] if c != "" else "nessuno"))
	if partita.in_rivolta(id):
		stato.append("in rivolta")
	if partita.s.sp.has(id) and partita.s.sp[id].dev:
		stato.append("devastato")
	info.add_child(etichetta(", ".join(stato) + ".", 18, INCHIOSTRO, f_grassetto, 370))
	if partita.s.sp.has(id):
		var x: Dictionary = partita.s.sp[id]
		for k in Dati.CHIAVI:
			if x.u.get(k, 0) > 0:
				var h := HBoxContainer.new()
				h.add_theme_constant_override("separation", 8)
				h.add_child(_figura(k, 34))
				var att: int = x.a.get(k, 0)
				h.add_child(etichetta("%s: %d%s" % [Dati.maiuscola(Dati.NOME_UNITA[k]), x.u[k] * (1 if k != "SG" else 1), (" (%d già impiegati)" % att) if att > 0 else ""], 18))
				info.add_child(h)
	var capi := partita.capi_in(id, "A") + partita.capi_in(id, "S")
	for cp in capi:
		info.add_child(etichetta("Condottiero: %s (tattico %d, strategico %d)" % [Dati.capo_nome(cp), Dati.CAPI[cp][1], Dati.CAPI[cp][2]], 18, INCHIOSTRO, f_corsivo, 370))
	if partita.presenti(id, "A") + partita.presenti(id, "S") > 0:
		var bz := bottone("Nascondi la zona d'influenza" if mappa.mostra_zoi == id else "Mostra la zona d'influenza", func(): mappa.mostra_zoi = "" if mappa.mostra_zoi == id else id; aggiorna(), 15)
		info.add_child(bz)

# ------------------------------------------------------------------ finestre
func _finestra(titolo: String, contenuto: Control, larghezza: float = 900.0) -> Control:
	var strato := Control.new()
	strato.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(strato)
	var ombra := ColorRect.new()
	ombra.color = Color(0, 0, 0, 0.6)
	ombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	strato.add_child(ombra)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	strato.add_child(centro)
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", _scatola(PERGAMENA, TERRACOTTA, 5, 10, 20))
	pc.custom_minimum_size = Vector2(larghezza, 0)
	centro.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	pc.add_child(v)
	var testa := HBoxContainer.new()
	v.add_child(testa)
	var t := etichetta(titolo, 28, TERRACOTTA, f_titoli)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	testa.add_child(t)
	var ch := bottone("Chiudi", strato.queue_free, 17)
	ch.custom_minimum_size = Vector2(120, 44)
	testa.add_child(ch)
	var g := Greca.new()
	g.custom_minimum_size = Vector2(larghezza - 40, 18)
	v.add_child(g)
	v.add_child(contenuto)
	return strato

func _altezza_finestra() -> float:
	return clampf(size.y - 260.0, 360.0, 720.0)

func _finestra_testo(titolo: String, bb: String) -> void:
	_finestra(titolo, testo_ricco(bb, 860, _altezza_finestra()))

func _avviso(testo: String) -> void:
	_finestra("Attenzione", etichetta(testo, 22, INCHIOSTRO, null, 500), 620)

func _apri_diario() -> void:
	var r := testo_ricco(_riepilogo_bb(partita.s.diario), 860, _altezza_finestra())
	r.scroll_following = true
	_finestra("Diario della guerra", r)

func _entrate_bb() -> String:
	var t := "[font_size=24][color=#8a2a1c]Entrate previste alla prossima fase amministrativa[/color][/font_size]\n\n"
	for lato in ["A", "S"]:
		var e := partita.entrate(lato)
		t += "[b]%s: %d talenti[/b]\n" % [Dati.NOME_LATO[lato], e.totale]
		for v in e.voci:
			t += "%s: %+d\n" % [v[0], v[1]]
		t += "Spazi della lega devastati, in rivolta o perduti: %d (ogni 10 tolgono 1 alla bellicosità).\n\n" % partita.spazi_persi(lato)
	return t

func _apri_tabelle() -> void:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	var schede := HBoxContainer.new()
	schede.add_theme_constant_override("separation", 6)
	v.add_child(schede)
	var testo := testo_ricco(Aiuto.matrice(Dati.AVV[partita.s.lato_g]), 960, _altezza_finestra() - 60)
	v.add_child(testo)
	for voce in [["Matrice di Atene", func(): return Aiuto.matrice("A")], ["Matrice di Sparta", func(): return Aiuto.matrice("S")], ["Eventi", func(): return Aiuto.EVENTI], ["Ritorni", func(): return Aiuto.RITORNI], ["Entrate", _entrate_bb]]:
		var b := bottone(voce[0], func(): testo.text = voce[1].call(); testo.scroll_to_line(0), 16)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		schede.add_child(b)
	_finestra("Tabelle", v, 1000)

func _apri_salva() -> void:
	_salva(true)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.add_child(etichetta("La partita si salva da sola a ogni mossa, su questo dispositivo e online.", 21, INCHIOSTRO, null, 500))
	v.add_child(etichetta("Codice della partita", 18, Color("5b4a36")))
	var c := etichetta(codice, 56, TERRACOTTA, f_titoli)
	c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(c)
	v.add_child(etichetta("Scrivilo nel menu di un altro dispositivo (\"Carica dal codice\") per riprendere da lì.", 20, INCHIOSTRO, null, 500))
	var esito := etichetta("Salvataggio online in corso...", 19, Color("5b4a36"), f_corsivo, 560)
	v.add_child(esito)
	var f := _finestra("Salvataggio", v, 620)
	for i in 40:
		await get_tree().create_timer(0.25).timeout
		if not is_instance_valid(f):
			return
		if not _salvataggio_in_corso:
			break
	if not is_instance_valid(esito):
		return
	if _rete_esito == "online":
		esito.text = "Salvata online."
	elif _rete_negata:
		esito.text = "Salvataggio online non riuscito: Firebase non ha ancora le regole per questo gioco. Basta incollare nella console di Firebase (Realtime Database, Regole) il file firebase/database.rules.json della ludoteca. Intanto la partita resta salvata su questo dispositivo."
	else:
		esito.text = "Salvataggio online non riuscito: la partita resta su questo dispositivo. %s" % net.ultimo_errore

# ------------------------------------------------------------------ avvio per le prove (screenshot)
func _avvio_prova(modo: String) -> void:
	net.offline = true
	if modo == "menu":
		return
	partita = Partita.new()
	partita.nuova("campagna", 4242)
	codice = "PROVA1"
	var passi := int(OS.get_environment("PW_PASSI")) if OS.get_environment("PW_PASSI") != "" else 0
	var b := Bot.new()
	for i in passi:
		if partita.s.finita:
			break
		b.gioca(partita)
	if modo in ["obiettivo", "raduno"]:
		for i in 3000:
			if partita.s.finita or partita.s.attesa.get("tipo", "") == "operazione":
				break
			b.gioca(partita)
	if modo.begins_with("fino_"):
		for i in 3000:
			if partita.s.finita or partita.s.attesa.get("tipo", "") == modo.substr(5):
				break
			b.gioca(partita)
	_apri_gioco()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	match modo:
		"obiettivo":
			if partita.s.attesa.get("tipo", "") == "operazione":
				_spazio_toccato("Megara")
		"raduno":
			if partita.s.attesa.get("tipo", "") == "operazione":
				partita.g_inizia("Megara", false, partita.capi_casa(partita.s.lato_g)[0])
				aggiorna()
				_spazio_toccato(Dati.CASA[partita.s.lato_g])
				raduno_q = partita.disponibili(raduno_spazio, partita.s.lato_g).duplicate()
				for k in raduno_q:
					raduno_q[k] = min(raduno_q[k], 2)
				aggiorna()
		"tabelle":
			_apri_tabelle()
		"diario":
			_apri_diario()
		"regole":
			_finestra_testo("Regole in breve", Aiuto.REGOLE)
		"salva":
			_apri_salva()
		"zoom":
			mappa.zoom = 1.1
			mappa.centra_su(Vector2(2000, 1700))
