## Screenshot di prova. Uso:
##   PW_AVVIO=<modo> PW_PASSI=<n> PW_LARG=1440 PW_ALT=900 xvfb-run -a godot --path . --script res://tests/screenshot.gd
## modo: menu, gioco, obiettivo, raduno, tabelle, diario, regole, salva, zoom. Salva /tmp/pw_<nome>.png
extends SceneTree

var n := 0

func _initialize() -> void:
	var l := int(OS.get_environment("PW_LARG")) if OS.get_environment("PW_LARG") != "" else 1440
	var a := int(OS.get_environment("PW_ALT")) if OS.get_environment("PW_ALT") != "" else 900
	root.size = Vector2i(l, a)
	DisplayServer.window_set_size(Vector2i(l, a))
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)

func _process(_d: float) -> bool:
	n += 1
	if n == 40:
		var nome := OS.get_environment("PW_NOME")
		if nome == "":
			nome = OS.get_environment("PW_AVVIO")
		root.get_texture().get_image().save_png("/tmp/pw_%s.png" % nome)
		print("screenshot ", nome)
		return true
	return false
