-- Locales/enUS.lua - the base language
--
-- ===========================================================================
-- One sentence per line, no line breaks inside a string: a translator should
-- never have to reassemble a sentence from fragments. enUS is the fallback
-- and must be COMPLETE - every other file only overwrites individual keys.
-- ===========================================================================
-- Notnagel: Sollte die Ladereihenfolge in der .toc einmal verrutschen,
-- legt diese Datei den Namensraum selbst an, statt in ein nil zu laufen.
_G.WarbandForge = _G.WarbandForge or {}
local WF = _G.WarbandForge

WF.L = WF.L or {}
local L = WF.L

L["ADDON_NAME"]        = "Warband Forge"
L["SLASH_HINT"]        = "Type /wf for the window, /wf doctor for a self-check."

L["WINDOW_TITLE"]      = "Warband Forge"
L["TAB_CATALOGUE"]     = "Catalogue"
L["TAB_MATERIALS"]     = "Materials"

L["NO_DATA"]           = "No data yet. Log in to each character once so the catalogue can fill up."
L["CHARACTERS_KNOWN"]  = "Characters known: %d"
L["LAST_SEEN"]         = "last seen %s"

L["DOCTOR_TITLE"]      = "Warband Forge - self-check"
L["DOCTOR_STORAGE_OK"] = "Storage: ready (%d characters)."
L["DOCTOR_STORAGE_NO"] = "Storage: NOT ready - saved variables did not load."
L["DOCTOR_NO_MODULES"] = "Modules: none installed."
L["DOCTOR_MODULE_ON"]  = "Module %s: active."
L["DOCTOR_MODULE_OFF"] = "Module %s: inactive (%s)."
L["DOCTOR_NO_REASON"]  = "no reason given"
