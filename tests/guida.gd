## Esegue il copione della partita guidata sul motore e stampa lo stato a ogni passo.
## godot --headless --path . -s tests/guida.gd -- [stampa]
extends SceneTree

func _init() -> void:
	var stampa := OS.get_cmdline_user_args().size() > 0
	var p := Partita.new()
	p.nuova("campagna", Guida.SEME)
	var i := 0
	for passo in Guida.COPIONE:
		var nomi: Array = passo.get("evid", []).duplicate()
		nomi.append(passo.get("centro", "Athens"))
		if passo.has("id"): nomi.append(passo.id)
		for nm in nomi:
			if not Dati.spazi.has(nm):
				print("ERRORE: spazio sconosciuto nel copione: ", nm)
				quit(1)
				return
		var att: String = p.s.attesa.get("tipo", "")
		var e := ""
		match passo.tipo:
			"leggi":
				pass
			"continua":
				if not (att in ["", "continua"]):
					e = "attesa %s invece di continua" % att
				else:
					p.avanza()
			"obiettivo":
				if att != "operazione":
					e = "attesa %s invece di operazione" % att
			"parti":
				e = p.g_inizia(Guida.COPIONE[i - 1].id, false, p.capi_casa("A")[0] if not p.capi_casa("A").is_empty() else "")
			"raduno":
				e = p.g_attiva(passo.id, passo.u)
			"marcia":
				e = p.g_marcia()
			"passa":
				if att != "operazione":
					e = "attesa %s invece di operazione" % att
				else:
					p.g_passa()
			"costruisci":
				e = p.g_costruisci(passo.lista)
				if e == "":
					p.avanza()
		if stampa:
			print("=== passo %d %s -> attesa %s, turno %d, tesoro %s, pv %d, sci %s, bel %s" % [i, passo.tipo, p.s.attesa.get("tipo", ""), p.s.turno, p.s.tes, p.s.pv, p.s.sci, p.s.bel])
			if passo.tipo == "marcia":
				print("   PERCORSO: ", " ".join(p.s.percorso.map(func(x): return Dati.nome(x))))
			if passo.tipo in ["continua", "marcia", "passa", "costruisci", "parti"]:
				for v in p.s.riepilogo:
					print("   ", v[1])
		if e != "":
			printerr("passo %d (%s): %s" % [i, passo.tipo, e])
			quit(1)
			return
		i += 1
	if stampa:
		print("capi in casa A: ", p.capi_casa("A"), "  S: ", p.capi_casa("S"), " lato ", p.s.lato_g, " strategia S ", p.s.strategia.S)
		for id in ["Athens", "Piraeus", "Erineus", "Methana", "Potidaea", "Naxos", "Corinth", "Thebes", "Sparta", "Naupactus", "Pela", "Larisa", "Chios", "Corcyra"]:
			if p.s.sp.has(id):
				print("   ", id, " ", p.s.sp[id].u, " riv ", p.s.sp[id].riv)
		print(p.entrate("A"), p.entrate("S"))
	print("guida: copione eseguito, turno %d, attesa %s, comandi %s" % [p.s.turno, p.s.attesa.get("tipo", ""), p.s.lato_g])
	quit(0)
