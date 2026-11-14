## Motore di Peloponnesian War (GMT, Mark Herman): stato della partita e tutte le regole.
## Non conosce l'interfaccia: avanza() fa procedere il turno finché serve una scelta del giocatore
## (s.attesa dice quale) oppure una pausa per leggere il diario.
class_name Partita
extends RefCounted

var s: Dictionary = {}
var rng := RandomNumberGenerator.new()
var op: Dictionary = {}          # operazione in corso (copia viva di s.op)

# ------------------------------------------------------------------ avvio e salvataggio
func nuova(scenario: String, seme: int = 0) -> void:
	Dati.carica()
	if seme == 0:
		rng.randomize()
	else:
		rng.seed = seme
	s = {
		"v": 1, "scenario": scenario, "turno": 1, "lato_g": "A", "pv": 0, "finita": false, "esito": "", "vittoria": false,
		"tes": {"A": 4500, "S": 3000}, "bel": {"A": 10, "S": 10}, "sci": {"A": 0, "S": 0},
		"strategia": {"A": "", "S": "attacco"}, "ostaggi": {"A": false, "S": false},
		"sp": {}, "capi": {}, "rit": {}, "perse": {}, "navi_perse": 0, "navi_perse_prec": 0,
		"macedonia": "A", "argo": "", "siracusa": "", "persia": false, "iaso": false, "sitalce": false, "corcira_neutrale": false,
		"alcibiade": 0, "ev3": false, "ev5": false, "ev6": false, "morti": {"A": 0, "S": 0}, "ev_morti": false,
		"max_op": {"A": 99, "S": 99}, "op_fatte": {"A": 0, "S": 0}, "corcira_ferma": false, "eisfora_no": false,
		"attica_prec": false, "attica_ora": false, "iloti": false, "iloti_malus": 0, "bel_malus": {"A": 0, "S": 0},
		"tregua_fatta": false, "nicia": false, "cambi": 0, "cambiato": false,
		"passato": {"A": false, "S": false}, "passo": "op_n_iniziale", "tocca": "", "attesa": {}, "diario": [],
		"op": {}, "difese": [], "sir_difesa": false, "obiettivi_S": [], "guardia_persa": false,
		"percorso": [], "ultimo_ob": "", "turni_guerra": 0, "riepilogo": [], "rientri": {}, "conta_rientri": {},
	}
	for c in Dati.CAPI:
		s.capi[c] = {"stato": "coppa", "pos": ""}
	_metti("Athens", {"AH": 6, "AC": 1}); _capo_in("pericles", "Athens")
	_metti("Piraeus", {"AN": 8})
	_metti("Naupactus", {"AN": 1})
	_metti("Corcyra", {"aN": 3, "aH": 1})
	_metti("Chios", {"aN": 2, "aH": 1})
	_metti("Larisa", {"aC": 5, "aH": 2})
	_metti("Pela", {"aC": 1})
	_metti("Amphipolis", {"aH": 1})
	_metti("Potidaea", {"AH": 2, "AN": 3, "aC": 1, "sH": 1}); _capo_in("phormio", "Potidaea")
	sp("Potidaea").riv = true
	sp("Potidaea").a = {"AH": 2, "AN": 3, "aC": 1}
	_metti("Sparta", {"SG": 3, "SH": 7, "SC": 1}); _capo_in("archidamus", "Sparta")
	_metti("Corinth", {"sH": 5, "sN": 5})
	_metti("Thebes", {"sH": 5, "sC": 4})
	s.op_fatte.A = 1
	nota("fase", "Turno 1 (%s a.C.). Comandi Atene. La spedizione di Formione assedia Potidea in rivolta; tocca a Sparta." % Dati.ANNI[0])
	op = {}

func esporta() -> Dictionary:
	s.op = op
	s["rng_stato"] = str(rng.state)
	s["rng_seme"] = str(rng.seed)
	return s.duplicate(true)

func importa(d: Dictionary) -> void:
	Dati.carica()
	s = _interi(d)
	rng.seed = int(str(s.get("rng_seme", "1")))
	rng.state = int(str(s.get("rng_stato", "1")))
	op = s.get("op", {})

func _interi(x):
	if x is float:
		return int(x)
	if x is Dictionary:
		var r := {}
		for k in x:
			r[k] = x[k] if k in ["rng_stato", "rng_seme"] else _interi(x[k])
		return r
	if x is Array:
		var a := []
		for y in x:
			a.append(_interi(y))
		return a
	return x

# ------------------------------------------------------------------ utilità
func d6() -> int:
	return rng.randi_range(1, 6)

func nota(tipo: String, testo: String) -> void:
	testo = Dati.eufonia(testo)
	s.diario.append([tipo, testo])
	s.riepilogo.append([tipo, testo])
	if s.diario.size() > 700:
		s.diario = s.diario.slice(s.diario.size() - 600)

func sp(id: String) -> Dictionary:
	if not s.sp.has(id):
		s.sp[id] = {"u": {}, "a": {}, "riv": false, "dev": false, "ass": ""}
	return s.sp[id]

func _metti(id: String, u: Dictionary) -> void:
	var x := sp(id)
	for k in u:
		if u[k] > 0:
			x.u[k] = x.u.get(k, 0) + u[k]

func _togli(u: Dictionary, k: String, n: int = 1) -> void:
	u[k] = u.get(k, 0) - n
	if u[k] <= 0:
		u.erase(k)

func _capo_in(c: String, id: String) -> void:
	s.capi[c] = {"stato": "mappa", "pos": id}

func nl(lato: String) -> String:
	return Dati.NOME_LATO[lato]

func unita(id: String) -> Dictionary:
	return s.sp[id].u if s.sp.has(id) else {}

static func conta(u: Dictionary, lato: String, tipo: String = "") -> int:
	var n := 0
	for k in u:
		if (lato == "" or Dati.lato_di(k) == lato) and (tipo == "" or Dati.tipo_di(k) == tipo):
			n += int(u[k])
	return n

func presenti(id: String, lato: String, tipo: String = "") -> int:
	return conta(unita(id), lato, tipo) if s.sp.has(id) else 0

func disponibili(id: String, lato: String) -> Dictionary:
	var r := {}
	if not s.sp.has(id):
		return r
	var x: Dictionary = s.sp[id]
	if id == "Corcyra" and s.corcira_ferma:
		return r
	for k in x.u:
		if Dati.lato_di(k) == lato and k != "SG":
			var n: int = x.u[k] - x.a.get(k, 0)
			if n > 0:
				r[k] = n
	return r

func capi_in(id: String, lato: String) -> Array:
	var r := []
	for c in s.capi:
		if s.capi[c].stato == "mappa" and s.capi[c].pos == id and Dati.CAPI[c][0] == lato:
			r.append(c)
	return r

func capi_sulla_mappa(lato: String) -> int:
	var n := 0
	for c in s.capi:
		if Dati.CAPI[c][0] == lato and s.capi[c].stato in ["mappa", "ritorno"]:
			n += 1
	return n

func coppa(lato: String) -> Array:
	var r := []
	for c in s.capi:
		if s.capi[c].stato == "coppa" and Dati.CAPI[c][0] == lato:
			r.append(c)
	return r

func tattico(capi: Array) -> int:
	if capi.is_empty():
		return 0
	var m := 99
	for c in capi:
		m = min(m, Dati.CAPI[c][1])
	return m

func descrivi(u: Dictionary) -> String:
	var p := []
	for k in Dati.CHIAVI:
		if u.get(k, 0) > 0:
			p.append("%s (%d)" % [Dati.NOME_UNITA[k], u[k]])
	return ", ".join(p) if not p.is_empty() else "nessuna unità"

func sci_piu(lato: String, n: int) -> void:
	s.sci[lato] = clampi(s.sci[lato] + n, -6, 6)

func pv_piu(n: int, motivo: String) -> void:
	s.pv += n
	nota("pv", "%s%d punti vittoria: %s (totale %d)." % ["+" if n > 0 else "", n, motivo, s.pv])

# ------------------------------------------------------------------ colore, controllo, zone d'influenza
func colore(id: String) -> String:
	if s.sitalce and (id == "Abdera" or id == "Maraneia"):
		return "R"
	if id == "Pela" or id == "Macedonia":
		return {"A": "G", "S": "R", "": "Y"}[s.macedonia]
	if id == "Argos":
		return "G" if s.argo == "A" else "Y"
	if id == "Syracuse":
		return "R" if s.siracusa == "S" else "Y"
	if id == "Sardis":
		return "R" if s.persia else "Y"
	if id == "Corcyra" and s.corcira_neutrale:
		return "Y"
	return Dati.spazi[id].c

func lato_colore(id: String) -> String:
	return {"G": "A", "R": "S", "Y": ""}[colore(id)]

func in_rivolta(id: String) -> bool:
	return s.sp.has(id) and s.sp[id].riv

## Il lato a cui lo spazio è amico per natura (colore, rovesciato se in rivolta).
func nat(id: String) -> String:
	var c := lato_colore(id)
	if in_rivolta(id) and c != "":
		return Dati.AVV[c]
	return c

func ctrl(id: String) -> String:
	var a := presenti(id, "A") > 0
	var b := presenti(id, "S") > 0
	if a and not b:
		return "A"
	if b and not a:
		return "S"
	return nat(id)

## Vero se un'armata di quel lato deve conquistare lo spazio (assedio se c'è una fortezza).
func nemico_per(id: String, lato: String) -> bool:
	if nat(id) == lato:
		return false
	if lato_colore(id) == "" and in_rivolta(id):
		return false
	return true

func zoi_da(id: String, lato: String, comb: bool) -> Dictionary:
	var r := {id: true}
	var u := unita(id)
	var cav := conta(u, lato, "C") > 0
	var nav := conta(u, lato, "N") > 0
	if cav and not (comb and lato == "A" and (id == "Athens" or id == "Piraeus")):
		for b in Dati.spazi[id].l:
			if Dati.spazi[id].l[b] != "S":
				r[b] = true
	if nav:
		for b in Dati.spazi[id].l:
			if Dati.spazi[id].l[b] != "L":
				r[b] = true
				for c in Dati.spazi[b].l:
					if Dati.spazi[b].l[c] != "L":
						r[c] = true
	if lato == "S":
		for m in ["Athens", "Piraeus"]:
			if m != id:
				r.erase(m)
	return r

## Spazi con forze di quel lato la cui zona d'influenza copre il bersaglio.
func copre(lato: String, bersaglio: String, comb: bool = false) -> Array:
	var r := []
	for id in s.sp:
		if presenti(id, lato) > 0 and zoi_da(id, lato, comb).has(bersaglio):
			r.append(id)
	return r

# ------------------------------------------------------------------ percorsi
static func comp_di(u: Dictionary) -> Dictionary:
	var t := 0
	var m := 0
	for k in u:
		if Dati.tipo_di(k) == "N":
			m += int(u[k])
		else:
			t += int(u[k])
	return {"terra": t, "mare": m}

func _entra_ok(b: String, lato: String, ob: String, dest: String, comp: Dictionary) -> bool:
	if b == "Argos" and s.argo == "":
		return false
	if b == "Syracuse" and s.siracusa == "":
		return false
	if b in ["Naupactus", "Amphipolis", "Byzantium"] and ctrl(b) != lato and b != ob:
		return false
	if b == "Sardis" and not s.persia:
		return false
	if comp.terra + comp.mare == 0:      # condottiero da solo
		if presenti(b, Dati.AVV[lato]) > 0:
			return false
		if nat(b) == Dati.AVV[lato] and b != dest:
			return false
	return true

func _arco_ok(a: String, b: String, comp: Dictionary, lato: String, gioc: bool) -> bool:
	var k: String = Dati.spazi[a].l[b]
	var solo: bool = comp.terra + comp.mare == 0
	if (a == "Cape Taenarum" and b == "Syracuse") or (a == "Syracuse" and b == "Cape Taenarum"):
		if not gioc:
			return false
	if solo or k == "C":
		return true
	if k == "L":
		if comp.mare == 0:
			return true
		var istmo := (a == "Corinth" and b == "Cenchrae") or (a == "Cenchrae" and b == "Corinth")
		return istmo and ctrl("Corinth") == lato and ctrl("Cenchrae") == lato
	return comp.mare > 0 and comp.terra <= comp.mare

