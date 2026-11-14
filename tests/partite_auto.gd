## Partite automatiche: un giocatore casuale gioca molte campagne per stanare errori del motore.
## Uso: godot --headless -s tests/partite_auto.gd -- [numero partite]
extends SceneTree

func _init() -> void:
	var n := 40
	var a := OS.get_cmdline_user_args()
	if a.size() > 0:
		n = int(a[0])
	var tot := {"vittorie": 0, "pv": 0, "turni": 0, "rese": 0, "tregue": 0, "cambi": 0, "op": 0}
	for i in n:
		var p := Partita.new()
		p.nuova("campagna" if i % 4 != 3 else "archidamo", 1000 + i)
		var bot := Bot.new()
		var passi := 0
		while not p.s.finita and passi < 4000:
			passi += 1
			bot.gioca(p)
			if passi % 7 == 0:      # prova il salvataggio a metà partita
				var copia := JSON.stringify(p.esporta())
				var q := Partita.new()
				q.importa(JSON.parse_string(copia))
				p = q
			_controlla(p, i)
		if not p.s.finita:
			printerr("partita %d non finita dopo %d passi (passo %s, attesa %s)" % [i, passi, p.s.passo, p.s.attesa])
			quit(1)
			return
		tot.vittorie += 1 if p.s.vittoria else 0
		tot.pv += p.s.pv
		tot.turni += p.s.turno
		tot.rese += 1 if p.s.has("resa_turno") else 0
		tot.tregue += 1 if p.s.tregua_fatta else 0
		tot.cambi += p.s.cambi
		tot.op += bot.operazioni
		if i < 3:
			print("--- partita %d: %s" % [i, p.s.esito])
	print("partite %d  vittorie %d  PV medi %.1f  turni medi %.1f  rese %d  tregue %d  cambi di lato %d  operazioni del giocatore %d" % [n, tot.vittorie, float(tot.pv) / n, float(tot.turni) / n, tot.rese, tot.tregue, tot.cambi, tot.op])
	quit(0)

func _controlla(p: Partita, i: int) -> void:
	for id in p.s.sp:
		var x: Dictionary = p.s.sp[id]
		for k in x.u:
			if x.u[k] <= 0 or not Dati.CHIAVI.has(k):
				printerr("partita %d: unità non valide a %s: %s" % [i, id, x.u])
				quit(1)
		for k in x.a:
			if x.a[k] > x.u.get(k, 0):
				printerr("partita %d: attivate più delle presenti a %s %s %s passo %s; %s" % [i, id, x.u, x.a, p.s.passo, p.s.diario.slice(-4)])
				quit(1)
	for k in Dati.CHIAVI:
		if p.in_gioco(k) > Dati.LIMITE[k] + 8:
			printerr("partita %d: troppe pedine %s: %d" % [i, k, p.in_gioco(k)])
			quit(1)
	for lato in ["A", "S"]:
		if p.s.tes[lato] < 0 or p.s.bel[lato] < 0 or p.s.bel[lato] > 12 or abs(p.s.sci[lato]) > 6:
			printerr("partita %d: valori fuori scala %s" % [i, lato])
			quit(1)
