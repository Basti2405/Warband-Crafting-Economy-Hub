@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

rem ===========================================================================
rem tools\junction.cmd - verbindet die Addon-Ordner mit dem AddOns-Verzeichnis
rem ---------------------------------------------------------------------------
rem WoW laedt Addons nur aus  ...\_retail_\Interface\AddOns\ . Statt die
rem Dateien dorthin zu kopieren (zwei Fassungen, die auseinanderlaufen) wird
rem je eine Junction angelegt: ein Verzeichnisverweis. Das Spiel sieht einen
rem normalen Ordner, geaendert wird aber nur an einer Stelle.
rem
rem Dieses Repository enthaelt MEHRERE Addons - den Kern und je einen Ordner
rem pro Modul. Verlinkt wird jeder Ordner, in dem eine .toc liegt.
rem
rem Eine Junction braucht KEINE Administratorrechte (anders als mklink /D).
rem ===========================================================================

set "QUELLE=%~dp0.."
for %%I in ("%QUELLE%") do set "QUELLE=%%~fI"

rem ---------------------------------------------------------------------------
rem WoW finden. Der erste Treffer gewinnt.
rem ---------------------------------------------------------------------------
set "ZIELBASIS="
for %%P in (
  "F:\Blizzard\World of Warcraft\_retail_\Interface\AddOns"
  "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
  "D:\World of Warcraft\_retail_\Interface\AddOns"
  "E:\World of Warcraft\_retail_\Interface\AddOns"
) do (
  if not defined ZIELBASIS if exist "%%~P" set "ZIELBASIS=%%~P"
)

if not defined ZIELBASIS (
  echo.
  echo   Der AddOns-Ordner wurde nicht gefunden.
  echo   Bitte den Pfad oben in dieser Datei eintragen.
  echo.
  pause
  exit /b 1
)

echo.
echo   Quelle : %QUELLE%
echo   Ziel   : %ZIELBASIS%
echo.

set /a ANGELEGT=0
set /a UEBERSPRUNGEN=0

rem ---------------------------------------------------------------------------
rem Jeden Ordner mit einer .toc verlinken
rem ---------------------------------------------------------------------------
for /d %%D in ("%QUELLE%\*") do (
  set "ORDNER=%%~nxD"
  if exist "%%D\!ORDNER!.toc" (
    set "ZIEL=%ZIELBASIS%\!ORDNER!"

    if exist "!ZIEL!" (
      rem Junctions erkennt man in der dir-Ausgabe am Merkmal ^<JUNCTION^>.
      dir /al "%ZIELBASIS%" 2>nul | find /i "!ORDNER!" >nul
      if !errorlevel! equ 0 (
        rmdir "!ZIEL!"
      ) else (
        echo   ACHTUNG: !ORDNER! ist dort ein ECHTER Ordner, keine Junction.
        echo            Er wird NICHT angetastet - sonst waeren Daten weg.
        set /a UEBERSPRUNGEN+=1
      )
    )

    if not exist "!ZIEL!" (
      mklink /J "!ZIEL!" "%%D" >nul
      if !errorlevel! equ 0 (
        echo   verbunden: !ORDNER!
        set /a ANGELEGT+=1
      ) else (
        echo   FEHLER bei: !ORDNER!
      )
    )
  )
)

echo.
echo   !ANGELEGT! Ordner verbunden, !UEBERSPRUNGEN! uebersprungen.
echo.
echo   Naechste Schritte im Spiel:
echo     1. Addons im Charakterbildschirm aktivieren
echo     2. /reload   (oder WoW neu starten)
echo.
pause