## Percorso più breve (lista degli spazi dopo la partenza). null se non esiste. A parità sceglie a caso.
func percorso(da: String, a: String, comp: Dictionary, lato: String, ob: String, gioc: bool):
	if da == a:
		return []
	var dist := {da: 0}
	var prec := {}
	var coda := [da]
	var i := 0
	while i < coda.size():
		var x: String = coda[i]
		i += 1
		if dist.has(a) and dist[x] >= dist[a]:
			break
		for b in Dati.spazi[x].l:
			if not _arco_ok(x, b, comp, lato, gioc) or not _entra_ok(b, lato, ob, a, comp):
				continue
			if not dist.has(b):
				dist[b] = dist[x] + 1
				prec[b] = [x]
				coda.append(b)
			elif dist[b] == dist[x] + 1:
				prec[b].append(x)
	if not dist.has(a):
		return null
	var p := [a]
	var c := a
	while c != da:
		var pr: Array = prec[c]
		c = pr[rng.randi_range(0, pr.size() - 1)]
		if c != da:
			p.push_front(c)
	return p

## Distanze in passi da uno spazio, senza restrizioni (per ordinare gli spazi "più vicini").
func distanze(da: String) -> Dictionary:
	var dist := {da: 0}
	var coda := [da]
	var i := 0
	while i < coda.size():
		var x: String = coda[i]
		i += 1
		for b in Dati.spazi[x].l:
			if not dist.has(b):
				dist[b] = dist[x] + 1
				coda.append(b)
	return dist

# ------------------------------------------------------------------ perdite e ritorni a casa
func _registra_perdita(k: String) -> void:
	s.perse[k] = s.perse.get(k, 0) + 1
	if Dati.lato_di(k) == "A" and Dati.tipo_di(k) == "N":
		s.navi_perse += 1

## Elimina n punti forza da u secondo le priorità (5.7.1). ambito: "tutto", "terra", "mare". Restituisce le sigle perse.
func perdi(u: Dictionary, lato: String, n: int, tipo_spazio: String, ambito: String, immune_guardia: bool = false) -> Array:
	var ordine := ["H", "C", "N"] if tipo_spazio != "I" else ["N", "C", "H"]
	if ambito == "terra":
		ordine = ["H", "C"] if tipo_spazio != "I" else ["C", "H"]
	elif ambito == "mare":
		ordine = ["N"]
	var perse := []
	while n > 0:
		var scelta := ""
		for t in ordine:
			var naz := ["aH", "AH"] if lato == "A" else ["sH", "SH", "SG"]
			if t == "C":
				naz = ["aC", "AC"] if lato == "A" else ["sC", "SC"]
			elif t == "N":
				naz = ["aN", "AN"] if lato == "A" else ["sN", "SN"]
			for k in naz:
				if u.get(k, 0) > 0 and not (k == "SG" and immune_guardia):
					scelta = k
					break
			if scelta != "":
				break
		if scelta == "":
			break
		_togli(u, scelta)
		_registra_perdita(scelta)
		perse.append(scelta)
		n -= 1
	if perse.has("SG"):
		s.guardia_persa = true
		if u.get("SG", 0) > 0:
			u["SH"] = u.get("SH", 0) + u["SG"]
			u.erase("SG")
	return perse

func _sistema_attivate(id: String) -> void:
	if not s.sp.has(id):
		return
	var x: Dictionary = s.sp[id]
	for k in x.a.keys():
		if x.a[k] > x.u.get(k, 0):
			x.a[k] = x.u.get(k, 0)
		if x.a[k] <= 0:
			x.a.erase(k)

func _in_ritorno(u: Dictionary, lato: String) -> void:
	for k in u.keys():
		if Dati.lato_di(k) == lato and k != "SG":
			s.rit[k] = s.rit.get(k, 0) + u[k]
			u.erase(k)

func _capo_a_casa(c: String) -> void:
	if s.capi[c].stato == "mappa":
		s.capi[c] = {"stato": "ritorno", "pos": ""}

## Manda nel riquadro "Ritorno a casa" la forza (unità e condottieri) di un lato in uno spazio.
func forza_a_casa(id: String, lato: String) -> void:
	if s.sp.has(id):
		_in_ritorno(s.sp[id].u, lato)
		_sistema_attivate(id)
	for c in capi_in(id, lato):
		_capo_a_casa(c)

func _valido(id: String, lato: String) -> bool:
	return not in_rivolta(id) and ctrl(id) == lato

## Colloca n punti forza appena tornati (o costruiti) secondo la tabella dei movimenti dopo il combattimento.
func rientra(k: String, n: int) -> void:
	var lato := Dati.lato_di(k)
	while n > 0:
		var dove := _destinazione(k)
		if dove == "":
			_registra_perdita(k)
			nota("op", "1 punto di %s non ha un porto dove rientrare ed è eliminato." % Dati.NOME_UNITA[k])
		else:
			_metti(dove, {k: 1})
			s.rientri[dove] = s.rientri.get(dove, 0) + 1
		n -= 1
	var _l := lato

func _destinazione(k: String) -> String:
	var t := Dati.tipo_di(k)
	match k:
		"AH", "AC":
			return "Athens" if ctrl("Athens") == "A" else ""
		"AN":
			return "Piraeus" if ctrl("Piraeus") == "A" else ""
		"SH", "SC", "SG":
			return "Sparta" if ctrl("Sparta") == "S" else ""
		"SN":
			if ctrl("Gythium") == "S":
				return "Gythium"
			return "Corinth" if ctrl("Corinth") == "S" else ""
		"aH":
			var c: int = s.conta_rientri.get("aH", 0)
			s.conta_rientri["aH"] = c + 1
			var seq := ["Amphipolis"]
			if s.argo == "A" and presenti("Argos", "S") == 0:
				seq += ["Argos", "Argos", "Argos", "Argos"]
			seq += ["Larisa", "Larisa"]
			if c < seq.size() and _valido(seq[c], "A"):
				return seq[c]
			return _meta(["Corcyra", _chio()], "A", "Athens", c)
		"aC":
			if s.macedonia == "A" and presenti("Pela", "S") == 0 and presenti("Pela", "A", "C") < 2:
				return "Pela"
			return "Larisa" if _valido("Larisa", "A") else ("Athens" if ctrl("Athens") == "A" else "")
		"aN":
			var c2: int = s.conta_rientri.get("aN", 0)
			s.conta_rientri["aN"] = c2 + 1
			return _meta(["Corcyra", _chio()], "A", "Piraeus", c2)
		"sH":
			if s.siracusa == "S" and presenti("Syracuse", "A") == 0 and presenti("Syracuse", "S", "H") < 2:
				return "Syracuse"
			var c3: int = s.conta_rientri.get("sH", 0)
			s.conta_rientri["sH"] = c3 + 1
			return _meta(["Corinth", "Thebes"], "S", "Sparta", c3)
		"sC":
			if s.persia and s.iaso and presenti("Sardis", "A") == 0 and presenti("Sardis", "S", "C") < 3:
				return "Sardis"
			if s.macedonia == "S" and presenti("Pela", "A") == 0 and presenti("Pela", "S", "C") < 2:
				return "Pela"
			if s.siracusa == "S" and presenti("Syracuse", "A") == 0 and presenti("Syracuse", "S", "C") < 2:
				return "Syracuse"
			return "Thebes" if _valido("Thebes", "S") else ("Sparta" if ctrl("Sparta") == "S" else "")
		"sN":
			if s.siracusa == "S" and presenti("Syracuse", "A") == 0 and presenti("Syracuse", "S", "N") < 2:
				return "Syracuse"
			if _valido("Corinth", "S"):
				return "Corinth"
			return "Gythium" if ctrl("Gythium") == "S" else ""
	var _t := t
	return ""

func _chio() -> String:
	if _valido("Chios", "A"):
		return "Chios"
	s["samo_coalizione"] = true
	return "Samos"

func _meta(due: Array, lato: String, riserva: String, indice: int) -> String:
	var ok := []
	for x in due:
		if _valido(x, lato) and not (x == "Corcyra" and s.corcira_neutrale):
			ok.append(x)
	if ok.is_empty():
		return riserva if ctrl(riserva) == lato else ""
	return ok[indice % ok.size()]

func ritorno_a_casa() -> void:
	s["rientri"] = {}
	s["conta_rientri"] = {}
	var r: Dictionary = s.rit
	s.rit = {}
	for k in Dati.CHIAVI:
		if r.get(k, 0) > 0:
			rientra(k, r[k])
	if not s.rientri.is_empty():
		var p := []
		for id in s.rientri:
			p.append("%d a %s" % [s.rientri[id], Dati.nome(id)])
		nota("op", "Ritorno a casa: " + ", ".join(p) + ".")

# ------------------------------------------------------------------ battaglie
## Una forza in battaglia: {lato, u (dizionario vivo), capi, dove ("op" o id dello spazio)}
func _forza_spazio(id: String, lato: String) -> Dictionary:
	return {"lato": lato, "u": sp(id).u, "capi": capi_in(id, lato), "dove": id}

func _forza_op() -> Dictionary:
	return {"lato": op.lato, "u": op.u, "capi": [op.capo], "dove": "op"}

func _sconfitta(f: Dictionary) -> void:
	if f.dove == "op":
		_in_ritorno(op.u, op.lato)
		_capo_a_casa(op.capo)
		op.annullata = true
	else:
		forza_a_casa(f.dove, f.lato)

func _muore_capo(f: Dictionary, dado: int) -> void:
	if not s.ev_morti or dado > 3 or f.capi.is_empty() or s.morti[f.lato] >= 3:
		return
	for c in f.capi:
		if c in ["alcibiades", "pericles"]:
			continue
		s.capi[c] = {"stato": "morto", "pos": ""}
		s.morti[f.lato] += 1
		f.capi.erase(c)
		nota("ev", "%s cade in battaglia (dado non modificato %d)." % [Dati.capo_nome(c), dado])
		if f.dove == "op" and op.capo == c:
			op["senza_capo"] = true
		return

## Risolve una battaglia. Restituisce il lato vincitore, "" per pareggio o battaglia nulla.
func battaglia(fa: Dictionary, fb: Dictionary, luogo: String, stesso_spazio: bool, da_scontro: bool) -> String:
	var na := conta(fa.u, fa.lato, "N")
	var nb := conta(fb.u, fb.lato, "N")
	var ta := conta(fa.u, fa.lato) - na
	var tb := conta(fb.u, fb.lato) - nb
	if (ta == 0 and nb == 0 and na > 0 and tb > 0) or (tb == 0 and na == 0 and nb > 0 and ta > 0):
		return _nulla(fa, fb, luogo, stesso_spazio, da_scontro)
	var v := ""
	if na > 0 and nb > 0:
		v = _navale(fa, fb, luogo)
	else:
		v = _terrestre(fa, fb, luogo)
	for f in [fa, fb]:
		if f.dove != "op":
			_sistema_attivate(f.dove)
	return v

func _nulla(fa: Dictionary, fb: Dictionary, luogo: String, stesso: bool, da_scontro: bool) -> String:
	nota("op", "Battaglia nulla a %s: una flotta contro truppe di terra." % Dati.nome(luogo))
	if da_scontro or not stesso:
		return ""
	if lato_colore(luogo) == "" and not in_rivolta(luogo):
		for f in [fa, fb]:
			for k in f.u.keys():
				if Dati.tipo_di(k) == "N" and Dati.lato_di(k) == f.lato:
					s.rit[k] = s.rit.get(k, 0) + f.u[k]
					f.u.erase(k)
		_sistema_attivate(luogo)
		return ""
	var arm_a: bool = not fa.capi.is_empty()
	var arm_b: bool = not fb.capi.is_empty()
	if arm_a and not arm_b:
		_sconfitta(fa)
	elif arm_b and not arm_a:
		_sconfitta(fb)
	elif arm_a and arm_b:
		_sconfitta(fa if nemico_per(luogo, fa.lato) else fb)
	return ""

