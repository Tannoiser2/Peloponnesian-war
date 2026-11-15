## Cerca un seme per la partita guidata: godot --headless --path . -s tests/cerca_seme.gd -- <da> <a>
extends SceneTree

func fino_scelta(p: Partita) -> Array:
	var log := []
	for i in 40:
		var t: String = p.s.attesa.get("tipo", "")
		if t in ["operazione", "raduno", "costruzione", "fine"]:
			break
		p.avanza()
		if p.s.attesa.get("tipo", "") == "continua":
			log.append([p.s.attesa.get("titolo", ""), p.s.riepilogo.duplicate()])
	return log

func testo(log: Array) -> String:
	var r := ""
	for x in log:
		for v in x[1]:
			r += v[1] + "\n"
	return r

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var da := int(a[0]) if a.size() > 0 else 1
	var fino := int(a[1]) if a.size() > 1 else 400
	var stampa := a.size() > 2
	for seme in range(da, fino):
		var p := Partita.new()
		p.nuova("campagna", seme)
		var tutto := ""
		var log := fino_scelta(p)
		tutto += testo(log)
		var ok: bool = p.s.attesa.get("tipo", "") == "operazione"
		var invasione: bool = p.s.sp.has("Decelea") and p.presenti("Decelea", "S") > 0 or p.presenti("Panactum", "S") > 0 or p.presenti("Athens", "S") > 0
		if not ok:
			continue
		# op 1: Pericle, 3 navi, Erineo
		var e := p.g_inizia("Erineus", false, "pericles")
		if e != "": continue
		e = p.g_attiva("Piraeus", {"AN": 3})
		if e != "" or p.s.attesa.get("tipo", "") != "raduno": continue
		p.g_marcia()
		var arrivato_erineo: bool = p.presenti("Erineus", "A") >= 3
		tutto += "\n".join(p.s.riepilogo.map(func(v): return v[1])) + "\n"
		log = fino_scelta(p)
		tutto += testo(log)
		if p.s.attesa.get("tipo", "") != "operazione":
			continue
		var capi := p.capi_casa("A")
		if capi.is_empty(): continue
		var capo: String = capi[0]
		e = p.g_inizia("Methana", false, capo)
		if e != "": continue
		if p.g_attiva("Athens", {"AH": 3}) != "": continue
		if p.g_attiva("Piraeus", {"AN": 3}) != "": continue
		p.g_marcia()
		var arrivato_metana: bool = p.presenti("Methana", "A") >= 6
		tutto += "\n".join(p.s.riepilogo.map(func(v): return v[1])) + "\n"
		log = fino_scelta(p)
		tutto += testo(log)
		if p.s.attesa.get("tipo", "") == "operazione":
			p.g_passa()
			log = fino_scelta(p)
			tutto += testo(log)
		if p.s.attesa.get("tipo", "") != "costruzione": continue
		var sieged_e: bool = tutto.contains("Assedio di Erineo: riuscito")
		var sieged_m: bool = tutto.contains("Assedio di Metana: riuscito")
		var navale: bool = tutto.contains("Battaglia navale") and tutto.contains("Vince Atene")
		var persa: bool = tutto.contains("Vince Sparta")
		var pv: int = p.s.pv
		var sci: int = p.s.sci.A
		var score: int = (2 if invasione else 0) + (2 if sieged_e else 0) + (2 if sieged_m else 0) + (2 if navale else 0) + (0 if persa else 1) + (1 if arrivato_erineo else 0) + (1 if arrivato_metana else 0)
		p.g_costruisci(["AH", "AH", "AN"])
		log = fino_scelta(p)
		var t2 := testo(log)
		tutto += t2
		var cambio: bool = p.s.lato_g == "S"
		if stampa:
			score += 0
		if score >= 11 and not stampa:
			print("SEME %d pv %d sciA %d capo2 %s cambio %s turno %d attesa %s tes %s bel %s" % [seme, pv, sci, capo, cambio, p.s.turno, p.s.attesa.get("tipo",""), p.s.tes, p.s.bel])
		if stampa:
			print("SEME %d punteggio %d pv %d sciA %d capo2 %s inv %s E %s M %s nav %s persa %s" % [seme, score, pv, sci, capo, invasione, sieged_e, sieged_m, navale, persa])
			print("SEME %d pv %d sciA %d capo2 %s cambio %s" % [seme, pv, sci, capo, cambio])
			print(tutto)
	quit(0)
