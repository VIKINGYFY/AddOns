﻿-- Contributors: Bullseiify@Curse, Merathilis@Curse, staratnight@Curse, MrKimab@Curse, tschebbischeff@Curse

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "deDE" then return end

L["ANCHOR_FRAME_#"] = "Ankerrahmen #%d"
L["ANCHOR_FRAMES"] = "Ankerrahmen"
L["ANCHOR_RESET_DESC"] = "|cffffffffShift-Klick|r um die Position zurückzusetzen."
L["BORDER"] = "Rahmen"
L["CHANGELOG"] = "Änderungsprotokoll"
L["CHANGELOG_FULL"] = "Komplett"
L["COLORS"] = "Farben"
L["COORDS"] = "Koordinaten"
L["COPPER_THRESHOLD"] = "Kupferschwelle"
L["COPPER_THRESHOLD_DESC"] = "Minimale Anzahl Kupfer. Ab dieser Anzahl wird eine Benachrichtigung erstellt."
L["DEFAULT_VALUE"] = "Standartwert: |cffffd200%s|r"
L["DND"] = "DND"
L["DND_TOOLTIP"] = "Benachrichtigungen im DND-Modus werden nicht während eines Kampfes angezeigt, sondern in einer Warteschlange gesammelt und erst angezeigt, sobald du den Kampf verlässt."
L["DOWNLOADS"] = "Downloads"
L["FADE_OUT_DELAY"] = "Ausblendungsverzögerung"
L["FILTERS"] = "Filter"
L["FLUSH_QUEUE"] = "Warteschlange"
L["FONTS"] = "Schriften"
L["GROWTH_DIR"] = "Ausbreitungsrichtung"
L["GROWTH_DIR_DOWN"] = "Nach unten"
L["GROWTH_DIR_LEFT"] = "Nach links"
L["GROWTH_DIR_RIGHT"] = "Nach rechts"
L["GROWTH_DIR_UP"] = "Nach oben"
L["ICON_BORDER"] = "Symbolrahmen"
L["INFORMATION"] = "Info"
L["NAME"] = "Name"
L["OPEN_CONFIG"] = "Konfiguration öffnen"
L["RARITY_THRESHOLD"] = "Schwellenwert der Seltenheit"
L["SCALE"] = "Skalierung"
L["SIZE"] = "Größe"
L["SKIN"] = "Oberfläche"
L["STRATA"] = "Ebene"
L["SUPPORT"] = "Support"
L["TEST"] = "Test"
L["TEST_ALL"] = "Alle testen"
L["TOAST_NUM"] = "Anzahl der Benachrichtigungen"
L["TOAST_TYPES"] = "Benachrichtigungstypen"
L["TOGGLE_ANCHORS"] = "Ankerpunkte umschalten"
L["TRACK_LOSS"] = "Verlust Verfolgung"
L["TRACK_LOSS_DESC"] = "Diese Option ignoriert die Kupferschwelle."
L["TYPE_LOOT_GOLD"] = "Beute (Gold)"
L["X_OFFSET"] = "X-Versatz"
L["Y_OFFSET"] = "Y-Versatz"
L["YOU_LOST"] = "Ihr verliert"
L["YOU_RECEIVED"] = "Ihr erhaltet"

-- Retail
L["CURRENCY_THRESHOLD_DESC"] = "Gib |cffffd200-1|r zum Ignorieren der Währung, |cffffd2000|r zum deaktivieren der Filter oder |cffffd200any number above 0|r um den Schwellenwert einzustellen unter dem keine Beanchrichtigungen erstellt werden, ein."
L["HANDLE_LEFT_CLICK"] = "Linksklick behandeln"
L["NEW_CURRENCY_FILTER_DESC"] = "Gib eine Währungs ID ein."
L["QUEST_ITEMS_DESC"] = "Zeigt alle Questgegenstände, ungeachtet deren Qualität."
L["TAINT_WARNING"] = "Diese Option führt beim Öffnen oder Schließen von bestimmten UI Fenstern während des Kampfes möglicher zu Fehlern."
L["THRESHOLD"] = "Schwellenwert"
L["TRANSMOG_ADDED"] = "Vorlage hinzugefügt"
L["TRANSMOG_REMOVED"] = "Vorlage entfernt"
L["TYPE_ACHIEVEMENT"] = "Erfolg"
L["TYPE_ARCHAEOLOGY"] = "Archäologie"
L["TYPE_CLASS_HALL"] = "Klassenhalle"
L["TYPE_COLLECTION"] = "Sammlung"
L["TYPE_COLLECTION_DESC"] = "Benachrichtigungen für erhaltene Reittiere, Haustiere und Spielzeuge."
L["TYPE_COVENANT"] = "Pakt"
L["TYPE_DUNGEON"] = "Dungeon"
L["TYPE_GARRISON"] = "Garnison"
L["TYPE_LOOT_COMMON"] = "Beute (Gewöhnlich)"
L["TYPE_LOOT_COMMON_DESC"] = "Benachrichtigungen, die von Chatereignissen ausgelöst werden wie grüne, blaue Gegenstände, manche epischen Gegenstände, alles was nicht von der Benachrichtigung für besondere Beute abgedeckt wird."
L["TYPE_LOOT_CURRENCY"] = "Beute (Abzeichen)"
L["TYPE_LOOT_SPECIAL"] = "Beute (Spezial)"
L["TYPE_LOOT_SPECIAL_DESC"] = "Benachrichtigungen, die von besonderen Beuteereignissen wie gewonnene Würfe, legendäre Gegenstände, persönliche Beute etc. ausgelöst werden."
L["TYPE_RUNECARVING"] = "Runenschnitzen"
L["TYPE_TRANSMOG"] = "Transmogrifikation"
L["TYPE_WAR_EFFORT"] = "Kriegsanstrengungen"
L["TYPE_WORLD_QUEST"] = "Weltquest"
