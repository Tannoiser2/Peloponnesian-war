# Peloponnesian War - versione digitale

Versione digitale, per uso personale, di **Peloponnesian War** di Mark Herman (GMT Games, 2019): la guerra fra Atene e
Sparta, 431-404 a.C. È un solitario: comandi una delle due leghe mentre il gioco guida l'altra con la sua matrice delle
strategie, e a inizio turno la sorte può farti cambiare schieramento.

Si gioca qui: https://tannoiser2.github.io/Peloponnesian-war/

## Che cosa c'è

- **Campagna** (10 turni) e **Guerra archidamica** (3 turni), le due partite del regolamento.
- Tutte le fasi del turno: politica (cambio di schieramento, eventi, rivolta nella Lega delio-attica, condottieri),
  strategia del lato guidato dal gioco, operazioni con auspici, raduno delle truppe, percorsi più brevi,
  intercettazioni, scaramucce e battaglie, devastazioni, fomentare la rivolta; combattimento con assedi, Lunghe Mura,
  battaglie nelle zone d'influenza e ritorno a casa; rivolte e iloti; entrate e costruzioni; bellicosità, resa e tregua.
- Strategia difensiva e matrici di Atene e di Sparta, tabella degli eventi, tabella dei ritorni, potenze minori
  (Argo, Siracusa, Macedonia, Persia), Alcibiade, ostaggi, Guardia di Sparta.
- Errata ufficiali e chiarimenti della comunità (luglio 2020) applicati.
- Mappa e pedine originali del modulo di Tabletop Simulator; interfaccia, regole in breve, tabelle e diario in italiano,
  con i termini dell'edizione italiana del regolamento (Lega di Delo, comandanti, SP, ZOI, SCI, Saccheggio,
  Schermaglia, Verso Casa, Armistizio).
- **Tutorial passo passo** (menu e barra in alto), 34 pagine: il regolamento in ordine con le situazioni mostrate
  sulla mappa, l'Esempio di Gioco del Manuale del Giocatore rivissuto mossa per mossa, e le strategie (conti della
  vittoria, probabilità, SCI e cambio di parte, Atene, Sparta, come battere la Matrice).
- Mappa da spostare e ingrandire con mouse, rotella e tocco (un dito trascina, due dita pizzicano), anche su iPad.
- Salvataggio automatico sul dispositivo e su Firebase (radice `peloponnesianwar/partite`, coperta dalla regola comune
  della ludoteca): con il codice di 6 caratteri la partita si riprende da un altro dispositivo.

## Scelte di questa versione

- I punti forza sono contati per tipo e nazionalità; il limite delle pedine vale come tetto ai punti in gioco.
- Le perdite colpiscono prima gli alleati, poi le truppe ateniesi o spartane, per ultima la Guardia di Sparta.
- Il giocatore raduna la spedizione toccando gli spazi amici uno dopo l'altro: il condottiero li raggiunge per la via
  più breve, con le intercettazioni del caso, e paga l'attivazione sul posto.
- Per ora ci sono la Campagna e la Guerra Archidamica. Gli altri scenari del Manuale del Giocatore (Guerra Deceleica,
  Caduta di Atene, Prima Guerra del Peloponneso; la Caduta di Sparta è solo per due giocatori) non sono ancora compresi.
- Dove l'Esempio di Gioco del manuale e la mappa non coincidono, vale la mappa: Pteleo-Eraclea è una LOC di sola Terra,
  e da Sparta a Corinto e da Atene a Chio esiste un percorso equivalente in più.
- Gli SP che contano per trasformare una schermaglia in battaglia si contano prima delle perdite della schermaglia,
  come nell'esempio del manuale.

## Sviluppo

Godot 4.7, GDScript, renderer `gl_compatibility`, esportazione web.

```
scripts/dati.gd       dati fissi: condottieri, matrici, tabelle
scripts/partita.gd    motore delle regole (stato in un solo dizionario, salvabile in JSON)
scripts/bot.gd        giocatore automatico per le prove e per "Suggerisci"
scripts/mappa.gd      mappa con spostamento e zoom, pedine e segnalini
scripts/main.gd       interfaccia
scripts/net.gd        salvataggi su Firebase
scripts/aiuto.gd      regole in breve e tabelle
scripts/tutorial.gd   tutorial passo passo: regolamento, esempio di gioco, strategie
data/spazi.json       193 spazi con posizione, tipo, colore, fortezza e collegamenti
tools/estrazione/     preparazione di mappa, pedine e dati dal modulo TTS
```

Prove:

```
godot --headless --path . -s tests/compila.gd
godot --headless --path . -s tests/regole.gd
godot --headless --path . -s tests/partite_auto.gd -- 60
python3 tools/controlla_glifi.py
PW_AVVIO=gioco xvfb-run -a godot --path . --script res://tests/screenshot.gd
```

## Pubblicazione

Il workflow `.github/workflows/pages.yml` non parte a ogni modifica: si avvia a mano (Actions, Pubblica, Run workflow)
oppure con un commit che nel messaggio contiene `[pubblica]`. Pubblica su GitHub Pages e, se nel repository ci sono i
segreti `CLOUDFLARE_API_TOKEN` e `CLOUDFLARE_ACCOUNT_ID`, anche sulla ludoteca privata di Cloudflare.

Mappa, pedine e regole sono di GMT Games e di Mark Herman; i font Cinzel, Cinzel Decorative ed EB Garamond sono
distribuiti con licenza OFL.
