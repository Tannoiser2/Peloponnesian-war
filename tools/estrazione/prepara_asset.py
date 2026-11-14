#!/usr/bin/env python3
"""Prepara gli asset del gioco partendo dal modulo di Tabletop Simulator.

Uso: python3 tools/estrazione/prepara_asset.py <cartella del modulo estratto> 
(la cartella che contiene Mods/Images e Mods/Workshop). Scrive assets/mappa, assets/pedine e data/spazi.json.
Il grafo dei collegamenti sta in tools/estrazione/grafo.txt (nome|colore|tipo|fortezza|collegamenti).
"""
import glob, json, os, re, sys
from PIL import Image, ImageDraw, ImageFont

SRC = sys.argv[1]
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
IMG = {re.sub(r'\.\w+$', '', os.path.basename(f)): f for f in glob.glob(SRC + '/Mods/Images/*')}
J = json.load(open(glob.glob(SRC + '/Mods/Workshop/*.json')[0]))
def locale(url): return IMG.get(re.sub(r'[^A-Za-z0-9]', '', url))

# ---------------------------------------------------------------- pedine del modulo
tessere = {}
mappa_obj = None
def visita(o, madre=None):
    global mappa_obj
    if o['Name'] == 'Custom_Tile':
        ci = o['CustomImage']
        n = o.get('Nickname') or 'x'
        if n == 'Map': mappa_obj = o
        tessere.setdefault(n, (locale(ci['ImageURL']), locale(ci.get('ImageSecondaryURL', '')) if ci.get('ImageSecondaryURL') else None))
    for x in o.get('ContainedObjects', []) or []:
        visita(x, o.get('Nickname'))
for o in J['ObjectStates']: visita(o)

# ---------------------------------------------------------------- mappa
mappa = Image.open(tessere['Map'][0]).convert('RGB')
W, H = mappa.size
os.makedirs(R + '/assets/mappa', exist_ok=True)
mappa.save(R + '/assets/mappa/mappa.webp', quality=86, method=6)

# ---------------------------------------------------------------- spazi
ALIAS = {'Amphilocia': 'Amphilochia', 'Halicarnasus': 'Halicarnarsus', 'Kitnos': 'Kithnos', 'Lampascus': 'Lampsacus',
         'Panormus2': 'Panormus (Sicily)', 'Salamus': 'Salamis', 'Zachantus': 'Zacynthus', 'Epidaurus Limea': 'Epidaurus Limera',
         'Cape Tanearum': 'Cape Taenarum', 'Liparian Island': 'Liparian Is.', 'Athens': 'ATHENS', 'Sparta': 'SPARTA'}
pos = {}
for m in re.findall(r'(?:\["([^"]+)"\]|(\w+))\s*=\s*\{(-?[\d.]+),\s*[\d.]+,\s*(-?[\d.]+)\}', mappa_obj['LuaScript']):
    n = m[0] or m[1]
    if n in ('rotation', 'scale'): continue
    pos[ALIAS.get(n, n)] = [round(W / 2 - float(m[2]) * H / 2), round(H / 2 + float(m[3]) * H / 2)]
pos['Priene'] = [3719, 1750]          # manca nello script del modulo
pos['Euxine'] = pos.get('Euxine', [3780, 60])

