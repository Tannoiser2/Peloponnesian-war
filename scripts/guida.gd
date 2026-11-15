## Partita guidata: una vera partita (Campagna, comandi Atene) con i dadi fissati da un seme, così ogni risultato
## è quello descritto. Nel primo turno la guida indica ogni mossa, accetta solo quella e spiega l'esito con le regole;
## nel turno 2 giochi tu e la guida dà consigli legati alla situazione; all'inizio del turno 3 si congeda.
## tests/guida.gd esegue il copione sul motore e controlla che i risultati siano proprio questi.
class_name Guida
extends RefCounted

const SEME := 24
const R := "#8a2a1c"

static func t(s: String) -> String:
	return "[color=%s][b]%s[/b][/color]\n" % [R, s]

## tipo: leggi | continua | obiettivo | parti | raduno | marcia | passa | costruisci
## centro: spazio da inquadrare; evid: spazi da cerchiare; attesa: tipo di attesa del motore previsto al passo.
const COPIONE := [
	# 0
	{"tipo": "leggi", "attesa": "", "centro": "Athens", "evid": [],
	"titolo": "Benvenuto nella partita guidata",
	"testo": """Giocherai il [b]primo turno della Campagna[/b] al comando di [b]Atene[/b]. È una partita vera: stessi dadi, stesse regole del gioco normale. I dadi però sono fissati in anticipo, così posso spiegarti ogni risultato con precisione.

[b]Come funziona[/b]
In ogni passo ti dico che cosa fare. Il gioco accetta solo quella mossa: se tocchi altro, te lo ricorda. Puoi sempre toccare gli spazi per leggerne i dettagli, aprire il Diario, le Tabelle o il Tutorial.
Questo riquadro si può ridurre con il pulsante [b]Riduci[/b], se copre la mappa.
Nel [b]turno 2[/b] giocherai da solo, con consigli che cambiano secondo la situazione.

[b]Che cosa imparerai[/b]
1. Come si muove la parte non-giocatore (Sparta).
2. Gli Auguri e la pesca dei comandanti.
3. Un'incursione navale che saccheggia la costa nemica.
4. Un'operazione con raduno in due spazi e trasporto navale.
5. La Fase di Combattimento: Lunghe Mura, battaglia navale, assedi, Verso Casa.
6. Entrate, costruzione, Bellicosità e il cambio di parte.

Premi [b]Avanti[/b] qui sotto."""},
	# 1
	{"tipo": "leggi", "attesa": "", "centro": "Megara", "evid": ["Athens", "Piraeus", "Potidaea", "Sparta", "Corinth", "Thebes"],
	"titolo": "La situazione iniziale",
	"testo": """Guarda la mappa: gli spazi cerchiati in giallo sono quelli importanti. Trascina e pizzica per spostarti.

""" + "[color=#8a2a1c][b]La tua parte: Lega di Delo[/b][/color]" + """
[b]Atene[/b]: Pericle (Valore Tattico 1, Strategico 0), 6 Opliti, 1 Cavalleria. [b]Pireo[/b]: 8 navi. Tesoro 4500 talenti, Bellicosità 10.
A [b]Potidea[/b], in Calcidica (fuori da questa inquadratura), Formione (2/0) assedia la città in ribellione con 2 Opliti, 3 navi e 1 Cavalleria alleata, già attivati: è l'operazione iniziale di Atene, già fatta.
Alleati: Corcira, Chio, Larissa, Pella, Anfipoli. Naupatto ha 1 nave.

""" + "[color=#8a2a1c][b]Il nemico: Lega del Peloponneso[/b][/color]" + """
[b]Sparta[/b]: Archidamo (1/-1), Guardia Nazionale (3), 7 Opliti, 1 Cavalleria. [b]Corinto[/b]: 5 Opliti e 5 navi alleati. [b]Tebe[/b]: 5 Opliti e 4 Cavalleria alleati. Tesoro 3000, Bellicosità 10.
La sua strategia è già scritta: [b]Attaccare Atene[/b], con una forza di 12 Opliti e 2 Cavalleria.

[b]Il turno 1 comincia a metà.[/b] La Fase Politica e quella Strategica si saltano, e la tua operazione iniziale è quella di Formione. Ora tocca all'operazione iniziale di Sparta, poi alle operazioni continuate.

Premi [b]Avanti[/b]."""},
	# 2
	{"tipo": "continua", "attesa": "", "centro": "Megara", "evid": ["Athens", "Panactum", "Decelea"],
	"titolo": "Sparta muove per prima",
	"testo": """La parte non-giocatore esegue la sua [b]Matrice Strategica[/b] in quattro passi.
1. [b]Strategia Difensiva?[/b] Nessuna tua Forza è entro due spazi da Sparta, né a Corinto o a Tebe: no.
2. [b]Obiettivo[/b]: con "Attaccare Atene" un dado sceglie fra Atene (1-3), Panatto (4) e Decelea (5-6), cerchiati sulla mappa.
3. [b]Forza[/b]: 12 Opliti e 2 Cavalleria.
4. [b]Raduno[/b]: prima nello spazio nazionale, poi negli spazi amici più vicini. Il gioco non attiva l'ultimo SP di un tipo in uno spazio se può evitarlo.

Premi [b]Continua[/b] nel pannello in basso a destra: Sparta fa la sua operazione."""},
	# 3
	{"tipo": "continua", "attesa": "continua", "centro": "Megara", "evid": ["Athens", "Platea", "Panactum", "Siphae"],
	"titolo": "Archidamo marcia su Atene",
	"testo": """Leggi il riepilogo in basso a destra. La linea gialla sulla mappa è il percorso della Spedizione.

[b]Obiettivo[/b]: dado 1, [b]Atene[/b] stessa.
[b]Raduno[/b]: a Sparta Archidamo attiva [b]7 Opliti spartani[/b], gratis. La Guardia Nazionale non si muove mai. La Cavalleria spartana resta: è l'ultimo SP di quel tipo e altra Cavalleria è disponibile a Tebe.
A Corinto prende 4 Opliti alleati (800 talenti): il quinto è l'ultimo Oplita dello spazio. A Tebe 1 Oplita e 2 Cavalleria (600 talenti). Totale 12 Opliti e 2 Cavalleria; Sparta ha speso [b]1400 talenti[/b] (Tesoro 1600).

[b]Intercettazioni[/b]. Ogni volta che una Spedizione entra in una ZOI nemica si tira un dado: con 4-6 è intercettata.
A [b]Sife[/b] la ZOI della tua nave di Naupatto (entro 2 rotte navali): dado 1, fallita.
A [b]Panatto[/b] la ZOI della tua Cavalleria di Atene: dado 6, [b]riuscita[/b]. Schermaglia: Sparta 5, Atene 3, nessun 1, nessuna perdita. Diventa battaglia? I dadi sommano 8, non 11. Gli SP di terra sono 21, ma i tuoi 7 sono meno della metà. No.
Ad [b]Atene[/b]: dado 2, fallita.

[b]Saccheggio[/b]: [b]Platea[/b] è tua, vuota e attraversata verso l'obiettivo: saccheggiata. Panatto no, perché lì l'intercettazione è riuscita. Atene no: è occupata da una tua Forza.

Ora a Sparta ci sono solo la Guardia e la Cavalleria. L'Armata di Archidamo è ad Atene, accanto alle tue truppe. Non si combatte adesso: battaglie e assedi si decidono tutti nella Fase di Combattimento.

Premi [b]Continua[/b]: comincia la tua prima operazione continuata."""},
	# 4
	{"tipo": "obiettivo", "id": "Erineus", "attesa": "operazione", "centro": "Erineus", "evid": ["Erineus"],
	"titolo": "Gli Auguri e il primo obiettivo",
	"testo": """[b]Auguri[/b]: prima di ogni operazione continuata si tira un dado. Con 6 o più devi passare.
Tu aggiungi metà dei tuoi comandanti in campo, arrotondata per difetto. Ne hai due, Pericle ad Atene e Formione a Potidea: +1. È uscito [b]2+1 = 3[/b]: favorevoli.
Il comandante è Pericle, l'unico nello spazio nazionale.

[b]Il piano: un'incursione navale.[/b] Una Spedizione di sole navi che gira attorno al Peloponneso:
1. [b]saccheggia[/b] ogni spazio nemico vuoto che attraversa, e ognuno toglie 50 talenti a Sparta; arrivati a 10 tolgono anche 1 di Bellicosità;
2. da terra non si può battere: contro truppe senza navi la battaglia è [b]nulla[/b];
3. arriva su una fortezza da [b]assediare[/b].

[b]Erineo[/b] è uno spazio costiero giallo, neutrale, con fortezza, nel Golfo di Corinto. Per arrivarci dal Pireo le navi devono fare il giro di tutto il Peloponneso. Essendo neutrale e obiettivo, va preso con un assedio: +10 punti vittoria se riesce.

[b]Tocca Erineo[/b] sulla mappa (cerchiato)."""},
	# 5
	{"tipo": "parti", "attesa": "operazione", "centro": "Erineus", "evid": ["Erineus"],
	"titolo": "Designa obiettivo e comandante",
	"testo": """Erineo è l'obiettivo: lo vedi con l'anello rosso.
Non spuntare "Causa Ribellione". Per il giocatore riesce solo con un 6, costa 100 talenti, e se fallisce l'operazione è annullata.

Premi [b]Parti[/b]: Pericle è designato comandante della Spedizione."""},
	# 6
	{"tipo": "raduno", "id": "Piraeus", "u": {"AN": 3}, "attesa": "raduno", "centro": "Piraeus", "evid": ["Piraeus"],
	"titolo": "Raduna la flotta al Pireo",
	"testo": """Ora Pericle raduna la Spedizione. Gli [b]spazi di raduno[/b] (cerchiati in verde) sono i tuoi spazi con unità non ancora attivate. Pericle li raggiunge da solo, per la via più breve.

Vuoi [b]solo navi[/b]: con truppe a bordo dovresti avere almeno tante navi quanti SP di terra, e una guarnigione di Opliti in Peloponneso sarebbe esposta. Ogni SP navale costa [b]400 talenti[/b]: 3 navi fanno 1200 (Tesoro da 4500 a 3300).
Atene non può mai scendere sotto [b]1000 talenti[/b] (Fondo di Emergenza): restano 2300 spendibili.

[b]Tocca il Pireo[/b]: le quantità sono già impostate a 3 navi ateniesi. Poi premi [b]Unisci[/b]."""},
	# 7
	{"tipo": "marcia", "attesa": "raduno", "centro": "Tegea", "evid": ["Prasiae", "Corone", "Erineus"],
	"titolo": "In mare",
	"testo": """Pericle è al Pireo con 3 navi. Premendo [b]Marcia[/b] la Spedizione segue la via più breve consentita a una flotta: Egina, Metana, Capo Scilleo, Idra, Ermione, Prasie, Epidauro Limera, Citera, Capo Tenaro, Corone, Asine, Pilo, Zacinto, Cefalonia, Eniade, Naupatto, Panormo, Erineo.

[b]Che cosa può succedere[/b]
A [b]Prasie[/b] e [b]Corone[/b] (cerchiate) entri nella ZOI della Cavalleria di Sparta, che copre gli spazi adiacenti: due tentativi di intercettazione. Anche se riuscissero, la schermaglia costerebbe al massimo una nave (con un 1 sul dado). L'eventuale battaglia sarebbe nulla: navi contro truppe di terra (a Sparta ci sono solo la Guardia Nazionale e la Cavalleria).
A [b]Erineo[/b] sei nella ZOI navale della flotta di Corinto (Corinto, Sicione, Erineo: due rotte). Qui intercettazione e schermaglia sono possibili, e con 11-12 sui dadi anche una battaglia navale.
Ogni spazio [b]rosso e vuoto[/b] attraversato verrà saccheggiato. Zacinto e Naupatto sono tuoi, Cefalonia e Panormo neutrali: quelli no.

Premi [b]Marcia su Erineo[/b]."""},
	# 8
	{"tipo": "continua", "attesa": "continua", "centro": "Tegea", "evid": ["Erineus"],
	"titolo": "Il giro del Peloponneso",
	"testo": """Leggi il riepilogo. [b]Dodici spazi saccheggiati[/b]: Metana, Capo Scilleo, Idra, Ermione, Prasie, Epidauro Limera, Citera, Capo Tenaro, Corone, Asine, Pilo, Eniade.
In Fase Amministrativa costeranno a Sparta 600 talenti. Superata la decina, a fine turno le toglieranno anche [b]1 punto di Bellicosità[/b].

Le tre intercettazioni (Prasie, Corone, Erineo) sono tutte fallite con un 3. Pericle è a Erineo con 3 navi, dentro la ZOI della flotta di Corinto e con Corinto dentro la sua: in Fase di Combattimento si combatterà.

Premi [b]Continua[/b]: tocca a Sparta."""},
	# 9
	{"tipo": "continua", "attesa": "continua", "centro": "Sparta", "evid": ["Sparta"],
	"titolo": "Sparta deve passare",
	"testo": """Per la sua operazione continuata Sparta ha consultato gli Auguri. La parte non-giocatore aggiunge sempre +1: è uscito [b]6+1 = 7[/b], sfavorevoli, e [b]deve passare[/b].
[b]Chi passa ha finito il turno[/b]: da qui in avanti fai operazioni solo tu, una alla volta, ognuna con i suoi Auguri.
Anche con Auguri favorevoli Sparta non avrebbe potuto molto: "Attaccare Atene" chiede 12 Opliti e 2 Cavalleria, e gliene restavano liberi solo 5 e 3.

Premi [b]Continua[/b]."""},
	# 10
	{"tipo": "obiettivo", "id": "Methana", "attesa": "operazione", "centro": "Aegina", "evid": ["Methana"],
	"titolo": "Seconda operazione: Demostene",
	"testo": """[b]Auguri[/b]: hai ancora due comandanti in campo, Pericle a Erineo e Formione a Potidea, quindi +1. Uscito [b]3+1 = 4[/b]: favorevoli.
Nello spazio nazionale non c'era nessun comandante: se n'è pescato uno dalla tazza, [b]Demostene[/b], Valore Tattico 2 e Strategico 1. Con tattico 2 un assedio riesce 5 volte su 6 (dado + 2, serve 4).

[b]Obiettivo: Metana[/b], fortezza costiera rossa a due rotte dal Pireo (Pireo, Egina, Metana). È vuota, già saccheggiata da Pericle, fuori dalle ZOI nemiche, e a più di due spazi da Sparta: non provocherà la sua Strategia Difensiva.

[b]Tocca Metana[/b] (cerchiata)."""},
	# 11
	{"tipo": "parti", "attesa": "operazione", "centro": "Aegina", "evid": ["Methana"],
	"titolo": "Parti con Demostene",
	"testo": """Premi [b]Parti[/b]: Demostene comanda la Spedizione verso Metana."""},
	# 12
	{"tipo": "raduno", "id": "Athens", "u": {"AH": 3}, "attesa": "raduno", "centro": "Piraeus", "evid": ["Athens"],
	"titolo": "Opliti da Atene",
	"testo": """Questa volta vuoi anche truppe di terra: se l'assedio riesce, resterà a Metana una [b]guarnigione di Opliti[/b], cioè uno spazio nemico tenuto nel Peloponneso.

[b]Tocca Atene[/b] e unisci [b]3 Opliti ateniesi[/b] (200 talenti l'uno, 600 in tutto).
Perché solo 3? Ad Atene c'è l'Armata spartana. Le tue truppe che restano (3 Opliti e 1 Cavalleria) non bastano per battersi in campo aperto, e non serve: con le Lunghe Mura sarà Sparta a dover assediare Atene. Lo vedrai in combattimento.
L'ordine conta: prima Atene, poi il Pireo. Da Atene al Pireo c'è una LOC di terra, che una Spedizione con navi non può usare."""},
	# 13
	{"tipo": "raduno", "id": "Piraeus", "u": {"AN": 3}, "attesa": "raduno", "centro": "Piraeus", "evid": ["Piraeus"],
	"titolo": "Navi per il trasporto",
	"testo": """Demostene ha 3 Opliti. Per andare per mare ogni SP di terra deve essere trasportato da un SP navale: servono [b]almeno 3 navi[/b].

[b]Tocca il Pireo[/b] e unisci [b]3 navi ateniesi[/b] (1200 talenti). Il Tesoro scende a [b]1500[/b]: per il Fondo di Emergenza ti resteranno solo 500 talenti spendibili."""},
	# 14
	{"tipo": "marcia", "attesa": "raduno", "centro": "Aegina", "evid": ["Aegina", "Methana"],
	"titolo": "Verso Metana",
	"testo": """La via più breve è Pireo, Egina, Metana: due rotte navali, nessuna ZOI nemica. La flotta di Corinto non oltrepassa l'Istmo e la Cavalleria di Sparta è lontana.

Premi [b]Marcia su Metana[/b]."""},
	# 15
	{"tipo": "continua", "attesa": "continua", "centro": "Aegina", "evid": ["Methana"],
	"titolo": "Demostene a Metana",
	"testo": """La Spedizione è arrivata senza intercettazioni: 3 Opliti e 3 navi su una fortezza nemica vuota. Sarà un assedio.
Metana era già saccheggiata dal passaggio di Pericle: non si saccheggia due volte.

Premi [b]Continua[/b]: altra operazione, altri Auguri."""},
	# 16
	{"tipo": "passa", "attesa": "operazione", "centro": "Aegina", "evid": [],
	"titolo": "Quando passare",
	"testo": """[b]Auguri[/b]: ora i tuoi comandanti in campo sono tre (Pericle, Formione, Demostene), sempre +1. Uscito [b]2+1 = 3[/b]: favorevoli. Dalla tazza è uscito [b]Trasillo[/b] (1/1).

Potresti fare una terza operazione, ma guarda il Tesoro: [b]1500 talenti[/b], cioè 500 spendibili sopra il Fondo di Emergenza. Basterebbero per 2 Opliti da Atene, senza navi: una Spedizione da 2 SP contro una fortezza spartana in Beozia o in Megaride, a portata della Cavalleria di Tebe. Rischieresti una battaglia persa (-15) per un assedio incerto con un comandante tattico 1.
Quando la prossima operazione non vale il rischio, [b]passa[/b]. Poiché anche Sparta ha già passato, la Fase Operazionale finisce.

Premi [b]Passa[/b] nel pannello delle azioni."""},
	# 17
	{"tipo": "continua", "attesa": "continua", "centro": "Megara", "evid": ["Athens", "Methana", "Erineus", "Corinth"],
	"titolo": "Prevedere il combattimento",
	"testo": """Prima di premere Continua, prevedi che cosa succederà nella Fase di Combattimento.

[b]1. Dove si assedia[/b] (6.1): ogni Armata in una fortezza nemica vuota, o con 5 SP più dei difensori senza comandante.
[b]Atene[/b]: c'è un'Armata spartana e Atene era il suo obiettivo. Con le Lunghe Mura è assedio automatico, perché non hai 3 SP di terra più di lei.
[b]Potidea[/b]: Formione ha 6 SP contro 1 Oplita senza comandante, 5 in più: assedio.
[b]Metana[/b] ed [b]Erineo[/b]: fortezze vuote, assedio.

[b]2. Battaglie[/b]: a Erineo le 3 navi di Pericle e le 5 di Corinto sono l'una nella ZOI dell'altra: [b]battaglia navale[/b], prima degli assedi.
Atene: +2 (navi tutte ateniesi) +1 (Pericle) = +3. Sparta: +2 (5 navi contro 3). A parità vince chi ha il Valore Tattico più alto, cioè Pericle. Probabilità di vittoria: circa 72%.

[b]3. Assedi[/b]: dado + Valore Tattico, serve 4. Metana (Demostene, 2): 5 su 6. Potidea (Formione, 2): 5 su 6. Erineo (Pericle, 1): 4 su 6.
[b]Atene[/b]: l'assedio spartano fallisce da solo, se Atene può tracciare una linea di spazi non spartani fino al Mar Nero. Bisanzio e l'Ellesponto sono tuoi.

Premi [b]Continua[/b]."""},
	# 18
	{"tipo": "continua", "attesa": "continua", "centro": "Megara", "evid": ["Athens", "Methana", "Erineus", "Potidaea"],
	"titolo": "Com'è andata",
	"testo": """[b]Battaglia navale a Erineo[/b]: Sparta 5+2 = 7, Atene 4+3 = 7. Parità: vince Atene perché Pericle ha Valore Tattico 1 contro nessuno. Le perdite sono pari alla differenza, quindi zero, ma lo sconfitto va [b]Verso Casa[/b] con tutta la Forza di Corinto: le 5 navi e l'Oplita che era con loro. +10 punti vittoria.
[b]Atene[/b]: assedio fallito automaticamente per le Lunghe Mura. L'Armata di Archidamo torna a casa. Ma un assedio fallito lascia lo spazio [b]saccheggiato[/b]: Atene lo è, e perderai l'Eisphora.
[b]Metana[/b] 2+2, [b]Erineo[/b] 3+1, [b]Potidea[/b] 5+2: tre assedi riusciti. +30 punti vittoria, +900 talenti dalla vendita degli schiavi.
[b]Punti vittoria: 40.[/b]

[b]SCI[/b] (Sicurezza Strategica): Atene +4 (una battaglia, tre assedi). Sparta -3: -1 per la battaglia persa (non avevi 3 navi più di lei), -1 per Metana, -1 per l'assedio fallito di Atene. Erineo era neutrale e Potidea in ribellione: niente -1 per quelle.

[b]Verso Casa[/b]: per ogni Armata un dado + Valore Strategico. Con meno di 6 resta solo 1 SP.
Formione 3+0, Demostene 3+1, Pericle 3+0: restano 1 Oplita a Potidea, 1 Oplita a Metana, 1 nave a Erineo. Il resto torna ad Atene, al Pireo e a Pella (la Cavalleria alleata).

Premi [b]Continua[/b]: ribellioni e amministrazione."""},
	# 19
	{"tipo": "costruisci", "lista": ["AN", "AN", "AH"], "attesa": "costruzione", "centro": "Megara", "evid": [],
	"titolo": "Entrate e nuove unità",
	"testo": """[b]Ribellione[/b]: Potidea ha una tua unità e nessuna ZOI spartana intorno: la ribellione è [b]sedata[/b].

[b]Entrate di Atene: 4350[/b]. 3500 di tributi; -150 per tre spazi saccheggiati (Platea, Atene, Potidea); +1000 per la LOC di Epidamno. Niente Eisphora: Atene è saccheggiata.
[b]Entrate di Sparta: 1900[/b]. 2500; -600 per i dodici spazi saccheggiati dalla tua flotta.

[b]Costruzione[/b]: puoi spendere fino a 600 talenti, 3 SP da 200 di qualunque tipo.
Costruisci [b]2 navi e 1 Oplita ateniesi[/b]. Una nave costa 200 da costruire e 400 da attivare a ogni operazione: averne molte non costa nulla finché non le usi. Il nuovo Oplita rinforza Atene.
I nuovi SP nascono nelle basi della tabella dei ritorni: navi al Pireo, Opliti ad Atene.

Le quantità sono già impostate. Premi [b]Costruisci[/b]."""},
	# 20
	{"tipo": "continua", "attesa": "continua", "centro": "Naxos", "evid": ["Naxos"],
	"titolo": "Fine del turno 1, inizio del turno 2",
	"testo": """[b]Bellicosità[/b] a fine turno: Atene da 10 a [b]12[/b], perché lo SCI +4 aggiunge la metà (+2). Sparta da 10 a [b]6[/b]: -3 di SCI e -1 per i 12 spazi perduti (uno ogni dieci).
Sparta ha ricostruito l'Oplita alleato perso a Potidea (200 talenti).

[b]Turno 2, Fase Politica[/b] (leggi il riepilogo):
[b]Cambio di parte[/b]: con SCI +4 hai dovuto tirare. Con 2 o più avresti dovuto [b]comandare Sparta[/b]: 5 probabilità su 6. È uscito 1: resti Atene. Hai visto il meccanismo centrale del gioco: più vinci, più è probabile che tu passi dall'altra parte.
[b]Evento 8[/b], Ribellione oligarchica nella Lega di Delo: [b]Nasso[/b] si ribella (cerchiata). Gli spazi vicini avevano bisogno di un 6 per seguirla: niente.
[b]Ribellione della Lega di Delo da SCI[/b]: no, il tuo SCI era positivo e non hai perso navi.
[b]Comandanti[/b]: Demostene per Atene, Gilippo (2/1) per Sparta.
[b]Strategia di Sparta[/b]: il suo SCI era negativo, quindi tira. 5, +1 per Gilippo: [b]Attaccare Alleato ateniese[/b] (3 Opliti e 3 navi, o 4 Opliti per terra, contro uno spazio delle sue aree).
Gli SCI tornano a zero.

Premi [b]Continua[/b]: da qui giochi tu. La guida resta aperta con i consigli."""},
]

