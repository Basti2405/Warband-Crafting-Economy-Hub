# Fahrplan

## Was heute steht

- Kern lädt, Modulsystem trägt, Speicher zieht sich auf.
- Drei Modul-Addons melden sich an, prüfen ihre Voraussetzung und melden
  sich still ab, wenn sie fehlt.
- Berufserfassung mit Wiederholung (der Login-Fallstrick ist eingebaut).
- `/wf`, `/wf doctor`.
- **22 Logiktests, alle grün** (`tools/test.sh`).

Das ist ein Gerüst, kein fertiges Addon. Es lädt, es stürzt nicht ab, und es
sagt ehrlich, dass es noch nichts erfasst hat.

## Reihenfolge

| # | Schritt | Warum diese Stelle |
|---|---|---|
| 1 | Rezepte erfassen (`TRADE_SKILL_SHOW`) | Ohne Rezepte ist der Katalog leer, und alles Weitere hat keine Grundlage. |
| 2 | Bestand erfassen | Zweite Hälfte der Leitfrage. |
| 3 | Ansicht „Wer kann X?" | Erster echter Alltagsnutzen. Billig, sobald 1 und 2 stehen. |
| 4 | Materialdefizit | Baut auf 2 auf. |
| 5 | Modul PriceSync | Kleinster Modul-Aufwand, sichtbarster Effekt. |
| 6 | Modul WorkOrders | Aufwendiger wegen der Ereignisse. |
| 7 | Modul Housing | **Erst nach der Prüfung**, ob `C_Housing` das hergibt. |

## Offene Fragen — vor dem Bau zu klären

1. **Wissenspunkte.** Ist `C_ProfSpecs` offen abfragbar, oder nur im
   Spezialisierungsfenster? Entscheidet, ob dieser Punkt aus dem Katalog
   fliegt.
2. **`C_Housing`.** Was gibt es tatsächlich her? Entscheidet über die
   Existenz eines ganzen Moduls.
3. **Größe der gespeicherten Datei.** Ab wie vielen Charakteren wird das
   Speichern beim Ausloggen spürbar? Vor Schritt 1 mit einem realistischen
   Datensatz messen, nicht schätzen.

Punkt 3 ist der, der am ehesten unterschätzt wird: Die `SavedVariables`
werden bei **jedem** Ausloggen vollständig geschrieben.

## Was gegen einen zu großen Wurf spricht

TSM ist für viele zu überladen — das war der Ausgangspunkt. Wer dieses Addon
Schritt für Schritt um alles erweitert, was TSM kann, landet bei einem
zweiten TSM. Die Grenze ist deshalb bewusst gezogen: **Katalog und
Materialfrage im Kern, alles Weitere als Modul, das man weglassen kann.**
