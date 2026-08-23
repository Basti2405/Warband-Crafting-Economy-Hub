-- Core.lua - startet alles auf und nimmt die Befehle entgegen
--
-- ===========================================================================
-- Laedt als LETZTE Datei des Kerns (siehe .toc). Alles, was hier aufgerufen
-- wird, steht zu diesem Zeitpunkt also schon.
--
-- Reihenfolge beim Login, und warum sie so ist:
--   1. Speicher aufziehen        - vorher darf niemand hineinschreiben
--   2. Module pruefen            - erst jetzt steht fest, wer mitspielt
--   3. Modul-Start rufen         - Module duerfen sich auf den Speicher verlassen
--   4. eigene Daten erfassen     - mit kurzem Abstand, siehe unten
-- ===========================================================================
local WF = _G.WarbandForge
local K = WF.Kompat
local M = WF.Module

-- ---------------------------------------------------------------------------
-- Eigene Berufe in den Katalog schreiben
-- ---------------------------------------------------------------------------
-- Direkt nach dem Login liefert GetProfessions noch nichts - die Daten des
-- Charakters sind dann teilweise noch unterwegs. Deshalb wird nicht sofort
-- erfasst, sondern kurz danach, und bei Misserfolg noch einmal. Wer hier
-- ohne Abstand erfasst, schreibt regelmaessig einen leeren Berufsstand in
-- den Katalog und ueberschreibt damit einen richtigen.
local function erfassen(versuch)
    versuch = versuch or 1

    local berufe = K.EigeneBerufe()
    if not berufe then
        if versuch < 4 then
            K.Spaeter(3, function() erfassen(versuch + 1) end)
        end
        return
    end

    local eintrag = WF.Speicher.EigenerAbschnitt()
    if not eintrag then return end

    eintrag.name   = UnitName("player")
    eintrag.klasse = select(2, UnitClass("player"))
    eintrag.berufe = berufe
    WF.Speicher.Stempeln(eintrag)

    -- Die Module wissen jetzt mehr als vorher.
    M.Rufen("Aktualisieren")
end

-- ---------------------------------------------------------------------------
-- Login
-- ---------------------------------------------------------------------------
K.Horchen("PLAYER_LOGIN", function()
    WF.Speicher.Start()
    M.Pruefen()
    M.Rufen("Start")

    K.Spaeter(2, function() erfassen(1) end)
end)

-- Berufsfenster geoeffnet oder Fertigkeit gestiegen: guter Zeitpunkt, den
-- Stand aufzufrischen - dann stimmt der Katalog ohne Zutun des Spielers.
K.Horchen("TRADE_SKILL_SHOW", function() erfassen(1) end)
K.Horchen("SKILL_LINES_CHANGED", function() erfassen(1) end)

-- ---------------------------------------------------------------------------
-- Befehle
-- ---------------------------------------------------------------------------
local function befehl(eingabe)
    local wort = strtrim((eingabe or ""):lower())

    if wort == "" then
        WF.UI.Umschalten()
    elseif wort == "doctor" then
        WF.Diagnose.Bericht()
    elseif wort == "help" or wort == "hilfe" then
        print("|cff8080ff[WF]|r " .. WF.L["SLASH_HINT"])
    else
        -- Unbekanntes Wort koennte einem Modul gehoeren. Der Kern kennt die
        -- Module nicht namentlich - er fragt sie einfach der Reihe nach, und
        -- das erste, das sich zustaendig erklaert, bekommt es.
        local behandelt = false
        for _, modul in ipairs(M.Aktive()) do
            if M.RufenAuf(modul, "Befehl", wort) then
                behandelt = true
                break
            end
        end
        if not behandelt then
            print("|cff8080ff[WF]|r " .. WF.L["SLASH_HINT"])
        end
    end
end

SLASH_WARBANDFORGE1 = "/wf"
SLASH_WARBANDFORGE2 = "/warbandforge"
SlashCmdList["WARBANDFORGE"] = befehl
