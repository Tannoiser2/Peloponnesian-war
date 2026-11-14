## Giocatore automatico semplice, usato dalle prove e dal pulsante "Suggerisci".
class_name Bot
extends RefCounted

var operazioni := 0

## Fa una mossa per il giocatore, qualunque sia la scelta richiesta.
func gioca(p: Partita) -> void:
	var a: Dictionary = p.s.attesa
	match a.get("tipo", ""):
		"":
			p.avanza()
		"continua":
			p.avanza()
		"operazione":
			var prop := proponi(p)
			if prop.is_empty():
				p.g_passa()
			else:
				var e := p.g_inizia(prop.ob, prop.rib, prop.capo)
				if e != "":
					p.g_passa()
				else:
					operazioni += 1
		"raduno":
			_raduna(p)
		"costruzione":
			var lista := []
			var c := p.costruibili(p.s.lato_g)
			for i in a.max:
				if not c.is_empty():
					lista.append(c[p.rng.randi_range(0, c.size() - 1)])
			if p.g_costruisci(lista) != "":
				p.g_costruisci([])
		"fine":
			pass

## Propone un'operazione: {ob, rib, capo} oppure {} per passare.
func proponi(p: Partita) -> Dictionary:
	var g: String = p.s.lato_g
	var avv: String = Dati.AVV[g]
	var capi := p.capi_casa(g)
	if capi.is_empty() or p.spendibile(g) < 600 and g == "A":
		return {}
	if p.rng.randf() < 0.12 and not p.s.attesa.get("iniziale", false):
		return {}
	var candidati := []
	for id in Dati.spazi:
		if p.in_rivolta(id) and p.lato_colore(id) == g:
			candidati.append([id, false, 5])
		elif p.ctrl(id) == avv and p.presenti(id, avv) <= 2 and id != Dati.CASA[avv]:
			candidati.append([id, false, 1 if p.presenti(id, avv) > 0 else 2])
	if candidati.is_empty():
		return {}
	var pesi := 0
	for c in candidati:
		pesi += c[2]
	var r := p.rng.randi_range(1, pesi)
	for c in candidati:
		r -= c[2]
		if r <= 0:
			if p.obiettivo_valido(c[0], false) != "":
				return {}
			return {"ob": c[0], "rib": false, "capo": capi[0]}
	return {}

func _raduna(p: Partita) -> void:
	var ob: String = p.op.ob
	var costa: bool = Dati.spazi[ob].t != "L"
	var vuoi := {"H": 3, "N": 3} if costa else {"H": 5, "C": 1}
	for giro in 6:
		var manca := vuoi.duplicate()
		for k in p.op.u:
			var t := Dati.tipo_di(k)
			manca[t] = manca.get(t, 0) - p.op.u[k]
		var fatto := false
		var dist := p.distanze(p.op.pos)
		var spazi := p.raduni_possibili()
		spazi.sort_custom(func(a, b): return dist[a] < dist[b])
		for id in spazi:
			var disp := p.disponibili(id, p.op.lato)
			var u := {}
			for k in disp:
				var t := Dati.tipo_di(k)
				var n: int = min(disp[k], manca.get(t, 0))
				if id == Dati.CASA[p.op.lato] and t == "H":
					n = min(n, disp[k] - 2)
				if n > 0:
					u[k] = n
					manca[t] -= n
			if u.is_empty():
				continue
			if p.g_attiva(id, u) == "":
				fatto = true
				break
			for k in u:
				manca[Dati.tipo_di(k)] += u[k]
		if p.s.attesa.get("tipo", "") != "raduno":
			return
		if not fatto:
			break
	if p.g_marcia() != "":
		p.g_rinuncia()
