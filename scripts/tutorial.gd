## Tutorial passo passo: il regolamento spiegato in ordine, l'esempio di gioco del manuale rivissuto sulla mappa
## e le strategie. I termini sono quelli dell'edizione italiana (Lega di Delo, comandanti, SP, ZOI, SCI, Verso Casa...).
## Ogni pagina: {parte, titolo, testo (BBCode), scena (facoltativa: situazione mostrata sulla mappa)}.
class_name Tutorial
extends RefCounted

const R := "#8a2a1c"

static func t(titolo: String) -> String:
	return "[color=%s][b]%s[/b][/color]\n" % [R, titolo]

static func pagine() -> Array:
	var p := []
	_regole(p)
	_esempio(p)
	_strategie(p)
	return p

# ====================================================================== PARTE 1: IL REGOLAMENTO
static func _regole(p: Array) -> void:
	var parte := "Il regolamento, passo passo"
	p.append({"parte": parte, "titolo": "1. Che cosa stai per giocare",
	"testo": """La Guerra del Peloponneso (Peloponnesian War, Mark Herman, GMT 2019) è un [b]solitario[/b] sulla guerra fra Atene e Sparta, 431-404 a.C. Le parti sono due: la [b]Lega di Delo[/b] (Atene e i suoi Alleati, verde) e la [b]Lega del Peloponneso[/b] (Sparta e i suoi Alleati, rosso).

Tu comandi una parte: la [b]parte del giocatore[/b]. L'altra, la [b]parte non-giocatore[/b], è mossa dal gioco con la sua [b]Matrice Strategica[/b]. La particolarità del sistema è che all'inizio di ogni turno, se stai andando bene, puoi essere costretto a [b]cambiare parte[/b]: erediti allora l'esercito che hai appena battuto e devi battere quello che avevi costruito. Non vinci "con Atene" o "con Sparta": vinci se la guerra finisce presto e con molte vittorie tue.

""" + t("Come si vince") + """[b]Gioco Campagna[/b] (10 turni di tre anni). La partita finisce alla fine del turno 10 oppure quando una parte si arrende. Hai una [b]vittoria decisiva[/b] se il tuo totale di punti vittoria è [b]superiore a 150[/b], oppure se una delle due parti si arrende [b]prima della fine del turno 3[/b]. Altrimenti la Grecia perde l'egemonia a favore di Tebe e della Persia: hai perso.

[b]Guerra Archidamica[/b] (scenario breve). Finisce subito quando: torni dalla parte spartana a quella ateniese; oppure c'è un armistizio; oppure una parte si arrende; oppure si completa il turno 3. Vinci con [b]40 punti vittoria o più[/b].

""" + t("I punti vittoria (regola 1.2)") + """[b]+10[/b] ogni volta che la tua parte vince una battaglia o porta a compimento un assedio.
[b]-15[/b] ogni volta che la tua parte perde una battaglia, o perde uno spazio amico per un assedio del non-giocatore.
[b]Resa[/b]: quando una parte si arrende ricevi 200 diviso il numero del turno, arrotondato per eccesso (turno 2: 100; turno 3: 67; turno 4: 50; turno 5: 40; turno 10: 20).

Nota bene tre cose, perché reggono tutta la strategia: una sconfitta costa più di quanto renda una vittoria; un [b]tuo assedio fallito non toglie punti vittoria[/b] (toglie altro, lo vedremo); un pareggio non dà e non toglie nulla.

In questa versione digitale dadi, percorsi, intercettazioni, perdite e conti li fa il programma: a te restano le decisioni. Il [b]Diario[/b] registra ogni tiro."""})

	p.append({"parte": parte, "titolo": "2. La mappa: spazi, colori, fortezze",
	"scena": {"centro": "Megara", "zoom": 0.95},
	"testo": """La mappa è fatta di [b]spazi[/b] collegati da linee. Qui sopra vedi l'Attica, la Beozia e l'Istmo: puoi trascinare e ingrandire anche questa mappa.

""" + t("La forma dice il tipo di spazio") + """[b]Quadrato[/b]: spazio di [b]Terra[/b] (Atene, Tebe, Platea, Sparta).
[b]Triangolo[/b]: spazio [b]Costiero[/b] (Pireo, Corinto, Megara, Maratona).
[b]Cerchio[/b]: spazio di [b]Isola[/b] (Egina, Salamina).
Il tipo conta per il movimento, per le perdite e per sapere se una schermaglia diventa battaglia.

""" + t("Il colore dice di chi è lo spazio") + """[b]Verde[/b]: Lega di Delo. [b]Rosso[/b]: Lega del Peloponneso. [b]Giallo[/b]: neutrale.
Atene e Sparta sono gli [b]spazi nazionali[/b]. Gli [b]spazi della coalizione[/b] sono le basi degli Alleati: per Atene Anfipoli, Larissa, Corcira e Chio; per Sparta Corinto e Tebe.

""" + t("Le fortezze") + """Il disegno delle mura dentro lo spazio indica una [b]fortezza[/b]: per prenderla serve un [b]assedio[/b] condotto da un'Armata, cioè da una forza con un comandante. Gli spazi senza fortezza (Sparta stessa, Maratona, Delio, Oropo) si controllano semplicemente occupandoli.

""" + t("Le linee: le LOC") + """[b]Linea doppia[/b]: LOC di [b]Terra[/b]. Ci passano solo le unità di terra.
[b]Linea punteggiata[/b]: LOC [b]Navale[/b]. Ci passano solo le navi; ogni SP Navale trasporta un SP di terra.
[b]Linea doppia punteggiata[/b]: LOC [b]Combinata[/b]. Ci passa chiunque.
Guarda Atene: è collegata al Pireo dalle [b]Lunghe Mura[/b] e all'entroterra solo per terra. La flotta sta al Pireo, non ad Atene.

Nel gioco digitale tocca uno spazio per vederne tipo, lega, controllo e unità. I nomi sulla mappa stampata sono quelli originali; nei pannelli trovi il nome italiano."""})

	p.append({"parte": parte, "titolo": "3. Le forze: SP, tipi, nazionalità",
	"scena": {"centro": "Megara", "zoom": 0.8},
	"testo": """La forza si misura in [b]SP[/b] (punti forza). Le pedine sono come monete: 5 SP di opliti sono 5 SP comunque li cambi. Per questo l'app mostra, per ogni spazio, una pedina per tipo con il [b]numero di SP[/b] nel dischetto.

""" + t("Tre tipi") + """[b]Opliti[/b]: la fanteria pesante. Decidono le battaglie di terra.
[b]Cavalleria[/b]: dà +1 in battaglia a chi ne ha di più, riduce le perdite dello sconfitto ed estende la ZOI agli spazi adiacenti.
[b]Navali[/b]: decidono le battaglie navali, trasportano le truppe e proiettano la ZOI a due spazi di distanza.

""" + t("Quattro nazionalità") + """[b]Ateniesi[/b] (verde scuro) e [b]Alleati ateniesi[/b] (verde chiaro); [b]Spartani[/b] (rosso scuro) e [b]Alleati spartani[/b] (rosso chiaro). La differenza pesa in quattro punti:
1. [b]Costo[/b]: Opliti e Cavalleria spartani (non Alleati) si attivano [b]gratis[/b]. Tutti gli altri SP di terra costano 200 talenti, ogni SP Navale 400.
2. [b]Bonus[/b]: Sparta ha +2 in battaglia di terra se almeno metà dei suoi Opliti sono spartani; Atene ha +2 in battaglia navale se almeno metà delle sue navi sono ateniesi.
3. [b]Ostaggi[/b]: si catturano solo eliminando Opliti ateniesi o spartani, non Alleati.
4. [b]Dove tornano[/b]: la Tabella del Movimento Post-Combattimento manda ogni nazionalità in basi diverse.

""" + t("La Guardia Nazionale spartana") + """3 SP di Opliti scelti che [b]non lasciano mai Sparta[/b]. Sono immuni alle perdite da schermaglia; se subiscono una perdita in battaglia la Guardia è eliminata per sempre (gli SP che le restano diventano Opliti normali).

""" + t("Forza, Armata, Spedizione") + """[b]Forza[/b]: tutte le unità di una parte in uno spazio. [b]Armata[/b]: una Forza con un comandante. [b]Spedizione[/b]: il comandante e gli SP che ha attivato durante un'operazione. Solo una Spedizione si muove; solo un'Armata assedia.

Le pedine [b]scurite[/b] sulla mappa hanno già agito in questo turno: un SP si attiva una sola volta per turno."""})

	p.append({"parte": parte, "titolo": "4. I comandanti",
	"testo": """Ogni comandante ha due numeri: [b]Valore Tattico[/b] (in alto sulla pedina) e [b]Valore Strategico[/b] (in basso). Nei pannelli li leggi come "tattico/strategico".

[b]Valore Tattico[/b]: si somma al dado in battaglia e in assedio. A parità di risultato vince chi ha il Valore Tattico positivo più alto.
[b]Valore Strategico[/b]: si somma al dado "Verso Casa" (con 6 o più l'Armata resta tutta sul posto) e, per la parte non-giocatore, al dado che sceglie la strategia.

""" + t("Atene") + """Pericle 1/0, Formione 2/0, Demostene 2/1, Trasibulo 2/1, Trasillo 1/1, Alcibiade 1/2, Nicia 0/1, Cleone 0/2.
""" + t("Sparta") + """Brasida 2/2, Lisandro 2/2, Gilippo 2/1, Mindaro 1/2, Agide 1/1, Callicratida 1/1, Archidamo 1/-1, Plistoanatte 0/0.

""" + t("Come entrano in gioco") + """I comandanti stanno nella [b]tazza[/b] della loro parte. Nella Fase Politica ogni parte ne pesca uno a caso e lo mette nello spazio nazionale: comanderà la prima operazione. Per ogni operazione successiva, se nello spazio nazionale non c'è un comandante, se ne pesca un altro. Chi ha comandato resta sulla mappa con la sua Armata fino al segmento Verso Casa, e alla fine del turno tutti tornano nella tazza.

Conseguenze pratiche: [b]non scegli tu[/b] chi comanda (a meno che nello spazio nazionale ce ne siano due); la prima operazione del turno spetta al comandante pescato, bravo o scarso che sia; ogni comandante già in campo rende più difficili gli Auguri delle tue operazioni successive.

[b]Nicia[/b]: se è un comandante ateniese nel turno in cui scatta un armistizio, l'armistizio dura di più (+1 al dado).
[b]Alcibiade[/b]: l'evento "Demagogo da Assumere" lo fa passare a Sparta, poi ai Persiani (in entrambi i casi dà +1 al dado della strategia spartana), poi lo riporta ad Atene, infine lo toglie dal gioco."""})

	p.append({"parte": parte, "titolo": "5. Amico, nemico, controllo",
	"scena": {"centro": "Potidaea", "zoom": 1.0, "cerchi": ["Potidaea"]},
	"testo": """Capire chi controlla uno spazio è indispensabile, perché da qui dipendono saccheggi, assedi, entrate e Bellicosità.

""" + t("Regola del controllo") + """Una parte controlla uno spazio se è [b]occupato da una sua unità[/b]; oppure se è [b]del suo colore e non contiene unità nemiche[/b]. Se l'ultimo SP amico lascia uno spazio di colore nemico, il controllo torna al proprietario originario.

""" + t("La ribellione rovescia il colore") + """Uno spazio con il segnalino [b]Ribellione[/b] è [b]nemico della sua Lega e amico dell'altra[/b]. Potidea, che vedi qui sopra a inizio partita, è verde ma in ribellione: è amica di Sparta (c'è 1 SP di Opliti Alleati spartani dentro) e nemica di Atene, tanto che Formione la sta assediando.
Uno spazio [b]neutrale in ribellione[/b] diventa amico della parte che vi entra per prima, che lo cattura automaticamente.

""" + t("Neutrali") + """Uno spazio giallo non è nemico di nessuno: attraversarlo non lo saccheggia. Se però lo dichiari [b]obiettivo[/b] e non è in ribellione, devi catturarlo: con un assedio se ha la fortezza.

""" + t("Perché conta") + """[b]Entrate[/b]: ogni spazio del tuo colore saccheggiato, in ribellione o controllato dal nemico toglie 50 talenti.
[b]Bellicosità[/b]: ogni 10 spazi della tua Lega in quelle condizioni toglie 1.
[b]Spazi di raduno[/b]: puoi attivare truppe solo in spazi amici.
[b]Saccheggio[/b]: si saccheggiano solo spazi controllati dal nemico.

Nell'app il riquadro in basso a sinistra, toccando uno spazio, scrive sempre chi lo controlla e se è in ribellione o saccheggiato."""})

	p.append({"parte": parte, "titolo": "6. La Zona di Influenza (ZOI)",
	"scena": {"centro": "Aegina", "zoom": 0.9, "zoi": "Piraeus"},
	"testo": """La [b]ZOI[/b] è l'area in cui una Forza fa sentire la sua presenza. Serve a tre cose: [b]intercettare[/b] le Spedizioni nemiche, [b]provocare battaglie[/b] nella Fase di Combattimento e [b]sedare o estendere le ribellioni[/b].

""" + t("Quanto si estende") + """[b]Opliti[/b]: solo lo spazio che occupano.
[b]Cavalleria[/b]: lo spazio che occupa e tutti quelli [b]adiacenti lungo LOC di Terra o Combinate[/b].
[b]Navali[/b]: lo spazio che occupano e ogni spazio [b]entro 2 LOC Navali o Combinate contigue[/b].
Una Forza mista ha la ZOI più ampia fra quelle delle sue unità.

Qui sopra vedi cerchiata in azzurro la ZOI della flotta ateniese del Pireo: copre Egina, Salamina, Capo Sunio e da lì arriva a Metana, Epidauro, Cencree, Megara, Citno, Ceo, Maratona. Otto navi ferme in porto sorvegliano mezzo Golfo Saronico.

""" + t("Tre eccezioni") + """[b]Lunghe Mura[/b]: nessuna ZOI nemica entra mai ad Atene o al Pireo. Inoltre, nella sola Fase di Combattimento, la ZOI della Cavalleria ateniese non esce da Atene e dal Pireo.
[b]Istmo di Corinto[/b]: le ZOI Navali non attraversano mai il collegamento Corinto-Cencree. In compenso una Forza con almeno un'unità di terra a Corinto intercetta [b]automaticamente[/b] chi entra a Cencree, e viceversa.
[b]Sovrapposizioni[/b]: due ZOI che si toccano non producono nulla. Serve che un'unità si trovi [b]dentro[/b] la ZOI nemica.

Nell'app: tocca uno spazio con delle unità e premi [b]Mostra la ZOI[/b]. Azzurro per la Lega di Delo, rosso per la Lega del Peloponneso. Prendi l'abitudine di guardarla prima di scegliere un obiettivo."""})

	p.append({"parte": parte, "titolo": "7. Tesoro, Bellicosità, SCI",
	"testo": """Ogni parte ha tre indicatori. Li trovi nei due pannelli in alto, a sinistra Atene e a destra Sparta.

""" + t("Tesoro") + """I talenti con cui si attivano le truppe e si costruiscono nuovi SP. Atene parte con 4500, Sparta con 3000.
[b]Fondo di Emergenza ateniese[/b]: Atene non può mai spendere se il Tesoro scenderebbe sotto [b]1000 talenti[/b]. Il vincolo cade solo se il Pireo o Decelea sono in mano nemica, o se 10 o più spazi della Lega di Delo sono in ribellione.

""" + t("Bellicosità") + """La voglia di continuare la guerra, da 0 a 12; si parte da 10. [b]A zero la parte si arrende.[/b] Si modifica alla fine di ogni turno (lo vedremo al punto 20) e per alcuni eventi.

""" + t("SCI, Indice di Sicurezza Strategica") + """Misura come è andato il turno per quella parte. Va da -6 a +6 e [b]torna a zero all'inizio di ogni turno[/b], nella Pianificazione Strategica. Durante il combattimento:
[b]+1[/b] a chi vince una battaglia; [b]-1[/b] a chi la perde (ma non se il vincitore aveva almeno 3 SP di Opliti, o di navi in mare, più di lui).
[b]+1[/b] a chi riesce in un assedio; [b]-1[/b] a chi lo subisce (non se lo spazio era neutrale o in ribellione).
Assedio fallito: [b]-1[/b] al non-giocatore, [b]-2[/b] al giocatore.

Lo SCI che una parte ha a fine turno produce tre effetti:
1. [b]Bellicosità[/b]: SCI negativo si sottrae per intero; SCI positivo aggiunge la sua metà, arrotondata per difetto.
2. [b]Cambio di parte[/b]: nella Fase Politica successiva, se il tuo SCI è zero o più tiri un dado e lo sommi; con 6 o più cambi parte.
3. [b]Strategia del non-giocatore[/b]: se il suo SCI è positivo e non hai cambiato parte, ripete la strategia del turno prima.
E per Atene uno in più: se lo SCI ateniese è [b]zero o meno[/b], scoppia una Ribellione della Lega di Delo.

Lo SCI è il vero volante del gioco: vincere molto ti fa cambiare parte, perdere abbassa la tua Bellicosità. Ci torneremo nelle strategie."""})

	p.append({"parte": parte, "titolo": "8. La sequenza del turno",
	"testo": """Ogni turno segue sempre lo stesso ordine. La barra in alto dell'app evidenzia la fase in corso.

[b]1. Fase Politica[/b] (saltata al turno 1)
   Determinazione della Parte; Evento; Ribellione della Lega di Delo; Scelta del Comandante.
[b]2. Fase di Pianificazione Strategica[/b] (saltata al turno 1)
   Determinazione della Strategia del non-giocatore; azzeramento dello SCI.
[b]3. Fase Operazionale[/b]
   Operazione iniziale del giocatore; operazione iniziale del non-giocatore; operazioni continuate, una a testa, finché entrambi passano; Verso Casa per le unità già nella casella.
[b]4. Fase di Combattimento[/b]
   Determinazione dell'Assedio; Risoluzione della Battaglia; Risoluzione degli Assedi; Verso Casa.
[b]5. Fase di Diffusione della Ribellione[/b]
   Continuazione; Diffusione; Ribellione degli Iloti.
[b]6. Fase Amministrativa[/b]
   Ricevimento delle Entrate; Costruzione degli SP.
[b]7. Fase di Armistizio e Resa[/b]
   Modifica della Bellicosità; Resa; Armistizio; Fine del turno.

""" + t("Il punto chiave") + """Nella Fase Operazionale [b]ci si muove soltanto[/b]: le Spedizioni arrivano sull'obiettivo, saccheggiano, subiscono intercettazioni. Battaglie e assedi "veri" si decidono tutti insieme [b]dopo[/b], nella Fase di Combattimento, quando tutte le pedine sono ferme. Per questo l'ordine delle operazioni e la posizione finale delle forze contano più della singola mossa.

Il Gioco Campagna comincia [b]a metà del turno 1[/b]: Atene ha già fatto la sua operazione iniziale (Formione a Potidea) e tocca all'operazione iniziale di Sparta, che ha già la strategia "Attaccare Atene"."""})

	p.append({"parte": parte, "titolo": "9. Fase Politica",
	"testo": t("3.1 Determinazione della Parte") + """Se lo SCI della tua parte è [b]zero o più[/b] devi tentare di cambiare parte: dado + SCI, con [b]6 o più[/b] passi a comandare la Lega avversaria. Con SCI negativo resti dove sei, senza tirare.
Probabilità di cambiare: SCI 0, 1 su 6; SCI +1, 2 su 6; SCI +2, 3 su 6; SCI +3, 4 su 6; SCI +4, 5 su 6; SCI +5 o +6, certo.
Quando cambi parte tieni i tuoi punti vittoria: continui semplicemente a fare punti dall'altra parte.

""" + t("3.2 Evento") + """Due dadi sulla Tabella degli Eventi; se l'evento è impossibile si ritira. I più pesanti: Epidemia ad Atene (6), Demagogo da Assumere (7, il più probabile), Ribellione oligarchica nella Lega di Delo (8), Morte di Comandanti (11), Fenomeno (12: chi è colpito fa al massimo 2 operazioni). L'elenco completo è nel pulsante [b]Tabelle[/b].

""" + t("3.3 Ribellione della Lega di Delo") + """Scatta se lo SCI ateniese è [b]zero o meno[/b], oppure se la Lega di Delo ha perso [b]4 o più SP Navali[/b] nel turno precedente. Si applica l'evento 8: due dadi scelgono lo spazio (2 Cnido, 3 Nasso, 4 Bisanzio, 5 Calcide, 6 Efeso, 7 Mitilene, 8 Olinto, 9 Mileto, 10 Camiro, 11 Lampsaco, 12 Anfipoli), poi ogni spazio adiacente si ribella con un 6. Una ribellione non può nascere in uno spazio occupato da una Forza amica.
Attenzione: lo SCI viene azzerato a ogni turno, quindi ad Atene [b]basta un turno senza vittorie[/b] per avere una ribellione il turno dopo.

""" + t("3.4 Scelta del Comandante") + """Ogni parte pesca un comandante dalla tazza e lo mette nel proprio spazio nazionale.

""" + t("4. Pianificazione Strategica") + """[b]4.1[/b] Se lo SCI del non-giocatore è positivo e non hai cambiato parte, la sua strategia resta quella del turno prima. Altrimenti: dado + Valore Strategico del suo comandante nello spazio nazionale (+1 per Sparta se Alcibiade è con gli Spartani o i Persiani), letto sulla sua Matrice. Risultati sotto 1 valgono 1, sopra 6 valgono 6.
[b]4.2[/b] Lo SCI di entrambe le parti torna a zero.

L'app si ferma dopo queste due fasi e ti mostra tutto quello che è successo: leggi sempre il riepilogo, ti dice con che strategia il nemico giocherà il turno."""})

	p.append({"parte": parte, "titolo": "10. La Matrice del non-giocatore",
	"testo": """La parte non-giocatore non ragiona: esegue la sua Matrice. Conoscerla ti permette di prevederla.

""" + t("Sparta guidata dal gioco") + """Dado 1: [b]Attaccare Atene[/b]. Forza 12 Opliti e 2 Cavalleria. Obiettivo: 1-3 Atene, 4 Panatto, 5-6 Decelea.
Dado 2-3: [b]Causare Ribellione[/b]. Forza 1 Oplita e 1 Navale (2 Opliti se l'obiettivo è di Terra).
Dado 4-5: [b]Tagliare LOC[/b]. Forza 2 Opliti e 2 Navali (2 Opliti per terra). Aree: 1-2 Tracia, 3-5 Ellesponto, 6 Isole.
Dado 6: [b]Attaccare Alleato ateniese[/b]. Forza 3 Opliti e 3 Navali (4 Opliti per terra).
Per le ultime tre un dado sceglie l'area (Caria, Ionia, Ellesponto, Tracia, Isole, Alleati) e un secondo dado lo spazio.

""" + t("Atene guidata dal gioco") + """Dado 1-2: [b]Attaccare Alleato spartano[/b]. Forza 4 Opliti e 4 Navali (7 Opliti e 2 Cavalleria per terra).
Dado 3-4: [b]Causare Ribellione[/b]. Forza 2 Opliti e 2 Navali (2 Opliti e 1 Cavalleria per terra).
Dado 5: [b]Tagliare LOC[/b]. Forza 3 Opliti e 3 Navali (3 Opliti e 2 Cavalleria per terra).
Dado 6: [b]Attaccare Sparta[/b]. Forza 15 Opliti e 4 Cavalleria. Obiettivo: Sparta, Carie, Tegea, Belmina, Metidrio, Mantinea.
Aree: Istmo, Beozia, Sicilia, Arcadia/Acaia, Peloponneso/Messenia, Alleati.

""" + t("La Strategia Difensiva ha la precedenza") + """All'inizio di [b]ogni[/b] operazione del non-giocatore si controlla prima se deve difendersi.
[b]Sparta[/b]: una Forza ateniese entro due spazi da Sparta per LOC di Terra o Combinata; oppure Corinto o Tebe occupate da una Forza ateniese; oppure Siracusa nella ZOI di una Forza ateniese. Risposta: 10 Opliti e 1 Cavalleria contro quello spazio (nel caso di Siracusa, contro un obiettivo "Attaccare Atene").
[b]Atene[/b]: una Forza spartana a Egina, Salamina, Naupatto, Chio, Anfipoli, Corcira, Samo, Calcide o entro 2 spazi da Proconneso. Risposta: 3 Opliti e 3 Navali.

""" + t("Come raduna la forza") + """Il comandante parte dallo spazio nazionale, prende lì più SP che può e poi va negli spazi amici più vicini. Non attiva l'ultimo SP di un tipo in uno spazio, né l'ultimo SP di uno spazio, se può evitarlo. Se la forza richiesta non esiste sulla mappa, o mancano i talenti, [b]passa[/b]: e chi passa ha finito il turno.

""" + t("Regole fisse") + """Se l'obiettivo sorteggiato è già controllato dal non-giocatore si ritira. Con Causare Ribellione si ritira anche se c'è una Forza nemica o se è uno spazio di coalizione o nazionale nemico. Per Sparta gli spazi di Tracia valgono come spazi di Terra (va a piedi con 2 o 4 Opliti); quelli dell'Ellesponto anche, se Anfipoli le è amica. Per Atene: se 4 dei 5 spazi che decidono la Ribellione degli Iloti le sono amici, il quinto è l'obiettivo senza tirare.

Le due matrici complete, con tutti gli spazi, sono nel pulsante [b]Tabelle[/b]."""})

	p.append({"parte": parte, "titolo": "11. La tua operazione: obiettivo e raduno",
	"scena": {"centro": "Aegina", "zoom": 0.85, "cerchi": ["Athens", "Piraeus"], "ob": "Megara"},
	"testo": """Un'operazione è sempre fatta di quattro passi (regola 5.1).

[b]1. Designa lo spazio obiettivo.[/b] Può essere qualunque spazio, anche amico (per rinforzarlo o per sedare una ribellione). Non puoi scegliere: Sardi finché la Persia non è in guerra; Argo se comandi Atene e Argo è neutrale; Siracusa se comandi Sparta e Siracusa è neutrale; lo spazio nazionale nemico e quelli adiacenti se il nemico ha i tuoi ostaggi.
[b]2. Designa il comandante[/b], che deve trovarsi nel tuo spazio nazionale.
[b]3. Raduna la Spedizione.[/b] Il comandante va, per la via più breve, negli [b]spazi di raduno[/b]: spazi amici con tue unità non ancora attivate. In ognuno attivi gli SP che vuoi, pagando subito. Può cominciare dallo spazio nazionale e visitare più spazi.
[b]4. Marcia sull'obiettivo[/b] per la via più breve. Lì la Spedizione si ferma e l'operazione finisce.

""" + t("Costi di attivazione") + """SP di terra 200 talenti; SP Navale 400; Opliti e Cavalleria spartani gratis. Nessun rimborso se l'SP poi va perduto. Atene deve rispettare il Fondo di Emergenza.

""" + t("Il comandante da solo") + """Mentre va a prendere le truppe il comandante viaggia senza scorta: non può entrare in spazi occupati dal nemico, né in spazi di colore nemico che non siano spazi di raduno. Se viene intercettato finisce nella casella Verso Casa e [b]l'operazione è annullata[/b]. Lo stesso accade se perde l'ultimo SP della Spedizione.

""" + t("Nell'app") + """1. Tocca lo spazio obiettivo: compare l'anello rosso. Se vuoi, spunta [b]Causa Ribellione[/b].
2. Premi [b]Parti[/b].
3. Gli spazi di raduno possibili sono cerchiati di verde (nell'immagine Atene e il Pireo). Tocca uno spazio, scegli quanti SP di ogni tipo con + e -, premi [b]Unisci[/b]. Il comandante ci va da solo, per la via più breve.
4. Quando la Spedizione è pronta premi [b]Marcia su...[/b].
[b]Rinuncia[/b] scioglie la Spedizione dove si trova, se non può proseguire.

Esempio classico per Atene: obiettivo uno spazio costiero; ad Atene prendi gli Opliti, al Pireo le navi (almeno tante quanti gli Opliti), poi marci."""})

	p.append({"parte": parte, "titolo": "12. Il movimento: la via più breve",
	"scena": {"centro": "Corinth", "zoom": 1.05, "cerchi": ["Corinth", "Cenchrae", "Naupactus"]},
	"testo": """Una Spedizione muove di quanti spazi vuole, ma [b]non sceglie la strada[/b]: segue sempre la via consentita più breve per la sua composizione; a parità di lunghezza decide il caso. Non puoi fare un giro più lungo per evitare una Forza nemica.

""" + t("Chi passa dove") + """LOC di Terra: solo unità di terra. Una Spedizione con delle navi non può usarle.
LOC Navali: solo se gli SP di terra sono [b]pari o inferiori[/b] agli SP Navali (trasporto navale). Una Spedizione di sole truppe non le usa.
LOC Combinate: sempre.
Il comandante da solo: qualunque LOC.

Ne segue che la [b]composizione decide il percorso[/b]. Tre Opliti e due navi non salpano. Una flotta non entra nell'entroterra. Otto Opliti senza navi da Atene al Peloponneso devono passare per l'Istmo, in mezzo ai nemici.

""" + t("Capacità insufficiente") + """Se dopo una schermaglia la Spedizione resta con meno navi che truppe e l'unica via è per mare, gli SP di terra in eccesso restano nell'ultimo spazio raggiunto e gli altri proseguono.

""" + t("Passaggi speciali") + """[b]Naupatto, Bisanzio e Anfipoli[/b]: non ci si entra e non si contano per la via più breve, a meno di controllarle o di averle come obiettivo.
[b]Argo e Siracusa[/b] neutrali: non si contano per la via più breve.
[b]Istmo di Corinto[/b] (nell'immagine): fra Corinto e Cencree le navi passano solo se la parte controlla entrambi gli spazi. Per questo la flotta di Corinto esce nell'Egeo e una flotta ateniese no.
[b]Capo Tenaro - Siracusa[/b]: solo la parte del giocatore può attraversare. Dado 1-4 arriva; 5-6 una tempesta distrugge tutta la Spedizione.

""" + t("Una forza nemica non blocca") + """Si può entrare e uscire da spazi con Forze nemiche e fortezze. A fermare una Spedizione è solo un'[b]intercettazione riuscita[/b] seguita da una battaglia persa.

Nell'app la via percorsa dall'ultima Spedizione resta disegnata in giallo sulla mappa: guardala dopo ogni operazione del nemico, impari le sue rotte."""})

	p.append({"parte": parte, "titolo": "13. Intercettazione e schermaglia",
	"testo": """Ogni volta che una Spedizione (anche il comandante da solo) [b]entra in uno spazio dentro una ZOI nemica[/b] c'è un tentativo di intercettazione. È obbligatorio per entrambe le parti: non puoi rinunciare a intercettare.

""" + t("Procedura (5.6)") + """Un dado: [b]1-3 fallisce[/b], la Spedizione prosegue; [b]4-6 riesce[/b].
Un solo tentativo per ogni spazio in cui si entra, anche se più Forze potrebbero intercettare (si sorteggia quale). La Forza che intercetta non si muove dal suo spazio; l'intercettazione "avviene" nello spazio in cui è entrata la Spedizione. Una Forza può intercettare quante volte capita, anche se ha già agito.

""" + t("Schermaglia (5.7)") + """Se l'intercettazione riesce, ogni parte tira un dado: [b]con 1 perde 1 SP[/b]. In spazio di Terra o Costiero la perdita è un Oplita se possibile, poi Cavalleria, poi Navale; in un'Isola prima Navale, poi Cavalleria, poi Opliti.
In uno spazio di raduno l'intercettazione avviene [b]prima[/b] che il comandante attivi le truppe del posto: quelle non contano e non assorbono perdite.

""" + t("Quando la schermaglia diventa battaglia") + """Subito, se vale una di queste condizioni:
1. la somma dei due dadi di schermaglia è [b]11 o 12[/b] (3 probabilità su 36);
2. spazio di Terra o Costiero: gli SP di terra delle due parti sommati sono [b]8 o più[/b] e [b]almeno la metà[/b] appartiene a chi intercetta;
3. spazio di Isola o Costiero: lo stesso con gli SP Navali.
Si risolve una battaglia normale. Se la Spedizione vince prosegue; se perde finisce Verso Casa e l'operazione è annullata. Una battaglia nulla (flotta contro truppe) lascia proseguire la Spedizione.

""" + t("Che cosa ne ricavi") + """Una Forza [b]grande[/b] nella ZOI giusta è un muro: con la condizione 2 o 3 ogni intercettazione riuscita diventa battaglia. Una Forza [b]piccola[/b] disturba soltanto (un SP perso una volta su sei) e rischia la battaglia solo con l'11-12.
Attenzione al rovescio: anche le [b]tue[/b] Forze intercettano per obbligo. Sette SP ad Atene contro 14 Spartani che entrano in Attica non raggiungono la metà del totale, quindi niente battaglia salvo 11-12; ma se ad Atene ci fossero tanti SP di terra quanti ne porta l'invasore, ogni intercettazione riuscita diventerebbe una battaglia, e contro il +2 degli Opliti spartani."""})

	p.append({"parte": parte, "titolo": "14. Saccheggio e Causare Ribellione",
	"testo": t("Saccheggio (5.8)") + """Quando una Spedizione entra in uno spazio [b]controllato dal nemico[/b] mentre muove [b]verso l'obiettivo[/b] (non verso uno spazio di raduno), lo spazio riceve il segnalino Saccheggiato, a meno che sia occupato da una Forza nemica o che lì sia riuscita un'intercettazione.
Gli spazi neutrali e quelli amici non si saccheggiano. Anche l'obiettivo, se è nemico e vuoto, viene saccheggiato all'arrivo.

Effetti di ogni spazio saccheggiato, per il turno in corso: [b]-50 talenti[/b] alle entrate del proprietario; conta fra gli spazi che ogni 10 tolgono [b]1 di Bellicosità[/b]; se è Atene, il Pireo, Panatto o Decelea, [b]niente Eisphora[/b] (1000 talenti). I segnalini si tolgono a fine turno.

Poiché il percorso è quello più breve, la scelta dell'obiettivo decide quanti spazi saccheggi. Una flotta che dal Pireo punta su uno spazio del Golfo di Corinto fa il giro del Peloponneso e ne saccheggia una decina; se la stessa flotta usasse Naupatto come spazio di raduno, il tratto fino a Naupatto non saccheggerebbe nulla.

""" + t("Causare Ribellione (5.4)") + """Qualunque tua operazione può essere dichiarata "Causare Ribellione". Dopo aver designato l'obiettivo e prima di radunare paghi [b]100 talenti[/b] e tiri un dado: con [b]6[/b] lo spazio riceve il segnalino Ribellione, diventa tuo amico e l'operazione prosegue; con 1-5 l'operazione è annullata, ma [b]non conta come passare[/b]. Il non-giocatore aggiunge 2 al dado (riesce con 4-6).

L'obiettivo non può contenere una Forza nemica e non può essere lo spazio nazionale né uno spazio di coalizione nemico. Argo, Siracusa e Pella non possono esserlo finché sono neutrali; gli altri spazi neutrali sì.

Perché farlo: lo spazio in ribellione diventa amico, quindi la tua Spedizione vi entra [b]senza assedio[/b] e la ribellione può [b]diffondersi[/b] da sola agli spazi vicini della stessa Lega. Perché non farlo spesso: per il giocatore riesce una volta su sei; se fallisce hai speso 100 talenti e il tuo turno di operazione, e per riprovare dovrai superare gli Auguri.

Nell'app: spunta [b]Causa Ribellione[/b] sotto il nome dell'obiettivo prima di premere Parti."""})

	p.append({"parte": parte, "titolo": "15. Auguri e passare",
	"testo": """Dopo le due operazioni iniziali si prosegue con le [b]operazioni continuate[/b]: una tu, una il non-giocatore, e così via finché entrambi hanno passato.

""" + t("Gli Auguri (5.3.1)") + """Prima di [b]ogni[/b] operazione continuata si consultano gli dèi: un dado, più
[b]+1[/b] se è un'operazione del non-giocatore;
[b]+ la metà, per difetto, dei comandanti della tua parte sulla mappa[/b] (compresi quelli nella casella Verso Casa) se è una tua operazione.
Con [b]6 o più[/b] l'operazione è annullata e quella parte [b]deve passare[/b].

Per te, quindi: con 0 o 1 comandanti in campo fallisci solo con 6 (1 su 6); con 2 o 3 comandanti con 5-6 (1 su 3); con 4 o 5 con 4-6 (1 su 2); con 6 o 7 con 3-6 (2 su 3). Il non-giocatore fallisce sempre con 5-6.
Attenzione: conta anche il comandante che aspetta nello spazio nazionale. All'inizio della campagna Atene ha Pericle ad Atene e Formione a Potidea: due comandanti, quindi +1 già alla prima operazione continuata. (L'esempio del manuale dice che "solo il 6 va male": applicando la regola 5.3.1 alla lettera il modificatore c'è, e l'app applica la regola.)

Se gli Auguri sono favorevoli e nel tuo spazio nazionale non c'è un comandante, ne peschi uno nuovo.

""" + t("Passare (5.3.2)") + """Puoi sempre passare volontariamente. Una parte [b]deve[/b] passare se: gli Auguri danno 6 o più; non ha comandanti nella tazza; non ha abbastanza unità non attivate; non ha fondi; per Atene, se pagare violerebbe il Fondo di Emergenza.
[b]Chi passa non fa più operazioni in quel turno.[/b] L'altra parte continua da sola, sempre consultando gli Auguri.

""" + t("Che cosa ne segue") + """La prima operazione del turno è l'unica sicura: non richiede Auguri. Mettici la cosa più importante.
Ogni operazione in più lascia un comandante in campo e rende più probabile il blocco delle successive. Tre operazioni per turno sono già un buon risultato; la quarta riesce di rado.
Un'operazione annullata da un'intercettazione o da una Causare Ribellione fallita non è un "passare": dopo puoi tentarne un'altra.

Quando entrambi hanno passato, le unità finite nella casella Verso Casa durante le operazioni rientrano sulla mappa (5.9) e si passa al combattimento."""})

	p.append({"parte": parte, "titolo": "16. Combattimento: dove si assedia",
	"scena": {"centro": "Athens", "zoom": 1.15, "cerchi": ["Athens", "Piraeus", "Decelea", "Panactum"]},
	"testo": """La Fase di Combattimento comincia stabilendo [b]dove c'è un assedio[/b] (6.1). Si guarda ogni [b]spazio di fortezza[/b] occupato da un'[b]Armata[/b] (forza con comandante) [b]nemica di quello spazio[/b]. C'è assedio se:
1. nello spazio non ci sono unità avversarie; oppure
2. c'è una Forza avversaria [b]senza comandante[/b] e l'Armata ha [b]almeno 5 SP in più[/b].
In ogni altro caso (difensori numerosi, o con un comandante) lì si combatterà una battaglia.

Conseguenze da ricordare:
Un'Armata che arriva su una fortezza nemica vuota la assedia sempre.
Bastano pochi difensori per negare l'assedio a una Spedizione piccola: contro 3 SP di guarnigione servono 8 SP per assediare; con meno, è battaglia.
Una Forza [b]senza comandante[/b] non assedia mai.
Negli spazi senza fortezza non esistono assedi: se sono vuoti si occupano, se sono difesi si combatte.

""" + t("Le Lunghe Mura di Atene (6.1.1)") + """Ad Atene e al Pireo la situazione è [b]automaticamente un assedio[/b] se lo spazio è stato designato come obiettivo ed è occupato da un'Armata spartana, a meno che gli Ateniesi abbiano lì [b]almeno 3 SP di terra in più[/b] degli Spartani. Quindi, di norma, sotto le mura di Atene non si combatte in campo aperto.

E l'assedio [b]fallisce automaticamente[/b] finché Atene può tracciare una linea continua di spazi non controllati dalla Lega del Peloponneso fino alla [b]Fonte LOC Euxine[/b] (il Mar Nero, oltre Bisanzio): il grano arriva per mare e la città non cade.

In pratica: [b]Atene non si prende per assedio finché regge la rotta del grano[/b]. Sparta deve prima tagliarla (Bisanzio, l'Ellesponto), oppure vincere la guerra in altro modo. Per chi comanda Sparta, assediare Atene con la rotta aperta significa un assedio fallito sicuro: -2 SCI.
Sparta ottiene comunque qualcosa invadendo l'Attica: saccheggia Decelea e Panatto (addio Eisphora) e rende possibile l'evento Epidemia nel turno successivo."""})

	p.append({"parte": parte, "titolo": "17. Combattimento: le battaglie",
	"testo": t("Dove si combatte (6.2), in quest'ordine") + """1. Spazi nazionali senza segnalino Assedio occupati da entrambe le parti.
2. Spazi della coalizione nelle stesse condizioni.
3. Tutti gli altri spazi nelle stesse condizioni.
4. [b]Ogni spazio dentro una ZOI amica occupato da un'unità nemica[/b] che non sia sotto un segnalino Assedio.
La battaglia è obbligatoria. Il punto 4 è quello che sorprende i principianti: una flotta combatte contro ogni Forza nemica entro due rotte navali, una Forza con cavalleria contro quelle adiacenti. Anche l'Armata che sta assediando può essere attaccata così (sta "sopra" il segnalino, non sotto). Una Forza può combattere più battaglie nella stessa fase.

""" + t("Tipo di battaglia (6.2.1)") + """[b]Nulla[/b]: una parte ha solo navi e l'altra solo truppe. In spazi diversi non succede niente. Nello stesso spazio: se è neutrale tutte le navi vanno Verso Casa; altrimenti va Verso Casa l'Armata contrapposta a una Forza senza comandante, oppure, fra due Armate, quella nemica dello spazio.
[b]Navale[/b]: se entrambe hanno navi.
[b]Di Terra[/b]: in tutti gli altri casi.

""" + t("Battaglia Navale (6.2.3)") + """Un dado a testa, più: [b]+2 ad Atene[/b] se almeno metà dei suoi SP Navali sono ateniesi (non Alleati); [b]+ la differenza di SP Navali[/b] a chi ne ha di più; [b]+ Valore Tattico[/b] del comandante.
Lo sconfitto elimina SP Navali pari alla differenza dei risultati, ma non più degli SP Navali del vincitore.
[b]Battaglia Combinata[/b]: se il vincitore ha Opliti pari o superiori a quelli dello sconfitto (almeno 1), i superstiti combattono subito anche una battaglia di terra.

""" + t("Battaglia di Terra (6.2.4)") + """Se si combatte a Sparta, si pesca un comandante spartano in più. Poi un dado a testa, più: [b]+2 a Sparta[/b] se combatte nello spazio di Sparta; [b]+2 a Sparta[/b] se almeno metà dei suoi Opliti sono spartani (non Alleati); [b]+1[/b] a chi ha più Cavalleria; [b]+ la differenza di Opliti[/b] a chi ne ha di più; [b]+ Valore Tattico[/b].
Lo sconfitto elimina SP di terra pari alla differenza dei risultati, ma non più degli Opliti del vincitore; le perdite calano di 1 per ogni SP di Cavalleria che lo sconfitto ha in più del vincitore, con un minimo di 1.

""" + t("Dopo ogni battaglia") + """Tutti i superstiti dello sconfitto, navi comprese, e i suoi comandanti vanno nella casella [b]Verso Casa[/b]. Il vincitore resta dov'è, senza perdite.
SCI: +1 al vincitore; -1 allo sconfitto, tranne quando il vincitore aveva all'inizio almeno 3 SP (di Opliti, o di navi) in più.
[b]Parità[/b]: vince chi ha il Valore Tattico positivo più alto; se è pari anche quello, ognuno perde 1 SP e [b]entrambi[/b] vanno Verso Casa.
Per te: +10 punti vittoria se vinci, -15 se perdi.

""" + t("Ostaggi (6.6)") + """Chi vince una battaglia di terra in cui lo sconfitto perde almeno un SP di Opliti [b]ateniesi o spartani[/b] cattura degli ostaggi. Finché non c'è un armistizio: se li hai tu, il non-giocatore non può usare la strategia Attaccare Atene / Attaccare Sparta; se li ha lui, tu non puoi designare come obiettivo il suo spazio nazionale né gli spazi adiacenti.
In questa versione le perdite colpiscono prima gli Alleati: gli ostaggi si rischiano solo quando gli Alleati non bastano."""})

	p.append({"parte": parte, "titolo": "18. Combattimento: assedi, Verso Casa",
	"testo": t("Risoluzione degli Assedi (6.3)") + """Prima si tolgono i segnalini Assedio rimasti senza Armata assediante (per esempio perché è stata battuta nella ZOI di qualcuno). Poi si risolvono gli altri: spazi nazionali, spazi della coalizione, tutti gli altri.

[b]Vantaggio dell'assediato[/b]: se la Forza assediata ha [b]più SP Navali[/b] dell'Armata assediante, l'assedio fallisce da solo.
[b]Vantaggio dell'assediante[/b]: altrimenti un dado + [b]Valore Tattico[/b] del comandante (-2 se lo spazio è Siracusa): [b]1-3 fallisce, 4 o più riesce[/b].
Probabilità di riuscita: Valore Tattico 0, 3 su 6; Valore Tattico 1, 4 su 6; Valore Tattico 2, 5 su 6. A Siracusa: 1 su 6, 2 su 6, 3 su 6.

[b]Assedio fallito[/b]: l'Armata assediante va Verso Casa; lo spazio è Saccheggiato; SCI dell'assediante -1 se non-giocatore, [b]-2 se giocatore[/b]. Nessun punto vittoria perso.
[b]Assedio riuscito[/b]: la Forza assediata è [b]eliminata[/b]; lo spazio è Saccheggiato; SCI dell'assediato -1 (non se la fortezza era neutrale o in ribellione); SCI dell'assediante +1; [b]+300 talenti[/b] all'assediante (la vendita degli schiavi). Per te +10 punti vittoria; -15 se a riuscire è il non-giocatore contro un tuo spazio.

Un'Armata che si trova in una fortezza nemica senza poterla assediare (ha vinto la battaglia contro i difensori, ma non c'era segnalino Assedio) non la prende: torna a casa (errata ufficiali).

""" + t("Verso Casa (6.4)") + """Per [b]ogni Armata ancora sulla mappa[/b] un dado + [b]Valore Strategico[/b]:
[b]1-5[/b]: resta [b]1 solo SP[/b] di guarnigione, il resto e il comandante vanno nella casella Verso Casa. In spazio di Terra o Costiero resta un Oplita se possibile, poi Cavalleria, poi Navale; in un'Isola un Navale se possibile; ateniese o spartano piuttosto che Alleato.
[b]6 o più[/b]: restano tutti gli SP, parte solo il comandante.
Probabilità che l'Armata resti intera: Valore Strategico 0, 1 su 6; 1, 2 su 6; 2, 3 su 6; con Archidamo (-1) mai.

Poi tutte le unità della casella rientrano secondo la [b]Tabella del Movimento Post-Combattimento[/b]:
Ateniesi: Opliti e Cavalleria ad Atene, navi al Pireo.
Alleati ateniesi: Opliti il primo ad Anfipoli, poi 2 a Larissa, il resto metà a Corcira e metà a Chio; Cavalleria a Larissa (prima a Pella fino a 2, se la Macedonia è alleata); navi metà a Corcira e metà a Chio. Se Chio è perduta, Samo.
Spartani: Opliti e Cavalleria a Sparta, navi a Gizio (se è ateniese, a Corinto).
Alleati spartani: Opliti metà a Corinto e metà a Tebe; Cavalleria a Tebe; navi a Corinto. Con Siracusa, Persia o Macedonia alleate, prima lì.

La fase finisce senza comandanti sulla mappa, senza segnalini Assedio e senza spazi contesi. È così che funziona la guerra in questo gioco: [b]si colpisce e si torna a casa[/b]. Sul terreno resta, di norma, una guarnigione di 1 SP."""})

	p.append({"parte": parte, "titolo": "19. Diffusione della Ribellione e Iloti",
	"scena": {"centro": "Gythium", "zoom": 0.95, "cerchi": ["Pylos", "Asine", "Corone", "Prasiae", "Epidaurus Limera"]},
	"testo": t("7.1 Continuazione") + """Una ribellione è [b]sedata[/b] (si toglie il segnalino) se lo spazio si trova nella ZOI di un'unità [b]del colore dello spazio[/b] e [b]non[/b] nella ZOI di un'unità nemica. Tutte le altre restano.
Non serve quindi "riconquistare" lo spazio: basta che una tua unità lo copra con la ZOI. Una squadra navale ferma in un'isola seda tutte le ribellioni entro due rotte, se non ci sono nemici intorno.

""" + t("7.2 Diffusione") + """Per ogni spazio [b]adiacente[/b] (lungo qualunque LOC) a uno spazio che ha iniziato il segmento in ribellione, [b]della stessa Lega[/b] e [b]senza un'unità del proprio colore[/b]: un dado, +2 se lo spazio è nella ZOI di un'unità nemica. Con [b]6 o più[/b] si ribella. I neutrali non si ribellano così.
Una guarnigione di 1 SP rende uno spazio immune al contagio. Una flotta nemica vicina lo triplica (da 1 su 6 a 3 su 6).

""" + t("7.3 Ribellione degli Iloti") + """Riguarda cinque spazi attorno a Sparta, cerchiati nell'immagine: [b]Pilo, Asine, Corone, Prasie, Epidauro Limera[/b].
1. Se anche uno solo è controllato da Sparta, non succede nulla.
2. Se [b]tutti e cinque sono occupati da unità della Lega di Delo[/b] e il segnalino non è sulla mappa, scoppia la Ribellione degli Iloti: [b]Bellicosità di Sparta -2[/b], eliminati [b]2 SP di Opliti spartani[/b] a Sparta, [b]-500 talenti[/b] alle entrate spartane di quel turno.
3. Se sono tutti occupati e il segnalino è già sulla mappa, la ribellione continua: [b]Bellicosità -2[/b] e [b]-1000 talenti[/b].
Sparta la seda riprendendo uno qualunque dei cinque spazi.

Occupare vuol dire avere un'unità dentro, non basta saccheggiare. Servono cinque operazioni riuscite, cinque assedi (sono tutte fortezze) e guarnigioni che reggano: è l'arma più potente di Atene contro la Bellicosità spartana, e la più difficile: tutti e cinque gli spazi sono entro due da Sparta per terra, quindi ogni tua Forza lì fa scattare la Strategia Difensiva spartana (vedi le strategie, S4)."""})

	p.append({"parte": parte, "titolo": "20. Entrate, Resa, Armistizio",
	"scena": {"centro": "Lampsacus", "zoom": 0.6, "percorso": ["Athens", "Piraeus", "Sunium", "Kea", "Carystos", "Andros", "Chios", "Psara", "Skiros", "Limnos", "Imbros", "Elaeus", "Cardia", "Perinthus", "Byzantium"], "cerchi": ["Byzantium"]},
	"testo": t("8.1 Entrate") + """Atene 3500 talenti, Sparta 2500. Poi:
[b]-50[/b] per ogni spazio del proprio colore saccheggiato, in ribellione o controllato dal nemico (una sola volta per spazio).
[b]Sparta[/b]: -200 per ciascuna fra Tebe e Corinto in mano alla Lega di Delo; +500 se Siracusa è sua alleata e Atene non la controlla; +500 (o +1000 se ha preso Iaso) dopo l'evento "La Persia entra in guerra".
[b]Atene[/b]: [b]-1500[/b] se non può tracciare un percorso senza spazi controllati dal nemico da Atene alla Fonte LOC Euxine (nell'immagine una delle rotte del grano, con Bisanzio in fondo); +1000 se controlla Siracusa e ha ZOI su ogni spazio della Sicilia.
[b]Epidamno[/b]: +1000 alla parte che la controlla e può tracciare un percorso senza unità nemiche fino al proprio spazio nazionale. È verde: all'inizio vale per Atene.
[b]Eisphora[/b]: +1000 ad Atene, [b]solo se la comandi tu[/b], se Atene, Pireo, Panatto e Decelea sono senza unità della Lega del Peloponneso e nessuno è saccheggiato.
Il pulsante [b]Tabelle[/b], scheda Entrate, ti mostra il conto previsto in ogni momento.

""" + t("8.2 Costruzione") + """Tu puoi spendere fino a [b]600 talenti[/b]: 3 SP da 200, di qualunque tipo. Il non-giocatore ricostruisce al massimo 3 SP fra quelli persi nel turno, senza scendere sotto 1000 talenti. I nuovi SP vanno dove dice la Tabella del Movimento Post-Combattimento.

""" + t("9.1 Modifica della Bellicosità") + """Per ciascuna parte: SCI negativo, si sottrae; SCI positivo, si aggiunge la metà per difetto; poi si contano gli spazi della sua Lega catturati, saccheggiati o in ribellione, si divide per 10 per difetto e si sottrae. Più gli eventuali -2 di eventi e Iloti.

""" + t("9.2 Resa") + """Una parte si arrende se il suo [b]spazio nazionale è controllato dal nemico[/b] o se la sua [b]Bellicosità è zero[/b]. La partita finisce e ricevi 200 diviso il numero del turno.

""" + t("9.3 Armistizio") + """Una sola volta per partita. Scatta se [b]entrambe[/b] le parti hanno Bellicosità 6 o meno, oppure Tesoro sotto 1000 (ognuna deve soddisfare almeno una delle due). Durata in turni: (dado, +1 se Nicia era comandante ateniese nel turno) diviso 2, per eccesso.
Effetti: gli SP ateniesi e spartani (non gli Alleati) lasciano gli spazi catturati; via tutti gli Ostaggi; un evento per ogni turno di pace; le ribellioni restano ma non si diffondono; entrate moltiplicate per i turni (ignorando saccheggi ed Eisphora); ogni parte costruisce fino a 5 SP senza scendere sotto 1000 talenti (il non-giocatore: Sparta solo navi, Atene solo Opliti); la Bellicosità di [b]entrambe[/b] diventa 10 meno i turni di guerra combattuti.
Nella Guerra Archidamica l'armistizio chiude la partita.

""" + t("9.4 Fine del turno") + """Via i segnalini Saccheggiato, i comandanti tornano nelle tazze, il turno avanza."""})

	p.append({"parte": parte, "titolo": "21. Neutrali della coalizione ed eventi",
	"testo": """Quattro potenze minori possono entrare in guerra.

[b]Macedonia[/b] (Pella e Macedonia). Nel Gioco Campagna comincia [b]alleata di Atene[/b], con 1 SP di Cavalleria Alleata a Pella. Cambia parte con l'evento 9 (Re Perdicca).
[b]Argo[/b]. Neutrale: gli Ateniesi non possono entrarci e non si conta per la via più breve. Diventa [b]alleata di Atene con 4 Opliti[/b] se Sparta la dichiara obiettivo (la matrice spartana la sorteggia nell'area Alleati) oppure con l'evento 10 nei turni 4-6.
[b]Siracusa[/b]. Neutrale: gli Spartani non possono entrarci. Diventa [b]alleata di Sparta con 2 Opliti, 2 Cavalleria e 2 Navali[/b] se Atene la dichiara obiettivo, oppure con l'evento 10 nei turni 7-8. Da quel momento Sparta incassa 500 talenti in più a turno. Assediarla costa -2 al dado.
[b]Persia[/b] (Sardi). Entra solo con l'evento 5: dal turno 5, con Bellicosità spartana a 6 o più e Alcibiade presso Spartani o Persiani.

""" + t("Gli eventi che cambiano la partita") + """[b]6 Epidemia ad Atene[/b] (una volta sola, solo se nel turno precedente una Forza spartana è stata ad Atene, Pireo, Panatto o Decelea): Atene perde un terzo degli Opliti ateniesi di Atene e Pireo, paga un quarto del costo delle sue navi e [b]perde Pericle[/b].
[b]7 Demagogo da Assumere[/b]: le quattro tappe di Alcibiade. È il risultato più probabile con due dadi.
[b]8 Ribellione oligarchica nella Lega di Delo[/b].
[b]3 Ribellione oligarchica ad Atene[/b] (SCI ateniese negativo e Alcibiade col nemico): Bellicosità di Atene -2, due ribellioni, niente Eisphora.
[b]4 e 9[/b]: Tracia (Abdera e Maronea) e Macedonia cambiano alleanza.
[b]10 Potenze Minori[/b]: turni 1-3 guerra civile a Corcira (le sue forze non operano); 4-6 Argo; 7-8 Siracusa; 9-10 Corcira diventa neutrale e Atene perde uno spazio di coalizione.
[b]11 Morte di Comandanti[/b]: nel turno, in battaglia, un dado naturale 1-3 uccide il comandante (massimo 3 per parte; Alcibiade e Pericle immuni).
[b]12 Fenomeno[/b]: eclissi (Atene) o terremoto (Sparta): al massimo 2 operazioni nel turno.
[b]2 Miniera d'argento[/b]: 400 talenti a una delle due.

Hai finito il regolamento. Le prossime pagine lo mostrano in azione sull'esempio di gioco del manuale, poi passiamo alle strategie."""})

