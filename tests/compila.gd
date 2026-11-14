## Controlla che tutti gli script si compilino: godot --headless -s tests/compila.gd
extends SceneTree
func _init() -> void:
	var ok := true
	for f in DirAccess.get_files_at("res://scripts"):
		if f.ends_with(".gd"):
			var s = load("res://scripts/" + f)
			if s == null or not s.can_instantiate():
				printerr("NON COMPILA: ", f)
				ok = false
	print("compilazione ", "riuscita" if ok else "FALLITA")
	quit(0 if ok else 1)
