-- .luacheckrc - Einstellungen fuer luacheck
--
-- Aufruf:  luacheck .
-- Ohne diese Datei meldet luacheck jede WoW-Funktion als "undefined global",
-- weil sie erst zur Laufzeit vom Spiel bereitgestellt wird.

-- WoW laeuft auf Lua 5.1.
std = "lua51"

-- WoW gibt Addon-Dateien zwei versteckte Argumente ueber "..." mit. Den Namen
-- braucht fast keine Datei, die Zuweisung muss aber dastehen.
unused_args = false

ignore = {
    -- unbenutzte Variable - nur fuer addonName, siehe oben.
    "211/addonName",

    -- "self" schattet "self". WoW-Idiom: ein Frame-Handler bekommt seinen
    -- Frame als self uebergeben.
    "431/self",
    "432/self",
}

max_line_length = 120

exclude_files = { "**/Libs/**", ".werkzeuge/**" }

-- ---------------------------------------------------------------------------
-- Globals, die WoW bereitstellt (nur lesen)
-- ---------------------------------------------------------------------------
read_globals = {
    -- Ausgabe und Text
    "print", "strtrim", "strsplit", "format", "wipe", "time", "date", "select",
    "unpack",

    -- Rahmen und Oberflaeche
    "CreateFrame", "UIParent", "GameTooltip", "ChatFontNormal",
    "InCombatLockdown", "ReloadUI",

    -- Einheiten und Gruppe
    "UnitGUID", "UnitName", "UnitClass", "UnitClassBase", "UnitIsUnit",
    "UnitGroupRolesAssigned", "IsInGroup", "IsInRaid", "GetNumGroupMembers",
    "GetRealmName",

    -- Instanzen
    "GetInstanceInfo", "C_ChallengeMode", "C_Map",

    -- Gegenstaende
    "C_Item", "GetItemCount", "GetInventoryItemLink",

    -- Addon-Verwaltung und Zeit
    "C_AddOns", "C_Timer", "GetBuildInfo", "GetAddOnMetadata",
    "C_ChatInfo",

    -- Sprache des Clients.
    "GetLocale",

    -- Berufe.
    "GetProfessions", "GetProfessionInfo",

    -- Midnight: Sperrvermerk auf Werten, erst ab 12.0 vorhanden.
    "issecretvalue",

    -- Fremdaddons, die Module optional lesen.
    "TSM_API", "Auctionator",

    -- Handwerk und Einrichtung.
    "C_CraftingOrders", "C_Housing",
}

-- ---------------------------------------------------------------------------
-- Globals, die dieses Addon selbst setzt (lesen und schreiben)
-- ---------------------------------------------------------------------------
globals = {
    "WarbandForge",          -- der Namensraum, den die Module brauchen
    "WarbandForgeDB",      -- SavedVariables

    "SLASH_WARBANDFORGE1",
    "SLASH_WARBANDFORGE2",
    "SlashCmdList",
}

-- ---------------------------------------------------------------------------
-- Sonderfaelle
-- ---------------------------------------------------------------------------
files["**/Tests/logik-test.lua"] = {
    -- Der Test baut die WoW-Umgebung absichtlich selbst nach und setzt dafuer
    -- Globals. Das ist hier kein Fehler, sondern der Zweck der Datei.
    globals = { "_G", "print2", "arg", "io", "os" },
    read_globals = { "loadfile" },
    max_line_length = 200,
}

files["**/Locales/*.lua"] = {
    -- Ein Satz gehoert in eine Zeile.
    max_line_length = 400,
}
