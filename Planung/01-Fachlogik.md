# Fachlogik des Kerns

Reihenfolge ist bewusst gewählt: Jeder Schritt ist für sich nützlich, und
keiner setzt einen späteren voraus.

## Schritt 1 — Katalog der Charaktere *(Grundstein, teilweise gebaut)*

**Ziel:** Beim Login schreibt jeder Charakter seinen eigenen Abschnitt.

Gebaut ist die Erfassung der Berufe (`Core.lua` → `erfassen()`), samt der
Wiederholung: Direkt nach dem Login liefert `GetProfessions()` noch nichts,
und wer ohne Abstand erfasst, überschreibt einen richtigen Stand mit einem
leeren. Deshalb wird bis zu viermal in Abständen versucht.

**Noch zu bauen:**

| Was | Woher | Bemerkung |
|---|---|---|
| Gelernte Rezepte | `C_TradeSkillUI.GetAllRecipeIDs()` | Nur verfügbar, während das Berufsfenster offen war. Deshalb: bei `TRADE_SKILL_SHOW` erfassen, nicht beim Login. |
| Fertigkeitsstand | `GetProfessionInfo` | Steht bereits zur Verfügung. |
| Wissenspunkte | `C_ProfSpecs` | Ungeprüft, ob offen abfragbar. **Vor der Umsetzung testen.** |
| Abklingzeiten | `C_TradeSkillUI.GetRecipeCooldown` | Transmutationen, wöchentliche Aufträge. |
| Taschen und Bank | `C_Item.GetItemCount(id, true, false, true, true)` | Kriegsmeuten-Bank ist im letzten Parameter enthalten. |

**Fallstrick, der eingeplant gehört:** Rezeptlisten sind lang. Alle IDs für
alle Charaktere roh zu speichern, lässt die `SavedVariables` schnell auf
mehrere Megabyte wachsen — und die wird bei **jedem** Ausloggen vollständig
geschrieben. Gespeichert wird deshalb je Charakter und Beruf eine sortierte
Liste, keine verschachtelten Tabellen mit Zusatzangaben je Rezept.

## Schritt 2 — Materialprüfung

**Leitfrage:** *Kann ich das herstellen, und wenn nein — was fehlt und wo
liegt es?*

Gerechnet wird gegen die Summe aus:

1. Taschen und Bank des **eingeloggten** Charakters (live abfragbar),
2. Kriegsmeuten-Bank (live, sofern der Client sie zwischengespeichert hat),
3. dem, was **andere** Charaktere beim letzten Login hinterlegt haben,
4. der Gildenbank — **nur wenn sie in dieser Sitzung offen war**.

Punkt 3 und 4 sind ausdrücklich als *Stand von damals* zu kennzeichnen. Eine
Zahl, die aussieht wie eine aktuelle, aber Wochen alt ist, ist schlimmer als
gar keine.

## Schritt 3 — „Wer kann X?"

Umkehrung des Katalogs: Rezept eingeben, Antwort ist die Liste der eigenen
Charaktere, die es können — sortiert nach dem, was am wenigsten fehlt.

Diese Ansicht ist der eigentliche Alltagsnutzen. Sie ist billig zu bauen,
sobald Schritt 1 und 2 stehen.

## Schritt 4 — Oberfläche

Das gebaute Fenster (`UI/Fenster.lua`) ist bewusst schlicht und ohne
Fremdbibliothek. Wächst der Inhalt über eine Textfläche hinaus, ist das der
Zeitpunkt für AceGUI — **dann**, nicht vorher: Eine Bibliothek, die man
nicht braucht, ist trotzdem Quelltext, den man ausliefert.

Reiter der Module kommen aus dem `Reiter`-Haken. Der Kern nennt kein Modul
beim Namen.
