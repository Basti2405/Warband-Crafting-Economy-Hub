-- Modul.lua - Einrichtung (Housing)
--
-- ===========================================================================
-- STAND: Geruest. Siehe Planung/02-Module.md.
--
-- Housing kam mit Midnight, und die Schnittstellen dazu sind zum Zeitpunkt
-- dieser Planung noch in Bewegung. Deshalb prueft dieses Modul besonders
-- vorsichtig und meldet sich lieber ab, als auf gut Glueck aufzurufen.
-- ===========================================================================
local WF = _G.WarbandForge
if not WF or not WF.Module then return end

local Modul = WF.Module.Registrieren("Housing", {})

function Modul:Pruefen()
    if not C_Housing then
        return false, "C_Housing steht in diesem Client nicht zur Verfuegung"
    end
    return true
end

function Modul:Start()
    self.daten = WF.Speicher.ModulSchublade("housing")
end

function Modul:Kennzahl()
    if not self.daten or not self.daten.stand then
        return WF.L["HO_NOT_YET"]
    end
    return WF.L["HO_KNOWN"]:format(self.daten.bekannt or 0)
end