ITA = dict(x.split('=') for x in '''Epidamnos=Epidamno|Macedonia=Macedonia|Pela=Pella|Sybota=Sibota|Ambracia=Ambracia|Idomene=Idomene|Olpae=Olpe|Amphilochia=Anfilochia|Dolopia=Dolopia|Pharsalus=Farsalo|Larisa=Larissa|Corcyra=Corcira|Methone=Metone|Pydna=Pidna|Magnesia=Magnesia|Potidaea=Potidea|Olynthus=Olinto|Stagirus=Stagira|Dium=Dion|Thyssus=Tisso|Torone=Torone|Scione=Scione|Amphipolis=Anfipoli|Thasos=Taso|Abdera=Abdera|Samothraki=Samotracia|Maraneia=Maronea|Cardia=Cardia|Perinthus=Perinto|Byzantium=Bisanzio|Proconneus=Proconneso|Cyzicus=Cizico|Lampsacus=Lampsaco|Abydos=Abido|Elaeus=Eleunte|Imbros=Imbro|Tenedos=Tenedo|Sigeum=Sigeo|Antandrus=Antandro|Mytilene=Mitilene|Arginusae=Arginuse|Cyme=Cuma|Methymna=Metimna|Phocaea=Focea|Smyrna=Smirne|Sardis=Sardi|Colophon=Colofone|Ephesus=Efeso|Clazomenae=Clazomene|Erythrae=Eritre|Pygela=Pigela|Priene=Priene|Teos=Teo|Miletus=Mileto|Samos=Samo|Iasus=Iaso|Halicarnarsus=Alicarnasso|Cnidus=Cnido|Loryma=Lorima|Lindus=Lindo|Camirus=Camiro|Chalce=Calce|Triopium=Triopio|Syme=Simi|Astipal=Astipalea|Kos=Coo|Kaliminos=Calimno|Leros=Lero|Patmos=Patmo|Limnos=Lemno|Sporades=Sporadi|Skiros=Sciro|Psara=Psara|Chios=Chio|Icaros=Icaria|Amorgos=Amorgo|Thera=Tera|Ios=Io|Lilybaeum=Lilibeo|Panormus (Sicily)=Palermo|Selinus=Selinunte|Gela=Gela|Acragas=Agrigento|Segesta=Segesta|Enna=Enna|Leontini=Leontini|Camarina=Camarina|Helorus=Eloro|Syracuse=Siracusa|Himera=Imera|Liparian Is.=Isole Lipari|Catana=Catania|Messina=Messina|Rhegium=Reggio|Locri=Locri|Taras=Taranto|Naxos=Nasso|Paros=Paro|Delos=Delo|Mikonos=Micono|Tinos=Teno|Andros=Andro|Siros=Siro|Sifnos=Sifno|Melos=Melo|Serifos=Serifo|Kithnos=Citno|Kea=Ceo|Carystos=Caristo|Eretria=Eretria|Marathon=Maratona|Sunium=Capo Sunio|Piraeus=Pireo|Salamis=Salamina|Aegina=Egina|Cythera=Citera|Idhra=Idra|Leucas=Leucade|Ithaca=Itaca|Cephallenia=Cefalonia|Zacynthus=Zacinto|Anactorium=Anattorio|Sollum=Sollio|Astacus=Astaco|Oeniadae=Eniade|Stratus=Strato|Aetolia=Etolia|Oeta=Eta|Aeniania=Eniania|Aegitium=Egizio|Amphisa=Anfissa|Delphi=Delfi|Cytinium=Citinio|Charonea=Cheronea|Thebes=Tebe|Tanagra=Tanagra|Platea=Platea|Olizon=Olizone|Pteleum=Pteleo|Heraclea=Eraclea|Siphae=Sife|Eupalium=Eupalio|Naupactus=Naupatto|Thermopylae=Termopili|Histiaea=Istiea|Atlante=Atalante|Chalcis=Calcide|Delium=Delio|Oropus=Oropo|Decelea=Decelea|ATHENS=Atene|Panactum=Panatto|Pegae=Pege|Megara=Megara|Corinth=Corinto|Sicyon=Sicione|Cenchrae=Cencree|Epidaurus=Epidauro|Methana=Metana|Cape Seyllaeum=Capo Scilleo|Troezen=Trezene|Hermione=Ermione|Prasiae=Prasie|Thyrea=Tirea|Cleonae=Cleone|Mycenae=Micene|Nemea=Nemea|Philius=Fliunte|Oronae=Ornee|Caryae=Carie|Tegea=Tegea|Orchomenus=Orcomeno|Elis=Elide|Olympia=Olimpia|Methydrum=Metidrio|Mantinea=Mantinea|Belmina=Belmina|SPARTA=Sparta|Gythium=Gizio|Epidaurus Limera=Epidauro Limera|Cape Taenarum=Capo Tenaro|Corone=Corone|Asine=Asine|Pylos=Pilo|Lepreum=Lepreo|Pheia=Fea|Cyllere=Cillene|Teichum=Tichio|Dyme=Dime|Patrae=Patrasso|Panormus=Panormo|Erineus=Erineo|Argos=Argo'''.split('|'))
ID = {'ATHENS': 'Athens', 'SPARTA': 'Sparta', 'Cyllere': 'Cyllene', 'Halicarnarsus': 'Halicarnassus', 'Panormus (Sicily)': 'Panormus Sicily'}
def ident(n): return ID.get(n, n)

