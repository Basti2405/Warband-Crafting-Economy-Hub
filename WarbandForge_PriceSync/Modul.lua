-- Modul.lua - Preise und Rentabilitaet
--
-- ===========================================================================
-- STAND: Geruest. Siehe Planung/02-Module.md.
--
-- WAS DIESES MODUL AUSDRUECKLICH NICHT TUT
-- ---------------------------------------------------------------------------
-- Es scannt das Auktionshaus NICHT selbst. Ein eigener Scanner waere ein
-- eigenes Programm - mit eigenem Speicherbedarf, eigener Wartung und einer
-- zweiten Preisdatenbank neben der, die der Spieler ohnehin schon hat.
-- Stattdessen wird gelesen, was ein vorhandenes Preis-Addon bereits weiss.
-- Ist keines da, meldet sich das Modul ab.
-- ===========================================================================
local WF = _G.WarbandForge
if not WF or not WF.Module then return end

local Modul = WF.Module.Registrieren("PriceSync", {})

-- Die unterstuetzten Quellen, in der Reihenfolge, in der sie gefragt werden.
-- Jede liefert eine Funktion  (itemID) -> Kupfer  oder nichts.
local QUELLEN = {
    {
        name = "TradeSkillMaster",
        holen = function()
            if not _G.TSM_API then return nil end
            return function(itemID)
                local ok, wert = pcall(_G.TSM_API.GetCustomPriceValue,
                    "dbmarket", "i:" .. itemID)
                return ok and wert or nil
            end
        end,
    },
    {
        name = "Auctionator",
        holen = function()
            local A = _G.Auctionator
            if not (A and A.API and A.API.v1 and A.API.v1.GetAuctionPriceByItemID) then return nil end
            return function(itemID)
                local ok, wert = pcall(A.API.v1.GetAuctionPriceByItemID, "WarbandForge", itemID)
                return ok and wert or nil
            end
        end,
    },
}

function Modul:Pruefen()
    for _, quelle in ipairs(QUELLEN) do
        local fn = quelle.holen()
        if fn then
            self.quelle = quelle.name
            self.Preis = fn
            return true
        end
    end
    return false, "kein unterstuetztes Preis-Addon gefunden"
end

function Modul:Start()
    self.daten = WF.Speicher.ModulSchublade("pricesync")
end

function Modul:Kennzahl()
    return WF.L["PS_SOURCE"]:format(self.quelle or "?")
end
