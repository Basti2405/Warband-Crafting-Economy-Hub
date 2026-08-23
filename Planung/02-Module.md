# Module

Jedes Modul ist ein eigener Addon-Ordner mit `## Dependencies: WarbandForge`.
Das Gerüst steht jeweils: Anmeldung, `Pruefen()`, `Start()`, `Kennzahl()`.
Was fehlt, ist die Fachlogik — und die steht hier.

---

## WorkOrders — Handwerksaufträge

**Zweck.** Eine Übersicht über Gilden- und persönliche Aufträge, mit
Materialdefizit und daraus abgeleiteter Einkaufsliste.

**Datenquelle.** `C_CraftingOrders`. Die Abfrage ist **asynchron und
seitenweise**: Man fordert an, das Ergebnis kommt per Ereignis
(`CRAFTINGORDERS_UPDATE_ORDER_COUNT`, `CRAFTINGORDERS_SHOW_CUSTOMER`), und
mehr als eine Seite bekommt man nur mit einer weiteren Anfrage.

**Fallstricke:**

- Aufträge sind **nur am Auftragstisch** abfragbar, nicht von unterwegs.
  Das Modul zeigt also immer den Stand des letzten Besuchs — und muss das
  auch so beschriften.
- Wer bei jedem Besuch alle Seiten durchblättert, erzeugt viele Anfragen.
  Ein Durchlauf je Besuch reicht.

**Was es nicht tun wird.** Aufträge annehmen oder herstellen. Beides ist ein
geschützter Ablauf.

**Aufwand:** mittel. Der Löwenanteil ist der Umgang mit den Ereignissen,
nicht die Rechnung.

---

## Housing — Einrichtung

**Zweck.** Tracker für Einrichtungsgegenstände: welche Rezepte sind bekannt,
welche Rohstoffe fehlen, was steht schon.

**Datenquelle.** `C_Housing` (mit Midnight gekommen).

**Der ehrliche Stand:** Diese Schnittstellen sind zum Zeitpunkt der Planung
noch in Bewegung. Deshalb prüft das Modul besonders vorsichtig und meldet
sich lieber ab, als auf gut Glück aufzurufen.

**Erster Schritt vor dem Bau:** Im laufenden Client nachsehen, was
`C_Housing` tatsächlich hergibt. Erst danach lässt sich sagen, ob dieses
Modul in der geplanten Form überhaupt gebaut werden kann. **Diese Prüfung
steht noch aus.**

**Aufwand:** unbekannt, bis die Prüfung gelaufen ist. Nicht einplanen, als
wäre er klein.

---

## PriceSync — Preise und Rentabilität

**Zweck.** Zu jedem Rezept: Was kosten die Materialien, was bringt das
Ergebnis, bleibt etwas übrig.

**Datenquelle.** Ein **vorhandenes** Preis-Addon. Unterstützt sind
TradeSkillMaster (`TSM_API.GetCustomPriceValue`) und Auctionator
(`Auctionator.API.v1`); die Reihenfolge steht im Modul.

**Was es ausdrücklich nicht tut: selbst scannen.** Ein eigener Scanner wäre
ein eigenes Programm — mit eigenem Speicherbedarf, eigener Wartung und einer
zweiten Preisdatenbank neben der, die der Spieler ohnehin hat. Ist kein
Preis-Addon da, meldet sich das Modul ab. Das ist bereits so gebaut.

**Fallstricke:**

- Preise sind **Marktwerte, keine Zusagen**. Die Oberfläche muss das
  benennen, sonst liest jemand eine Gewinnzusage heraus.
- Für ein Rezept mit vielen Materialien fällt je Material eine Abfrage an.
  Bei einer ganzen Liste ist das viel — Ergebnisse innerhalb einer Sitzung
  zwischenspeichern.
- Ruf-, Qualitäts- und Auftragsstufen ändern den tatsächlichen Ertrag. Der
  erste Bau rechnet **ohne** sie und sagt das dazu.

**Aufwand:** klein bis mittel — die fremde Schnittstelle nimmt einem die
Arbeit ab.

---

## Ein viertes Modul?

Bewusst **nicht** eingeplant, aber notiert: eine Anbindung an die
Gildenseite (`happy-accident-wow.de`). Sie wäre kein WoW-Problem, sondern
eine Frage der Ausfuhr — und die gehört, wenn überhaupt, in den Kern, nicht
in ein viertes Modul. Siehe dazu die Ausfuhr in *Guild Ops*, wo dasselbe
Thema bereits gelöst ist.