## Consigli per la parte libera (turno 2): dipendono dalla situazione.
static func consiglio(p: Partita) -> String:
	var s: Dictionary = p.s
	var g: String = s.lato_g
	var avv: String = Dati.AVV[g]
	var a: Dictionary = s.attesa
	var r := ""
	match a.get("tipo", ""):
		"operazione":
			r += t("Tocca a te: scegli un obiettivo o passa")
			var capi := p.capi_casa(g)
			for c in capi:
				var tt: int = Dati.CAPI[c][1]
				r += "Nello spazio nazionale c'è [b]%s[/b] (%d/%d): con lui un assedio riesce %d volte su 6.\n" % [Dati.capo_nome(c), tt, Dati.CAPI[c][2], clampi(3 + tt, 0, 6)]
			r += "Tesoro %d, di cui spendibili [b]%d[/b] (1 SP di terra 200, 1 nave 400%s).\n" % [s.tes[g], p.spendibile(g), ", Opliti e Cavalleria spartani gratis" if g == "S" else ""]
			if not a.get("iniziale", false):
				var n := p.capi_sulla_mappa(g)
				r += "Comandanti in campo: %d. Per la prossima operazione gli Auguri falliranno con %d o più sul dado (%d su 6).\n" % [n, 6 - n / 2, min(6, n / 2 + 1)]
			else:
				r += "È la tua [b]operazione iniziale[/b]: niente Auguri. Mettici il colpo più importante.\n"
			var ribelli := []
			for id in s.sp:
				if s.sp[id].riv and p.lato_colore(id) == g:
					ribelli.append(id)
			if not ribelli.is_empty():
				r += "\n[b]Spazi tuoi in ribellione[/b]: %s. Sono nemici: se hanno una fortezza li riprendi con un assedio (+10). Altrimenti basta che una tua unità li copra con la ZOI, senza ZOI nemiche, nella Fase di Ribellione.\n" % ", ".join(ribelli.map(func(x): return Dati.nome(x)))
				if ribelli.has("Naxos"):
					r += "Per [b]Nasso[/b], isola con fortezza: una Spedizione di navi dal Pireo, con Demostene, la assedia con 5 probabilità su 6.\n"
			var st: String = s.strategia[avv]
			r += "\n[b]Il nemico[/b] ha la strategia \"%s\". %s\n" % [Dati.nome_strategia(st, avv), _spiega_strategia(st, avv)]
			r += "\nTocca uno spazio per sceglierlo come obiettivo. [b]Suggerisci[/b] ne propone uno sensato; [b]Passa[/b] chiude le tue operazioni del turno."
		"raduno":
			var o: Dictionary = p.op
			r += t("Raduna la Spedizione")
			r += "Obiettivo: [b]%s[/b] (%s%s). Gli spazi cerchiati in verde sono quelli dove puoi prendere truppe.\n" % [Dati.nome(o.ob), Dati.tipo_spazio_nome(Dati.spazi[o.ob].t), ", fortezza" if Dati.spazi[o.ob].f == 1 else ""]
			r += "Per viaggiare per mare servono navi almeno pari agli SP di terra. Una Spedizione con navi non può usare le LOC di terra: raduna prima le truppe, poi le navi.\n"
			if Dati.spazi[o.ob].f == 1 and p.presenti(o.ob, Dati.AVV[o.lato]) > 0:
				r += "A %s ci sono %d SP nemici: per assediare serve un'Armata con almeno 5 SP in più, altrimenti si combatte una battaglia.\n" % [Dati.nome(o.ob), p.presenti(o.ob, Dati.AVV[o.lato])]
			r += "Quando sei pronto premi [b]Marcia[/b]."
		"costruzione":
			r += t("Nuove unità")
			r += "Fino a %d SP da 200 talenti. Navi e truppe costano uguale da costruire, ma una nave costa 400 da attivare a ogni operazione. Gli Opliti decidono le battaglie di terra e fanno le guarnigioni.\nSe vuoi risparmiare, non costruire nulla: i talenti restano per le operazioni del prossimo turno." % a.max
		"continua":
			var tit: String = a.get("titolo", "")
			r += t(tit)
			if tit.begins_with("Fase di combattimento"):
				r += "Leggi il riepilogo: per ogni battaglia trovi dadi e modificatori. Ogni tua vittoria e ogni tuo assedio riuscito valgono +10; ogni sconfitta -15. Un tuo assedio fallito non toglie punti, ma toglie 2 allo SCI.\nPoi, per ogni Armata, il dado Verso Casa: con meno di 6 (dado + Strategico) resta solo 1 SP."
			elif tit.begins_with("Fase politica"):
				r += "Leggi il riepilogo: cambio di parte, evento, ribellioni, comandanti pescati e strategia del nemico. La strategia ti dice dove colpirà."
			elif tit.contains("passa"):
				r += "Chi passa non fa più operazioni in questo turno. Se è il nemico, da qui le operazioni le fai solo tu."
			else:
				r += "Leggi il riepilogo e guarda la linea gialla sulla mappa: è il percorso dell'ultima Spedizione. Le intercettazioni riuscite e i saccheggi sono elencati in ordine."
			r += "\n\nPremi [b]Continua[/b]."
		"fine":
			r += t("Partita finita")
			r += s.esito
	return r