func _esito_pv(v: String) -> void:
	if v == s.lato_g:
		pv_piu(10, "battaglia vinta")
	elif v != "":
		pv_piu(-15, "battaglia persa")

func _navale(fa: Dictionary, fb: Dictionary, luogo: String) -> String:
	var f := [fa, fb]
	var n := [conta(fa.u, fa.lato, "N"), conta(fb.u, fb.lato, "N")]
	var dado := [d6(), d6()]
	var tot := [0, 0]
	var txt := []
	for i in 2:
		var m := 0
		var d := []
		if f[i].lato == "A" and f[i].u.get("AN", 0) * 2 >= n[i]:
			m += 2
			d.append("+2 flotta ateniese")
		if n[i] > n[1 - i]:
			m += n[i] - n[1 - i]
			d.append("+%d navi in più" % (n[i] - n[1 - i]))
		var t := tattico(f[i].capi)
		if t != 0:
			m += t
			d.append("%+d %s" % [t, Dati.capo_nome(f[i].capi[0]) if f[i].capi.size() == 1 else "condottieri"])
		tot[i] = dado[i] + m
		txt.append("%s dado %d%s = %d" % [nl(f[i].lato), dado[i], (" (" + ", ".join(d) + ")") if not d.is_empty() else "", tot[i]])
	nota("batt", "Battaglia navale a %s: %s; %s." % [Dati.nome(luogo), txt[0], txt[1]])
	var ta := [tattico(fa.capi), tattico(fb.capi)]
	for i in 2:
		_muore_capo(f[i], dado[i])
	var v := -1
	if tot[0] != tot[1]:
		v = 0 if tot[0] > tot[1] else 1
	elif ta[0] != ta[1] and max(ta[0], ta[1]) > 0:
		v = 0 if ta[0] > ta[1] else 1
	if v < 0:
		nota("batt", "Pareggio: ognuno perde 1 punto di navi e tutti tornano a casa.")
		if not (n[0] == 1 and n[1] == 1):
			for i in 2:
				perdi(f[i].u, f[i].lato, 1, "I", "mare")
		_sconfitta(fa)
		_sconfitta(fb)
		return ""
	var p: int = min(abs(tot[0] - tot[1]), n[v])
	var perse := perdi(f[1 - v].u, f[1 - v].lato, p, "I", "mare")
	nota("batt", "Vince %s. %s perde %d punti di navi." % [nl(f[v].lato), nl(f[1 - v].lato), perse.size()])
	_esito_pv(f[v].lato)
	var hv := conta(f[v].u, f[v].lato, "H")
	var hp := conta(f[1 - v].u, f[1 - v].lato, "H")
	if hv >= max(hp, 1):
		nota("batt", "Il vincitore sbarca: segue una battaglia di terra.")
		return _terrestre(fa, fb, luogo)
	_sconfitta(f[1 - v])
	sci_piu(f[v].lato, 1)
	if n[v] < n[1 - v] + 3:
		sci_piu(f[1 - v].lato, -1)
	return f[v].lato

func _terrestre(fa: Dictionary, fb: Dictionary, luogo: String) -> String:
	if luogo == "Sparta":
		var cp := coppa("S")
		if not cp.is_empty():
			var c: String = cp[rng.randi_range(0, cp.size() - 1)]
			_capo_in(c, "Sparta")
			nota("batt", "Si combatte a Sparta: accorre %s." % Dati.capo_nome(c))
			for ff in [fa, fb]:
				if ff.lato == "S" and ff.dove == "Sparta":
					ff.capi = capi_in("Sparta", "S")
	var f := [fa, fb]
	var h := [conta(fa.u, fa.lato, "H"), conta(fb.u, fb.lato, "H")]
	var cv := [conta(fa.u, fa.lato, "C"), conta(fb.u, fb.lato, "C")]
	var dado := [d6(), d6()]
	var tot := [0, 0]
	var txt := []
	for i in 2:
		var m := 0
		var d := []
		if f[i].lato == "S":
			if luogo == "Sparta":
				m += 2
				d.append("+2 a Sparta")
			var sh: int = f[i].u.get("SH", 0) + f[i].u.get("SG", 0)
			if sh > 0 and sh * 2 >= h[i]:
				m += 2
				d.append("+2 opliti spartani")
		if cv[i] > cv[1 - i]:
			m += 1
			d.append("+1 cavalleria")
		if h[i] > h[1 - i]:
			m += h[i] - h[1 - i]
			d.append("+%d opliti in più" % (h[i] - h[1 - i]))
		var t := tattico(f[i].capi)
		if t != 0:
			m += t
			d.append("%+d %s" % [t, Dati.capo_nome(f[i].capi[0]) if f[i].capi.size() == 1 else "condottieri"])
		tot[i] = dado[i] + m
		txt.append("%s dado %d%s = %d" % [nl(f[i].lato), dado[i], (" (" + ", ".join(d) + ")") if not d.is_empty() else "", tot[i]])
	nota("batt", "Battaglia di terra a %s: %s; %s." % [Dati.nome(luogo), txt[0], txt[1]])
	var ta := [tattico(fa.capi), tattico(fb.capi)]
	for i in 2:
		_muore_capo(f[i], dado[i])
	var v := -1
	if tot[0] != tot[1]:
		v = 0 if tot[0] > tot[1] else 1
	elif ta[0] != ta[1] and max(ta[0], ta[1]) > 0:
		v = 0 if ta[0] > ta[1] else 1
	var ts: String = Dati.spazi[luogo].t
	if v < 0:
		nota("batt", "Pareggio: ognuno perde 1 punto di truppe e tutti tornano a casa.")
		var la: int = h[0] + cv[0]
		var lb: int = h[1] + cv[1]
		if not (la == 1 and lb == 1):
			for i in 2:
				_ostaggi(f[1 - i].lato, perdi(f[i].u, f[i].lato, 1, ts, "terra"))
		_sconfitta(fa)
		_sconfitta(fb)
		return ""
	var p: int = min(abs(tot[0] - tot[1]), h[v])
	var ecc: int = max(0, cv[1 - v] - cv[v])
	p = max(1, p - ecc)
	var perse := perdi(f[1 - v].u, f[1 - v].lato, p, ts, "terra")
	nota("batt", "Vince %s. %s perde %d punti di truppe." % [nl(f[v].lato), nl(f[1 - v].lato), perse.size()])
	_ostaggi(f[v].lato, perse)
	_esito_pv(f[v].lato)
	_sconfitta(f[1 - v])
	sci_piu(f[v].lato, 1)
	if h[v] < h[1 - v] + 3:
		sci_piu(f[1 - v].lato, -1)
	return f[v].lato

func _ostaggi(vincitore: String, perse: Array) -> void:
	if s.ostaggi[vincitore]:
		return
	for k in perse:
		if k in ["AH", "SH", "SG"]:
			s.ostaggi[vincitore] = true
			nota("ev", "%s cattura degli ostaggi: finché non c'è una tregua %s non può attaccare la capitale nemica." % [nl(vincitore), nl(Dati.AVV[vincitore])])
			return

# ------------------------------------------------------------------ operazioni: movimento, intercettazioni
func _op_nuova(lato: String, ob: String, capo: String, np: bool) -> void:
	op = {"lato": lato, "ob": ob, "capo": capo, "pos": Dati.CASA[lato], "u": {}, "np": np, "annullata": false, "rib": false, "tappe": [Dati.CASA[lato]]}
	s.percorso = [Dati.CASA[lato]]
	s.ultimo_ob = ob
	if ob == "Syracuse" and lato == "A" and s.siracusa == "":
		_attiva_siracusa()
	if ob == "Argos" and lato == "S" and s.argo == "":
		_attiva_argo()
	if lato == "S" and not s.obiettivi_S.has(ob):
		s.obiettivi_S.append(ob)

func _attiva_siracusa() -> void:
	s.siracusa = "S"
	_metti("Syracuse", {"sH": 2, "sC": 2, "sN": 2})
	nota("ev", "Siracusa entra in guerra a fianco di Sparta con 2 opliti, 2 di cavalleria e 2 di navi.")

func _attiva_argo() -> void:
	s.argo = "A"
	_metti("Argos", {"aH": 4})
	nota("ev", "Argo entra in guerra a fianco di Atene con 4 punti di opliti.")

func _costo(k: String) -> int:
	if k == "SH" or k == "SC":
		return 0
	return 400 if Dati.tipo_di(k) == "N" else 200

func fondo_emergenza_sospeso() -> bool:
	if ctrl("Piraeus") == "S" or ctrl("Decelea") == "S":
		return true
	var n := 0
	for id in s.sp:
		if s.sp[id].riv and lato_colore(id) == "A":
			n += 1
	return n >= 10

func spendibile(lato: String) -> int:
	if lato == "A" and not fondo_emergenza_sospeso():
		return max(0, s.tes.A - 1000)
	return max(0, s.tes[lato])

## Attiva unità nello spazio dove si trova la spedizione. Restituisce "" o il motivo del rifiuto.
func _attiva(u: Dictionary) -> String:
	var disp := disponibili(op.pos, op.lato)
	var costo := 0
	for k in u:
		if u[k] > disp.get(k, 0):
			return "Non ci sono abbastanza unità disponibili."
		costo += _costo(k) * u[k]
	if costo > spendibile(op.lato):
		return "Il tesoro non basta (servono %d talenti)." % costo
	var x := sp(op.pos)
	for k in u:
		if u[k] > 0:
			_togli(x.u, k, u[k])
			op.u[k] = op.u.get(k, 0) + u[k]
	_sistema_attivate(op.pos)
	s.tes[op.lato] -= costo
	nota("op", "A %s si uniscono %s (%d talenti)." % [Dati.nome(op.pos), descrivi(u), costo])
	return ""

func _deposita(id: String, u: Dictionary) -> void:
	var x := sp(id)
	for k in u:
		if u[k] > 0:
			x.u[k] = x.u.get(k, 0) + u[k]
			x.a[k] = x.a.get(k, 0) + u[k]

func _op_fine_qui() -> void:
	_deposita(op.pos, op.u)
	op.u = {}
	if s.capi[op.capo].stato == "mappa":
		s.capi[op.capo].pos = op.pos

## Muove la spedizione fino a dest. Falso se l'operazione è stata annullata.
func muovi(dest: String, verso_ob: bool) -> bool:
	var guardia := 0
	while op.pos != dest and guardia < 80:
		guardia += 1
		var comp := comp_di(op.u)
		var p = percorso(op.pos, dest, comp, op.lato, op.ob, not op.np)
		if p == null:
			if comp.mare > 0 and comp.terra > comp.mare:
				var ecc: int = comp.terra - comp.mare
				var lasciate := {}
				for k in ["aH", "sH", "AH", "SH", "aC", "sC", "AC", "SC"]:
					while ecc > 0 and op.u.get(k, 0) > 0:
						_togli(op.u, k)
						lasciate[k] = lasciate.get(k, 0) + 1
						ecc -= 1
				_deposita(op.pos, lasciate)
				nota("op", "Le navi non bastano: restano a %s %s." % [Dati.nome(op.pos), descrivi(lasciate)])
				continue
			nota("op", "Nessuna rotta possibile verso %s: la spedizione si ferma a %s." % [Dati.nome(dest), Dati.nome(op.pos)])
			return false
		var b: String = p[0]
		if (op.pos == "Cape Taenarum" and b == "Syracuse") or (op.pos == "Syracuse" and b == "Cape Taenarum"):
			var dt := d6()
			if dt >= 5:
				nota("batt", "Traversata verso %s (dado %d): una tempesta distrugge la spedizione." % [Dati.nome(b), dt])
				for k in op.u.keys():
					for i in op.u[k]:
						_registra_perdita(k)
				op.u = {}
				_capo_a_casa(op.capo)
				op.annullata = true
				return false
			nota("op", "Traversata verso %s riuscita (dado %d)." % [Dati.nome(b), dt])
		var avv: String = Dati.AVV[op.lato]
		var era_nemico := ctrl(b) == avv
		op.pos = b
		s.capi[op.capo].pos = b
		s.percorso.append(b)
		var intercettata := false
		var forze := copre(avv, b)
		if not forze.is_empty():
			var fz: String = forze[rng.randi_range(0, forze.size() - 1)]
			var di := d6()
			if di >= 4:
				intercettata = true
				if not _scontro(fz, b, di):
					return false
			else:
				nota("op", "A %s l'intercettazione da %s fallisce (dado %d)." % [Dati.nome(b), Dati.nome(fz), di])
		if verso_ob and era_nemico and not intercettata and presenti(b, avv) == 0 and not sp(b).dev:
			sp(b).dev = true
			nota("op", "%s viene devastata." % Dati.nome(b))
	return op.pos == dest

