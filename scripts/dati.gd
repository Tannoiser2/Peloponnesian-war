## Dati fissi del gioco: spazi della mappa, condottieri, matrici delle strategie, tabelle.
class_name Dati
extends RefCounted

const CASA := {"A": "Athens", "S": "Sparta"}
const NOME_LATO := {"A": "Atene", "S": "Sparta"}
const LEGA := {"A": "Lega di Delo", "S": "Lega del Peloponneso"}
const AVV := {"A": "S", "S": "A"}

## Sigle delle unità: prima lettera = nazionalità (A ateniesi, a alleati di Atene, S spartani, s alleati di Sparta),
## seconda = tipo (H opliti, C cavalleria, N navi). SG = Guardia di Sparta (opliti scelti, 3 punti forza).
const CHIAVI := ["AH", "AC", "AN", "aH", "aC", "aN", "SH", "SG", "SC", "SN", "sH", "sC", "sN"]
const NOME_UNITA := {
	"AH": "opliti ateniesi", "AC": "cavalleria ateniese", "AN": "navi ateniesi",
	"aH": "opliti alleati di Atene", "aC": "cavalleria alleata di Atene", "aN": "navi alleate di Atene",
	"SH": "opliti spartani", "SG": "Guardia Nazionale", "SC": "cavalleria spartana", "SN": "navi spartane",
	"sH": "opliti alleati di Sparta", "sC": "cavalleria alleata di Sparta", "sN": "navi alleate di Sparta",
}
const BREVE := {
	"AH": "Opl. ateniesi", "AC": "Cav. ateniese", "AN": "Navi ateniesi", "aH": "Opl. alleati", "aC": "Cav. alleata", "aN": "Navi alleate",
	"SH": "Opl. spartani", "SG": "Guardia", "SC": "Cav. spartana", "SN": "Navi spartane", "sH": "Opl. alleati", "sC": "Cav. alleata", "sN": "Navi alleate",
}
## Limite delle pedine: punti forza massimi in gioco per ogni tipo.
const LIMITE := {"AH": 12, "AC": 2, "AN": 22, "aH": 14, "aC": 14, "aN": 15, "SH": 13, "SG": 3, "SC": 2, "SN": 6, "sH": 20, "sC": 19, "sN": 11}

## Condottieri della campagna: [lato, valore tattico, valore strategico, nome italiano]
const CAPI := {
	"pericles": ["A", 1, 0, "Pericle"], "phormio": ["A", 2, 0, "Formione"], "thasyllus": ["A", 1, 1, "Trasillo"],
	"thrasybulus": ["A", 2, 1, "Trasibulo"], "nicias": ["A", 0, 1, "Nicia"], "alcibiades": ["A", 1, 2, "Alcibiade"],
	"cleon": ["A", 0, 2, "Cleone"], "demosthenes": ["A", 2, 1, "Demostene"],
	"archidamus": ["S", 1, -1, "Archidamo"], "lysander": ["S", 2, 2, "Lisandro"], "pleistoanax": ["S", 0, 0, "Plistoanatte"],
	"agis": ["S", 1, 1, "Agide"], "brasidas": ["S", 2, 2, "Brasida"], "mindaurus": ["S", 1, 2, "Mindaro"],
	"gylippus": ["S", 2, 1, "Gilippo"], "callicratades": ["S", 1, 1, "Callicratida"],
}

const NOME_STRATEGIA := {
	"": "nessuna", "attacco": "Attaccare lo spazio nazionale nemico", "rivolta": "Causare Ribellione",
	"loc": "Tagliare LOC", "alleati": "Attaccare Alleato nemico",
}

## Nome della strategia come sulla Matrice Strategica della parte indicata.
static func nome_strategia(k: String, lato: String) -> String:
	if k == "attacco":
		return "Attaccare Atene" if lato == "S" else "Attaccare Sparta"
	if k == "alleati":
		return "Attaccare Alleato ateniese" if lato == "S" else "Attaccare Alleato spartano"
	return NOME_STRATEGIA[k]

