# Änderungen

## 0.1.0 – Gerüst

Erste Fassung. **Noch kein fertiges Addon**: Der Aufbau steht und trägt, die
Fachlogik ist in `Planung/` beschrieben und größtenteils noch zu bauen.

- **Kern (WarbandForge).** Lädt, zieht den account-weiten Speicher auf und stellt
  das Modulsystem bereit.
- **Modulsystem.** Module sind eigene Addons mit `## Dependencies: WarbandForge`
  und einzeln abwählbar. Der Kern kennt kein Modul namentlich; ein Modul,
  das seine Voraussetzung nicht findet oder in einem Haken wirft, wird
  stillgelegt, statt den Kern mitzureißen.
- **Selbstdiagnose** über `doctor`: Speicherstand, Module und deren Gründe.
- **22 Logiktests**, lauffähig ohne WoW über `tools/test.sh` (prüft
  zusätzlich Syntax und den Abgleich der `.toc` gegen die Dateien).
- **Werkzeuge.** `tools/junction.cmd` verbindet alle Addon-Ordner des
  Repositories mit dem AddOns-Verzeichnis.