## Intercettazione riuscita: scaramuccia ed eventuale battaglia. Falso se l'operazione finisce.
func _scontro(fz: String, qui: String, dado_int: int) -> bool:
	var avv: String = Dati.AVV[op.lato]
	if conta(op.u, op.lato) == 0:
		nota("op", "%s, da solo, è intercettato a %s dalle forze di %s (dado %d) e torna a casa: operazione annullata." % [Dati.capo_nome(op.capo), Dati.nome(qui), Dati.nome(fz), dado_int])
		_capo_a_casa(op.capo)
		op.annullata = true
		return false
	var ts: String = Dati.spazi[qui].t
	var d1 := d6()
	var d2 := d6()
	var t := "Intercettata a %s dalle forze di %s (dado %d). Scaramuccia: %s %d, %s %d." % [Dati.nome(qui), Dati.nome(fz), dado_int, nl(op.lato), d1, nl(avv), d2]
	if d1 == 1:
		var pp := perdi(op.u, op.lato, 1, ts, "tutto", true)
		if not pp.is_empty():
			t += " La spedizione perde 1 punto di %s." % Dati.NOME_UNITA[pp[0]]
	if d2 == 1:
		var pq := perdi(sp(fz).u, avv, 1, ts, "tutto", true)
		_sistema_attivate(fz)
		if not pq.is_empty():
			t += " Chi intercetta perde 1 punto di %s." % Dati.NOME_UNITA[pq[0]]
	nota("batt", t)
	if conta(op.u, op.lato) == 0:
		nota("op", "%s resta senza truppe e torna a casa: operazione annullata." % Dati.capo_nome(op.capo))
		_capo_a_casa(op.capo)
		op.annullata = true
		return false
	if presenti(fz, avv) == 0:
		return true
	var te := conta(op.u, op.lato) - conta(op.u, op.lato, "N")
	var ti := presenti(fz, avv) - presenti(fz, avv, "N")
	var ne := conta(op.u, op.lato, "N")
	var ni := presenti(fz, avv, "N")
	var batt := d1 + d2 >= 11
	if ts != "I" and te + ti >= 8 and ti * 2 >= te + ti:
		batt = true
	if ts != "L" and ne + ni >= 8 and ni * 2 >= ne + ni:
		batt = true
	if not batt:
		return true
	var v := battaglia(_forza_op(), _forza_spazio(fz, avv), qui, fz == qui, true)
	if op.annullata or conta(op.u, op.lato) == 0:
		if not op.annullata:
			_capo_a_casa(op.capo)
			op.annullata = true
		nota("op", "La spedizione è respinta: operazione annullata.")
		return false
	if op.has("senza_capo"):
		nota("op", "Senza condottiero la spedizione si ferma a %s." % Dati.nome(qui))
		_deposita(qui, op.u)
		op.u = {}
		op.annullata = true
		return false
	var _v := v
	return true

# ------------------------------------------------------------------ operazioni del giocatore
func capi_casa(lato: String) -> Array:
	return capi_in(Dati.CASA[lato], lato)

func obiettivo_valido(id: String, rib: bool) -> String:
	var g: String = s.lato_g
	var avv: String = Dati.AVV[g]
	if id == "Sardis" and not s.persia:
		return "Sardi non può essere un obiettivo finché la Persia non entra in guerra."
	if id == "Argos" and g == "A" and s.argo == "":
		return "Le forze ateniesi non possono entrare ad Argo finché resta neutrale."
	if id == "Syracuse" and g == "S" and s.siracusa == "":
		return "Le forze spartane non possono entrare a Siracusa finché resta neutrale."
	if s.ostaggi[avv] and (id == Dati.CASA[avv] or Dati.spazi[Dati.CASA[avv]].l.has(id)):
		return "Il nemico ha degli ostaggi: non puoi puntare sulla sua capitale né sugli spazi adiacenti."
	if rib:
		if presenti(id, avv) > 0:
			return "Non si può fomentare la rivolta dove c'è una forza nemica."
		if id == Dati.CASA[avv] or id in Dati.COALIZIONE[avv] or (avv == "A" and id == "Samos" and not _valido("Chios", "A")):
			return "Non si può fomentare la rivolta nella capitale o in uno spazio di coalizione del nemico."
		if id in ["Argos", "Syracuse", "Pela", "Macedonia", "Sardis"]:
			return "Gli spazi delle potenze minori si ribellano solo per evento."
		if in_rivolta(id):
			return "Lo spazio è già in rivolta."
		if lato_colore(id) == g:
			return "È uno spazio della tua lega."
		if spendibile(g) < 100:
			return "Servono 100 talenti."
	return ""

func raduni_possibili() -> Array:
	var r := []
	for id in s.sp:
		if ctrl(id) == op.lato and not disponibili(id, op.lato).is_empty():
			r.append(id)
	return r

func g_inizia(ob: String, rib: bool, capo: String) -> String:
	if s.attesa.get("tipo", "") != "operazione":
		return "Non è il momento."
	var e := obiettivo_valido(ob, rib)
	if e != "":
		return e
	if not capi_casa(s.lato_g).has(capo):
		return "Il condottiero deve essere nella capitale."
	s.riepilogo = []
	_op_nuova(s.lato_g, ob, capo, false)
	op.rib = rib
	s.op_fatte[s.lato_g] += 1
	nota("op", "%s: %s guida una spedizione verso %s%s." % [nl(op.lato), Dati.capo_nome(capo), Dati.nome(ob), " per fomentare la rivolta" if rib else ""])
	if rib:
		s.tes[op.lato] -= 100
		var d := d6()
		if d < 6:
			nota("op", "Fomentare la rivolta a %s (100 talenti, dado %d): fallita. Operazione annullata." % [Dati.nome(ob), d])
			op = {}
			_dopo_op(s.lato_g)
			return ""
		sp(ob).riv = true
		nota("op", "Fomentare la rivolta a %s (100 talenti, dado %d): %s insorge." % [Dati.nome(ob), d, Dati.nome(ob)])
	s.attesa = {"tipo": "raduno"}
	return ""

## Sposta il condottiero nello spazio di raduno (se serve) e attiva le unità indicate.
func g_attiva(id: String, u: Dictionary) -> String:
	if s.attesa.get("tipo", "") != "raduno":
		return "Non è il momento."
	if ctrl(id) != op.lato:
		return "Non è uno spazio amico."
	var disp := disponibili(id, op.lato)
	var costo := 0
	var tot := 0
	for k in u:
		if u[k] > disp.get(k, 0):
			return "Non ci sono abbastanza unità disponibili."
		costo += _costo(k) * u[k]
		tot += u[k]
	if tot == 0:
		return "Scegli almeno un'unità."
	if costo > spendibile(op.lato):
		return "Il tesoro non basta: servono %d talenti%s." % [costo, " (Atene deve tenerne 1000 di riserva)" if op.lato == "A" and not fondo_emergenza_sospeso() else ""]
	if id != op.pos:
		if percorso(op.pos, id, comp_di(op.u), op.lato, op.ob, true) == null:
			return "La spedizione non può raggiungere %s con le forze attuali." % Dati.nome(id)
		if not muovi(id, false):
			_g_fine_op()
			return ""
		op.tappe.append(id)
		for k in u:
			u[k] = min(u[k], disponibili(id, op.lato).get(k, 0))
	_attiva(u)
	return ""

func g_marcia() -> String:
	if s.attesa.get("tipo", "") != "raduno":
		return "Non è il momento."
	if percorso(op.pos, op.ob, comp_di(op.u), op.lato, op.ob, true) == null:
		return "Con queste forze la spedizione non può raggiungere %s (servono navi per il mare, e una flotta non marcia nell'entroterra)." % Dati.nome(op.ob)
	if muovi(op.ob, true):
		nota("op", "La spedizione di %s arriva a %s con %s." % [Dati.capo_nome(op.capo), Dati.nome(op.ob), descrivi(op.u)])
	_g_fine_op()
	return ""

func _g_fine_op() -> void:
	if not op.annullata:
		_op_fine_qui()
	_segna_attica()
	op = {}
	_dopo_op(s.lato_g)

## Scioglie la spedizione dove si trova (quando non può proseguire o non conviene più).
func g_rinuncia() -> void:
	if s.attesa.get("tipo", "") != "raduno":
		return
	nota("op", "La spedizione di %s si ferma a %s." % [Dati.capo_nome(op.capo), Dati.nome(op.pos)])
	_g_fine_op()

func g_passa() -> void:
	if s.attesa.get("tipo", "") != "operazione":
		return
	s.passato[s.lato_g] = true
	s.riepilogo = []
	nota("op", "%s passa: niente più operazioni in questo turno." % nl(s.lato_g))
	_dopo_op(s.lato_g)

func _dopo_op(lato: String) -> void:
	s.attesa = {}
	if s.passo == "op_g_iniziale":
		s.passo = "op_n_iniziale"
	elif s.passo == "op_n_iniziale":
		s.passo = "op_continua"
		s.tocca = s.lato_g
	else:
		s.tocca = Dati.AVV[lato]
	if lato == s.lato_g:
		s.attesa = {"tipo": "continua", "titolo": "Operazione conclusa"}

func _segna_attica() -> void:
	for id in ["Athens", "Piraeus", "Panactum", "Decelea"]:
		if presenti(id, "S") > 0:
			s.attica_ora = true

# ------------------------------------------------------------------ operazioni del lato guidato dal gioco
func _np() -> String:
	return Dati.AVV[s.lato_g]

func _difesa() -> Dictionary:
	var np := _np()
	if np == "S":
		var dist := {"Sparta": 0}
		var coda := ["Sparta"]
		var i := 0
		while i < coda.size():
			var x: String = coda[i]
			i += 1
			if dist[x] >= 2:
				continue
			for b in Dati.spazi[x].l:
				if Dati.spazi[x].l[b] != "S" and not dist.has(b):
					dist[b] = dist[x] + 1
					coda.append(b)
		var meglio := ""
		for id in dist:
			if presenti(id, "A") > 0 and not s.difese.has(id) and (meglio == "" or dist[id] < dist[meglio]):
				meglio = id
		if meglio != "":
			return {"ob": meglio, "forza": {"H": 10, "C": 1}}
		var due := []
		for id in ["Corinth", "Thebes"]:
			if presenti(id, "A") > 0 and not s.difese.has(id):
				due.append(id)
		if not due.is_empty():
			return {"ob": due[rng.randi_range(0, due.size() - 1)], "forza": {"H": 10, "C": 1}}
		if not s.sir_difesa and s.siracusa == "S" and not copre("A", "Syracuse").is_empty():
			var ob: String = Dati.MATRICE.S.attacco.obiettivi[d6() - 1]
			if not (s.ostaggi.A and not s.tregua_fatta):
				return {"ob": ob, "forza": {"H": 10, "C": 1}, "sir": true}
		return {}
	var lista: Array = Dati.DIFESA_ATENE.duplicate()
	var dp := distanze("Proconneus")
	for id in dp:
		if dp[id] <= 2 and not lista.has(id):
			lista.append(id)
	for id in lista:
		if presenti(id, "S") > 0 and not s.difese.has(id):
			return {"ob": id, "forza": {"H": 3, "N": 3}}
	return {}

