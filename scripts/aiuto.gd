## Testi di aiuto: regole in breve e tabelle del gioco, in italiano.
class_name Aiuto
extends RefCounted

const REGOLE := """[font_size=26][color=#8a2a1c]La guerra del Peloponneso, 431-404 a.C.[/color][/font_size]

Peloponnesian War, di Mark Herman (GMT Games), è un solitario. Comandi uno dei due contendenti, Atene con la Lega delio-attica oppure Sparta con la Lega del Peloponneso, mentre il gioco guida l'altro con la sua matrice delle strategie. Se combatti bene, però, a inizio turno puoi essere chiamato a cambiare schieramento: diventi il peggior nemico di te stesso. Lo scopo è chiudere la guerra in fretta, con un vincitore ancora forte.

[color=#8a2a1c][b]Come si vince[/b][/color]
Campagna: 10 turni di tre anni ciascuno. Vinci se alla fine hai più di 150 punti vittoria, oppure se uno dei due si arrende entro il terzo turno.
Guerra archidamica: finisce al terzo turno, alla tregua, alla resa o quando torni al comando di Atene. Vinci con 40 punti o più.
Punti vittoria: +10 per ogni battaglia vinta o assedio riuscito dal lato che comandi; -15 per ogni battaglia persa o città amica presa per assedio dal nemico; alla resa di un contendente, 200 diviso il numero del turno.

[color=#8a2a1c][b]La mappa[/b][/color]
Quadrati: spazi di terra. Triangoli: spazi costieri. Cerchi: isole. Verde: Lega delio-attica. Rosso: Lega del Peloponneso. Giallo: neutrali. Le torri indicano una fortezza, che va presa con un assedio.
Linee doppie: vie di terra (solo truppe). Linee punteggiate: rotte navali (solo navi; ogni punto di navi trasporta un punto di truppe). Linee doppie punteggiate: vie miste (tutti).
Trascina per spostare la mappa, rotella o due dita per ingrandire. Tocca uno spazio per vederne i dettagli.

[color=#8a2a1c][b]Le forze[/b][/color]
Opliti, cavalleria e navi, di Atene, di Sparta e dei rispettivi alleati. Il numero sulla pedina è la forza in punti. Le pedine scurite hanno già agito in questo turno.
Zona d'influenza: gli opliti controllano solo il proprio spazio; la cavalleria anche gli spazi adiacenti per via di terra o mista; le navi tutti gli spazi entro due rotte navali o miste. Nessuna zona d'influenza nemica entra ad Atene o al Pireo.

[color=#8a2a1c][b]Il turno[/b][/color]
[b]1. Fase politica[/b] (non al primo turno). Se la tua fiducia strategica è zero o più tiri un dado e aggiungi la fiducia: con 6 o più cambi schieramento. Poi un evento, la possibile rivolta nella Lega delio-attica (se la fiducia di Atene è zero o meno, o se ha perso 4 punti di navi) e l'estrazione di un condottiero per parte.
[b]2. Strategia.[/b] Il lato guidato dal gioco conferma la strategia se la sua fiducia era positiva, altrimenti tira sulla matrice. Poi le fiducie tornano a zero.
[b]3. Operazioni.[/b] Prima tu, poi il nemico, poi a turno finché entrambi passano. Dalla seconda operazione in poi si consultano gli auspici: con 6 o più (il nemico aggiunge 1, tu la metà dei tuoi condottieri già in campo) bisogna passare.
Per un'operazione scegli un obiettivo e un condottiero nella capitale; il condottiero raggiunge gli spazi amici dove vuoi radunare truppe, le attivi pagando (200 talenti per punto di truppe, 400 per punto di navi; opliti e cavalleria spartani sono gratuiti; Atene deve tenere 1000 talenti di riserva), poi la spedizione marcia sull'obiettivo per la via più breve. Le truppe attivate non agiscono più nel turno.
Entrando nella zona d'influenza di una forza nemica si rischia l'intercettazione (4-6): segue una scaramuccia (con 1 si perde un punto) e, se i dadi sommano 11 o più o se chi intercetta ha almeno metà di 8 o più punti in campo, una battaglia. Gli spazi nemici vuoti attraversati verso l'obiettivo vengono devastati.
Fomentare la rivolta: paghi 100 talenti e con 6 lo spazio obiettivo insorge e diventa amico.
[b]4. Combattimento.[/b] Si individuano gli assedi (un'armata con condottiero in una fortezza nemica vuota, o con almeno 5 punti più dei difensori), si combattono le battaglie fra forze nello stesso spazio o dentro una zona d'influenza nemica, si risolvono gli assedi (4 o più sul dado, più il valore tattico) e le armate tornano a casa: con 1-5 (più il valore strategico) resta una guarnigione di 1 punto, con 6 o più restano tutti.
In battaglia ogni lato tira un dado e aggiunge: la differenza di opliti (o di navi), il valore tattico del condottiero, +1 per la superiorità di cavalleria, +2 a Sparta se almeno metà degli opliti sono spartani e +2 se combatte in patria, +2 ad Atene in mare se almeno metà delle navi sono ateniesi. Chi perde elimina tanti punti quanti la differenza e torna a casa.
[b]5. Rivolte.[/b] Le rivolte vicine a una forza amica e lontane dal nemico sono domate; le altre possono estendersi agli spazi adiacenti (6, +2 se il nemico è vicino). Se Atene occupa Pilo, Asine, Corone, Prasie ed Epidauro Limera insorgono gli iloti.
[b]6. Amministrazione.[/b] Entrate (3500 Atene, 2500 Sparta, meno 50 per ogni spazio devastato, in rivolta o perduto, più i casi speciali) e costruzione di nuove unità: tu fino a 600 talenti, il nemico rimpiazza fino a 3 punti perduti.
[b]7. Tregua e resa.[/b] La bellicosità cala con la fiducia negativa e con gli spazi perduti, sale con la fiducia positiva. A zero, o con la capitale in mano nemica, ci si arrende. Se entrambi sono a 6 o meno (o sotto i 1000 talenti) scoppia la tregua, una sola volta per partita.

[color=#8a2a1c][b]Note su questa versione[/b][/color]
Il gioco applica da solo dadi, percorsi più brevi, intercettazioni, perdite e ritorni a casa, e segue le errata e i chiarimenti ufficiali del 2020. Le perdite colpiscono prima gli alleati. Sono compresi la Campagna e la Guerra archidamica del regolamento; gli altri scenari del Playbook non sono nel modulo di partenza.
"""

