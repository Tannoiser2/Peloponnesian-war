## Stampa il diario di una partita automatica: godot --headless -s tests/una.gd -- <seme> <righe>
extends SceneTree
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var p := Partita.new()
	p.nuova("campagna", int(a[0]) if a.size() > 0 else 7)
	var b := Bot.new()
	var righe := int(a[1]) if a.size() > 1 else 120
	var i := 0
	while not p.s.finita and p.s.diario.size() < righe and i < 3000:
		b.gioca(p)
		i += 1
	for v in p.s.diario:
		print(v[1])
	quit(0)