G = {}
for riga in open(os.path.dirname(os.path.abspath(__file__)) + '/grafo.txt', encoding='utf-8'):
    if not riga.strip(): continue
    n, c, t, f, ls = riga.strip().split('|')
    G[n] = {'c': c, 't': t, 'f': int(f), 'l': dict(x.rsplit(':', 1) for x in ls.split(','))}
# correzioni verificate sulla mappa
G['Tenedos']['l'].pop('Limnos', None)
G['Segesta']['l']['Selinus'] = 'L'
G['Ephesus']['l']['Teos'] = 'C'; G['Teos']['l']['Ephesus'] = 'C'
G['Histiaea']['l']['Olizon'] = 'S'; G['Olizon']['l']['Histiaea'] = 'S'
for a in G:
    for b in list(G[a]['l']):
        k = G[a]['l'][b]
        if G[a]['t'] == 'L' or G[b]['t'] == 'L': k = 'L'     # uno spazio di terra non ha rotte navali
        G[a]['l'][b] = k; G[b]['l'][a] = k
spazi = {}
for n, d in G.items():
    assert n in pos, n
    assert n in ITA, n
    spazi[ident(n)] = {'nome': ITA[n], 'c': d['c'], 't': d['t'], 'f': d['f'], 'x': pos[n][0], 'y': pos[n][1],
                       'l': {ident(b): k for b, k in d['l'].items()}}
for a in spazi:
    for b, k in spazi[a]['l'].items():
        assert spazi[b]['l'][a] == k, (a, b)