static func matrice(lato: String) -> String:
	var m: Dictionary = Dati.MATRICE[lato]
	var t := "[font_size=24][color=#8a2a1c]Matrice delle strategie di %s[/color][/font_size]\n" % Dati.NOME_LATO[lato]
	t += "Vale quando %s è guidata dal gioco. Il dado, più il valore strategico del condottiero nella capitale, sceglie la strategia.\n\n" % Dati.NOME_LATO[lato]
	if lato == "S":
		t += "[b]Strategia difensiva[/b] (ha la precedenza): se una forza ateniese è entro due spazi da Sparta per via di terra, oppure occupa Corinto o Tebe, parte una spedizione di 10 opliti e 1 cavalleria contro di essa. Se Siracusa è nella zona d'influenza ateniese, 10 opliti e 1 cavalleria attaccano l'Attica.\n\n"
	else:
		t += "[b]Strategia difensiva[/b] (ha la precedenza): se una forza spartana occupa Egina, Salamina, Naupatto, Chio, Anfipoli, Corcira, Samo, Calcide o uno spazio entro due da Proconneso, parte una spedizione di 3 opliti e 3 navi.\n\n"
	var per_strategia := {}
	for d in range(1, 7):
		var st: String = m.dado[d]
		if not per_strategia.has(st):
			per_strategia[st] = []
		per_strategia[st].append(str(d))
	for st in per_strategia:
		t += "[b]Dado %s: %s[/b]\n" % ["-".join(per_strategia[st]), Dati.NOME_STRATEGIA[st]]
		var f: Dictionary = m[st].forza
		t += "Forza per costa o isola: %s. Per terra: %s.\n" % [_forza(f.C), _forza(f.L)]
		if st == "attacco":
			var nomi := []
			for i in 6:
				nomi.append("%d %s" % [i + 1, Dati.nome(m.attacco.obiettivi[i])])
			t += "Obiettivo: %s.\n\n" % ", ".join(nomi)
		else:
			var nomi2 := []
			for i in 6:
				nomi2.append("%d %s" % [i + 1, m[st].aree[i]])
			t += "Area (dado verde): %s.\n\n" % ", ".join(nomi2)
	t += "[b]Obiettivi per area (dado rosso)[/b]\n"
	for area in m.aree:
		var nomi3 := []
		for i in 6:
			nomi3.append("%d %s" % [i + 1, Dati.nome(m.aree[area][i])])
		t += "[color=#8a2a1c]%s[/color]: %s.\n" % [area, ", ".join(nomi3)]
	if lato == "S":
		t += "\nGli spazi di Tracia valgono come spazi di terra per forza e percorso; quelli dell'Ellesponto anche, se Anfipoli è amica di Sparta.\n"
	else:
		t += "\nSe 4 dei 5 spazi di Peloponneso e Messenia che decidono la rivolta degli iloti sono amici di Atene, il quinto è l'obiettivo senza tirare.\n"
	return t

