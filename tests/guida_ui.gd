## Gioca l'intera partita guidata attraverso l'interfaccia (come il giocatore) e controlla
## che il copione non si interrompa e che la partita prosegua liberamente al turno 2.
##   PW_AVVIO=menu xvfb-run -a godot --path . --script res://tests/guida_ui.gd
extends SceneTree

var n := 0
var main

func _initialize() -> void:
	root.size = Vector2i(1024, 768)
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)

func _process(_d: float) -> bool:
	n += 1
	if n == 5:
		main._nuova_guidata()
	elif n > 6 and n < 6 + Guida.COPIONE.size() + 1:
		var i: int = main._guida_passo()
		if i != n - 7:
			print("ERRORE: passo %d invece di %d (copione interrotto)" % [i, n - 7])
			quit(1)
			return true
		main._guida_esegui_passo()
	elif n == 8 + Guida.COPIONE.size():
		var p = main.partita
		var ok: bool = main._guida_passo() == Guida.COPIONE.size() and p.s.turno == 2 and p.s.attesa.get("tipo", "") == "operazione"
		print("guida_ui: passo %d, turno %d, attesa %s, consiglio %d caratteri" % [main._guida_passo(), p.s.turno, p.s.attesa.get("tipo", ""), Guida.consiglio(p).length()])
		print("guida_ui: tutto bene" if ok else "guida_ui: ERRORE")
		quit(0 if ok else 1)
		return true
	return false
