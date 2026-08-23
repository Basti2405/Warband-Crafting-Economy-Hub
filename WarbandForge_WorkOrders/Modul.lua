-- Modul.lua - Handwerksauftraege
--
-- ===========================================================================
-- Ein eigenes Addon, das sich beim Kern anmeldet. Der Kern kennt diese Datei
-- nicht - er ruft nur die Haken auf, die hier gesetzt werden.
--
-- STAND: Geruest. Die Haken stehen und werden gerufen, die Fachlogik fehlt
-- noch - siehe Planung/02-Module.md. Was hier NICHT steht, ist Absicht: ein
-- Haken, der ein erfundenes Ergebnis liefert, ist schlimmer als ein leerer.
-- ===========================================================================
local WF = _G.WarbandForge

-- Kann eigentlich nicht fehlschlagen: "## Dependencies: WarbandForge" sorgt
-- dafuer, dass WoW uns ohne den Kern gar nicht erst laedt. Die Abfrage steht
-- trotzdem da - fuer den Fall, dass jemand den Ordner von Hand kopiert und
-- die .toc dabei verliert.
if not WF or not WF.Module then return end

local Modul = WF.Module.Registrieren("WorkOrders", {})

-- ---------------------------------------------------------------------------
-- Voraussetzung
-- ---------------------------------------------------------------------------
-- Die Auftraege haengen an C_CraftingOrders. Fehlt die Schnittstelle - alter
-- Client, oder Blizzard hat sie verschoben - meldet sich das Modul still ab.
function Modul:Pruefen()
    if not C_CraftingOrders then
        return false, "C_CraftingOrders steht in diesem Client nicht zur Verfuegung"
    end
    return true
end

function Modul:Start()
    -- Eigene Schublade im Speicher des Kerns. Kein eigenes SavedVariables,
    -- siehe Logik/Speicher.lua im Kern.
    self.daten = WF.Speicher.ModulSchublade("workorders")
end

-- Eine Zeile fuer die Uebersicht des Kerns. Solange nichts erfasst ist,
-- sagen wir genau das - und nicht "0 offene Auftraege", was nach einer
-- gepruegten Tatsache aussaehe.
function Modul:Kennzahl()
    if not self.daten or not self.daten.stand then
        return WF.L["WO_NOT_YET"]
    end
    return WF.L["WO_OPEN"]:format(self.daten.offen or 0)
end
