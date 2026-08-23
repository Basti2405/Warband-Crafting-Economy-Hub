-- Tests/logik-test.lua - prueft die Logik ohne laufendes WoW
--
-- ===========================================================================
-- Aufruf:   ../tools/test.sh        (baut sich Lua 5.1 und ruft diese Datei)
--
-- Was hier geprueft wird, ist das Zusammenspiel, das man im Spiel nur muehsam
-- nachstellt: Meldet sich ein Modul an? Filtert Pruefen() richtig? Bekommt
-- ein durchgefallenes Modul wirklich KEINEN Haken mehr gerufen? Und reisst
-- ein Modul, das wirft, den Kern mit?
--
-- Dafuer wird die WoW-Umgebung unten nachgebaut - nur so weit, wie der Kern
-- sie anfasst. Das ist Absicht: Je weniger der Nachbau kann, desto eher
-- faellt auf, wenn der Kern etwas benutzt, das er nicht angemeldet hat.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- WoW nachbauen
-- ---------------------------------------------------------------------------
local ereignisse = {}

_G.UIParent = {}

function _G.CreateFrame()
    local f = {}
    f.RegisterEvent = function(_, e) ereignisse[e] = true end
    f.SetScript = function(self, was, fn) self["_" .. was] = fn end
    f.SetSize = function() end
    f.SetPoint = function() end
    f.ClearAllPoints = function() end
    f.SetMovable = function() end
    f.EnableMouse = function() end
    f.RegisterForDrag = function() end
    f.CreateFontString = function()
        return { SetPoint = function() end, SetJustifyH = function() end,
                 SetJustifyV = function() end, SetText = function() end }
    end
    f.Hide = function(self) self.gezeigt = false end
    f.Show = function(self) self.gezeigt = true end
    f.IsShown = function(self) return self.gezeigt end
    f.GetPoint = function() return "CENTER", nil, "CENTER", 0, 0 end
    f.StartMoving = function() end
    f.StopMovingOrSizing = function() end
    f.TitleText = { SetText = function() end }
    return f
end