## Matrice di Sparta (quando Sparta è guidata dal gioco). Dado modificato -> strategia.
const MATRICE := {
	"S": {
		"dado": {1: "attacco", 2: "rivolta", 3: "rivolta", 4: "loc", 5: "loc", 6: "alleati"},
		"attacco": {"forza": {"C": {"H": 12, "C": 2}, "I": {"H": 12, "C": 2}, "L": {"H": 12, "C": 2}},
			"obiettivi": ["Athens", "Athens", "Athens", "Panactum", "Decelea", "Decelea"]},
		"rivolta": {"forza": {"C": {"H": 1, "N": 1}, "I": {"H": 1, "N": 1}, "L": {"H": 2}},
			"aree": ["Caria", "Ionia", "Ellesponto", "Tracia", "Isole", "Alleati"]},
		"loc": {"forza": {"C": {"H": 2, "N": 2}, "I": {"H": 2, "N": 2}, "L": {"H": 2}},
			"aree": ["Tracia", "Tracia", "Ellesponto", "Ellesponto", "Ellesponto", "Isole"]},
		"alleati": {"forza": {"C": {"H": 3, "N": 3}, "I": {"H": 3, "N": 3}, "L": {"H": 4}},
			"aree": ["Caria", "Ionia", "Ellesponto", "Tracia", "Isole", "Alleati"]},
		"aree": {
			"Caria": ["Halicarnassus", "Cnidus", "Kos", "Camirus", "Lindus", "Triopium"],
			"Ionia": ["Miletus", "Phocaea", "Antandrus", "Erythrae", "Mytilene", "Cyme"],
			"Ellesponto": ["Abydos", "Lampsacus", "Cardia", "Sigeum", "Elaeus", "Byzantium"],
			"Tracia": ["Maraneia", "Abdera", "Amphipolis", "Amphipolis", "Olynthus", "Potidaea"],
			"Isole": ["Andros", "Chios", "Naxos", "Samos", "Tenedos", "Chalcis"],
			"Alleati": ["Argos", "Aegina", "Corcyra", "Stratus", "Naupactus", "Platea"],
		},
	},
	"A": {
		"dado": {1: "alleati", 2: "alleati", 3: "rivolta", 4: "rivolta", 5: "loc", 6: "attacco"},
		"attacco": {"forza": {"C": {"H": 15, "C": 4}, "I": {"H": 15, "C": 4}, "L": {"H": 15, "C": 4}},
			"obiettivi": ["Sparta", "Caryae", "Tegea", "Belmina", "Methydrum", "Mantinea"]},
		"alleati": {"forza": {"C": {"H": 4, "N": 4}, "I": {"H": 4, "N": 4}, "L": {"H": 7, "C": 2}},
			"aree": ["Istmo", "Beozia", "Sicilia", "Arcadia e Acaia", "Peloponneso e Messenia", "Alleati"]},
		"rivolta": {"forza": {"C": {"H": 2, "N": 2}, "I": {"H": 2, "N": 2}, "L": {"H": 2, "C": 1}},
			"aree": ["Peloponneso e Messenia", "Peloponneso e Messenia", "Sicilia", "Alleati", "Alleati", "Arcadia e Acaia"]},
		"loc": {"forza": {"C": {"H": 3, "N": 3}, "I": {"H": 3, "N": 3}, "L": {"H": 3, "C": 2}},
			"aree": ["Istmo", "Istmo", "Arcadia e Acaia", "Peloponneso e Messenia", "Peloponneso e Messenia", "Sicilia"]},
		"aree": {
			"Istmo": ["Corinth", "Sicyon", "Pegae", "Cenchrae", "Megara", "Epidaurus"],
			"Beozia": ["Thebes", "Delium", "Tanagra", "Siphae", "Heraclea", "Cytinium"],
			"Sicilia": ["Syracuse", "Syracuse", "Syracuse", "Messina", "Gela", "Panormus Sicily"],
			"Arcadia e Acaia": ["Elis", "Leucas", "Cyllene", "Hermione", "Methana", "Troezen"],
			"Peloponneso e Messenia": ["Pylos", "Epidaurus Limera", "Gythium", "Asine", "Prasiae", "Corone"],
			"Alleati": ["Tegea", "Nemea", "Syracuse", "Mantinea", "Melos", "Methydrum"],
		},
	},
}
const TRACIA := ["Maraneia", "Abdera", "Amphipolis", "Olynthus", "Potidaea"]
const ELLESPONTO := ["Abydos", "Lampsacus", "Cardia", "Sigeum", "Elaeus", "Byzantium"]
const ILOTI := ["Pylos", "Asine", "Corone", "Prasiae", "Epidaurus Limera"]
const DIFESA_ATENE := ["Aegina", "Salamis", "Naupactus", "Chios", "Amphipolis", "Corcyra", "Samos", "Chalcis"]
const COALIZIONE := {"A": ["Amphipolis", "Larisa", "Corcyra", "Chios"], "S": ["Corinth", "Thebes"]}
const RIVOLTE_DELIE := {2: "Cnidus", 3: "Naxos", 4: "Byzantium", 5: "Chalcis", 6: "Ephesus", 7: "Mytilene", 8: "Olynthus", 9: "Miletus", 10: "Camirus", 11: "Lampsacus", 12: "Amphipolis"}
const SICILIA := ["Lilybaeum", "Panormus Sicily", "Selinus", "Gela", "Acragas", "Segesta", "Enna", "Leontini", "Camarina", "Helorus", "Syracuse", "Himera", "Catana", "Messina"]

