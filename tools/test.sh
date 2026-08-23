#!/usr/bin/env bash
#
# tools/test.sh - Syntaxpruefung und Logiktests, ohne WoW zu starten
#
# WoW laeuft auf Lua 5.1. Die meisten Systeme bringen 5.4 mit, und die beiden
# unterscheiden sich genug, dass ein Test unter 5.4 wenig aussagt. Darum holt
# und baut dieses Skript einmalig Lua 5.1 nach .werkzeuge/ - danach laeuft es
# ohne Netz.
#
# Dieses Repository enthaelt MEHRERE Addons: den Kern und je einen Ordner pro
# Modul. Geprueft wird alles, was eine .toc hat.
#
#   ./tools/test.sh            alles pruefen
#   ./tools/test.sh --syntax   nur Syntax
#
# Rueckgabe: 0 wenn alles bestanden, sonst 1.

set -euo pipefail

WURZEL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WERKZEUGE="$WURZEL/.werkzeuge"
LUA_VERSION="5.1.5"
LUA_DIR="$WERKZEUGE/lua-$LUA_VERSION"
LUA="$LUA_DIR/src/lua"
LUAC="$LUA_DIR/src/luac"

rot()   { printf '\033[31m%s\033[0m\n' "$*"; }
gruen() { printf '\033[32m%s\033[0m\n' "$*"; }
info()  { printf '\033[36m%s\033[0m\n' "$*"; }

# ---------------------------------------------------------------------------
# Lua 5.1 bereitstellen
# ---------------------------------------------------------------------------
if [ ! -x "$LUAC" ]; then
  info "Lua $LUA_VERSION wird einmalig nach .werkzeuge/ gebaut ..."
  mkdir -p "$WERKZEUGE"
  if [ ! -d "$LUA_DIR" ]; then
    curl -fsSL "https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz" \
      -o "$WERKZEUGE/lua.tar.gz"
    tar xzf "$WERKZEUGE/lua.tar.gz" -C "$WERKZEUGE"
  fi
  ( cd "$LUA_DIR" && make linux >/dev/null 2>&1 ) || ( cd "$LUA_DIR" && make posix >/dev/null 2>&1 )
  [ -x "$LUAC" ] || { rot "Lua liess sich nicht bauen."; exit 1; }
fi

# ---------------------------------------------------------------------------
# Alle Addon-Ordner dieses Repositories finden (alles mit einer .toc)
# ---------------------------------------------------------------------------
ADDONS=()
while IFS= read -r toc; do
  ADDONS+=("$(dirname "$toc")")
done < <(find "$WURZEL" -maxdepth 2 -name "*.toc" -not -path "*/.werkzeuge/*" | sort)

[ ${#ADDONS[@]} -gt 0 ] || { rot "Kein Addon-Ordner gefunden (keine .toc)."; exit 1; }

fehler=0

# ---------------------------------------------------------------------------
# 1. Syntax
# ---------------------------------------------------------------------------
info "Syntax"
for addon in "${ADDONS[@]}"; do
  while IFS= read -r datei; do
    if ! ausgabe=$("$LUAC" -p "$datei" 2>&1); then
      rot "  $datei"
      echo "     $ausgabe"
      fehler=$((fehler + 1))
    fi
  done < <(find "$addon" -name "*.lua" -not -path "*/Libs/*" | sort)
done
[ $fehler -eq 0 ] && gruen "  alle Dateien in Ordnung"

# ---------------------------------------------------------------------------
# 2. Stimmt die .toc mit den Dateien ueberein?
# ---------------------------------------------------------------------------
# Eine Datei, die in der .toc steht, aber fehlt, laedt WoW stillschweigend
# nicht - und der Fehler zeigt sich erst als "Funktion ist nil" an ganz
# anderer Stelle.
info ".toc gegen Dateien"
for addon in "${ADDONS[@]}"; do
  toc=$(find "$addon" -maxdepth 1 -name "*.toc" | head -1)
  while IFS= read -r zeile; do
    zeile="${zeile%$'\r'}"
    case "$zeile" in
      ""|"#"*) continue ;;
    esac
    pfad="${zeile//\\//}"
    if [ ! -f "$addon/$pfad" ]; then
      rot "  $(basename "$toc"): $zeile fehlt"
      fehler=$((fehler + 1))
    fi
  done < "$toc"
done
[ $fehler -eq 0 ] && gruen "  alle eingetragenen Dateien vorhanden"

if [ "${1:-}" = "--syntax" ]; then
  [ $fehler -eq 0 ] && { gruen "Bestanden."; exit 0; } || { rot "$fehler Fehler."; exit 1; }
fi

# ---------------------------------------------------------------------------
# 3. Logiktests
# ---------------------------------------------------------------------------
info "Logik"
gefunden=0
for addon in "${ADDONS[@]}"; do
  if [ -f "$addon/Tests/logik-test.lua" ]; then
    gefunden=1
    ( cd "$addon" && "$LUA" Tests/logik-test.lua ) || fehler=$((fehler + 1))
  fi
done
[ $gefunden -eq 1 ] || info "  (keine Logiktests vorhanden)"

echo
if [ $fehler -eq 0 ]; then gruen "Bestanden."; exit 0; else rot "$fehler Fehler."; exit 1; fi