_G.GetTime = os.clock
_G.time = os.time
_G.date = os.date
_G.strtrim = function(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end
_G.GetLocale = function() return "enUS" end
_G.UnitName = function() return "Testchar" end
_G.UnitClass = function() return "Mage", "MAGE" end
_G.GetRealmName = function() return "Antonidas" end
_G.SlashCmdList = {}
_G.C_Timer = { After = function(_, fn) fn() end }

-- Berufe: liefert erst beim zweiten Versuch etwas. Genau der Fall, fuer den
-- Core.lua den Wiederholungsversuch hat.
local berufsAbrufe = 0
_G.GetProfessions = function()
    berufsAbrufe = berufsAbrufe + 1
    if berufsAbrufe < 2 then return end
    return 1
end
_G.GetProfessionInfo = function()
    return "Blacksmithing", nil, 100, 100, nil, nil, 164
end

-- ---------------------------------------------------------------------------
-- Kleines Testgeruest
-- ---------------------------------------------------------------------------
local bestanden, gefallen = 0, 0

local function pruefe(bedingung, was)
    if bedingung then
        bestanden = bestanden + 1
        print(("  ok    %s"):format(was))
    else
        gefallen = gefallen + 1
        print(("  FEHLT %s"):format(was))
    end
end

-- ---------------------------------------------------------------------------
-- Kern laden, in der Reihenfolge der .toc
-- ---------------------------------------------------------------------------
local hier = (arg and arg[0] or ""):match("(.*)Tests[/\\]") or "./"

local function lade(pfad)
    local fn, fehler = loadfile(hier .. pfad)
    if not fn then error("kann " .. pfad .. " nicht laden: " .. tostring(fehler)) end
    -- WoW gibt jeder Datei (addonName, addonTabelle) mit.
    fn("WarbandForge", {})
end

lade("Logik/Kompat.lua")
lade("Locales/enUS.lua")
lade("Locales/deDE.lua")
lade("Logik/Speicher.lua")
lade("Logik/Modulsystem.lua")
lade("Logik/Diagnose.lua")
lade("UI/Fenster.lua")
lade("Core.lua")

local WF = _G.WarbandForge

print("Kern")
pruefe(WF ~= nil, "Namensraum ist global erreichbar (Module brauchen das)")
pruefe(WF.Module ~= nil, "Modulsystem steht")
pruefe(ereignisse["PLAYER_LOGIN"], "PLAYER_LOGIN ist angemeldet")
pruefe(_G.SlashCmdList["WARBANDFORGE"] ~= nil, "Slash-Befehl ist angemeldet")

-- ---------------------------------------------------------------------------
-- Module anmelden - so, wie es ein eigenes Modul-Addon tut
-- ---------------------------------------------------------------------------
local gutGelaufen = { gestartet = false }
local Gut = WF.Module.Registrieren("Gut", {
    Pruefen = function() return true end,
    Start = function() gutGelaufen.gestartet = true end,
    Kennzahl = function() return "alles in Ordnung" end,
})

local Schlecht = WF.Module.Registrieren("Schlecht", {
    Pruefen = function() return false, "Voraussetzung fehlt" end,
    Kennzahl = function() error("darf nie gerufen werden") end,
})

local Wirft = WF.Module.Registrieren("Wirft", {
    Pruefen = function() error("kaputt schon beim Pruefen") end,
})

print("Anmeldung")
pruefe(#WF.Module.liste == 3, "drei Module angemeldet")
pruefe(WF.Module.Registrieren("Gut", {}) == Gut, "zweite Anmeldung desselben Namens gibt das erste zurueck")

-- ---------------------------------------------------------------------------
-- Login durchspielen
-- ---------------------------------------------------------------------------
local rahmen = nil
-- Der Login-Horcher haengt am Sammelrahmen aus Kompat.lua. Wir rufen ihn
-- ueber die oeffentliche Seite auf, statt in Interna zu greifen.
WF.Speicher.Start()
WF.Module.Pruefen()
WF.Module.Rufen("Start")

print("Pruefen")
pruefe(Gut.aktiv == true, "gutes Modul ist aktiv")
pruefe(Schlecht.aktiv == false, "durchgefallenes Modul ist nicht aktiv")
pruefe(Schlecht.grund == "Voraussetzung fehlt", "Grund wurde uebernommen")
pruefe(Wirft.aktiv == false, "werfendes Pruefen legt das Modul still, statt den Kern mitzureissen")
pruefe(type(Wirft.grund) == "string" and Wirft.grund:find("kaputt"), "Fehlertext steht als Grund")
pruefe(gutGelaufen.gestartet == true, "Start-Haken wurde gerufen")

print("Haken")
local kennzahlen = WF.Module.Rufen("Kennzahl")
pruefe(#kennzahlen == 1, "nur das aktive Modul liefert eine Kennzahl")
pruefe(kennzahlen[1] and kennzahlen[1].wert == "alles in Ordnung", "Kennzahl kommt unveraendert an")

-- Ein Modul, das IM HAKEN wirft, muss stillgelegt werden - und beim naechsten
-- Durchlauf nicht erneut werfen.
local Spaeter = WF.Module.Registrieren("Spaeter", {
    Pruefen = function() return true end,
    Kennzahl = function() error("erst hier kaputt") end,
})
WF.Module.EinzelnPruefen(Spaeter)
WF.Module.Rufen("Kennzahl")
pruefe(Spaeter.aktiv == false, "Fehler im Haken legt das Modul stumm")

print("Speicher")
local db = WF.Speicher.db
pruefe(type(db) == "table", "Speicher wurde aufgezogen")
pruefe(type(db.charaktere) == "table", "Charakter-Tabelle steht")
local schublade = WF.Speicher.ModulSchublade("test")
schublade.wert = 42
pruefe(WF.Speicher.ModulSchublade("test").wert == 42, "Modul-Schublade behaelt ihren Inhalt")
pruefe(db.module.test ~= nil, "Schublade liegt im Speicher des Kerns, nicht daneben")

local eintrag = WF.Speicher.EigenerAbschnitt()
pruefe(eintrag ~= nil, "eigener Abschnitt wird angelegt")
pruefe(eintrag.schluessel == "Testchar-Antonidas", "Schluessel enthaelt Name und Realm")
WF.Speicher.Stempeln(eintrag)
pruefe(type(eintrag.aktualisiert) == "number", "Zeitstempel wird gesetzt")

-- ---------------------------------------------------------------------------
print("")
print(("bestanden: %d   gefallen: %d"):format(bestanden, gefallen))
if gefallen > 0 then os.exit(1) end
os.exit(0)