func _tipo_per_forza(id: String) -> String:
	var t: String = Dati.spazi[id].t
	if _np() == "S":
		if id in Dati.TRACIA:
			return "L"
		if id in Dati.ELLESPONTO and ctrl("Amphipolis") == "S":
			return "L"
	return t

## Sceglie l'obiettivo secondo la matrice. {} se non ne trova uno valido.
func _obiettivo_matrice() -> Dictionary:
	var np := _np()
	var st: String = s.strategia[np]
	var m: Dictionary = Dati.MATRICE[np]
	for tentativo in 60:
		var ob := ""
		var testo := ""
		if st == "attacco":
			var d := d6()
			ob = m.attacco.obiettivi[d - 1]
			testo = "dado %d" % d
		else:
			var dv := d6()
			var area: String = m[st].aree[dv - 1]
			var dr := d6()
			ob = m.aree[area][dr - 1]
			testo = "dado verde %d: %s; dado rosso %d" % [dv, area, dr]
			if np == "A" and area == "Peloponneso e Messenia":
				var mancanti := []
				for x in Dati.ILOTI:
					if ctrl(x) != "A":
						mancanti.append(x)
				if mancanti.size() == 1:
					ob = mancanti[0]
					testo = "manca un solo spazio per la rivolta degli iloti"
		if ctrl(ob) == np:
			continue
		if ob == "Sardis" and not s.persia:
			continue
		if st == "rivolta":
			var avv: String = Dati.AVV[np]
			if presenti(ob, avv) > 0 or ob == Dati.CASA[avv] or ob in Dati.COALIZIONE[avv] or ob in ["Argos", "Syracuse", "Pela"] or in_rivolta(ob):
				continue
			if avv == "A" and ob == "Samos" and not _valido("Chios", "A"):
				continue
		return {"ob": ob, "forza": m[st].forza[_tipo_per_forza(ob)].duplicate(), "testo": testo}
	return {}

func _np_capo() -> String:
	var c := capi_casa(_np())
	if c.is_empty():
		return ""
	return c[rng.randi_range(0, c.size() - 1)]

## Piano di raduno: lista di [spazio, {sigla: n}] nell'ordine di visita, oppure null se la forza non c'è.
func _piano(forza: Dictionary):
	var np := _np()
	var casa: String = Dati.CASA[np]
	var dist := distanze(casa)
	var spazi := []
	for id in s.sp:
		if ctrl(id) == np and not disponibili(id, np).is_empty():
			spazi.append(id)
	spazi.sort_custom(func(a, b): return dist[a] < dist[b] or (dist[a] == dist[b] and a < b))
	var manca := forza.duplicate()
	var presi := {}
	var ordine := []
	for passata in 4:
		for id in spazi:
			if passata < 3 and lato_colore(id) != np and passata == 2:
				continue
			var disp := disponibili(id, np)
			var gia: Dictionary = presi.get(id, {})
			var tot_resto := 0
			for k in disp:
				tot_resto += disp[k] - gia.get(k, 0)
			for t in ["H", "C", "N"]:
				if manca.get(t, 0) <= 0:
					continue
				var naz := ["SH", "sH"] if np == "S" else ["AH", "aH"]
				if t == "C":
					naz = ["SC", "sC"] if np == "S" else ["AC", "aC"]
				elif t == "N":
					naz = ["SN", "sN"] if np == "S" else ["AN", "aN"]
				var resto_tipo := 0
				for k in naz:
					resto_tipo += disp.get(k, 0) - gia.get(k, 0)
				for k in naz:
					while manca[t] > 0 and disp.get(k, 0) - gia.get(k, 0) > 0:
						if passata == 0 and resto_tipo <= 1:
							break
						if passata == 1 and tot_resto <= 1:
							break
						gia[k] = gia.get(k, 0) + 1
						manca[t] -= 1
						resto_tipo -= 1
						tot_resto -= 1
			if not gia.is_empty():
				if not presi.has(id):
					ordine.append(id)
				presi[id] = gia
	for t in manca:
		if manca[t] > 0:
			return null
	var costo := 0
	var r := []
	if presi.has(casa):
		ordine.erase(casa)
		ordine.push_front(casa)
	for id in ordine:
		r.append([id, presi[id]])
		for k in presi[id]:
			costo += _costo(k) * presi[id][k]
	if costo > spendibile(np):
		return null
	return r

func _np_operazione(iniziale: bool) -> void:
	var np := _np()
	s.riepilogo = []
	s.percorso = []
	if s.passato[np]:
		return
	var motivo := ""
	if s.op_fatte[np] >= s.max_op[np]:
		motivo = "i prodigi fermano le operazioni"
	if motivo == "" and not iniziale:
		var d := d6()
		if d + 1 >= 6:
			motivo = "gli auspici sono sfavorevoli (dado %d+1)" % d
		else:
			nota("op", "%s consulta gli auspici: favorevoli (dado %d+1)." % [nl(np), d])
			if capi_casa(np).is_empty():
				var cp := coppa(np)
				if cp.is_empty():
					motivo = "non restano condottieri"
				else:
					var c: String = cp[rng.randi_range(0, cp.size() - 1)]
					_capo_in(c, Dati.CASA[np])
					nota("op", "%s affida il comando a %s." % [nl(np), Dati.capo_nome(c)])
	var capo := _np_capo()
	if motivo == "" and capo == "":
		motivo = "non c'è un condottiero nella capitale"
	var scelta := {}
	var piano = null
	var difesa := false
	if motivo == "":
		scelta = _difesa()
		if not scelta.is_empty():
			difesa = true
			nota("op", "%s adotta la strategia difensiva: obiettivo %s." % [nl(np), Dati.nome(scelta.ob)])
		else:
			scelta = _obiettivo_matrice()
			if scelta.is_empty():
				motivo = "non trova un obiettivo valido"
			else:
				nota("op", "%s, strategia \"%s\": obiettivo %s (%s)." % [nl(np), Dati.NOME_STRATEGIA[s.strategia[np]], Dati.nome(scelta.ob), scelta.testo])
	if motivo == "":
		var extra := 100 if (not difesa and s.strategia[np] == "rivolta") else 0
		piano = _piano(scelta.forza)
		if piano == null or spendibile(np) < extra:
			motivo = "non può radunare la forza richiesta (%s)" % _forza_testo(scelta.forza)
	if motivo != "":
		s.passato[np] = true
		nota("op", "%s passa: %s." % [nl(np), motivo])
		_dopo_op(np)
		s.attesa = {"tipo": "continua", "titolo": "%s passa" % nl(np)}
		return
	s.op_fatte[np] += 1
	_op_nuova(np, scelta.ob, capo, true)
	if difesa:
		if scelta.has("sir"):
			s.sir_difesa = true
	elif s.strategia[np] == "rivolta":
		op.rib = true
		s.tes[np] -= 100
		var dr := d6()
		if dr + 2 < 6:
			nota("op", "Fomentare la rivolta a %s (100 talenti, dado %d+2): fallita. Operazione annullata." % [Dati.nome(op.ob), dr])
			op = {}
			_dopo_op(np)
			s.attesa = {"tipo": "continua", "titolo": "Operazione di %s" % nl(np)}
			return
		sp(op.ob).riv = true
		nota("op", "Fomentare la rivolta a %s (100 talenti, dado %d+2): %s insorge." % [Dati.nome(op.ob), dr, Dati.nome(op.ob)])
		piano = _piano(scelta.forza)
		if piano == null:
			piano = []
	nota("op", "%s guida la spedizione: servono %s." % [Dati.capo_nome(capo), _forza_testo(scelta.forza)])
	var ok := true
	for tappa in piano:
		var id: String = tappa[0]
		if id != op.pos:
			if percorso(op.pos, id, comp_di(op.u), np, op.ob, false) == null:
				continue
			if not muovi(id, false):
				ok = false
				break
			op.tappe.append(id)
		var u := {}
		var disp := disponibili(id, np)
		var budget := spendibile(np)
		for k in tappa[1]:
			var n: int = min(tappa[1][k], disp.get(k, 0))
			while n > 0 and _costo(k) * n > budget:
				n -= 1
			if n > 0:
				u[k] = n
				budget -= _costo(k) * n
		if not u.is_empty():
			_attiva(u)
	if ok and not op.annullata:
		if conta(op.u, np) == 0:
			nota("op", "La spedizione non riesce a radunarsi.")
		elif muovi(op.ob, true):
			nota("op", "La spedizione di %s arriva a %s con %s." % [Dati.capo_nome(capo), Dati.nome(op.ob), descrivi(op.u)])
			if difesa and not s.difese.has(op.ob):
				s.difese.append(op.ob)
	if not op.annullata:
		_op_fine_qui()
	if difesa and not scelta.has("sir") and not s.difese.has(scelta.ob):
		s["difese_tentativi"] = s.get("difese_tentativi", 0) + 1
		if s.difese_tentativi >= 3:
			s.difese.append(scelta.ob)
	_segna_attica()
	op = {}
	_dopo_op(np)
	s.attesa = {"tipo": "continua", "titolo": "Operazione di %s" % nl(np)}

func _forza_testo(f: Dictionary) -> String:
	var p := []
	for t in ["H", "C", "N"]:
		if f.get(t, 0) > 0:
			p.append("%s %d" % [{"H": "opliti", "C": "cavalleria", "N": "navi"}[t], f[t]])
	return ", ".join(p)

# ------------------------------------------------------------------ sequenza del turno
func avanza() -> void:
	var guardia := 0
	while not s.finita and guardia < 200:
		guardia += 1
		if not s.attesa.is_empty():
			if s.attesa.tipo == "continua":
				s.attesa = {}
			else:
				return
		s["fase"] = s.passo
		match s.passo:
			"politica":
				_politica()
			"strategia":
				_strategia()
			"op_g_iniziale":
				_g_turno_op(true)
			"op_n_iniziale":
				_np_operazione(true)
			"op_continua":
				_continua_op()
			"combattimento":
				_combattimento()
			"rivolte":
				_rivolte()
			"amministrazione":
				_amministrazione()
			"costruzione_np":
				_costruzione_np()
			"tregua":
				_tregua_resa()
			"fine_turno":
				_fine_turno()
		if not s.attesa.is_empty():
			return

func _g_turno_op(iniziale: bool) -> void:
	var g: String = s.lato_g
	s.riepilogo = []
	if s.passato[g]:
		_dopo_op(g)
		s.attesa = {}
		return
	var motivo := ""
	if s.op_fatte[g] >= s.max_op[g]:
		motivo = "i prodigi fermano le operazioni"
	if motivo == "" and not iniziale:
		var bonus := capi_sulla_mappa(g) / 2
		var d := d6()
		if d + bonus >= 6:
			motivo = "gli auspici sono sfavorevoli (dado %d+%d)" % [d, bonus]
		else:
			nota("op", "%s consulta gli auspici: favorevoli (dado %d+%d)." % [nl(g), d, bonus])
			if capi_casa(g).is_empty():
				var cp := coppa(g)
				if cp.is_empty():
					motivo = "non restano condottieri"
				else:
					var c: String = cp[rng.randi_range(0, cp.size() - 1)]
					_capo_in(c, Dati.CASA[g])
					nota("op", "Estratto dalla coppa: %s." % Dati.capo_nome(c))
	if motivo == "" and capi_casa(g).is_empty():
		motivo = "non c'è un condottiero nella capitale"
	if motivo != "":
		s.passato[g] = true
		nota("op", "%s deve passare: %s." % [nl(g), motivo])
		_dopo_op(g)
		s.attesa = {"tipo": "continua", "titolo": "%s passa" % nl(g)}
		return
	s.attesa = {"tipo": "operazione", "iniziale": iniziale}

func _continua_op() -> void:
	if s.passato.A and s.passato.S:
		nota("fase", "Fine delle operazioni.")
		ritorno_a_casa()
		_segna_attica()
		s.passo = "combattimento"
		return
	if s.passato[s.tocca]:
		s.tocca = Dati.AVV[s.tocca]
	if s.tocca == s.lato_g:
		_g_turno_op(false)
	else:
		_np_operazione(false)

