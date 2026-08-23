# Architektur

## Warum überhaupt getrennte Addons

Der Kern beantwortet **eine** Frage: *Was kann welcher meiner Charaktere, und
wo liegt das Material dafür?* Alles, was darüber hinausgeht — Aufträge,
Einrichtung, Preise —, ist ein eigenes Programm mit eigener Datenquelle und
eigenem Risiko. Wer Preise nicht braucht, soll den Preis-Code nicht im
Speicher haben.

Deshalb liegt hier nicht ein Addon mit Schaltern, sondern **vier Addons**:

```
WarbandForge/                  Kern  – Katalog, Speicher, Modulsystem, Fenster
WarbandForge_WorkOrders/       Modul – Handwerksaufträge
WarbandForge_Housing/          Modul – Einrichtung
WarbandForge_PriceSync/        Modul – Preise und Rentabilität
```

Jedes Modul trägt in seiner `.toc` die Zeile

```
## Dependencies: WarbandForge
```

Das hat zwei Wirkungen, und beide sind gewollt:

1. **Ohne Kern lädt das Modul nicht** — und WoW sagt dem Spieler auch, warum.
   Ein Modul ohne seinen Kern hätte keine Daten und stünde mit halbem
   Gesicht da.
2. **WoW lädt Abhängigkeiten zuerst.** Wenn ein Modul läuft, steht der Kern
   garantiert. Darauf verlässt sich das Modulsystem.

## Wie ein Modul andockt

Der Kern kennt **kein einziges Modul namentlich**. Er ruft nur Haken auf; wer
sich angemeldet hat, wird gefragt.

```lua
local Modul = WarbandForge.Module.Registrieren("WorkOrders", {})

function Modul:Pruefen()   -- Voraussetzung da? true / false, Grund
function Modul:Start()     -- einmal beim Login, nachdem Pruefen zusagte
function Modul:Kennzahl()  -- eine Zeile für die Übersicht
function Modul:Ausfuhr()   -- was in eine Datenausgabe einfließt
```

`Pruefen()` wird **genau einmal** ausgewertet. Fällt ein Modul durch, meldet
es sich still ab und taucht nur in `/wf doctor` mit seinem Grund auf. Ein
fehlendes Fremdaddon ist eine Zeile in der Diagnose, keine Fehlermeldung im
Chat.

Wirft ein Modul in einem Haken, wird **es** stillgelegt — nicht der Kern.
Das ist getestet (`Tests/logik-test.lua`).

## Der globale Namensraum — und warum er hier nötig ist

Bei einem Addon aus einem einzigen Ordner bekommt jede Datei die
Addon-Tabelle von WoW über `...` mitgeliefert. Getrennte Addons bekommen
**getrennte** Tabellen — ein Modul käme an eine addon-lokale Tabelle des
Kerns nicht heran.

Deshalb legt `Logik/Kompat.lua` den Namensraum als `_G.WarbandForge` an, und
zwar **als erste Datei der `.toc`, noch vor den Sprachdateien**. Diese
Reihenfolge ist kein Geschmack: Steht `Kompat` später, läuft die erste
Sprachdatei in ein `nil`. Genau das ist beim Bau einmal passiert und wurde
vom Logiktest gefunden.

## Speicher

Ein einziger, **account-weiter** Speicher (`WarbandForgeDB`). Ein Katalog,
der nur den eingeloggten Charakter kennt, kann die Leitfrage nicht
beantworten.

Module bekommen darin eine **Schublade** (`Speicher.ModulSchublade(name)`)
statt einer eigenen `SavedVariables`-Datei — sonst hätte der Spieler zwei
Dateien, die getrennt beschädigt werden und auseinanderlaufen können.

Jeder Charakterabschnitt trägt einen Zeitstempel. Ein Charakter, der lange
nicht eingeloggt war, hat veraltete Angaben; die Oberfläche zeigt das an,
statt einen alten Stand als Tatsache auszugeben.

## Was der Kern grundsätzlich nicht kann

Ehrlichkeit an dieser Stelle ist wichtiger als eine vollständig aussehende
Funktionsliste:

- **Er sieht nur, was der Client weiß.** Was auf einem anderen Charakter
  liegt, weiß er, weil dieser Charakter es beim letzten Login hinterlegt
  hat — nicht, weil er es gerade nachschaut. Wer einen Twink seit Wochen
  nicht gespielt hat, bekommt dessen Stand von vor Wochen.
- **Die Gildenbank ist nur zu sehen, wenn sie offen war.** WoW liefert
  Gildenbankinhalte nicht im Hintergrund.
- **Er kauft nichts und stellt nichts her.** Handeln im Auktionshaus und
  Herstellen sind geschützte Abläufe.

Diese drei Punkte gehören in die README, damit niemand etwas erwartet, das
technisch nicht geht.
