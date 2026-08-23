-- Logik/Modulsystem.lua - Module an- und abkoppeln
--
-- ===========================================================================
-- WAS EIN MODUL IST
-- ---------------------------------------------------------------------------
-- Ein Modul ist ein EIGENES Addon in einem eigenen Ordner, mit eigener .toc
-- und  ## Dependencies: WarbandForge  darin. Der Spieler entscheidet im
-- Addon-Menue, ob er es laedt; wer es nicht braucht, hat den Quelltext gar
-- nicht erst im Speicher.
--
-- Der Kern ruft die Haken auf, wenn es soweit ist - das Modul kennt den Kern,
-- der Kern kennt kein einziges Modul namentlich. Ein neues Modul ist deshalb
-- ein neuer Ordner, und am Kern aendert sich nichts.
--
-- Die Haken, alle optional ausser Pruefen:
--   Pruefen(self)                  ist die Voraussetzung da?  true / false, Grund
--   Start(self)                    einmal beim Login, nachdem Pruefen zusagte
--   Aktualisieren(self)            der Katalog hat sich geaendert
--   Kennzahl(self)                 eine Zeile fuer die Uebersicht (Text)
--   Reiter(self, container)        Inhalt des eigenen Reiters
--
-- WICHTIG: Pruefen() wird genau EINMAL ausgewertet. Faellt ein Modul durch,
-- bekommt es keinen Reiter und meldet sich auch sonst nicht - es taucht nur
-- in  /wf doctor  mit seinem Grund auf. Ein fehlendes Fremdaddon soll eine
-- stille Zeile in der Diagnose sein, keine Fehlermeldung im Chat.
--
-- ZUR LADEREIHENFOLGE
-- ---------------------------------------------------------------------------
-- WoW laedt Abhaengigkeiten zuerst. Wenn ein Modul laeuft, steht dieser Kern
-- also. Der umgekehrte Fall - ein Modul, das nachtraeglich geladen wird,
-- nachdem der Login schon durch war - wird unten in Registrieren() mit
-- abgefangen: Das Modul wird dann sofort geprueft und gestartet, statt bis
-- zum naechsten Login zu warten.
-- ===========================================================================
local WF = _G.WarbandForge

WF.Module = WF.Module or {}
local M = WF.Module

-- Alle angemeldeten Module, in Anmeldereihenfolge (= Reihenfolge, in der WoW
-- die Addons laedt, und damit die Reihenfolge der Reiter).
M.liste = {}
M.nachName = {}

-- Steht auf true, sobald der Login-Durchlauf einmal stattgefunden hat.
M.geprueft = false

-- ---------------------------------------------------------------------------
-- Anmelden
-- ---------------------------------------------------------------------------
function M.Registrieren(name, modul)
    if type(name) ~= "string" or name == "" then return nil end
    if M.nachName[name] then return M.nachName[name] end

    modul = modul or {}
    modul.name  = name
    modul.aktiv = false
    modul.grund = nil

    M.liste[#M.liste + 1] = modul
    M.nachName[name] = modul

    -- Nachzuegler: Wurde der Login-Durchlauf schon gemacht, holen wir ihn
    -- fuer dieses eine Modul sofort nach.
    if M.geprueft then
        M.EinzelnPruefen(modul)
        if modul.aktiv and type(modul.Start) == "function" then
            pcall(modul.Start, modul)
        end
    end

    return modul
end

-- ---------------------------------------------------------------------------
-- Pruefen
-- ---------------------------------------------------------------------------
function M.EinzelnPruefen(modul)
    if type(modul.Pruefen) ~= "function" then
        modul.aktiv = true
        return
    end

    -- Ein Modul haengt an fremdem Code. Wirft dessen Pruefung, ist das ein
    -- Grund, das Modul stillzulegen - kein Grund, den Login des Spielers zu
    -- stoeren.
    local ok, ergebnis, grund = pcall(modul.Pruefen, modul)
    if not ok then
        modul.aktiv = false
        modul.grund = tostring(ergebnis)
    else
        modul.aktiv = ergebnis and true or false
        modul.grund = grund
    end
end

-- Einmal beim Login entscheiden, wer mitspielt.
function M.Pruefen()
    for _, modul in ipairs(M.liste) do
        M.EinzelnPruefen(modul)
    end
    M.geprueft = true
end

-- ---------------------------------------------------------------------------
-- Haken aufrufen
-- ---------------------------------------------------------------------------
-- Ein Modul, das beim Aufruf eines Hakens wirft, wird stillgelegt statt bei
-- jedem weiteren Aufruf erneut zu werfen. Der Grund landet in der Diagnose.
local function rufen(modul, hakenName, ...)
    local haken = modul[hakenName]
    if type(haken) ~= "function" then return nil end

    local ok, ergebnis = pcall(haken, modul, ...)
    if not ok then
        modul.aktiv = false
        modul.grund = "Fehler in " .. hakenName .. "(): " .. tostring(ergebnis)
        return nil
    end
    return ergebnis
end

function M.Rufen(hakenName, ...)
    local ergebnisse = {}
    for _, modul in ipairs(M.liste) do
        if modul.aktiv then
            local wert = rufen(modul, hakenName, ...)
            if wert ~= nil then
                ergebnisse[#ergebnisse + 1] = { modul = modul, wert = wert }
            end
        end
    end
    return ergebnisse
end

function M.RufenAuf(modul, hakenName, ...)
    if not modul or not modul.aktiv then return nil end
    return rufen(modul, hakenName, ...)
end

-- ---------------------------------------------------------------------------
-- Auskunft
-- ---------------------------------------------------------------------------
function M.Aktive()
    local ergebnis = {}
    for _, modul in ipairs(M.liste) do
        if modul.aktiv then ergebnis[#ergebnis + 1] = modul end
    end
    return ergebnis
end