os.makedirs(R + '/data', exist_ok=True)
json.dump({'larghezza': W, 'altezza': H, 'eusino': pos['Euxine'], 'spazi': spazi}, open(R + '/data/spazi.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(len(spazi), 'spazi,', sum(len(s['l']) for s in spazi.values()) // 2, 'collegamenti')

# ---------------------------------------------------------------- pedine
PD = R + '/assets/pedine'
os.makedirs(PD, exist_ok=True)
def apri(n, retro=False): return Image.open(tessere[n][1 if retro else 0]).convert('RGBA').resize((200, 200), Image.LANCZOS)
FIG = {'AH': ('Athenian Hoplite 1/2', (62, 4, 198, 198)), 'AC': ('Athenian Cavalry 1/2', (44, 4, 198, 198)), 'AN': ('Athenian Navy 1/2', (2, 34, 198, 132)),
       'aH': ('Athenian Ally Hoplite 1/2', (62, 4, 198, 198)), 'aC': ('Athenian Ally Cavalry 1/2', (44, 4, 198, 198)), 'aN': ('Athenian Ally Navy 1/2', (2, 34, 198, 132)),
       'SH': ('Spartan Hoplite 1/2', (62, 4, 198, 198)), 'SC': ('Spartan Cavalry 1/2', (62, 4, 198, 198)), 'SN': ('Spartan Navy 1/2', (2, 34, 198, 132)),
       'sH': ('Spartan Ally Hoplite 1/2', (62, 4, 198, 198)), 'sC': ('Spartan Ally Cavalry 1/2', (62, 4, 198, 198)), 'sN': ('Spartan Ally Navy 1/2', (2, 34, 198, 132))}
colori = {}
for k, (n, box) in FIG.items():
    im = apri(n)
    im.crop(box).save(f'{PD}/fig_{k}.png')
    colori[k] = '#%02x%02x%02x' % im.getpixel((6, 194))[:3]
json.dump(colori, open(R + '/data/colori_pedine.json', 'w'), indent=1)
CAPI = ['Pericles', 'Phormio', 'Archidamus', 'Thasyllus', 'Thrasybulus', 'Nicias', 'Alcibiades', 'Cleon', 'Demosthenes', 'Lysander', 'Pleistoanax', 'Agis', 'Brasidas', 'Mindaurus', 'Gylippus', 'Callicratades']
def capo(o, madre=None):
    if o['Name'] == 'Custom_Tile' and o.get('Nickname') in CAPI and (madre or o['Nickname'] in ('Pericles', 'Phormio', 'Archidamus')):
        f = locale(o['CustomImage']['ImageURL'])
        if o['Nickname'] in ('Pericles',) and abs(o['Transform']['posX']) > 30: return
        Image.open(f).convert('RGBA').resize((160, 160), Image.LANCZOS).save(f'{PD}/capo_{o["Nickname"].lower()}.png')
    for x in o.get('ContainedObjects', []) or []: capo(x, o.get('Nickname') or o['Name'])
for o in J['ObjectStates']: capo(o)

# segnalini con la scritta in italiano
F = lambda px: ImageFont.truetype(R + '/assets/font/Titoli.ttf', px)
def scritta(d, testo, cy, px, colore, larg=200):
    f = F(px)
    while d.textlength(testo, font=f) > larg - 14 and px > 10:
        px -= 1; f = F(px)
    d.text((100, cy), testo, font=f, fill=colore, anchor='mm')
r = apri('Rebellion'); d = ImageDraw.Draw(r)
for y in range(0, 92):        # copre la scritta inglese ricopiando le righe a strisce di sotto
    r.paste(r.crop((0, 100 + (y % 60), 200, 101 + (y % 60))), (0, y))
r2 = apri('Rebellion'); r.paste(r2.crop((0, 92, 200, 200)), (0, 92)); d = ImageDraw.Draw(r)
d.rectangle([0, 8, 200, 62], fill=(20, 20, 20, 255)); scritta(d, 'RIBELLIONE', 35, 34, 'white'); r.save(PD + '/rivolta.png')
v = apri('Ravaged'); n = Image.new('RGBA', (200, 200), (16, 12, 10, 255))
n.paste(v.crop((14, 14, 96, 96)), (10, 6)); n.paste(v.crop((104, 104, 190, 190)), (108, 108))
d = ImageDraw.Draw(n); scritta(d, 'SACCHEGGIATO', 104, 27, (255, 236, 200)); n.save(PD + '/devastato.png')
s = apri('Siege'); d = ImageDraw.Draw(s); d.rectangle([0, 0, 200, 58], fill=s.getpixel((6, 6))); scritta(d, 'ASSEDIO', 30, 34, (40, 28, 10)); s.save(PD + '/assedio.png')
o = apri('Operation Objective'); n = Image.new('RGBA', (200, 200), (250, 246, 232, 255)); n.paste(o.crop((40, 62, 160, 138)), (40, 76))
d = ImageDraw.Draw(n); scritta(d, 'OBIETTIVO', 40, 30, (120, 20, 20)); d.rectangle([3, 3, 196, 196], outline=(120, 20, 20), width=6); n.save(PD + '/obiettivo.png')
h = apri('Helot Rebellion'); n = Image.new('RGBA', (200, 200), (0, 0, 0, 0)); d = ImageDraw.Draw(n); d.rounded_rectangle([2, 2, 198, 198], 26, fill=(12, 12, 12, 255))
n.paste(h.crop((60, 60, 140, 140)), (60, 62)); d = ImageDraw.Draw(n); scritta(d, 'ILOTI', 34, 34, 'white'); scritta(d, 'IN RIBELLIONE', 168, 26, 'white'); n.save(PD + '/iloti.png')
for lato, nome in (('Athenian', 'ostaggi_A'), ('Spartan', 'ostaggi_S')):
    o = apri(lato + ' Hostages'); d = ImageDraw.Draw(o); d.rectangle([0, 0, 200, 78], fill=o.getpixel((6, 190))); scritta(d, 'OSTAGGI', 42, 32, 'black' if lato == 'Athenian' else 'white'); o.save(f'{PD}/{nome}.png')
apri('Game Turn').crop((62, 62, 140, 140)).save(PD + '/civetta.png')
for lato, nome in (('Athenian', 'elmo_A'), ('Spartan', 'elmo_S')):
    apri(lato + ' Strategy').crop((40, 76, 160, 196)).save(f'{PD}/{nome}.png')
# copertina per la ludoteca e icona
cop = Image.open(glob.glob(SRC + '/Mods/Workshop/*.png')[0]).convert('RGB')
print('copertina del modulo', cop.size)
cop.save(R + '/assets/ui/anteprima_modulo.png')
print('fatto')