static func _forza(f: Dictionary) -> String:
	var p := []
	for k in ["H", "C", "N"]:
		if f.get(k, 0) > 0:
			p.append("%s %d" % [{"H": "opliti", "C": "cavalleria", "N": "navi"}[k], f[k]])
	return ", ".join(p)

const EVENTI := """[font_size=24][color=#8a2a1c]Tabella degli eventi (due dadi)[/color][/font_size]

[b]2. Scoperta una miniera d'argento.[/b] Dado 1-3: Sparta guadagna 400 talenti; 4-6: Atene.
[b]3. Rivolta oligarchica ad Atene.[/b] Solo se la fiducia di Atene è negativa e Alcibiade è con Spartani o Persiani; una volta per partita. Bellicosità di Atene -2, +100 talenti, niente eisphora nel turno, due tiri di rivolta (evento 8).
[b]4. Re Sitalce di Tracia cambia alleanza.[/b] Abdera e Maronea passano all'altro schieramento con i loro alleati.
[b]5. La Persia entra in guerra.[/b] Solo dal turno 5, con bellicosità di Sparta a 6 o più e Alcibiade con Spartani o Persiani; una volta per partita. Sparta riceve 500 talenti a turno; se conquista Iaso, 1000 e 3 punti di cavalleria a Sardi.
[b]6. Peste ad Atene: muore Pericle.[/b] Solo se nel turno precedente una forza spartana è stata ad Atene, al Pireo, a Panatto o a Decelea; una volta per partita. Atene perde un terzo degli opliti ateniesi di Atene e del Pireo e paga un quarto del costo delle sue navi.
[b]7. Un demagogo in vendita.[/b] La prima volta Alcibiade passa a Sparta (+1 al dado della strategia spartana); la seconda fugge a Sardi; la terza torna ad Atene come condottiero; la quarta esce dal gioco.
[b]8. Rivolta oligarchica nella Lega delio-attica.[/b] Due dadi: 2 Cnido, 3 Nasso, 4 Bisanzio, 5 Calcide, 6 Efeso, 7 Mitilene, 8 Olinto, 9 Mileto, 10 Camiro, 11 Lampsaco, 12 Anfipoli. Se lo spazio è già in rivolta o presidiato si ritira aggiungendo 1 per ogni tiro fatto. Ogni spazio adiacente si ribella con 6.
[b]9. Re Perdicca di Macedonia cambia alleanza.[/b] Pella e la Macedonia passano all'altro schieramento.
[b]10. Potenze minori.[/b] Turni 1-3: guerra civile a Corcira, le sue forze non operano nel turno. Turni 4-6: Argo si allea con Atene (4 opliti). Turni 7-8: Siracusa si allea con Sparta (2 opliti, 2 cavalleria, 2 navi). Turni 9-10: Corcira diventa neutrale.
[b]11. Morte dei condottieri.[/b] Nel turno, in ogni battaglia, un dado non modificato da 1 a 3 uccide il condottiero (al massimo 3 per parte in tutta la partita; Alcibiade e Pericle sono immuni).
[b]12. Prodigi.[/b] Dado 1-3: eclissi di luna su Atene; 4-6: terremoto a Sparta. Chi è colpito non fa più di 2 operazioni nel turno.
"""

const RITORNI := """[font_size=24][color=#8a2a1c]Ritorno a casa e nuove unità[/color][/font_size]

Le unità sconfitte, quelle delle armate che rientrano e quelle appena costruite si collocano così:

[b]Opliti ateniesi[/b]: Atene.   [b]Cavalleria ateniese[/b]: Atene.   [b]Navi ateniesi[/b]: Pireo.
[b]Opliti alleati di Atene[/b]: il primo ad Anfipoli, poi 2 a Larissa (prima 4 ad Argo, se alleata), il resto metà a Corcira e metà a Chio.
[b]Cavalleria alleata di Atene[/b]: Larissa (prima a Pella finché ce ne sono 2, se la Macedonia è alleata).
[b]Navi alleate di Atene[/b]: metà a Corcira e metà a Chio.
Se Chio è in rivolta o in mano nemica, al suo posto Samo.

[b]Opliti e cavalleria spartani[/b]: Sparta.   [b]Navi spartane[/b]: Gizio, altrimenti Corinto.
[b]Opliti alleati di Sparta[/b]: metà a Corinto e metà a Tebe (prima a Siracusa finché ce ne sono 2, se alleata).
[b]Cavalleria alleata di Sparta[/b]: Tebe (prima a Sardi, a Pella o a Siracusa se alleate, finché ce ne sono 3, 2 e 2).
[b]Navi alleate di Sparta[/b]: Corinto, altrimenti Gizio (prima a Siracusa finché ce ne sono 2, se alleata).

Se la destinazione è in rivolta o in mano nemica si passa alla successiva; le navi senza un porto sono eliminate.
"""