# ====================================================================== PARTE 2: ESEMPIO DI GIOCO
static func _esempio(p: Array) -> void:
	var parte := "L'esempio di gioco del manuale"
	p.append({"parte": parte, "titolo": "E1. La situazione iniziale",
	"scena": {"centro": "Megara", "zoom": 0.62},
	"testo": """Riviviamo sulla mappa l'Esempio di Gioco del Manuale del Giocatore: il turno 1 del Gioco Campagna. Nelle tue partite i dadi daranno altri risultati; qui contano i meccanismi.

""" + t("Lega di Delo (tu)") + """Tesoro 4500, Bellicosità 10.
Atene: Pericle (1/0), 6 Opliti, 1 Cavalleria. Pireo: 8 Navali. Naupatto: 1 Navale.
Alleati: Corcira 3 Navali e 1 Oplita; Chio 2 Navali e 1 Oplita; Larissa 5 Cavalleria e 2 Opliti; Pella 1 Cavalleria; Anfipoli 1 Oplita.
Potidea: [b]Formione[/b] (2/0) con 2 Opliti, 3 Navali e 1 Cavalleria Alleata, già attivati. È l'operazione iniziale di Atene: Potidea è in ribellione con 1 Oplita Alleato spartano dentro.

""" + t("Lega del Peloponneso (non-giocatore)") + """Tesoro 3000, Bellicosità 10, strategia [b]Attaccare Atene[/b].
Sparta: Archidamo (1/-1), Guardia Nazionale (3), 7 Opliti, 1 Cavalleria.
Corinto: 5 Opliti e 5 Navali Alleati. Tebe: 5 Opliti e 4 Cavalleria Alleati.

""" + t("Che cosa osservare prima di cominciare") + """Sparta ha in tutto 17 SP di Opliti mobili: per una Spedizione da 12 deve svuotare quasi tutto, e pagare gli Alleati.
La flotta di Atene è tripla di quella nemica, ma ogni SP Navale attivato costa 400 talenti e sotto i 1000 non si scende: Atene può muovere 8 SP Navali in tutto il turno, non di più.
Le Forze ad Atene (Cavalleria) e a Tebe (Cavalleria) hanno ZOI sugli spazi adiacenti: l'Attica e la Beozia sono piene di possibili intercettazioni."""})

	p.append({"parte": parte, "titolo": "E2. Archidamo invade l'Attica",
	"scena": {"centro": "Megara", "zoom": 0.7, "ob": "Decelea",
		"percorso": ["Sparta", "Belmina", "Methydrum", "Orchomenus", "Philius", "Sicyon", "Corinth", "Pegae", "Panactum", "Platea", "Thebes", "Delium", "Oropus", "Decelea"],
		"sp": {"Sparta": {"u": {"SG": 3, "SC": 1}}, "Corinth": {"u": {"sH": 1, "sN": 5}}, "Thebes": {"u": {"sH": 4, "sC": 2}},
			"Decelea": {"u": {"SH": 7, "sH": 5, "sC": 2}, "a": {"SH": 7, "sH": 5, "sC": 2}, "dev": true}, "Oropus": {"dev": true}},
		"capi": {"archidamus": "Decelea"}},
	"testo": """[b]Operazione iniziale del non-giocatore.[/b]

[b]Strategia Difensiva?[/b] Nessuna Forza ateniese vicino a Sparta, a Corinto o a Tebe: no.
[b]Obiettivo.[/b] Con "Attaccare Atene" basta un dado: esce 5, [b]Decelea[/b].
[b]Forza richiesta.[/b] 12 Opliti e 2 Cavalleria.

[b]Raduno.[/b] A Sparta Archidamo attiva i 7 Opliti spartani, gratis. La Guardia Nazionale non si muove. La Cavalleria spartana resta: sarebbe l'ultimo SP di quel tipo nello spazio e altra Cavalleria è disponibile altrove.
Lo spazio amico più vicino con truppe è Corinto. La via più breve passerebbe per Argo, ma [b]Argo neutrale non si conta[/b]: si va per Belmina, Metidrio, Orcomeno, Fliunte, Sicione, Corinto. (Sulla mappa è lunga uguale anche la via per Tegea e Mantinea: nell'app decide il dado.) Nessuna ZOI ateniese lungo la strada.
A Corinto: 4 Opliti Alleati, [b]800 talenti[/b] (Tesoro 2200). Ne resta 1, con le 5 navi.
Verso Tebe ci sono quattro percorsi di pari lunghezza: il dado sceglie Pege, Panatto, Platea, Tebe.
[b]Panatto è nella ZOI della Forza di Atene[/b] (ha Cavalleria): intercettazione, dado 4, riuscita. Schermaglia: 2 e 2, nessuna perdita. Battaglia? La somma è 4, non 11; gli SP di terra sono più di 8 ma quelli ateniesi (7) sono meno della metà del totale (18): no. La Spedizione prosegue.
Panatto e Platea [b]non[/b] vengono saccheggiate: la Spedizione sta andando a uno spazio di raduno, non all'obiettivo.
A Tebe: 1 Oplita e 2 Cavalleria Alleati, [b]600 talenti[/b] (Tesoro 1600). La forza è completa: 12 Opliti e 2 Cavalleria.

[b]Marcia sull'obiettivo.[/b] Due percorsi da 3 spazi; esce Delio, Oropo, Decelea. [b]Oropo[/b] è ateniese, vuota e fuori da ogni ZOI: [b]saccheggiata[/b]. A Decelea la Cavalleria di Atene tenta l'intercettazione: dado 1, fallita. [b]Decelea saccheggiata[/b]. L'operazione è finita.

Risultato: l'Armata di Archidamo è su una fortezza nemica vuota; Atene ha già perso l'Eisphora di questo turno; Sparta ha speso 1400 dei suoi 3000 talenti."""})

	p.append({"parte": parte, "titolo": "E3. Pericle fa il giro del Peloponneso",
	"scena": {"centro": "Tegea", "zoom": 0.5, "ob": "Erineus",
		"percorso": ["Athens", "Piraeus", "Aegina", "Methana", "Cape Seyllaeum", "Troezen", "Hermione", "Prasiae", "Epidaurus Limera", "Cythera", "Cape Taenarum", "Corone", "Asine", "Pylos", "Zacynthus", "Cephallenia", "Oeniadae", "Naupactus", "Panormus", "Erineus"],
		"sp": {"Sparta": {"u": {"SG": 3, "SC": 1}}, "Corinth": {"u": {"sH": 1, "sN": 5}}, "Thebes": {"u": {"sH": 4, "sC": 2}},
			"Decelea": {"u": {"SH": 7, "sH": 5, "sC": 2}, "a": {"SH": 7, "sH": 5, "sC": 2}, "dev": true}, "Oropus": {"dev": true},
			"Piraeus": {"u": {"AN": 5}}, "Erineus": {"u": {"AN": 3}, "a": {"AN": 3}},
			"Methana": {"dev": true}, "Cape Seyllaeum": {"dev": true}, "Troezen": {"dev": true}, "Hermione": {"dev": true}, "Epidaurus Limera": {"dev": true},
			"Cythera": {"dev": true}, "Cape Taenarum": {"dev": true}, "Corone": {"dev": true}, "Asine": {"dev": true}, "Pylos": {"dev": true}, "Oeniadae": {"dev": true}},
		"capi": {"archidamus": "Decelea", "pericles": "Erineus"}},
	"testo": """[b]Prima operazione continuata di Atene.[/b] Auguri favorevoli. Pericle è già ad Atene: comanda lui.

Il giocatore vuole saccheggiare la costa del Peloponneso e sfidare la flotta di Corinto. Sceglie come obiettivo [b]Erineo[/b], nel Golfo di Corinto: uno spazio giallo, neutrale, con fortezza. Da Atene Pericle va al Pireo (spazio di raduno) e attiva [b]3 SP Navali: 1200 talenti[/b] (Tesoro 3300). Solo navi: la via più breve è tutta per mare.

[b]Il percorso[/b] (in giallo): Egina, Metana, Capo Scilleo, Trezene, Ermione, Prasie, Epidauro Limera, Citera, Capo Tenaro, Corone, Asine, Pilo, Zacinto, Cefalonia, Eniade, Naupatto, Panormo, Erineo.

Ogni spazio rosso vuoto attraversato viene [b]saccheggiato[/b]: sono [b]undici[/b]. Non lo sono Zacinto (amica), Cefalonia (neutrale), Naupatto (amica), Panormo (neutrale).

[b]Prasie[/b] è nella ZOI della Forza di Sparta, che ha Cavalleria. Intercettazione: 5, riuscita. Schermaglia: 6 e 6, nessuna perdita, ma [b]la somma è 12: battaglia immediata[/b]. Da una parte solo navi, dall'altra solo truppe: [b]battaglia nulla[/b], Pericle prosegue. Prasie però non viene saccheggiata, perché l'intercettazione è riuscita.
[b]Corone[/b], stessa ZOI: dado 2, intercettazione fallita, saccheggiata.
[b]Erineo[/b] è nella ZOI navale della Forza di Corinto: dado basso, intercettazione fallita.

""" + t("Che cosa insegna") + """Una Spedizione di sole navi è quasi intoccabile da terra: la schermaglia può costarle un SP (un 1 su 6), ma la battaglia è sempre nulla.
Undici saccheggi sono 550 talenti in meno per Sparta e, superata la decina, [b]1 punto di Bellicosità[/b].
L'obiettivo è stato scelto [b]per il percorso[/b] che obbliga a fare. Se Pericle avesse usato Naupatto come spazio di raduno, quel tratto non avrebbe saccheggiato nulla.
E nota dov'è finito: a due rotte da Corinto. La sua ZOI copre la flotta nemica."""})

	p.append({"parte": parte, "titolo": "E4. Demostene a Eraclea, Cleone a Tebe",
	"scena": {"centro": "Chalcis", "zoom": 0.62, "ob": "Thebes",
		"percorso": ["Athens", "Piraeus", "Aegina", "Kithnos", "Siros", "Andros", "Chios", "Psara", "Skiros", "Sporades", "Olizon", "Pteleum", "Thermopylae", "Heraclea"],
		"sp": {"Sparta": {"u": {"SG": 3, "SC": 1}}, "Corinth": {"u": {"sH": 1, "sN": 5}},
			"Thebes": {"u": {"sH": 4, "sC": 2, "AH": 5, "AC": 1}, "a": {"AH": 5, "AC": 1}},
			"Decelea": {"u": {"SH": 7, "sH": 5, "sC": 2}, "a": {"SH": 7, "sH": 5, "sC": 2}, "dev": true}, "Oropus": {"dev": true},
			"Piraeus": {"u": {"AN": 5}}, "Erineus": {"u": {"AN": 3}, "a": {"AN": 3}}, "Athens": {"u": {}},
			"Chios": {"u": {"aN": 1}}, "Heraclea": {"u": {"aH": 1, "aN": 1}, "a": {"aH": 1, "aN": 1}, "dev": true}},
		"capi": {"archidamus": "Decelea", "pericles": "Erineus", "demosthenes": "Heraclea", "cleon": "Thebes"}},
	"testo": """[b]Sparta tenta la seconda operazione.[/b] Auguri: 5, +1 per il non-giocatore, 6: [b]deve passare[/b]. Non avrebbe comunque potuto: le restano 5 Opliti e 2 Cavalleria non attivati contro i 12 e 2 richiesti. Da qui in poi gioca solo Atene.

""" + t("Terza operazione ateniese: Demostene") + """Auguri favorevoli. Ad Atene non c'è un comandante: si pesca [b]Demostene[/b] (2/1). Obiettivo [b]Eraclea[/b], fortezza rossa sul Golfo Maliaco. Il giocatore vuole usare gli Alleati di Chio.
Demostene parte [b]da solo[/b]. Esisterebbe una via da 5 spazi per Decelea, ma Decelea è occupata dal nemico e un comandante da solo non può entrarci: restano le vie da 6 spazi (il manuale ne elenca tre, sulla mappa ce n'è una quarta per Ceo e Siro) e il dado ne sceglie una senza intercettazioni (in giallo fino a Chio). Se fosse stato intercettato, operazione annullata.
A Chio attiva 1 Oplita e 1 Navale Alleati: [b]600 talenti[/b] (Tesoro 2700). Un SP Navale porta un SP di terra: la Spedizione salpa per Psara, Sciro, Sporadi, Olizone, Pteleo, Termopili, Eraclea. Spazi amici o neutrali tranne l'ultimo: solo [b]Eraclea è saccheggiata[/b]. (Il manuale scrive Pteleo-Eraclea; sulla mappa però quel collegamento è di sola Terra, e una Spedizione con una nave passa per le Termopili: uno spazio in più, stesso risultato. L'app segue la mappa.)

""" + t("Quarta operazione ateniese: Cleone") + """Auguri ancora favorevoli; si pesca [b]Cleone[/b] (0/2). Obiettivo [b]Tebe[/b], spazio di coalizione spartano. Cleone attiva tutto quello che c'è ad Atene, 6 Opliti e 1 Cavalleria: [b]1400 talenti[/b] (Tesoro 1300).
Via Panatto e Tanagra. A [b]Tanagra[/b] (ZOI della Cavalleria di Tebe) l'intercettazione fallisce. A [b]Tebe[/b] riesce: schermaglia, Atene tira 1 e [b]perde 1 Oplita[/b], Sparta tira 2. Battaglia immediata? Gli SP di terra in gioco sono 13 (7 di Cleone, 6 a Tebe) e chi intercetta ne ha meno della metà: niente battaglia. Cleone resta a Tebe con 5 Opliti e 1 Cavalleria, accanto a 4 Opliti e 2 Cavalleria Alleati spartani.

""" + t("Atene passa") + """Con 1300 talenti e il Fondo di Emergenza a 1000 potrebbe attivare un solo SP di terra: il giocatore passa. Fine delle operazioni.

""" + t("Che cosa insegna") + """Il denaro, non le truppe, ferma Atene: quattro operazioni sono costate 3200 talenti.
Cleone ha Valore Tattico 0 ed è finito a combattere in uno spazio di coalizione nemico con un solo Oplita di vantaggio e meno Cavalleria. È esattamente il tipo di battaglia da non cercare."""})

	p.append({"parte": parte, "titolo": "E5. La Fase di Combattimento",
	"scena": {"centro": "Megara", "zoom": 0.72,
		"sp": {"Sparta": {"u": {"SG": 3, "SC": 1}}, "Corinth": {"u": {"sH": 1, "sN": 5}},
			"Thebes": {"u": {"sH": 4, "sC": 2, "AH": 5, "AC": 1}},
			"Decelea": {"u": {"SH": 7, "sH": 5, "sC": 2}, "dev": true, "ass": "S"}, "Oropus": {"dev": true},
			"Piraeus": {"u": {"AN": 5}}, "Erineus": {"u": {"AN": 3}, "ass": "A"}, "Athens": {"u": {}},
			"Chios": {"u": {"aN": 1}}, "Heraclea": {"u": {"aH": 1, "aN": 1}, "dev": true, "ass": "A"}, "Potidaea": {"ass": "A"}},
		"capi": {"archidamus": "Decelea", "pericles": "Erineus", "demosthenes": "Heraclea", "cleon": "Thebes"}, "cerchi": ["Thebes", "Corinth"]},
	"testo": t("1. Determinazione dell'Assedio") + """[b]Potidea[/b]: Formione ha 6 SP contro 1 difensore senza comandante: 5 in più, assedio.
[b]Eraclea[/b], [b]Decelea[/b], [b]Erineo[/b]: Armate su fortezze nemiche (o neutrale obiettivo) vuote: assedio.
[b]Tebe[/b]: Cleone ha 6 SP contro 6: non ne ha 5 in più. Niente assedio: battaglia.

""" + t("2. Battaglie") + """[b]Tebe[/b] (spazio di coalizione, si risolve per prima). Battaglia di terra. Atene: +1 per la differenza di Opliti (5 contro 4), Cleone 0. Sparta: +1 per la Cavalleria (2 contro 1); niente +2, sono tutti Alleati. Dadi: Atene 3+1 = 4, Sparta 4+1 = 5. [b]Vince Sparta di 1[/b]: Atene elimina 1 Oplita; Cleone e i superstiti vanno Verso Casa. SCI Sparta +1, Atene -1. Per il giocatore: [b]-15 punti vittoria[/b]. E poiché è caduto un Oplita [b]ateniese[/b], Sparta cattura [b]ostaggi[/b]: da ora Atene non può più "Attaccare Sparta".

[b]Battaglie nelle ZOI[/b]. La flotta di Pericle a Erineo e la Forza di Corinto sono l'una nella ZOI navale dell'altra: [b]battaglia navale[/b], prima che gli assedi siano risolti. Atene: +2 (navi ateniesi) +1 (Pericle) = +3. Sparta: +2 (5 navi contro 3). Dadi: Atene 6+3 = 9, Sparta 1+2 = 3. Differenza 6, ma il vincitore ha solo 3 navi: [b]Sparta elimina 3 SP Navali[/b]. I 2 Navali e l'Oplita superstiti vanno Verso Casa. SCI: Atene da -1 a 0, Sparta da +1 a 0. [b]+10 punti vittoria[/b].

""" + t("3. Assedi") + """[b]Decelea[/b] (Archidamo, tattico 1): dado 2+1 = 3, [b]fallito[/b]. L'Armata spartana va Verso Casa. SCI Sparta -1.
[b]Erineo[/b] (Pericle, 1): 4+1 = 5, [b]riuscito[/b]. +300 talenti, SCI Atene +1, +10 punti vittoria. Erineo era neutrale: lo SCI spartano non cala.
[b]Eraclea[/b] (Demostene, 2): 2+2 = 4, [b]riuscito[/b]. +300 talenti, SCI Atene +2, Sparta -2, +10 punti vittoria.
[b]Potidea[/b] (Formione, 2): 1+2 = 3, [b]fallito[/b]. Formione Verso Casa, Potidea saccheggiata e ancora in ribellione. SCI Atene da +2 a [b]0[/b]: il giocatore perde 2. Nessun punto vittoria perso.

""" + t("4. Verso Casa") + """Pericle (strategico 0): meno di 6. Resta [b]1 SP Navale a Erineo[/b], gli altri 2 e Pericle tornano. Demostene (strategico 1): 5+1 = 6: [b]tutta la forza resta a Eraclea[/b], lui torna.
Poi la casella si svuota: 6 Opliti ateniesi ad Atene, 7 spartani a Sparta, 6 Alleati spartani metà a Corinto e metà a Tebe, la Cavalleria Alleata ateniese a [b]Pella[/b] (Macedonia alleata, non ce ne sono ancora 2), le navi al Pireo e a Corinto.

[b]Bilancio del giocatore[/b]: una battaglia persa, una vinta, due assedi riusciti, uno fallito: -15 +10 +10 +10 = [b]+15 punti vittoria[/b], SCI finale 0."""})

	p.append({"parte": parte, "titolo": "E6. Fine del turno 1 e inizio del turno 2",
	"scena": {"centro": "Megara", "zoom": 0.62,
		"sp": {"Sparta": {"u": {"SG": 3, "SH": 7, "SC": 1}}, "Corinth": {"u": {"sH": 3, "sN": 5}}, "Thebes": {"u": {"sH": 7, "sC": 4}},
			"Athens": {"u": {"AH": 8, "AC": 2}}, "Piraeus": {"u": {"AN": 10}}, "Erineus": {"u": {"AN": 1}}, "Chios": {"u": {"aN": 1}},
			"Heraclea": {"u": {"aH": 1, "aN": 1}}, "Potidaea": {"u": {"sH": 1}, "riv": true}, "Methone": {"riv": true}, "Pela": {"u": {"aC": 2}}},
		"capi": {"pericles": "", "archidamus": "", "phormio": ""}},
	"testo": t("Diffusione della Ribellione") + """Potidea resta in ribellione (c'è un Oplita spartano dentro, nessuna unità ateniese la copre). Candidati al contagio: Metone, Olinto, Scione, tutti verdi e senza guarnigione. Pidna è neutrale: esclusa. Per Metone esce 6: [b]si ribella[/b].

""" + t("Entrate") + """[b]Atene[/b]: 3500, meno 2 spazi saccheggiati (Oropo, Decelea) e 2 in ribellione (Potidea, Metone) = [b]3300[/b]. Niente Eisphora: Decelea è saccheggiata. Tesoro da 1900 a 5200.
[b]Sparta[/b]: 2500, meno 11 spazi saccheggiati e 1 catturato (Eraclea, che conta una volta sola anche se è pure saccheggiata) = [b]1900[/b]. Tesoro da 1600 a 3500.
(Il manuale non conteggia qui i 1000 talenti della LOC di Epidamno; l'app applica la regola 8.1.4 e li assegna ad Atene finché Epidamno è sua e il percorso è libero.)

""" + t("Costruzione") + """Sparta ricostruisce i 3 SP Navali Alleati perduti: 600 talenti, a Corinto. Il giocatore costruisce 2 Opliti e 1 Cavalleria ateniesi, ad Atene.

""" + t("Bellicosità") + """[b]Sparta da 10 a 7[/b]: -2 per lo SCI a -2, -1 per i 12 spazi saccheggiati o catturati. Atene resta a 10: SCI 0, quattro spazi soltanto.
Tre punti di Bellicosità in un solo turno: ecco perché una resa entro il turno 3 non è un'ipotesi di scuola.

""" + t("Turno 2, Fase Politica") + """[b]Determinazione della Parte[/b]: SCI del giocatore 0, quindi deve tirare. Esce [b]6[/b]: il giocatore [b]passa a comandare Sparta[/b].
[b]Evento[/b]: 6, Epidemia ad Atene. Una Forza spartana è stata a Decelea nel turno precedente: si applica. Atene perde 3 Opliti (un terzo di 8, per eccesso), 600 talenti (un quarto di 10 SP Navali, per eccesso: 3 SP a 200) e [b]Pericle[/b].
[b]Ribellione della Lega di Delo[/b]: SCI ateniese 0, scatta. Esce 12: [b]Anfipoli[/b]; con un 6 la segue [b]Taso[/b].
[b]Strategia[/b]: il giocatore ha cambiato parte, quindi Atene tira: 4, +1 per il Valore Strategico di Nicia = 5, [b]Tagliare LOC[/b]. Se fosse uscito "Attaccare Sparta" si sarebbe ritirato: Sparta ha gli ostaggi.

""" + t("La lezione dell'esempio") + """Il giocatore ha chiuso il turno a +15 punti e SCI 0: né abbastanza male da restare ateniese, né abbastanza bene da evitare la ribellione. Ora eredita una Sparta a Bellicosità 7 e 2900 talenti, contro un'Atene senza Pericle, con Anfipoli in ribellione. Ogni vittoria ottenuta prima diventa un problema suo. Questo è il gioco."""})

