# Warband Crafting & Economy Hub

**Ein Katalog über die ganze Warband: welcher Charakter kann was, und wo
liegt das Material dafür.**

*[English version](README.en.md)*

> Der Kern heißt im AddOns-Verzeichnis **WarbandForge**, der Slash-Befehl ist
> `/wf`. WoW verlangt, dass Ordner- und `.toc`-Name identisch sind, und
> verträgt darin weder `&` noch Klammern.

TSM ist für viele Gelegenheitsspieler zu überladen; einfache
Inventar-Addons bilden keine Berufslogik ab. Dieses Addon beantwortet
stattdessen genau zwei Fragen — und hört danach auf.

## Stand: Gerüst

**Dies ist noch kein fertiges Addon.** Es lädt, es stürzt nicht ab, es sagt
ehrlich, dass es noch nichts erfasst hat — und die Architektur trägt
(22 Logiktests, alle grün). Was gebaut ist und was nicht, steht in
[`Planung/`](Planung/).

| Steht | Fehlt |
|---|---|
| Kern lädt, Modulsystem trägt | Rezepte erfassen |
| Speicher (account-weit, mit Zeitstempeln) | Materialprüfung |
| Berufserfassung mit Wiederholung | Ansicht „Wer kann X?" |
| Drei Modul-Gerüste mit `## Dependencies` | Fachlogik der Module |
| `/wf`, `/wf doctor` | |

## Aufbau

Vier eigenständige Addons in einem Repository:

```
WarbandForge/                  Kern
WarbandForge_WorkOrders/       Modul – Work Orders
WarbandForge_Housing/          Modul – Housing
WarbandForge_PriceSync/        Modul – Preise
```

Jedes Modul trägt `## Dependencies: WarbandForge` und lässt sich **einzeln
abwählen**. Wer Preise nicht braucht, hat den Preis-Code nicht im Speicher.
Der Kern kennt kein Modul namentlich.

## Befehle

| Befehl | Wirkung |
|---|---|
| `/wf` | Fenster anzeigen oder verstecken |
| `/wf doctor` | Selbstdiagnose – bei Problemen zuerst |
| `/wf help` | alle Befehle |

## Was es *nicht* kann

- **Es sieht nur, was der Client weiß.** Was auf einem anderen Charakter
  liegt, weiß es, weil dieser Charakter es beim letzten Login hinterlegt
  hat — nicht, weil es nachschaut. Ein Twink, der seit Wochen nicht
  gespielt wurde, hat den Stand von vor Wochen. Deshalb steht an jeder
  Angabe, wann sie erhoben wurde.
- **Die Guild Bank sieht es nur, wenn sie offen war.** WoW liefert deren
  Inhalt nicht im Hintergrund.
- **Es kauft nichts und stellt nichts her.** Beides sind geschützte Abläufe.
- **Es scannt das Auction House nicht.** Das Preis-Modul liest ein
  vorhandenes Preis-Addon; ist keines da, meldet es sich ab.

## Entwickeln

```bash
tools/junction.cmd    # verbindet alle Addon-Ordner mit dem AddOns-Verzeichnis
./tools/test.sh       # Syntax, .toc-Abgleich und Logiktests (baut sich Lua 5.1)
```

## Lizenz

MIT, siehe [LICENSE](LICENSE).
