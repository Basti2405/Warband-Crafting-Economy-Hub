-- Locales/deDE.lua - Deutsch
--
-- ===========================================================================
-- Ueberschreibt nur einzelne Schluessel. Was hier fehlt, kommt aus enUS -
-- eine fehlende Uebersetzung ist deshalb englischer Text, nie eine Luecke.
-- ===========================================================================
if GetLocale() ~= "deDE" then return end

local WF = _G.WarbandForge
local L = WF.L

L["SLASH_HINT"]        = "/wf oeffnet das Fenster, /wf doctor prueft sich selbst."

L["TAB_CATALOGUE"]     = "Katalog"
L["TAB_MATERIALS"]     = "Material"

L["NO_DATA"]           = "Noch nichts erfasst. Melde dich mit jedem Charakter einmal an, dann fuellt sich der Katalog."
L["CHARACTERS_KNOWN"]  = "Bekannte Charaktere: %d"
L["LAST_SEEN"]         = "zuletzt gesehen %s"

L["DOCTOR_TITLE"]      = "Warband Forge - Selbstdiagnose"
L["DOCTOR_STORAGE_OK"] = "Speicher: bereit (%d Charaktere)."
L["DOCTOR_STORAGE_NO"] = "Speicher: NICHT bereit - die gespeicherten Variablen wurden nicht geladen."
L["DOCTOR_NO_MODULES"] = "Module: keines installiert."
L["DOCTOR_MODULE_ON"]  = "Modul %s: aktiv."
L["DOCTOR_MODULE_OFF"] = "Modul %s: nicht aktiv (%s)."
L["DOCTOR_NO_REASON"]  = "ohne Angabe"