static func _spiega_strategia(st: String, lato: String) -> String:
	var m: Dictionary = Dati.MATRICE[lato]
	match st:
		"attacco":
			return "Manderà %d Opliti e %d Cavalleria contro il tuo spazio nazionale o i dintorni." % [m.attacco.forza.L.H, m.attacco.forza.L.C]
		"alleati", "rivolta", "loc":
			var f: Dictionary = m[st].forza
			var aree: Array = []
			for x in m[st].aree:
				if not aree.has(x):
					aree.append(x)
			return "Forza: %s per costa o isola, %s per terra. Aree possibili: %s. Prima però controllerà la Strategia Difensiva." % [_forza(f.C), _forza(f.L), ", ".join(aree)]
	return ""

static func _forza(f: Dictionary) -> String:
	var p := []
	for k in ["H", "C", "N"]:
		if f.get(k, 0) > 0:
			p.append("%d %s" % [f[k], {"H": "Opliti", "C": "Cavalleria", "N": "navi"}[k]])
	return " e ".join(p)

const CONGEDO := """Il turno 2 è finito: la partita guidata si chiude qui. La partita però continua: è una Campagna normale, e puoi giocarla fino in fondo.

Ricorda le tre idee del primo turno:
1. [b]La prima operazione è l'unica senza Auguri[/b]: mettici il colpo principale.
2. [b]Gli assedi con un comandante di Valore Tattico 2[/b] sono la fonte più sicura di punti. Un assedio fallito non toglie punti vittoria.
3. [b]Più vinci, più è probabile che tu passi dall'altra parte[/b]: gioca sapendo che erediterai quello che lasci.

Il Tutorial (pulsante in alto) ha le regole complete e le strategie per Atene e per Sparta.

Premi [b]Chiudi la guida[/b]."""