const NOME_EVENTO := {
	2: "Scoperta una miniera d'argento", 3: "Ribellione oligarchica ad Atene", 4: "Re Sitalce di Tracia cambia alleanza",
	5: "La Persia entra in guerra", 6: "Epidemia ad Atene: Pericle muore", 7: "Demagogo da Assumere (Alcibiade)",
	8: "Ribellione oligarchica nella Lega di Delo", 9: "Re Perdicca di Macedonia cambia alleanza",
	10: "Potenze minori", 11: "Morte dei comandanti", 12: "Fenomeno: eclissi o terremoto",
}

const ANNI := ["431-429", "428-426", "425-423", "422-420", "419-417", "416-414", "413-411", "410-408", "407-405", "404-402"]

static var spazi: Dictionary = {}
static var larghezza := 4080
static var altezza := 2640
static var eusino := Vector2(3780, 60)
static var colori: Dictionary = {}

static func carica() -> void:
	if not spazi.is_empty():
		return
	var j = JSON.parse_string(FileAccess.get_file_as_string("res://data/spazi.json"))
	spazi = j["spazi"]
	larghezza = int(j["larghezza"])
	altezza = int(j["altezza"])
	eusino = Vector2(j["eusino"][0], j["eusino"][1])
	colori = JSON.parse_string(FileAccess.get_file_as_string("res://data/colori_pedine.json"))

static func nome(id: String) -> String:
	return spazi[id]["nome"] if spazi.has(id) else id

static func capo_nome(c: String) -> String:
	return CAPI[c][3]

static func lato_di(chiave: String) -> String:
	return "A" if chiave[0] == "A" or chiave[0] == "a" else "S"

static func tipo_di(chiave: String) -> String:
	return "H" if chiave == "SG" else chiave[1]

static func alleata(chiave: String) -> bool:
	return chiave[0] == "a" or chiave[0] == "s"

static func chiavi_di(lato: String) -> Array:
	return ["AH", "AC", "AN", "aH", "aC", "aN"] if lato == "A" else ["SH", "SG", "SC", "SN", "sH", "sC", "sN"]

static func tipo_spazio_nome(t: String) -> String:
	return {"L": "terra", "C": "costa", "I": "isola"}[t]

static func maiuscola(t: String) -> String:
	return t.substr(0, 1).to_upper() + t.substr(1)

static var _re_eufonia: RegEx

## "a Atene" diventa "ad Atene".
static func eufonia(t: String) -> String:
	if _re_eufonia == null:
		_re_eufonia = RegEx.new()
		_re_eufonia.compile("\\b([aA]) (A[a-z])")
	return _re_eufonia.sub(t, "$1d $2", true)
