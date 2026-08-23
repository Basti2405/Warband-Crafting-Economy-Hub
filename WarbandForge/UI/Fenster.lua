-- UI/Fenster.lua - das Fenster, bewusst schlicht
--
-- ===========================================================================
-- Ohne Fremdbibliothek gebaut (siehe die Begruendung in der .toc). Fuer das,
-- was hier zu sehen ist - eine Kopfzeile, ein Textbereich, Reiter der Module
-- - reicht CreateFrame vollstaendig aus.
--
-- Die Reiter kommen NICHT von hier. Jedes Modul, das einen Reiter-Haken hat,
-- bekommt einen; diese Datei kennt kein einziges Modul namentlich.
-- ===========================================================================
local WF = _G.WarbandForge
local M = WF.Module

WF.UI = WF.UI or {}
local UI = WF.UI

local BREITE, HOEHE = 640, 440

local function bauen()
    local f = CreateFrame("Frame", "WarbandForgeFenster", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(BREITE, HOEHE)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Position merken, damit das Fenster dort wieder aufgeht, wo der
        -- Spieler es zuletzt hingeschoben hat.
        local punkt, _, relativ, x, y = self:GetPoint()
        local db = WF.Speicher and WF.Speicher.db
        if db then db.einstellungen.fensterPunkt = { punkt, relativ, x, y } end
    end)

    f.TitleText:SetText(WF.L["WINDOW_TITLE"])

    -- Inhalt
    local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 18, -34)
    text:SetPoint("BOTTOMRIGHT", -18, 18)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    f.Inhalt = text

    -- Gespeicherte Position wiederherstellen.
    local db = WF.Speicher and WF.Speicher.db
    local p = db and db.einstellungen.fensterPunkt
    if p then
        f:ClearAllPoints()
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    end

    f:Hide()
    return f
end

function UI.Fenster()
    if not UI.rahmen then UI.rahmen = bauen() end
    return UI.rahmen
end

-- Was im Fenster steht. Der Kern liefert die Grundzeilen, die Module je eine
-- Kennzahl-Zeile - wer keine hat, taucht nicht auf.
local function inhaltBauen()
    local L = WF.L
    local zeilen = {}

    local alle = WF.Speicher and WF.Speicher.AlleCharaktere() or {}
    local n = 0
    for _ in pairs(alle) do n = n + 1 end

    if n == 0 then
        zeilen[#zeilen + 1] = L["NO_DATA"]
    else
        zeilen[#zeilen + 1] = L["CHARACTERS_KNOWN"]:format(n)
        zeilen[#zeilen + 1] = " "
        for schluessel, eintrag in pairs(alle) do
            local wann = eintrag.aktualisiert
                and date("%d.%m.%Y", eintrag.aktualisiert)
                or "?"
            zeilen[#zeilen + 1] = ("|cffffd100%s|r  (%s)"):format(schluessel, L["LAST_SEEN"]:format(wann))
        end
    end

    local kennzahlen = M.Rufen("Kennzahl")
    if #kennzahlen > 0 then
        zeilen[#zeilen + 1] = " "
        for _, treffer in ipairs(kennzahlen) do
            zeilen[#zeilen + 1] = ("|cff8080ff%s|r  %s"):format(treffer.modul.name, tostring(treffer.wert))
        end
    end

    return table.concat(zeilen, "\n")
end

function UI.Umschalten()
    local f = UI.Fenster()
    if f:IsShown() then
        f:Hide()
    else
        f.Inhalt:SetText(inhaltBauen())
        f:Show()
    end
end
