## Verifiche puntuali delle regole: godot --headless --path . -s tests/regole.gd
extends SceneTree

var errori := 0

func vero(c: bool, cosa: String) -> void:
	if not c:
		errori += 1
		printerr("FALLITA: ", cosa)

func _init() -> void:
	Dati.carica()
	vero(Dati.spazi.size() == 193, "193 spazi")
	for a in Dati.spazi:
		for b in Dati.spazi[a].l:
			vero(Dati.spazi[b].l.get(a, "") == Dati.spazi[a].l[b], "collegamento simmetrico %s-%s" % [a, b])
	for lato in ["A", "S"]:
		for area in Dati.MATRICE[lato].aree:
			for id in Dati.MATRICE[lato].aree[area]:
				vero(Dati.spazi.has(id), "spazio della matrice: " + id)
	for n in Dati.RIVOLTE_DELIE:
		vero(Dati.spazi.has(Dati.RIVOLTE_DELIE[n]), "spazio delle rivolte")
	var p := Partita.new()
	p.nuova("campagna", 5)
	vero(p.ctrl("Potidaea") == "S" or p.presenti("Potidaea", "A") > 0, "Potidea contesa")
	vero(p.nat("Potidaea") == "S", "Potidea in rivolta è amica di Sparta")
	vero(p.ctrl("Athens") == "A" and p.ctrl("Sparta") == "S", "capitali")
	# zone d'influenza
	vero(p.zoi_da("Piraeus", "A", false).has("Cenchrae"), "le navi del Pireo arrivano a Cencree")
	vero(not p.zoi_da("Piraeus", "A", false).has("Corinth"), "la zona navale non passa l'istmo")
	vero(p.zoi_da("Thebes", "S", false).has("Tanagra"), "la cavalleria di Tebe copre Tanagra")
	vero(not p.zoi_da("Thebes", "S", false).has("Athens"), "nessuna zona nemica ad Atene")
	vero(p.zoi_da("Athens", "A", false).has("Decelea"), "cavalleria ateniese fuori da Atene nelle operazioni")
	vero(not p.zoi_da("Athens", "A", true).has("Decelea"), "non in combattimento (Lunghe Mura)")
	# percorsi
	var terra := {"terra": 3, "mare": 0}
	var misto := {"terra": 2, "mare": 2}
	var troppe := {"terra": 3, "mare": 2}
	vero(p.percorso("Athens", "Naxos", terra, "A", "Naxos", true) == null, "le truppe non vanno a Nasso senza navi")
	vero(p.percorso("Piraeus", "Naxos", misto, "A", "Naxos", true) != null, "con le navi sì")
	vero(p.percorso("Piraeus", "Naxos", troppe, "A", "Naxos", true) == null, "non con più truppe che navi")
	vero(p.percorso("Piraeus", "Thebes", misto, "A", "Thebes", true) == null, "una flotta non entra nell'entroterra")
	vero(p.percorso("Sparta", "Athens", terra, "S", "Athens", false) != null, "Sparta raggiunge Atene per terra")
	var pr = p.percorso("Sparta", "Epidaurus", terra, "S", "Epidaurus", false)
	vero(pr != null and not pr.has("Argos"), "non si passa per Argo neutrale")
	vero(p.percorso("Corinth", "Eupalium", misto, "S", "Eupalium", false) != null and not p.percorso("Corinth", "Eupalium", misto, "S", "Eupalium", false).has("Naupactus"), "Naupatto nemica non si attraversa")
	vero(p.percorso("Cape Taenarum", "Syracuse", misto, "S", "Syracuse", false) == null, "Siracusa neutrale chiusa a Sparta")
	# entrate iniziali
	var ea := p.entrate("A")
	vero(ea.totale == 3500 - 50 + 1000 + 1000, "entrate iniziali di Atene: %d" % ea.totale)
	vero(p.entrate("S").totale == 2500, "entrate iniziali di Sparta")
	# obiettivi
	vero(p.obiettivo_valido("Argos", false) != "", "Atene non può puntare su Argo neutrale")
	vero(p.obiettivo_valido("Megara", false) == "", "Megara è un obiettivo valido")
	vero(p.obiettivo_valido("Corinth", true) != "", "niente rivolta in uno spazio di coalizione")
	# primo turno: Sparta attacca l'Attica e Atene può agire
	p.avanza()
	vero(p.s.attesa.get("tipo", "") == "continua", "pausa dopo l'operazione di Sparta")
	vero(p.s.tes.S < 3000, "Sparta ha pagato gli alleati")
	# battaglia: +2 opliti spartani, differenza opliti
	var q := Partita.new()
	q.nuova("campagna", 9)
	q.sp("Megara").u = {"SH": 4, "AH": 2}
	var prima: int = q.s.pv
	q.battaglia(q._forza_spazio("Megara", "A"), q._forza_spazio("Megara", "S"), "Megara", true, false)
	vero(q.presenti("Megara", "A") == 0 or q.presenti("Megara", "S") == 0, "il perdente lascia lo spazio")
	vero(q.s.pv != prima, "la battaglia sposta i punti vittoria")
	# guarnigione di sole navi contro un'Armata di soli Opliti: battaglia nulla, torna a casa l'Armata (6.2.2)
	var g := Partita.new()
	g.nuova("campagna", 3)
	g.sp("Pylos").u = {"AN": 1, "SH": 7, "sH": 3, "SC": 1}
	g._capo_in("brasidas", "Pylos")
	var pv0: int = g.s.pv
	g.battaglia(g._forza_spazio("Pylos", "A"), g._forza_spazio("Pylos", "S"), "Pylos", true, false)
	vero(g.presenti("Pylos", "A") == 1 and g.presenti("Pylos", "S") == 0 and g.s.pv == pv0, "la guarnigione navale resta, l'Armata di terra torna a casa senza punti")
	# percorsi dell'esempio di gioco del manuale
	var e := Partita.new()
	e.nuova("campagna", 4)
	var visti0 := {}
	for i in 60:
		var pe = e.percorso("Sparta", "Corinth", {"terra": 7, "mare": 0}, "S", "Decelea", false)
		visti0[" ".join(pe)] = true
		vero(pe.size() == 6 and not pe.has("Argos"), "Sparta-Corinto in 6 spazi senza Argo: %s" % [pe])
	vero(visti0.has("Belmina Methydrum Orchomenus Philius Sicyon Corinth") and visti0.size() == 2, "la via del manuale e quella per Tegea e Mantinea: %s" % [visti0.keys()])
	var visti := {}
	for i in 80:
		visti[" ".join(e.percorso("Corinth", "Thebes", {"terra": 11, "mare": 0}, "S", "Decelea", false))] = true
	vero(visti.size() == 4, "quattro percorsi equivalenti Corinto-Tebe: %d" % visti.size())
	visti = {}
	for i in 60:
		visti[" ".join(e.percorso("Thebes", "Decelea", {"terra": 14, "mare": 0}, "S", "Decelea", false))] = true
	vero(visti.size() == 2, "due percorsi Tebe-Decelea: %d" % visti.size())
	var giro = e.percorso("Piraeus", "Erineus", {"terra": 0, "mare": 3}, "A", "Erineus", true)
	vero(giro.size() == 18 and giro.has("Pylos") and giro.has("Naupactus") and giro[giro.size() - 2] == "Panormus", "il giro del Peloponneso di Pericle: %d spazi" % giro.size())
	e.sp("Decelea").u = {"SH": 7}
	visti = {}
	for i in 80:
		var pc = e.percorso("Athens", "Chios", {"terra": 0, "mare": 0}, "A", "Heraclea", true)
		visti[" ".join(pc)] = pc.size()
	vero(visti.size() == 4 and visti.values().max() == 6 and visti.has("Piraeus Aegina Kithnos Siros Andros Chios"), "quattro percorsi da 6 spazi per Demostene da solo (non per Decelea occupata): %s" % [visti.keys()])
	# salvataggio
	var r := Partita.new()
	r.importa(JSON.parse_string(JSON.stringify(q.esporta())))
	vero(JSON.stringify(r.esporta()) == JSON.stringify(q.esporta()), "salvataggio e ripristino identici")
	print("regole: ", "tutto bene" if errori == 0 else "%d verifiche fallite" % errori)
	quit(0 if errori == 0 else 1)
