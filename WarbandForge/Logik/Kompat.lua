-- Logik/Kompat.lua - Bruecke zu den Schnittstellen des Spiels
--
-- ===========================================================================
-- WOZU DIESE DATEI
-- ---------------------------------------------------------------------------
-- Blizzard benennt Funktionen um, verschiebt sie in C_-Tabellen und entfernt
-- alte Namen. Wenn jede Datei die WoW-Funktionen direkt aufruft, muss man bei
-- jedem Patch das ganze Addon durchsuchen. Hier steht alles an EINER Stelle:
-- die anderen Dateien holen sich ihre Funktionen von hier und merken von
-- einer Umbenennung nichts.
--
-- Zweiter Zweck: der Test. Tests/ baut diese Bruecke nach und kann die Logik
-- dann ohne laufendes WoW pruefen.
--
-- DER NAMENSRAUM
-- ---------------------------------------------------------------------------
-- Diese Datei laedt als erste und legt den Namensraum an - und zwar GLOBAL.
-- Das ist der Unterschied zu einem Addon aus einem einzigen Ordner: dort
-- reicht das zweite Vararg-Argument, das WoW jeder Datei desselben Addons
-- mitgibt. Unsere Module sind aber EIGENE Addons mit eigenem Vararg - sie
-- kaemen an eine addon-lokale Tabelle nicht heran. Ein globaler Name ist
-- hier also keine Bequemlichkeit, sondern die Voraussetzung dafuer, dass
-- getrennte Addon-Ordner ueberhaupt zusammenarbeiten koennen.
-- ===========================================================================
local addonName = ...

_G.WarbandForge = _G.WarbandForge or {}
local WF = _G.WarbandForge

WF.name = addonName
WF.version = "0.1.0"

WF.Kompat = WF.Kompat or {}
local K = WF.Kompat

-- ---------------------------------------------------------------------------
-- Kleinkram, den wir ueberall brauchen
-- ---------------------------------------------------------------------------
K.Zeit = GetTime
K.Datum = time

-- Midnight (12.0) versieht manche Werte mit einem Sperrvermerk: Sie duerfen
-- gelesen, aber nicht in die Oberflaeche geschrieben werden. Die Funktion
-- gibt es in aelteren Clients nicht, deshalb ueber _G statt direkt.
local issecret = _G.issecretvalue
function K.IstGesperrt(wert)
    if not issecret then return false end
    local ok, ergebnis = pcall(issecret, wert)
    return ok and ergebnis or false
end

-- ---------------------------------------------------------------------------
-- Wer sind wir gerade?
-- ---------------------------------------------------------------------------
-- Der Schluessel, unter dem ein Charakter im Katalog steht. Name UND Realm,
-- weil dieselbe Kriegsmeute Charaktere auf mehreren Realms haben kann.
function K.CharakterSchluessel()
    local name = UnitName("player")
    if not name then return nil end
    local realm = GetRealmName and GetRealmName() or ""
    realm = (realm or ""):gsub("%s+", "")
    if realm == "" then return name end
    return name .. "-" .. realm
end

-- ---------------------------------------------------------------------------
-- Berufe
-- ---------------------------------------------------------------------------
-- GetProfessions liefert Indizes in das Berufe-Fenster, nicht die Berufe
-- selbst. Erst GetProfessionInfo macht daraus etwas Lesbares. Beides kann
-- direkt nach dem Login noch nichts liefern - der Aufrufer muss also damit
-- rechnen, nichts zu bekommen, und es spaeter erneut versuchen.
function K.EigeneBerufe()
    if not GetProfessions then return nil end
    local ergebnis = {}
    local indizes = { GetProfessions() }
    for _, index in ipairs(indizes) do
        if index then
            local name, _, rang, maxRang, _, _, skillLineID = GetProfessionInfo(index)
            if name and skillLineID then
                ergebnis[#ergebnis + 1] = {
                    name = name,
                    skillLineID = skillLineID,
                    rang = rang,
                    maxRang = maxRang,
                }
            end
        end
    end
    if #ergebnis == 0 then return nil end
    return ergebnis
end

-- ---------------------------------------------------------------------------
-- Bestand
-- ---------------------------------------------------------------------------
-- Zaehlt, was der EINGELOGGTE Charakter dabei hat - Taschen, Bank und
-- Kriegsmeuten-Bank, sofern die jeweilige Bank gerade offen ist bzw. der
-- Client sie zwischengespeichert hat. Was auf anderen Charakteren liegt,
-- beantwortet nicht diese Funktion, sondern der Katalog: dort steht, was
-- der jeweilige Charakter beim letzten Ausloggen hatte.
function K.EigenerBestand(itemID)
    if not itemID then return 0 end
    if C_Item and C_Item.GetItemCount then
        return C_Item.GetItemCount(itemID, true, false, true, true) or 0
    end
    if _G.GetItemCount then
        return _G.GetItemCount(itemID, true, false, true) or 0
    end
    return 0
end

-- ---------------------------------------------------------------------------
-- Ereignisse
-- ---------------------------------------------------------------------------
-- Ein einziger Rahmen fuer das ganze Addon. Wer ein Ereignis braucht, meldet
-- sich hier an, statt sich einen eigenen Frame zu bauen.
local rahmen = CreateFrame("Frame")
local horcher = {}

rahmen:SetScript("OnEvent", function(_, ereignis, ...)
    local liste = horcher[ereignis]
    if not liste then return end
    for _, fn in ipairs(liste) do
        -- Ein Fehler in einem Horcher darf die anderen nicht mitreissen.
        local ok, fehler = pcall(fn, ereignis, ...)
        if not ok then
            WF.letzterFehler = tostring(fehler)
        end
    end
end)

function K.Horchen(ereignis, fn)
    if not horcher[ereignis] then
        horcher[ereignis] = {}
        rahmen:RegisterEvent(ereignis)
    end
    local liste = horcher[ereignis]
    liste[#liste + 1] = fn
end

-- Etwas spaeter erledigen. Direkt nach dem Login liefern viele Abfragen noch
-- nichts; ein kurzer Abstand erspart eine Menge Sonderbehandlung.
function K.Spaeter(sekunden, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(sekunden, fn)
    else
        fn()
    end
end