# ------------------------------------------------------------------ fase politica e strategia
func _politica() -> void:
	s.riepilogo = []
	nota("fase", "Turno %d (%s a.C.). Fase politica." % [s.turno, Dati.ANNI[min(s.turno, 10) - 1]])
	var g: String = s.lato_g
	s.cambiato = false
	if s.sci[g] >= 0:
		var d := d6()
		if d + s.sci[g] >= 6:
			s.lato_g = Dati.AVV[g]
			s.cambiato = true
			s.cambi += 1
			nota("ev", "Cambio di schieramento (dado %d + fiducia %d): ora comandi %s." % [d, s.sci[g], nl(s.lato_g)])
			if s.scenario == "archidamo" and s.lato_g == "A":
				_fine("Sei tornato al comando di Atene: la Guerra archidamica si chiude qui.")
				return
		else:
			nota("ev", "Resti al comando di %s (dado %d + fiducia %d, serviva 6)." % [nl(g), d, s.sci[g]])
	else:
		nota("ev", "Fiducia negativa: resti al comando di %s." % nl(g))
	_evento_segmento()
	if s.sci.A <= 0 or s.navi_perse_prec >= 4:
		nota("ev", "Rivolta nella Lega delio-attica (%s)." % ("fiducia di Atene a zero o meno" if s.sci.A <= 0 else "4 o più punti di navi persi nel turno scorso"))
		_rivolta_delia()
	for lato in ["A", "S"]:
		var cp := coppa(lato)
		if cp.is_empty():
			nota("ev", "%s non ha più condottieri nella coppa." % nl(lato))
			continue
		var c: String = cp[rng.randi_range(0, cp.size() - 1)]
		_capo_in(c, Dati.CASA[lato])
		nota("ev", "%s: il comando va a %s (tattico %d, strategico %d)." % [nl(lato), Dati.capo_nome(c), Dati.CAPI[c][1], Dati.CAPI[c][2]])
		if c == "nicias":
			s.nicia = true
	s.passo = "strategia"

func _alcibiade_con_sparta() -> bool:
	return s.alcibiade == 1 or s.alcibiade == 2

func _evento_segmento() -> void:
	for i in 40:
		var d := d6() + d6()
		if _evento(d, true):
			return
	nota("ev", "Nessun evento possibile.")

## Applica l'evento. Falso se in questo momento è impossibile (e va ritirato).
func _evento(n: int, annuncia: bool) -> bool:
	match n:
		2:
			var d := d6()
			var lato := "S" if d <= 3 else "A"
			s.tes[lato] += 400
			nota("ev", "Evento 2, %s: %s guadagna 400 talenti (dado %d)." % [Dati.NOME_EVENTO[2], nl(lato), d])
		3:
			if s.ev3 or s.sci.A >= 0 or not _alcibiade_con_sparta():
				return false
			s.ev3 = true
			s.bel_malus.A += 2
			s.tes.A += 100
			s.eisfora_no = true
			nota("ev", "Evento 3, %s: bellicosità di Atene -2, +100 talenti, niente eisphora in questo turno, due rivolte." % Dati.NOME_EVENTO[3])
			_rivolta_delia()
			_rivolta_delia()
		4:
			s.sitalce = not s.sitalce
			var nuovo := "S" if s.sitalce else "A"
			for id in ["Abdera", "Maraneia"]:
				_cambia_alleati(id, nuovo)
			nota("ev", "Evento 4, %s: Abdera e Maronea passano con %s." % [Dati.NOME_EVENTO[4], nl(nuovo)])
		5:
			if s.ev5 or s.turno < 5 or s.bel.S < 6 or not _alcibiade_con_sparta():
				return false
			s.ev5 = true
			s.persia = true
			nota("ev", "Evento 5, %s: Sparta riceve 500 talenti in più a ogni fase amministrativa; se conquista Iaso ne riceve 1000 e la cavalleria persiana si schiera a Sardi." % Dati.NOME_EVENTO[5])
		6:
			if s.ev6 or not s.attica_prec:
				return false
			s.ev6 = true
			var tolti := 0
			for id in ["Athens", "Piraeus"]:
				var h: int = unita(id).get("AH", 0)
				var q := int(ceil(h / 3.0))
				for i in q:
					_togli(sp(id).u, "AH")
					_registra_perdita("AH")
				tolti += q
			var navi := 0
			for id in s.sp:
				navi += unita(id).get("AN", 0)
			var costo := int(ceil(navi * 200 / 4.0))
			s.tes.A = max(0, s.tes.A - costo)
			if s.capi.pericles.stato != "morto":
				s.capi.pericles = {"stato": "morto", "pos": ""}
				s.morti.A += 1
			nota("ev", "Evento 6, %s: Atene perde %d punti di opliti e %d talenti per i nuovi equipaggi. Pericle esce dal gioco." % [Dati.NOME_EVENTO[6], tolti, costo])
		7:
			if s.alcibiade >= 4 or s.capi.alcibiades.stato == "morto":
				return false
			s.alcibiade += 1
			match s.alcibiade:
				1:
					s.capi.alcibiades = {"stato": "consigliere", "pos": "Sparta"}
					nota("ev", "Evento 7, Alcibiade passa a Sparta: +1 al dado della strategia spartana.")
				2:
					s.capi.alcibiades = {"stato": "consigliere", "pos": "Sardis"}
					nota("ev", "Evento 7, Alcibiade fugge a Sardi, presso i Persiani: resta il +1 al dado della strategia spartana.")
				3:
					s.capi.alcibiades = {"stato": "mappa", "pos": "Athens"}
					nota("ev", "Evento 7, Alcibiade torna ad Atene come condottiero.")
				4:
					s.capi.alcibiades = {"stato": "morto", "pos": ""}
					nota("ev", "Evento 7, Alcibiade va in esilio volontario ed esce dal gioco.")
		8:
			nota("ev", "Evento 8, %s." % Dati.NOME_EVENTO[8])
			_rivolta_delia()
		9:
			s.macedonia = "S" if s.macedonia == "A" else "A"
			for id in ["Pela", "Macedonia"]:
				_cambia_alleati(id, s.macedonia)
			nota("ev", "Evento 9, %s: la Macedonia passa con %s." % [Dati.NOME_EVENTO[9], nl(s.macedonia)])
		10:
			if s.turno <= 3:
				s.corcira_ferma = true
				nota("ev", "Evento 10, guerra civile a Corcira: le sue forze non partecipano alle operazioni di questo turno.")
			elif s.turno <= 6:
				if s.argo != "":
					return false
				_attiva_argo()
			elif s.turno <= 8:
				if s.siracusa != "":
					return false
				_attiva_siracusa()
			else:
				if s.corcira_neutrale:
					return false
				s.corcira_neutrale = true
				var x := sp("Corcyra")
				for k in ["aH", "aC", "aN"]:
					x.u.erase(k)
				for k in ["AH", "AC", "AN"]:
					if x.u.get(k, 0) > 0:
						_metti("Athens" if k != "AN" else "Piraeus", {k: x.u[k]})
						x.u.erase(k)
				nota("ev", "Evento 10, Corcira diventa neutrale: i suoi alleati escono dal gioco e non è più uno spazio di coalizione ateniese.")
		11:
			s.ev_morti = true
			nota("ev", "Evento 11, %s: in ogni battaglia di questo turno, con un dado non modificato da 1 a 3, il condottiero muore." % Dati.NOME_EVENTO[11])
		12:
			var d2 := d6()
			var lato2 := "A" if d2 <= 3 else "S"
			s.max_op[lato2] = 2
			nota("ev", "Evento 12, %s (dado %d): %s; %s non può fare più di 2 operazioni in questo turno." % [Dati.NOME_EVENTO[12], d2, "un'eclissi di luna spaventa Atene" if lato2 == "A" else "un terremoto scuote Sparta", nl(lato2)])
			if lato2 == "S" and s.alcibiade == 1:
				s.alcibiade = 2
				s.capi.alcibiades = {"stato": "consigliere", "pos": "Sardis"}
				nota("ev", "Il terremoto rivela la tresca di Alcibiade con la regina: fugge a Sardi.")
	var _a := annuncia
	return true

func _cambia_alleati(id: String, nuovo: String) -> void:
	var x := sp(id)
	var mappa := {"aH": "sH", "aC": "sC", "aN": "sN"} if nuovo == "S" else {"sH": "aH", "sC": "aC", "sN": "aN"}
	for k in mappa:
		if x.u.get(k, 0) > 0:
			x.u[mappa[k]] = x.u.get(mappa[k], 0) + x.u[k]
			x.u.erase(k)
	x.a = {}
	for k in ["AH", "AC", "AN", "SH", "SC", "SN"]:
		if x.u.get(k, 0) > 0:
			s["rientri"] = {}
			s["conta_rientri"] = {}
			var n: int = x.u[k]
			x.u.erase(k)
			rientra(k, n)

func _rivolta_delia() -> void:
	var extra := 0
	for i in 30:
		var d: int = min(12, d6() + d6() + extra)
		var id: String = Dati.RIVOLTE_DELIE[d]
		if in_rivolta(id) or presenti(id, "A") > 0 or lato_colore(id) != "A":
			extra += 1
			if extra > 12:
				break
			continue
		sp(id).riv = true
		var altre := []
		for b in Dati.spazi[id].l:
			if lato_colore(b) == "A" and not in_rivolta(b) and presenti(b, "A") == 0 and b != "Athens" and d6() == 6:
				sp(b).riv = true
				altre.append(Dati.nome(b))
		nota("ev", "%s si ribella ad Atene%s." % [Dati.nome(id), (" e trascina con sé " + ", ".join(altre)) if not altre.is_empty() else ""])
		return
	nota("ev", "Nessuno spazio può ribellarsi.")

func _strategia() -> void:
	var np := _np()
	var capo_casa := capi_casa(np)
	var blocco: bool = s.ostaggi[s.lato_g] and not s.tregua_fatta
	if s.sci[np] > 0 and not s.cambiato and s.strategia[np] != "" and not (blocco and s.strategia[np] == "attacco"):
		nota("ev", "%s mantiene la strategia \"%s\" (fiducia positiva)." % [nl(np), Dati.NOME_STRATEGIA[s.strategia[np]]])
	else:
		var mod := 0
		if not capo_casa.is_empty():
			mod = Dati.CAPI[capo_casa[0]][2]
		if np == "S" and _alcibiade_con_sparta():
			mod += 1
		for i in 40:
			var d := d6()
			var r: int = clampi(d + mod, 1, 6)
			var st: String = Dati.MATRICE[np].dado[r]
			if st == "attacco" and blocco:
				continue
			s.strategia[np] = st
			nota("ev", "Strategia di %s (dado %d%+d = %d): %s." % [nl(np), d, mod, r, Dati.NOME_STRATEGIA[st]])
			break
	s.sci = {"A": 0, "S": 0}
	s.passo = "op_g_iniziale"
	s.attesa = {"tipo": "continua", "titolo": "Fase politica e strategia"}

# ------------------------------------------------------------------ fase di combattimento
func _lunghe_mura_aperte() -> bool:
	return _traccia("Athens", "Byzantium", func(id): return presenti(id, "S") == 0 or id in ["Athens", "Piraeus"])

func _traccia(da: String, a: String, libero: Callable) -> bool:
	if not libero.call(a):
		return false
	var visti := {da: true}
	var coda := [da]
	var i := 0
	while i < coda.size():
		var x: String = coda[i]
		i += 1
		if x == a:
			return true
		for b in Dati.spazi[x].l:
			if not visti.has(b) and libero.call(b):
				visti[b] = true
				coda.append(b)
	return false

