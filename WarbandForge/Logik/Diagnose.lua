-- Logik/Diagnose.lua - beantwortet  /wf doctor
--
-- ===========================================================================
-- WOZU
-- ---------------------------------------------------------------------------
-- Wenn ein Spieler sagt "geht nicht", ist die erste Frage immer dieselbe:
-- laedt das Addon ueberhaupt, steht der Speicher, welche Module sind
-- angekoppelt und welche haben sich abgemeldet - und warum. Diese Datei
-- beantwortet das in einem Rutsch, damit niemand raten muss.
--
-- Grundsatz: Sie stellt nichts fest, was sie nicht wirklich geprueft hat.
-- Lieber "unbekannt" als eine beruhigende Zeile, die nicht stimmt.
-- ===========================================================================
local WF = _G.WarbandForge
local M = WF.Module

WF.Diagnose = WF.Diagnose or {}
local D = WF.Diagnose

local function sag(text) print("|cff8080ff[WF]|r " .. tostring(text)) end

local function anzahl(tabelle)
    local n = 0
    for _ in pairs(tabelle or {}) do n = n + 1 end
    return n
end

function D.Bericht()
    local L = WF.L
    sag(L["DOCTOR_TITLE"])

    -- Fassung und Speicher
    sag(("Version %s"):format(WF.version or "?"))
    local db = WF.Speicher and WF.Speicher.db
    if db then
        sag(L["DOCTOR_STORAGE_OK"]:format(anzahl(db.charaktere)))
    else
        sag(L["DOCTOR_STORAGE_NO"])
    end

    -- Module. Der Kern kennt sie nur ueber das Modulsystem - was hier steht,
    -- hat sich selbst angemeldet.
    if #M.liste == 0 then
        sag(L["DOCTOR_NO_MODULES"])
    else
        for _, modul in ipairs(M.liste) do
            if modul.aktiv then
                sag(L["DOCTOR_MODULE_ON"]:format(modul.name))
            else
                sag(L["DOCTOR_MODULE_OFF"]:format(modul.name, modul.grund or L["DOCTOR_NO_REASON"]))
            end
        end
    end

    -- Ein Fehler, der einen Ereignis-Horcher erwischt hat, wird in Kompat.lua
    -- weggefangen, damit er die anderen nicht mitreisst - hier ist die
    -- Stelle, an der er trotzdem sichtbar wird.
    if WF.letzterFehler then
        sag("Letzter abgefangener Fehler: " .. WF.letzterFehler)
    end
end