# ====================================================================== PARTE 3: STRATEGIE
static func _strategie(p: Array) -> void:
	var parte := "Le strategie"
	p.append({"parte": parte, "titolo": "S1. Fare i conti con la vittoria",
	"testo": """Prima di parlare di Atene e di Sparta bisogna guardare l'aritmetica, perché è spietata.

""" + t("Obiettivo 150 in dieci turni") + """Più di 150 punti con +10 per vittoria e -15 per sconfitta vuol dire, per esempio, 16 successi e nessuna sconfitta; oppure 22 successi e 4 sconfitte. Su meno di dieci turni giocati sono [b]due successi netti a turno, tutti i turni[/b]. La resa aggiunge poco se arriva tardi: 50 punti al turno 4, 40 al 5, 29 al 7.

""" + t("Le tre fonti di punti") + """[b]Assedi tuoi[/b]: +10 se riescono, [b]zero se falliscono[/b]. Non esiste nel gioco altra scommessa senza penalità in punti. Con un comandante tattico 2 riescono 5 volte su 6, con tattico 1 due su tre, con tattico 0 una su due.
[b]Battaglie[/b]: +10 o -15. Conviene solo con un vantaggio netto (vedi S2).
[b]Assedi del non-giocatore contro di te[/b]: -15 se riescono. Si prevengono con le guarnigioni e con le ZOI.

Ne segue la regola base: [b]il grosso dei punti si fa assediando fortezze nemiche vuote o quasi, con i comandanti di Valore Tattico 2[/b], e si combattono in campo aperto solo le battaglie già vinte in partenza.

""" + t("La vittoria rapida") + """Se una parte si arrende entro la fine del turno 3 hai vinto, qualunque sia il punteggio. La Bellicosità parte da 10 e nell'esempio del manuale Sparta ne perde 3 nel solo turno 1. Le leve, tutte cumulabili nello stesso turno:
SCI negativo dell'avversario: ogni sua battaglia persa -1 (se non avevi 3 Opliti o 3 navi più di lui), ogni tuo assedio riuscito su un suo spazio -1, ogni suo assedio fallito -1.
Spazi saccheggiati, in ribellione o catturati: -1 ogni 10.
Ribellione degli Iloti: -2 a turno contro Sparta.
Eventi: -2 ad Atene con la Ribellione oligarchica.
Portare Sparta da 10 a 0 in tre turni richiede più di -3 a turno: difficile, ma è l'unica strada che non passa dai 150 punti. Vale la pena tentarla quando il turno 1 va molto bene; altrimenti si gioca per i punti.

""" + t("Il rovescio: la tua Bellicosità") + """Anche tu ti arrendi a zero, e la resa della [b]tua[/b] parte dà gli stessi punti di quella avversaria: non è una sconfitta in sé. Ma una resa tardiva con pochi punti chiude la partita in perdita. Tieni d'occhio soprattutto i tuoi assedi falliti: -2 SCI l'uno, cioè -2 di Bellicosità a fine turno se non li compensi.

""" + t("Guerra Archidamica") + """40 punti in tre turni, e la partita finisce appena torni ateniese dopo essere stato spartano. Servono quattro successi netti: l'esempio del manuale ne fa uno e mezzo nel primo turno. Qui si gioca aggressivi fin dalla prima operazione."""})

	p.append({"parte": parte, "titolo": "S2. Le probabilità da sapere",
	"testo": t("Battaglia: quanto vale un vantaggio") + """Sia V la differenza fra i tuoi modificatori e quelli del nemico (Opliti o navi in più, +2 nazionali, Cavalleria, Valore Tattico). Due dadi, uno a testa:
V = 0: vinci 42%, pareggi 17%, perdi 42%
V = +1: vinci 58%, pareggi 14%, perdi 28%
V = +2: vinci 72%, pareggi 11%, perdi 17%
V = +3: vinci 83%, pareggi 8%, perdi 8%
V = +4: vinci 92%, pareggi 6%, perdi 3%
V = +5: vinci 97%, pareggi 3%
V = +6: vinci sempre.
Il pareggio lo vince chi ha il Valore Tattico positivo più alto: con un comandante migliore il "pareggi" diventa "vinci".

In punti vittoria attesi (+10 / -15): a V = 0 perdi in media 2 punti a battaglia; a +1 ne guadagni meno di 2; a [b]+2 ne guadagni quasi 5[/b]; a +3 più di 7. La soglia sensata è [b]+2[/b]: sotto, non cercare la battaglia; se V è negativo, evitala a ogni costo.

""" + t("Da dove viene il vantaggio") + """Ogni Oplita in più vale +1: è il modificatore più economico (200 talenti, gratis per gli Spartani).
Sparta con metà Opliti spartani: +2 fisso. Sei Opliti ateniesi contro quattro spartani partono alla pari.
Atene in mare con metà navi ateniesi: +2 fisso. Tre navi ateniesi con Formione (+2) contro cinque Alleate spartane: +4 contro +2.
La Cavalleria: +1 secco, e uno sconto sulle perdite se perdi.

""" + t("Le perdite") + """Lo sconfitto perde la differenza dei risultati, ma mai più degli Opliti (o delle navi) del vincitore. Una forza piccola che vince una grande le fa poco male; una grande che vince ne distrugge una piccola.

""" + t("Assedio") + """Tattico 0: 50%. Tattico 1: 67%. Tattico 2: 83%. A Siracusa: 17%, 33%, 50%.

""" + t("Intercettazione") + """50% per ogni spazio in ZOI nemica in cui entri. Tre spazi in ZOI: 87% di subirne almeno una. Ogni intercettazione riuscita: 1 su 6 di perdere un SP, 1 su 12 di battaglia per i dadi, battaglia certa se chi intercetta ha almeno metà di 8 o più SP.

""" + t("Auguri (tue operazioni continuate)") + """0-1 comandanti in campo: 83% di procedere. 2-3: 67%. 4-5: 50%. 6-7: 33%.
Probabilità di fare almeno tre operazioni nel turno partendo con un solo comandante (quello pescato): circa 56%. Quattro: circa 37%.

""" + t("Verso Casa") + """L'Armata resta intera: strategico 0, 17%; 1, 33%; 2, 50%.

""" + t("Causare Ribellione") + """Tu: 17%. Il non-giocatore: 50%.

""" + t("Cambio di parte") + """SCI 0: 17%. +1: 33%. +2: 50%. +3: 67%. +4: 83%. +5: 100%. Negativo: 0%."""})

	p.append({"parte": parte, "titolo": "S3. Lo SCI e il cambio di parte",
	"testo": """Ogni turno lo SCI riparte da zero e a fine turno decide tre cose insieme: la Bellicosità, la probabilità di cambiare parte, la ribellione nella Lega di Delo. Non puoi ottimizzarle tutte: devi scegliere.

""" + t("Chiudere il turno con SCI negativo") + """Resti sicuramente dalla tua parte. Ma la tua Bellicosità scende di altrettanto, e se sei Atene avrai una Ribellione della Lega di Delo. È la scelta di chi ha un piano a lungo termine da quella parte e Bellicosità da spendere.

""" + t("Chiudere a zero") + """Una probabilità su sei di cambiare, Bellicosità ferma. Per Atene, però, zero significa comunque ribellione.

""" + t("Chiudere positivo") + """+1 o +2 danno Bellicosità ferma o +1 e un cambio di parte una volta su tre o una su due. Da +4 in su il cambio è quasi certo e la Bellicosità sale di 2 o 3.

""" + t("Come si governa") + """Lo SCI si muove solo in combattimento: +1 per vittoria e assedio riuscito, -1 per sconfitta, [b]-2 per ogni tuo assedio fallito[/b]. Quest'ultimo è il freno: un assedio azzardato con un comandante tattico 0 è insieme un tentativo da +10 punti e, se fallisce, un -2 che ti tiene dalla tua parte. Non regala niente, ma è l'unico modo di "perdere SCI" senza perdere punti vittoria.
Ricorda anche l'eccezione: se vinci con 3 o più Opliti (o navi) di vantaggio, lo sconfitto [b]non[/b] perde SCI. Le vittorie schiaccianti danno punti a te ma non logorano la Bellicosità nemica; quelle di misura sì.

""" + t("Giocare sapendo che cambierai") + """Dai per scontato che cambierai parte due o tre volte. Quindi:
1. [b]Non distruggere quello che erediterai.[/b] Gli assedi di fortezze vuote danno punti senza eliminare un solo SP nemico. Le battaglie di annientamento ti consegnano poi un esercito a pezzi.
2. [b]Non lasciare la tua parte in bolletta.[/b] Un Tesoro a 1000 e nessuna guarnigione sono un regalo che fai al te stesso del turno dopo... dall'altra parte del tavolo. Ma anche l'inverso: se sei quasi certo di cambiare, i talenti spesi oggi in guarnigioni saranno ostacoli tuoi domani.
3. [b]Guarda sempre che cosa farebbe la matrice con la parte che lasci.[/b] La tua ex parte sarà mossa da forze piccole e prevedibili: le posizioni solide che lasci restano solide, quelle che richiedono le tue decisioni crollano.
4. [b]Le posizioni valgono per tutti e due.[/b] Una guarnigione ateniese nei cinque spazi degli Iloti fa calare la Bellicosità spartana chiunque comandi. Se stai puntando alla resa di Sparta, continuerà a lavorare per te anche quando comanderai Sparta: la resa ti dà punti comunque.

""" + t("L'armistizio") + """Scatta quando entrambe sono a Bellicosità 6 o meno (o senza soldi). Poi la Bellicosità di entrambe diventa 10 meno i turni combattuti: dopo quattro turni di guerra, 6 a testa. Fa saltare da uno a tre turni (meno tempo per i punti) ma lascia due parti fragili, a pochi passi dalla resa. Toglie anche gli ostaggi. Se sei avanti nei punti e lontano da 150, un armistizio seguito da una spinta alla resa è spesso la via più corta."""})

	p.append({"parte": parte, "titolo": "S4. Comandare Atene",
	"scena": {"centro": "Gythium", "zoom": 0.72, "cerchi": ["Pylos", "Asine", "Corone", "Prasiae", "Epidaurus Limera", "Gythium", "Methana", "Troezen", "Hermione"]},
	"testo": t("I tuoi punti di forza") + """Il mare. Il +2 delle navi ateniesi, più Formione, Demostene o Trasibulo (tattico 2), fa di ogni battaglia navale una vittoria quasi certa. Una Spedizione di sole navi non può essere battuta da truppe di terra (battaglia nulla). E il Tesoro: 3500 di entrate, più 1000 di Eisphora e 1000 di Epidamno quando ci sono.

""" + t("I tuoi limiti") + """Ogni SP Navale costa 400 talenti e non puoi scendere sotto 1000: con 4500 muovi 8 navi, o 3 navi e 11 Opliti. Gli Opliti ateniesi sono pochi (6) e ogni battaglia di terra contro gli Spartani parte da -2. Se chiudi il turno con SCI zero o meno, una città della Lega si ribella.

""" + t("Piano tipo del turno") + """[b]Prima operazione (senza Auguri): l'incursione navale.[/b] Tre o quattro navi dal Pireo verso un obiettivo che obblighi a costeggiare il Peloponneso. Saccheggi una decina di spazi (-500 talenti e -1 Bellicosità a Sparta) e arrivi su una fortezza costiera vuota da assediare. Come obiettivo scegli una fortezza [b]a più di due spazi da Sparta[/b] (vedi sotto perché): Metana, Trezene, Ermione sono a un passo dal Pireo; Lepreo, Fea, Cillene sulla costa occidentale, o Erineo nel Golfo di Corinto, obbligano al giro lungo e a saccheggiare tutta la costa. Nell'immagine sono cerchiati gli spazi vicini a Sparta: quelli si attraversano, non si scelgono come primo obiettivo.
[b]Aggiungi Opliti alle navi[/b] (pari numero) quando vuoi che la guarnigione che resta sia un Oplita, e quando ti aspetti una battaglia combinata: dopo una vittoria navale, se hai almeno tanti Opliti quanti il nemico, combatti subito anche a terra.
[b]Seconda operazione: un secondo assedio[/b] con il comandante che peschi. Se è Cleone o Nicia (tattico 0), mandalo a rinforzare o a sedare una ribellione, non ad assediare.
[b]Terza: solo se il Tesoro regge.[/b] Lasciare 1000 talenti inutilizzabili è normale; lasciarne 2500 è uno spreco, ma restare senza difese in Attica è peggio.

""" + t("Sparta reagisce: il raggio di due spazi") + """Se una tua Forza si trova entro due spazi da Sparta per LOC di Terra o Combinata, la prossima operazione di Sparta (guidata dal gioco) è per forza la Strategia Difensiva: 10 Opliti e 1 Cavalleria contro quello spazio. Dentro il raggio ci sono Tegea, Carie, Prasie, Gizio, Corone, Belmina e, al secondo passo, Mantinea, Argo, Tirea, Epidauro Limera, Capo Tenaro, Asine, Metidrio, [b]Pilo[/b].
Che cosa succede quando arriva, nella Fase di Combattimento (lo spazio è rosso, quindi per Sparta non è un assedio ma una battaglia):
[b]Hai lì delle truppe di terra[/b] (appena sbarcate o di guarnigione): battaglia di terra contro 10 Opliti, sette dei quali spartani (+2). La perdi: -15.
[b]Hai lì la tua Armata di sole navi[/b], arrivata in questo turno: battaglia nulla fra due Armate, torna a casa quella nemica dello spazio, cioè la tua. Nessun punto perso, ma nessun assedio.
[b]Hai lì una guarnigione di sole navi senza comandante[/b], rimasta da un turno precedente: battaglia nulla fra un'Armata e una Forza senza comandante nello stesso spazio non neutrale. La regola 6.2.2 manda Verso Casa [b]l'Armata[/b]: gli Spartani se ne vanno e la tua nave resta. Rischia solo la schermaglia dell'intercettazione (perde l'SP con un 1).
Ma c'è il rovescio: Sparta deve avere [b]10 Opliti e 1 Cavalleria non ancora attivati[/b] e i talenti per gli Alleati. Se ha già speso i suoi Opliti (per esempio nell'invasione dell'Attica, che ne impegna 12), non può radunare la forza e [b]deve passare[/b]: ha finito il turno.
Quindi: [b]sbarca vicino a Sparta dopo che Sparta ha mosso il suo esercito, mai prima[/b]. Come prima operazione del turno, colpisci fuori dal raggio.

""" + t("Gli Iloti") + """I cinque spazi della Ribellione degli Iloti (Pilo, Asine, Corone, Prasie, Epidauro Limera) sono tutti dentro quel raggio e sono tutti fortezze. Se nella Fase di Diffusione della Ribellione sono tutti occupati da tue unità, Sparta perde 2 di Bellicosità [b]a ogni turno[/b], 2 Opliti e fino a 1000 talenti. A Sparta basta riprenderne [b]uno[/b] per fermare tutto.
Il modo che regge alle regole è questo: [b]prendili con Spedizioni di sole navi, quando Sparta non può più reagire in quel turno[/b] (ha già attivato i suoi Opliti o ha passato). Sono tutti e cinque spazi costieri: l'assedio riuscito lascia come guarnigione 1 SP Navale, e contro una guarnigione di sole navi la Spedizione difensiva spartana, che è fatta di soli Opliti e Cavalleria, ottiene una battaglia nulla e torna a casa. Per sloggiarla servono navi spartane, che la Strategia Difensiva non porta.
Una guarnigione di Opliti, invece, nel raggio di Sparta è un -15 annunciato: non lasciare truppe di terra lì.
Costa: cinque assedi, cioè cinque operazioni riuscite in due o tre turni, con 3 navi ciascuna (1200 talenti). Ma ogni assedio riuscito sono +10 punti e 300 talenti, e quando il quinto cade Sparta comincia a perdere 2 punti di Bellicosità a turno.
Se comandi Sparta, ricordalo al contrario: Atene guidata dal gioco, appena quattro dei cinque spazi le sono amici, punta automaticamente sul quinto.

""" + t("Difendere ciò che conta") + """[b]La rotta del grano.[/b] Finché Atene traccia un percorso libero fino a Bisanzio non può cadere per assedio e non perde 1500 talenti. La strategia spartana "Tagliare LOC" punta proprio lì (Tracia, Ellesponto) con forze minuscole: 2 Opliti, o 2 Opliti e 2 navi. Una squadra di 3 navi e 3 Opliti lasciata nell'Ellesponto le copre con la ZOI: intercetta, e in combattimento attacca chiunque arrivi.
[b]L'Attica.[/b] Non difendere Atene in campo aperto: con le Lunghe Mura l'assedio spartano fallisce da solo e costa SCI a Sparta. Tieni ad Atene meno SP di terra di quanti ne porta l'invasore (di solito 14), così l'intercettazione non diventa battaglia.
[b]Le ribellioni.[/b] Si sedano con la ZOI: una squadra navale a Samo o a Chio copre mezza Ionia. Chiudi i turni con SCI almeno +1 quando puoi permetterti il rischio di cambiare parte.
[b]Siracusa.[/b] Non dichiararla obiettivo senza un motivo: entra in guerra con Sparta, le porta 500 talenti a turno, e assediarla costa -2 al dado."""})

	p.append({"parte": parte, "titolo": "S5. Comandare Sparta",
	"scena": {"centro": "Platea", "zoom": 0.85, "cerchi": ["Platea", "Decelea", "Panactum", "Larisa", "Naupactus"]},
	"testo": t("I tuoi punti di forza") + """La terra. Opliti e Cavalleria spartani si attivano gratis; con metà Opliti spartani hai +2 in ogni battaglia di terra; Brasida, Lisandro e Gilippo hanno Valore Tattico 2. Dodici Opliti con Brasida battono qualunque cosa Atene possa mettere in campo.

""" + t("I tuoi limiti") + """2500 talenti di entrate, che l'incursione ateniese riduce ogni turno. Gli Alleati (Corinto, Tebe) costano 200 l'uno. La flotta è di soli Alleati: niente +2, contro il +2 ateniese. Tutto ciò che è al di là del mare ti è quasi precluso finché non costruisci navi.

""" + t("Non assediare Atene") + """Con la rotta del grano aperta l'assedio di Atene (o del Pireo) [b]fallisce automaticamente[/b]: -2 SCI per te. Se comandi Sparta, in Attica i bersagli sono altri, cerchiati nell'immagine:
[b]Decelea e Panatto[/b]: fortezze di solito vuote. Assedio con probabilità piena, +10 l'una, saccheggio che toglie l'Eisphora ad Atene (se la comanda il gioco non la riceve comunque) e una guarnigione a Decelea fa cadere il Fondo di Emergenza ateniese.
[b]Platea[/b]: fortezza verde in mezzo alla Beozia, a un passo da Tebe.
Arrivando in Attica entri nella ZOI della Cavalleria di Atene: metti nella Spedizione abbastanza Opliti da non temere la battaglia (con 12 Opliti di cui 7 spartani contro 6 Ateniesi parti da +8).

""" + t("La guerra di terra contro gli Alleati di Atene") + """[b]Tessaglia e Macedonia[/b]: Larissa (5 Cavalleria e 2 Opliti Alleati) è uno spazio di coalizione ateniese raggiungibile a piedi. È una battaglia vera: la Cavalleria nemica ti toglie il +1 e riduce le sue perdite, ma con 8-10 Opliti spartani vinci di larga misura.
[b]La via di Brasida[/b]: Eraclea, Tessaglia, Macedonia, Pella, e da lì Anfipoli, Olinto, Potidea, Stagira. Fortezze verdi lontane dalla flotta ateniese, a un passo dalla rotta del grano. Ricorda che Anfipoli si attraversa solo se la controlli o se è l'obiettivo.
[b]L'Acarnania e Naupatto[/b]: Naupatto ospita una nave ateniese ed è la chiave del Golfo di Corinto; è raggiungibile per terra dall'Etolia.

""" + t("Il mare, più tardi") + """Per tagliare la rotta del grano servono navi: Bisanzio, Abido, Lampsaco, Sigeo. Le navi Alleate si costruiscono a 200 talenti (3 SP a turno) e nascono a Corinto; dall'Istmo escono nell'Egeo solo se controlli sia Corinto sia Cencree. Con "La Persia entra in guerra" arrivano 500 talenti a turno, 1000 se prendi Iaso. Evita la battaglia navale contro navi ateniesi a meno di essere almeno 4 SP in più: loro hanno +2 e comandanti migliori.

""" + t("Difenderti") + """[b]Gli Iloti.[/b] Non lasciare che tutti e cinque gli spazi siano occupati: basta che tu ne controlli uno. Un Oplita spartano di guarnigione a Gizio o a Corone costa zero talenti.
[b]L'incursione navale.[/b] Non puoi fermarla (flotta contro truppe: battaglia nulla), ma puoi negarle gli assedi: 1 SP di terra in una fortezza costiera toglie a una Spedizione di 3 navi il diritto all'assedio (non ha 5 SP in più) e la costringe a una battaglia nulla in cui, essendo un'Armata contro una Forza senza comandante, è lei a tornare a casa.
[b]Le guarnigioni navali nemiche.[/b] Vale anche al contrario: una nave ateniese rimasta in una tua fortezza costiera non la scacci con un'Armata di soli Opliti (battaglia nulla, torni a casa tu). Porta almeno 1 SP Navale nella Spedizione: così è battaglia navale, e se la vinci con più Opliti segue quella di terra.
[b]Gli ostaggi.[/b] Se Atene elimina un tuo Oplita spartano in una battaglia di terra, non potrai più puntare su Atene, Decelea, Panatto e Pireo fino all'armistizio. Tieni sempre degli Alleati nella Spedizione: le perdite cadono prima su di loro.

""" + t("Causare Ribellione") + """Per te riesce una volta su sei. Usala solo come operazione in più, contro spazi verdi lontani e senza flotta ateniese vicina, dove la ribellione possa poi diffondersi da sola."""})

	p.append({"parte": parte, "titolo": "S6. Battere la Matrice",
	"testo": """La parte non-giocatore è prevedibile in tre cose: [b]che forza manda[/b], [b]dove può mandarla[/b], [b]che strada fa[/b]. Sfruttale.

""" + t("Le sue Spedizioni sono piccole") + """Tolti l'attacco allo spazio nazionale (12 o 15 Opliti) e la Strategia Difensiva (10 Opliti e 1 Cavalleria per Sparta, 3 e 3 per Atene), il non-giocatore manda da 2 a 8 SP. Contro una fortezza: se è vuota la assedia; se ci sono difensori deve avere 5 SP più di loro, altrimenti è [b]battaglia[/b]. Una guarnigione di soli 3 Opliti nega l'assedio a una Spedizione da 4, ma la battaglia la combatti con un Oplita in meno (e senza comandante). Servono difensori [b]almeno 2 Opliti più dell'attaccante[/b]: contro i 3 o 4 Opliti di "Attaccare Alleato" ne bastano 6, e la battaglia è tua: +10.

""" + t("Aspettalo con le ZOI") + """Nella Fase di Combattimento ogni tua Forza combatte contro le unità nemiche nella sua ZOI, [b]prima[/b] che gli assedi siano risolti. Una tua squadra navale con Opliti, ferma al centro di un'area che la sua matrice bersaglia, è una difesa di zona: intercetta la Spedizione all'arrivo e poi l'attacca mentre assedia. Se la batti, l'assedio non si risolve nemmeno.
Per Atene: Ellesponto (attorno a Lampsaco e Proconneso) e Ionia (Samo, Chio). Per Sparta: la Cavalleria a Tebe copre Platea, Tanagra, Delio, Cheronea; la flotta di Corinto copre il Golfo fino a Sife, Erineo e Panormo, e le truppe di Corinto intercettano automaticamente chi entra a Cencree.
Ricorda che una Forza senza comandante resta dov'è a fine turno: sono le Armate a tornare a casa. Le guarnigioni si costruiscono con i comandanti di Valore Strategico alto e con i nuovi SP, che nascono nelle basi.

""" + t("Fagli finire i soldi e le truppe") + """Il non-giocatore passa se non può radunare l'intera forza richiesta o pagarla. Atene guidata dal gioco deve tenere 1000 talenti; Sparta paga 200 per ogni Alleato. Un nemico che ha passato non fa più nulla per tutto il turno: tu continui da solo.
"Attaccare Sparta" chiede 15 Opliti e 4 Cavalleria: Atene quasi mai li ha, e passa subito. "Attaccare Atene" chiede 12 Opliti e 2 Cavalleria: dopo una battaglia persa Sparta non li ha più.

""" + t("Fallo difendere") + """La Strategia Difensiva ha la precedenza su tutto. Una tua Forza entro due spazi da Sparta, o a Corinto o a Tebe, costringe Sparta a mandare 10 Opliti e 1 Cavalleria lì, invece di seguire la sua strategia. Se in quello spazio la aspetta una battaglia che puoi vincere, o se le sue truppe migliori sono già state attivate, hai deciso tu la sua mossa.
Allo stesso modo una Forza spartana a Egina, Salamina, Calcide o Naupatto richiama 3 Opliti e 3 navi ateniesi: 1800 talenti che Atene non spende altrove.

""" + t("Leggi la sua strategia") + """A inizio turno il riepilogo ti dice quale strategia userà. "Tagliare LOC" spartano: proteggi Tracia ed Ellesponto. "Attaccare Alleato": guarda le sei aree della sua matrice in Tabelle. E ricorda che se il suo SCI è positivo la ripeterà il turno dopo.
Il comandante pescato sposta il dado: uno Spartano con Valore Strategico 2 (Brasida, Lisandro, Mindaro) non attaccherà mai l'Attica; con Archidamo (-1) lo farà due volte su sei.

""" + t("Gli ostaggi come scudo") + """Se vinci una battaglia di terra eliminando Opliti ateniesi o spartani, il non-giocatore perde la strategia di attacco al tuo spazio nazionale fino all'armistizio. Per Atene vuol dire Attica intatta, Eisphora ogni turno e niente Epidemia."""})

	p.append({"parte": parte, "titolo": "S7. Dieci regole e gli errori tipici",
	"testo": t("Dieci regole") + """1. [b]La prima operazione è l'unica garantita[/b]: mettici il colpo principale.
2. [b]Assedia con i tattici 2[/b] (Formione, Demostene, Trasibulo; Brasida, Lisandro, Gilippo). Con i tattici 0 rinforza, seda ribellioni, presidia.
3. [b]Cerca battaglia solo da +2 in su[/b], contando tutto: Opliti, +2 nazionale, Cavalleria, comandanti.
4. [b]Scegli l'obiettivo guardando la strada[/b]: è il percorso a decidere saccheggi e intercettazioni. Prima di premere Parti controlla le ZOI lungo la via.
5. [b]Componi la Spedizione pensando alla rotta[/b]: navi pari alle truppe per il mare aperto; niente navi per l'entroterra.
6. [b]Ogni guarnigione di 1 SP[/b] tiene il controllo, ferma il contagio delle ribellioni e nega l'assedio "gratis" alle Spedizioni piccole.
7. [b]Guarda lo SCI prima dell'ultima operazione[/b] e decidi se ti conviene salire o no.
8. [b]Conta gli spazi[/b] saccheggiati, in ribellione e catturati di ciascuna Lega: a 10 e a 20 scatta un punto di Bellicosità. Nove saccheggi non valgono dieci. Il conto è in Tabelle, scheda Entrate.
9. [b]Tieni 1000 talenti oltre il necessario[/b] per la costruzione: 3 SP nuovi a turno sono l'unica crescita possibile.
10. [b]Rileggi il Diario dopo il combattimento[/b]: ogni dado è spiegato, ed è il modo più rapido per fissare le regole.

""" + t("Errori tipici") + """[b]Attaccare Tebe o Corinto con forze pari.[/b] Sono spazi di coalizione pieni di Opliti e Cavalleria: è l'errore di Cleone nell'esempio, -15 e ostaggi.
[b]Radunare troppi Opliti ad Atene.[/b] Con tanti SP di terra quanti l'invasore, ogni intercettazione riuscita diventa battaglia, contro il +2 spartano.
[b]Mandare un comandante da solo attraverso ZOI nemiche[/b] per andare a prendere truppe lontane: metà delle volte l'operazione è annullata.
[b]Navi e Opliti in numero sbagliato.[/b] Quattro Opliti e tre navi non salpano: l'app te lo dice, ma l'operazione è già cominciata e il comandante è impegnato.
[b]Assediare con più navi nemiche in porto.[/b] Se gli assediati hanno più SP Navali di te l'assedio fallisce da solo.
[b]Dichiarare Siracusa o Argo obiettivo per distrazione[/b]: regali un alleato al nemico.
[b]Dimenticare che le Armate tornano a casa.[/b] Non puoi "tenere" un fronte: dopo il combattimento resta 1 SP. Pianifica ogni turno come un'incursione che parte da casa.
[b]Vincere troppo.[/b] Quattro vittorie nello stesso turno ti portano quasi di sicuro dall'altra parte, a comandare quello che resta.

""" + t("Per cominciare") + """Gioca la [b]Guerra Archidamica[/b]: tre turni bastano per vedere tutto. Al primo turno ripeti l'esempio del manuale (un'incursione navale con assedio, un secondo assedio con il comandante pescato) e leggi nel Diario come vengono risolti combattimento, ritorni ed entrate. Il pulsante [b]Suggerisci[/b] propone un obiettivo sensato quando non sai dove andare; le [b]Tabelle[/b] hanno matrici, eventi, ritorni ed entrate previste.

Buona guerra."""})