func _ordine_spazi(lista: Array) -> Array:
	var casa := []
	var coal := []
	var altri := []
	for id in lista:
		if id == "Athens" or id == "Sparta":
			casa.append(id)
		elif id in Dati.COALIZIONE.A or id in Dati.COALIZIONE.S or id in ["Argos", "Syracuse", "Pela", "Sardis"]:
			coal.append(id)
		else:
			altri.append(id)
	for l in [casa, coal, altri]:
		for i in range(l.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var t = l[i]
			l[i] = l[j]
			l[j] = t
	return casa + coal + altri

func _combattimento() -> void:
	s.riepilogo = []
	s.percorso = []
	s.ultimo_ob = ""
	nota("fase", "Fase di combattimento.")
	# 6.1 assedi
	for id in s.sp.keys():
		var x: Dictionary = s.sp[id]
		x.ass = ""
		if Dati.spazi[id].f != 1:
			continue
		for lato in ["A", "S"]:
			if capi_in(id, lato).is_empty() or presenti(id, lato) == 0 or not nemico_per(id, lato):
				continue
			var avv: String = Dati.AVV[lato]
			var opp := presenti(id, avv)
			if opp == 0 or (capi_in(id, avv).is_empty() and presenti(id, lato) >= opp + 5):
				x.ass = lato
		if id in ["Athens", "Piraeus"] and s.obiettivi_S.has(id) and not capi_in(id, "S").is_empty() and presenti(id, "S") > 0:
			var ta := presenti(id, "A") - presenti(id, "A", "N")
			var tsp := presenti(id, "S") - presenti(id, "S", "N")
			if ta < tsp + 3:
				x.ass = "S"
		if x.ass != "":
			nota("batt", "%s è sotto assedio da parte di %s." % [Dati.nome(id), nl(x.ass)])
	# 6.2 battaglie nello stesso spazio
	var stessi := []
	for id in s.sp:
		if s.sp[id].ass == "" and presenti(id, "A") > 0 and presenti(id, "S") > 0:
			stessi.append(id)
	for id in _ordine_spazi(stessi):
		if presenti(id, "A") > 0 and presenti(id, "S") > 0:
			battaglia(_forza_spazio(id, "A"), _forza_spazio(id, "S"), id, true, false)
			_sistema_attivate(id)
	# battaglie nelle zone d'influenza
	var fatte := {}
	for giro in 60:
		var coppia := []
		for x in s.sp.keys():
			for lato in ["A", "S"]:
				if presenti(x, lato) == 0 or _sotto_assedio(x, lato):
					continue
				var z := zoi_da(x, lato, true)
				for y in z:
					if y == x or presenti(y, Dati.AVV[lato]) == 0 or _sotto_assedio(y, Dati.AVV[lato]):
						continue
					var chiave: String = (x + "|" + y) if x < y else (y + "|" + x)
					if fatte.has(chiave):
						continue
					coppia = [x, lato, y, chiave]
					break
				if not coppia.is_empty():
					break
			if not coppia.is_empty():
				break
		if coppia.is_empty():
			break
		fatte[coppia[3]] = true
		battaglia(_forza_spazio(coppia[0], coppia[1]), _forza_spazio(coppia[2], Dati.AVV[coppia[1]]), coppia[2], false, false)
		_sistema_attivate(coppia[0])
		_sistema_attivate(coppia[2])
	# 6.3 assedi
	for id in s.sp.keys():
		var x: Dictionary = s.sp[id]
		if Dati.spazi[id].f == 1 and x.ass == "":
			for lato in ["A", "S"]:
				if not capi_in(id, lato).is_empty() and presenti(id, lato) > 0 and nemico_per(id, lato):
					nota("batt", "L'armata di %s a %s non può assediare la fortezza e torna a casa." % [nl(lato), Dati.nome(id)])
					forza_a_casa(id, lato)
		if x.ass != "" and (capi_in(id, x.ass).is_empty() or presenti(id, x.ass) == 0):
			x.ass = ""
	var assedi := []
	for id in s.sp:
		if s.sp[id].ass != "":
			assedi.append(id)
	for id in _ordine_spazi(assedi):
		_assedio(id)
	# 6.4 ritorno a casa
	for id in s.sp.keys():
		for lato in ["A", "S"]:
			var cc := capi_in(id, lato)
			if cc.is_empty():
				continue
			if presenti(id, lato) == 0 or id == Dati.CASA[lato]:
				for c in cc:
					_capo_a_casa(c)
				continue
			var d := d6()
			var st: int = Dati.CAPI[cc[0]][2]
			var x: Dictionary = s.sp[id]
			if d + st <= 5:
				var resta := _chi_resta(id, lato)
				var via := {}
				for k in x.u.keys():
					if Dati.lato_di(k) == lato and k != "SG":
						var n: int = x.u[k] - (1 if k == resta else 0)
						if n > 0:
							via[k] = n
							s.rit[k] = s.rit.get(k, 0) + n
							_togli(x.u, k, n)
				nota("op", "%s a %s (dado %d%+d): l'armata torna a casa lasciando una guarnigione di 1 punto." % [Dati.capo_nome(cc[0]), Dati.nome(id), d, st])
			else:
				nota("op", "%s a %s (dado %d%+d): l'armata resta sul posto, il condottiero rientra." % [Dati.capo_nome(cc[0]), Dati.nome(id), d, st])
			for c in cc:
				_capo_a_casa(c)
			_sistema_attivate(id)
	ritorno_a_casa()
	_segna_attica()
	for id in s.sp:
		s.sp[id].ass = ""
	if s.iloti:
		for id in Dati.ILOTI:
			if ctrl(id) == "S" and presenti(id, "S") > 0:
				s.iloti = false
				nota("ev", "Sparta riprende %s: la rivolta degli iloti è domata." % Dati.nome(id))
				break
	if s.persia and not s.iaso and presenti("Iasus", "S") > 0 and presenti("Iasus", "A") == 0:
		s.iaso = true
		_metti("Sardis", {"sC": 3})
		nota("ev", "Sparta tiene Iaso: 3 punti di cavalleria persiana si schierano a Sardi e il sussidio persiano raddoppia.")
	s.passo = "rivolte"
	s.attesa = {"tipo": "continua", "titolo": "Fase di combattimento"}

func _sotto_assedio(id: String, lato: String) -> bool:
	return s.sp[id].ass != "" and s.sp[id].ass != lato

func _chi_resta(id: String, lato: String) -> String:
	var u := unita(id)
	if u.get("SG", 0) > 0 and lato == "S":
		return "SG"
	var ordine := ["H", "C", "N"] if Dati.spazi[id].t != "I" else ["N", "H", "C"]
	for t in ordine:
		var naz := ["AH", "aH"] if lato == "A" else ["SH", "sH"]
		if t == "C":
			naz = ["AC", "aC"] if lato == "A" else ["SC", "sC"]
		elif t == "N":
			naz = ["AN", "aN"] if lato == "A" else ["SN", "sN"]
		for k in naz:
			if u.get(k, 0) > 0:
				return k
	return ""

func _assedio(id: String) -> void:
	var x: Dictionary = s.sp[id]
	var lato: String = x.ass
	var avv: String = Dati.AVV[lato]
	if lato == "" or capi_in(id, lato).is_empty() or presenti(id, lato) == 0:
		x.ass = ""
		return
	var nb := presenti(id, lato, "N")
	var nd := presenti(id, avv, "N")
	var riesce := false
	var testo := ""
	if id in ["Athens", "Piraeus"] and lato == "S" and _lunghe_mura_aperte():
		testo = "le Lunghe Mura e il grano del Mar Nero rendono vano l'assedio"
	elif nd > nb:
		testo = "gli assediati hanno più navi"
	else:
		var d := d6()
		var t := tattico(capi_in(id, lato))
		var m := t - (2 if id == "Syracuse" else 0)
		riesce = d + m >= 4
		testo = "dado %d%+d" % [d, m]
	var amico_g: bool = (lato_colore(id) == s.lato_g and not x.riv) or presenti(id, s.lato_g) > 0
	if not riesce:
		nota("batt", "Assedio di %s: fallito (%s). L'armata di %s torna a casa." % [Dati.nome(id), testo, nl(lato)])
		forza_a_casa(id, lato)
		x.dev = true
		sci_piu(lato, -2 if lato == s.lato_g else -1)
	else:
		var neutro_o_rivolta: bool = lato_colore(id) == "" or x.riv
		for k in x.u.keys():
			if Dati.lato_di(k) == avv:
				for i in x.u[k]:
					_registra_perdita(k)
				if k == "SG":
					s.guardia_persa = true
				x.u.erase(k)
		for c in capi_in(id, avv):
			_capo_a_casa(c)
		_sistema_attivate(id)
		x.dev = true
		if not neutro_o_rivolta:
			sci_piu(avv, -1)
		sci_piu(lato, 1)
		s.tes[lato] += 300
		nota("batt", "Assedio di %s: riuscito (%s). %s prende la città e incassa 300 talenti." % [Dati.nome(id), testo, nl(lato)])
		if lato == s.lato_g:
			pv_piu(10, "assedio riuscito")
		elif amico_g:
			pv_piu(-15, "città perduta per assedio")
	x.ass = ""

# ------------------------------------------------------------------ rivolte
func _rivolte() -> void:
	s.riepilogo = []
	nota("fase", "Fase delle rivolte.")
	var in_riv := []
	for id in s.sp.keys():
		if s.sp[id].riv:
			var c := lato_colore(id)
			if c == "":
				if presenti(id, "A") + presenti(id, "S") > 0:
					continue
				in_riv.append(id)
				continue
			if not copre(c, id).is_empty() and copre(Dati.AVV[c], id).is_empty():
				s.sp[id].riv = false
				nota("ev", "La rivolta di %s è domata." % Dati.nome(id))
			else:
				in_riv.append(id)
	if not s.get("in_tregua", false):
		var candidati := {}
		for id in in_riv:
			var c := lato_colore(id)
			if c == "":
				continue
			for b in Dati.spazi[id].l:
				if lato_colore(b) == c and not in_rivolta(b) and presenti(b, c) == 0 and b != Dati.CASA[c]:
					candidati[b] = c
		for b in candidati:
			var c2: String = candidati[b]
			var d := d6()
			var m := 2 if not copre(Dati.AVV[c2], b).is_empty() else 0
			if d + m >= 6:
				sp(b).riv = true
				nota("ev", "La rivolta si estende a %s (dado %d%+d)." % [Dati.nome(b), d, m])
	if s.get("samo_coalizione", false) and _valido("Chios", "A") and s.sp.has("Samos"):
		s["samo_coalizione"] = false
		var sm := sp("Samos")
		for k in ["aH", "aC", "aN"]:
			if sm.u.get(k, 0) > 0:
				_metti("Chios", {k: sm.u[k]})
				sm.u.erase(k)
		nota("ev", "Chio è di nuovo fedele: gli alleati raccolti a Samo vi fanno ritorno.")
	# iloti
	var spartano := false
	var tutti := true
	for id in Dati.ILOTI:
		if ctrl(id) == "S":
			spartano = true
		if presenti(id, "A") == 0:
			tutti = false
	s.iloti_malus = 0
	if not spartano and tutti:
		s.bel_malus.S += 2
		if not s.iloti:
			s.iloti = true
			var q: int = min(2, unita("Sparta").get("SH", 0))
			for i in q:
				_togli(sp("Sparta").u, "SH")
				_registra_perdita("SH")
			s.iloti_malus = 500
			nota("ev", "Rivolta degli iloti: bellicosità di Sparta -2, %d punti di opliti spartani eliminati, 500 talenti di entrate in meno." % q)
		else:
			s.iloti_malus = 1000
			nota("ev", "La rivolta degli iloti continua: bellicosità di Sparta -2 e 1000 talenti di entrate in meno.")
	s.passo = "amministrazione"

# ------------------------------------------------------------------ amministrazione
func entrate(lato: String, tregua: bool = false) -> Dictionary:
	var voci := []
	var tot := 3500 if lato == "A" else 2500
	voci.append(["Tributi della lega", tot])
	var n := 0
	for id in Dati.spazi:
		if lato_colore(id) != lato:
			continue
		var x: Dictionary = s.sp.get(id, {})
		if (x.get("dev", false) and not tregua) or x.get("riv", false) or ctrl(id) == Dati.AVV[lato]:
			n += 1
	if n > 0:
		voci.append(["%d spazi devastati, in rivolta o in mano nemica" % n if n > 1 else "1 spazio devastato, in rivolta o in mano nemica", -50 * n])
	if lato == "S":
		for id in ["Thebes", "Corinth"]:
			if ctrl(id) == "A":
				voci.append(["%s in mano ateniese" % Dati.nome(id), -200])
		if s.siracusa == "S" and ctrl("Syracuse") != "A":
			voci.append(["Aiuti dalla Sicilia", 500])
		if s.persia:
			voci.append(["Oro persiano", 1000 if s.iaso else 500])
		if s.iloti_malus > 0 and not tregua:
			voci.append(["Rivolta degli iloti", -s.iloti_malus])
	else:
		if ctrl("Syracuse") == "A" and presenti("Syracuse", "A") > 0:
			var tutta := true
			for id in Dati.SICILIA:
				if copre("A", id).is_empty():
					tutta = false
			if tutta:
				voci.append(["Sicilia sottomessa", 1000])
		if not _traccia("Athens", "Byzantium", func(id): return ctrl(id) != "S"):
			voci.append(["Rotta del grano dal Mar Nero interrotta", -1500])
		if lato == s.lato_g and not tregua and not s.eisfora_no:
			var ok := true
			for id in ["Athens", "Piraeus", "Panactum", "Decelea"]:
				if presenti(id, "S") > 0 or s.sp.get(id, {}).get("dev", false):
					ok = false
			if ok:
				voci.append(["Eisphora (tassa sui ricchi)", 1000])
	if ctrl("Epidamnos") == lato and _traccia("Epidamnos", Dati.CASA[lato], func(id): return presenti(id, Dati.AVV[lato]) == 0):
		voci.append(["Rotta di Epidamno", 1000])
	var somma := 0
	for v in voci:
		somma += v[1]
	return {"voci": voci, "totale": max(0, somma)}

func in_gioco(k: String) -> int:
	var n: int = s.rit.get(k, 0)
	for id in s.sp:
		n += s.sp[id].u.get(k, 0)
	return n

func _amministrazione() -> void:
	nota("fase", "Fase amministrativa.")
	for lato in ["A", "S"]:
		var e := entrate(lato)
		s.tes[lato] += e.totale
		var p := []
		for v in e.voci:
			p.append("%s %+d" % [v[0], v[1]])
		nota("ev", "Entrate di %s: %d talenti (%s). Tesoro %d." % [nl(lato), e.totale, "; ".join(p), s.tes[lato]])
	s.passo = "costruzione_np"
	var mx: int = min(3, spendibile(s.lato_g) / 200)
	if mx > 0:
		s.attesa = {"tipo": "costruzione", "max": mx, "tregua": false}

func costruibili(lato: String) -> Array:
	var r := []
	for k in Dati.chiavi_di(lato):
		if k != "SG" and in_gioco(k) < Dati.LIMITE[k]:
			r.append(k)
	return r

## Il giocatore costruisce: lista di sigle (anche vuota).
func g_costruisci(lista: Array) -> String:
	if s.attesa.get("tipo", "") != "costruzione":
		return "Non è il momento."
	if lista.size() > s.attesa.max:
		return "Puoi costruire al massimo %d punti forza." % s.attesa.max
	var conto := {}
	for k in lista:
		conto[k] = conto.get(k, 0) + 1
		if Dati.lato_di(k) != s.lato_g or k == "SG":
			return "Unità non valida."
		if in_gioco(k) + conto[k] > Dati.LIMITE[k]:
			return "Le pedine di %s sono finite." % Dati.NOME_UNITA[k]
	if lista.size() * 200 > spendibile(s.lato_g):
		return "Il tesoro non basta."
	s.tes[s.lato_g] -= lista.size() * 200
	s["rientri"] = {}
	s["conta_rientri"] = {}
	for k in lista:
		rientra(k, 1)
	if not lista.is_empty():
		nota("ev", "%s costruisce %s (%d talenti)." % [nl(s.lato_g), descrivi(conto), lista.size() * 200])
	var era_tregua: bool = s.attesa.tregua
	s.attesa = {}
	if era_tregua:
		_tregua_fine()
	return ""

func _costruzione_np() -> void:
	var np := _np()
	var lista := []
	for k in s.perse:
		if Dati.lato_di(k) == np and k != "SG":
			for i in s.perse[k]:
				lista.append(k)
	var fatte := {}
	var n := 0
	while n < 3 and not lista.is_empty() and s.tes[np] - 200 >= 1000:
		var i := rng.randi_range(0, lista.size() - 1)
		var k: String = lista[i]
		lista.remove_at(i)
		if in_gioco(k) >= Dati.LIMITE[k]:
			continue
		s.tes[np] -= 200
		s["rientri"] = {}
		s["conta_rientri"] = {}
		rientra(k, 1)
		fatte[k] = fatte.get(k, 0) + 1
		n += 1
	if n > 0:
		nota("ev", "%s ricostruisce %s (%d talenti)." % [nl(np), descrivi(fatte), n * 200])
	s.passo = "tregua"

# ------------------------------------------------------------------ tregua, resa, fine turno
func spazi_persi(lato: String) -> int:
	var n := 0
	for id in Dati.spazi:
		if lato_colore(id) != lato:
			continue
		var x: Dictionary = s.sp.get(id, {})
		if x.get("dev", false) or x.get("riv", false) or ctrl(id) == Dati.AVV[lato]:
			n += 1
	return n

func _tregua_resa() -> void:
	nota("fase", "Tregua e resa.")
	for lato in ["A", "S"]:
		var prima: int = s.bel[lato]
		var b := prima
		var p := []
		if s.sci[lato] < 0:
			b += s.sci[lato]
			p.append("fiducia %d" % s.sci[lato])
		elif s.sci[lato] > 1:
			b += s.sci[lato] / 2
			p.append("fiducia %+d" % (s.sci[lato] / 2))
		var q := spazi_persi(lato) / 10
		if q > 0:
			b -= q
			p.append("spazi perduti -%d" % q)
		if s.bel_malus[lato] > 0:
			b -= s.bel_malus[lato]
			p.append("eventi -%d" % s.bel_malus[lato])
		s.bel_malus[lato] = 0
		s.bel[lato] = clampi(b, 0, 12)
		nota("ev", "Bellicosità di %s: da %d a %d%s." % [nl(lato), prima, s.bel[lato], (" (" + ", ".join(p) + ")") if not p.is_empty() else ""])
	s.turni_guerra += 1
	var resa := []
	for lato in ["A", "S"]:
		if ctrl(Dati.CASA[lato]) == Dati.AVV[lato] or s.bel[lato] == 0:
			resa.append(lato)
	if not resa.is_empty():
		var pt := int(ceil(200.0 / s.turno))
		pv_piu(pt, "resa di %s al turno %d" % [" e ".join(resa.map(func(l): return nl(l))), s.turno])
		s["resa_turno"] = s.turno
		_fine("%s si arrende." % " e ".join(resa.map(func(l): return nl(l))))
		return
	s.passo = "fine_turno"
	if not s.tregua_fatta and (s.bel.A <= 6 or s.tes.A < 1000) and (s.bel.S <= 6 or s.tes.S < 1000):
		_tregua()

func _tregua() -> void:
	s.tregua_fatta = true
	var d := d6()
	var n := int(ceil((d + (1 if s.nicia else 0)) / 2.0))
	s["tregua_turni"] = n
	nota("ev", "Tregua! Entrambi i contendenti sono stremati (dado %d%s): la pace dura %d turni." % [d, " +1 per Nicia" if s.nicia else "", n])
	if s.scenario == "archidamo":
		_fine("La tregua chiude la Guerra archidamica.")
		return
	s["rientri"] = {}
	s["conta_rientri"] = {}
	for id in s.sp.keys():
		var x: Dictionary = s.sp[id]
		for k in ["AH", "AC", "AN", "SH", "SC", "SN"]:
			if x.u.get(k, 0) > 0 and lato_colore(id) != Dati.lato_di(k):
				var q: int = x.u[k]
				x.u.erase(k)
				rientra(k, q)
		x.a = {}
	s.ostaggi = {"A": false, "S": false}
	s["in_tregua"] = true
	for i in n:
		_evento(d6() + d6(), true)
	for lato in ["A", "S"]:
		var e := entrate(lato, true)
		s.tes[lato] += e.totale * n
		nota("ev", "Entrate di %s durante la tregua: %d talenti. Tesoro %d." % [nl(lato), e.totale * n, s.tes[lato]])
	var np := _np()
	var k := "SN" if np == "S" else "AH"
	var fatti := 0
	while fatti < 5 and s.tes[np] - 200 >= 1000 and in_gioco(k) < Dati.LIMITE[k]:
		s.tes[np] -= 200
		rientra(k, 1)
		fatti += 1
	if fatti > 0:
		nota("ev", "%s approfitta della pace e costruisce %d punti di %s." % [nl(np), fatti, Dati.NOME_UNITA[k]])
	var mx: int = min(5, max(0, s.tes[s.lato_g] - 1000) / 200)
	if mx > 0:
		s.attesa = {"tipo": "costruzione", "max": mx, "tregua": true}
	else:
		_tregua_fine()

func _tregua_fine() -> void:
	var b: int = clampi(10 - s.turni_guerra, 1, 12)
	s.bel = {"A": b, "S": b}
	s["in_tregua"] = false
	s.turno += s.tregua_turni
	nota("ev", "Finita la tregua, la bellicosità di entrambi torna a %d. La guerra riprende." % b)

func _fine_turno() -> void:
	for id in s.sp.keys():
		var x: Dictionary = s.sp[id]
		x.dev = false
		x.a = {}
		x.ass = ""
		if x.u.is_empty() and not x.riv:
			s.sp.erase(id)
	for c in s.capi:
		if s.capi[c].stato in ["ritorno", "mappa"]:
			s.capi[c] = {"stato": "coppa", "pos": ""}
	if s.alcibiade == 3 and s.capi.alcibiades.stato == "coppa":
		pass
	s.navi_perse_prec = s.navi_perse
	s.navi_perse = 0
	s.perse = {}
	s.attica_prec = s.attica_ora
	s.attica_ora = false
	s.ev_morti = false
	s.max_op = {"A": 99, "S": 99}
	s.op_fatte = {"A": 0, "S": 0}
	s.corcira_ferma = false
	s.eisfora_no = false
	s.nicia = false
	s.passato = {"A": false, "S": false}
	s.difese = []
	s["difese_tentativi"] = 0
	s.sir_difesa = false
	s.obiettivi_S = []
	s.percorso = []
	s.ultimo_ob = ""
	s.turno += 1
	if s.scenario == "archidamo" and s.turno > 3:
		_fine("Il terzo turno è concluso.")
		return
	if s.turno > 10:
		_fine("La guerra si trascina fino al 402 a.C.: il decimo turno è concluso.")
		return
	s.passo = "politica"

func _fine(motivo: String) -> void:
	s.finita = true
	s.attesa = {"tipo": "fine"}
	if s.scenario == "archidamo":
		s.vittoria = s.pv >= 40
		s.esito = "%s Hai %d punti vittoria: %s" % [motivo, s.pv, "vittoria (ne servivano 40)." if s.vittoria else "sconfitta (ne servivano 40)."]
	else:
		var presto: bool = s.has("resa_turno") and s.resa_turno <= 3
		s.vittoria = s.pv > 150 or presto
		if s.vittoria:
			s.esito = "%s Hai %d punti vittoria: vittoria decisiva. La Grecia esce dalla guerra abbastanza forte da respingere Tebe, la Macedonia e la Persia." % [motivo, s.pv]
		else:
			s.esito = "%s Hai %d punti vittoria (ne servivano più di 150): la Grecia, dissanguata, perderà l'egemonia a vantaggio di Tebe e della Persia." % [motivo, s.pv]
	nota("fase", s.esito)
