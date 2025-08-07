-- Variables --
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, "BetterBags - Teleports requires BetterBags")

---@class Categories: AceModule
local Categories = BetterBags:GetModule('Categories')

---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

---@class Teleporters: AceModule
local Teleporters = BetterBags:NewModule('Teleporters')

---@class AceDB-3.0: AceModule
local AceDB = LibStub("AceDB-3.0")

---@class Config: AceModule
local Config = BetterBags:GetModule('Config')

---@class Context: AceModule
local Context = BetterBags:GetModule('Context')

---@class Events: AceModule
local Events = BetterBags:GetModule('Events')

---@type string, AddonNS
local _, addon = ...

local _, _, _, interfaceVersion = GetBuildInfo()

local db
local defaults = {
    profile = {}
}
local configOptions

-- Get the game version
local isRetail  = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isTBC     = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local isWotLK   = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
local isCata    = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
local isMists   = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC

-- “Or above” helpers for gating
local isMistsOrAbove   = isMists   or isRetail
local isCataOrAbove    = isCata    or isMists or isRetail
local isWotLKOrAbove   = isWotLK   or isCata  or isMists or isRetail
local isTBCOrAbove     = isTBC     or isWotLK or isCata  or isMists or isRetail
local isClassicOrAbove = isClassic or isTBC   or isWotLK or isCata  or isMists or isRetail

-- Kill the category from different plugin.
Categories:WipeCategory(Context:New('BBTeleporters_DeleteCategory'),TUTORIAL_TITLE31)

-- Make an empty table to store item data in...
local teleporters = {}

if isClassic or isTBC or isWotLK or isCata then
    defaults.profile = {
        enablePortalReagents = false,
    }

    configOptions = {
        classicOptions = {
            name = L:G("Classic Options"),
            type = "group",
            order = 1,
            inline = true,
            args = {
                addReagentsToCategory = {
                    type = "toggle",
                    name = "Add Reagents",
                    desc = "This will add the mage reagents for portals to the Teleporters category.",
                    get = function(info)
                        return Teleporters.db.profile.enablePortalReagents
                    end,
                    set = function(info, value)
                        Teleporters.db.profile.enablePortalReagents = value
                        Teleporters:clearTeleportCategory()
                        Teleporters:addTeleportItemsToTable()
                        Teleporters:addTeleportersToCategory()
                        local ctx = Context:New('BBTeleporters_RefreshAll')
                        Events:SendMessage(ctx, 'bags/FullRefreshAll')
                    end,
                },
                forceRefreshTeleports = {
                    type = "execute",
                    name = "Force Refresh",
                    desc = "This will forcibly refresh the Teleporters category.",
                    func = function()
                        Teleporters:clearTeleportCategory()
                        Teleporters:addTeleportItemsToTable()
                        Teleporters:addTeleportersToCategory()
                        local ctx = Context:New('BBTeleporters_RefreshAll')
                        Events:SendMessage(ctx, 'bags/FullRefreshAll')
                    end,
                },
            },
        },
    }
else
    configOptions = {
        retailOptions = {
            name = L:G("Options"),
            type = "group",
            order = 1,
            inline = true,
            args = {
                forceRefreshTeleports = {
                    type = "execute",
                    name = "Force Refresh",
                    desc = "This will forcibly refresh the Teleporters category.",
                    func = function()
                        Teleporters:clearTeleportCategory()
                        Teleporters:addTeleportItemsToTable()
                        Teleporters:addTeleportersToCategory()
                        local ctx = Context:New('BBTeleporters_RefreshAll')
                        Events:SendMessage(ctx, 'bags/FullRefreshAll')
                    end,
                },
            },
        },
    }
end

function Teleporters:addTeleportersConfig()
    if not Config or not configOptions then
        print("Failed to load configurations for Teleporters plugin.")
        return
    end

    Config:AddPluginConfig("Teleporters", configOptions)
end

function Teleporters:clearTeleportCategory()
    Categories:WipeCategory(Context:New('BBTeleporters_DeleteCategory'),L:G("Teleporters"))
end

function Teleporters:addTeleportItemsToTable()
    -- Clear the table of items if needed.
    table.wipe(teleporters)

    if (isClassic or isTBC or isWotLK or isCata) and db.enablePortalReagents then
        -- Add the reagents for mage portals to the teleporters category.
        table.insert(teleporters, { itemID = 17031, itemName = "Rune of Teleportation" })
        table.insert(teleporters, { itemID = 17032, itemName = "Rune of Portals" })
    end

    -- Section Vanilla
    if isClassicOrAbove then
        table.insert(teleporters, { itemID = 6948, itemName = "Hearthstone" })
        table.insert(teleporters, { itemID = 17690, itemName = "Frostwolf Insignia Rank 1" })
        table.insert(teleporters, { itemID = 17691, itemName = "Stormpike Insignia Rank 1" })
        table.insert(teleporters, { itemID = 17900, itemName = "Stormpike Insignia Rank 2" })
        table.insert(teleporters, { itemID = 17901, itemName = "Stormpike Insignia Rank 3" })
        table.insert(teleporters, { itemID = 17902, itemName = "Stormpike Insignia Rank 4" })
        table.insert(teleporters, { itemID = 17903, itemName = "Stormpike Insignia Rank 5" })
        table.insert(teleporters, { itemID = 17904, itemName = "Stormpike Insignia Rank 6" })
        table.insert(teleporters, { itemID = 17905, itemName = "Frostwolf Insignia Rank 2" })
        table.insert(teleporters, { itemID = 17906, itemName = "Frostwolf Insignia Rank 3" })
        table.insert(teleporters, { itemID = 17907, itemName = "Frostwolf Insignia Rank 4" })
        table.insert(teleporters, { itemID = 17908, itemName = "Frostwolf Insignia Rank 5" })
        table.insert(teleporters, { itemID = 17909, itemName = "Frostwolf Insignia Rank 6" })
        table.insert(teleporters, { itemID = 18149, itemName = "Rune of Recall (Frostwolf Keep)" })
        table.insert(teleporters, { itemID = 18150, itemName = "Rune of Recall (Dun Baldar)" })
        table.insert(teleporters, { itemID = 18984, itemName = "Dimensional Ripper - Everlook" })
        table.insert(teleporters, { itemID = 18986, itemName = "Ultrasafe Transporter - Gadgetzan" })
        table.insert(teleporters, { itemID = 22589, itemName = "Atiesh, Greatstaff of the Guardian (Mage)" })
        table.insert(teleporters, { itemID = 22630, itemName = "Atiesh, Greatstaff of the Guardian (Warlock)" })
        table.insert(teleporters, { itemID = 22631, itemName = "Atiesh, Greatstaff of the Guardian (Priest)" })
        table.insert(teleporters, { itemID = 22632, itemName = "Atiesh, Greatstaff of the Guardian (Druid)" })
    end
    -- Section TBC
    if isTBCOrAbove then
        table.insert(teleporters, { itemID = 28585, itemName = "Ruby Slippers" })
        table.insert(teleporters, { itemID = 29796, itemName = "Socrethar's Teleportation Stone" })
        table.insert(teleporters, { itemID = 30542, itemName = "Dimensional Ripper - Area 52" })
        table.insert(teleporters, { itemID = 30544, itemName = "Ultrasafe Transporter - Toshley's Station" })
        table.insert(teleporters, { itemID = 32757, itemName = "Blessed Medallion of Karabor" })
        table.insert(teleporters, { itemID = 35230, itemName = "Darnarian's Scroll of Teleportation" })
        table.insert(teleporters, { itemID = 37118, itemName = "Scroll of Recall" })
        table.insert(teleporters, { itemID = 37863, itemName = "Direbrew's Remote" })
        if not isRetail then
            table.insert(teleporters, { itemID = 184871, itemName = "Dark Portal (TBC)" })
        end
    end
    -- Section WotLK
    if isWotLKOrAbove then
        table.insert(teleporters, { itemID = 40585, itemName = "Signet of the Kirin Tor" })
        table.insert(teleporters, { itemID = 40586, itemName = "Band of the Kirin Tor" })
        table.insert(teleporters, { itemID = 43824, itemName = "The Schools of Arcane Magic - Mastery (spires atop the Violet Citadel)" })
        table.insert(teleporters, { itemID = 44314, itemName = "Scroll of Recall II" })
        table.insert(teleporters, { itemID = 44315, itemName = "Scroll of Recall III" })
        table.insert(teleporters, { itemID = 44934, itemName = "Loop of the Kirin Tor" })
        table.insert(teleporters, { itemID = 44935, itemName = "Ring of the Kirin Tor" })
        table.insert(teleporters, { itemID = 45688, itemName = "Inscribed Band of the Kirin Tor" })
        table.insert(teleporters, { itemID = 45689, itemName = "Inscribed Loop of the Kirin Tor" })
        table.insert(teleporters, { itemID = 45690, itemName = "Inscribed Ring of the Kirin Tor" })
        table.insert(teleporters, { itemID = 45691, itemName = "Inscribed Signet of the Kirin Tor" })
        table.insert(teleporters, { itemID = 46874, itemName = "Argent Crusader's Tabard" })
        table.insert(teleporters, { itemID = 48933, itemName = "Wormhole Generator: Northrend" })
        table.insert(teleporters, { itemID = 48954, itemName = "Etched Band of the Kirin Tor" })
        table.insert(teleporters, { itemID = 48955, itemName = "Etched Loop of the Kirin Tor" })
        table.insert(teleporters, { itemID = 48956, itemName = "Etched Ring of the Kirin Tor" })
        table.insert(teleporters, { itemID = 48957, itemName = "Etched Signet of the Kirin Tor" })
        table.insert(teleporters, { itemID = 50287, itemName = "Boots of the Bay" })
        table.insert(teleporters, { itemID = 51557, itemName = "Runed Signet of the Kirin Tor" })
        table.insert(teleporters, { itemID = 51558, itemName = "Runed Loop of the Kirin Tor" })
        table.insert(teleporters, { itemID = 51559, itemName = "Runed Ring of the Kirin Tor" })
        table.insert(teleporters, { itemID = 51560, itemName = "Runed Band of the Kirin Tor" })
        table.insert(teleporters, { itemID = 52251, itemName = "Jaina's Locket" })
        table.insert(teleporters, { itemID = 54452, itemName = "Ethereal Portal" })
        if not isRetail then
            table.insert(teleporters, { itemID = 199335, itemName = "Teleport Scroll: Menethil Harbor" })
            table.insert(teleporters, { itemID = 199336, itemName = "Teleport Scroll: Stormwind Harbor" })
            table.insert(teleporters, { itemID = 199777, itemName = "Teleport Scroll: Orgrimmar Zepplin Tower" })
            table.insert(teleporters, { itemID = 199778, itemName = "Teleport Scroll: Undercity Zepplin Tower" })
            table.insert(teleporters, { itemID = 200068, itemName = "Teleport Scroll: Shattrath City" })
        end
    end
    -- Section Cataclysm
    if isCataOrAbove then
        table.insert(teleporters, { itemID = 58487, itemName = "Potion of Deepholm" })
        table.insert(teleporters, { itemID = 61379, itemName = "Gidwin's Hearthstone" })
        table.insert(teleporters, { itemID = 63206, itemName = "Wrap of Unity: Stormwind" })
        table.insert(teleporters, { itemID = 63207, itemName = "Wrap of Unity: Orgrimmar" })
        table.insert(teleporters, { itemID = 63352, itemName = "Shroud of Cooperation: Stormwind" })
        table.insert(teleporters, { itemID = 63353, itemName = "Shroud of Cooperation: Orgrimmar" })
        table.insert(teleporters, { itemID = 63378, itemName = "Hellscream's Reach Tabard" })
        table.insert(teleporters, { itemID = 63379, itemName = "Baradin's Wardens Tabard" })
        table.insert(teleporters, { itemID = 64457, itemName = "The Last Relic of Argus" })
        table.insert(teleporters, { itemID = 64488, itemName = "The Innkeeper's Daughter" })
        table.insert(teleporters, { itemID = 65274, itemName = "Cloak of Coordination: Orgrimmar" })
        table.insert(teleporters, { itemID = 65360, itemName = "Cloak of Coordination: Stormwind" })
        table.insert(teleporters, { itemID = 68808, itemName = "Hero's Hearthstone" })
        table.insert(teleporters, { itemID = 68809, itemName = "Veteran's Hearthstone" })
    end
    -- Section Mists
    if isMistsOrAbove then
        table.insert(teleporters, { itemID = 87215, itemName = "Wormhole Generator: Pandaria" })
        table.insert(teleporters, { itemID = 87548, itemName = "Lorewalker's Lodestone" })
        table.insert(teleporters, { itemID = 92510, itemName = "Vol'jin's Hearthstone" })
        table.insert(teleporters, { itemID = 93672, itemName = "Dark Portal (MoP)" })
        table.insert(teleporters, { itemID = 95050, itemName = "The Brassiest Knuckle (Brawl'gar Arena)" })
        table.insert(teleporters, { itemID = 95051, itemName = "The Brassiest Knuckle (Bizmo's Brawlpub)" })
        table.insert(teleporters, { itemID = 95567, itemName = "Kirin Tor Beacon" })
        table.insert(teleporters, { itemID = 95568, itemName = "Sunreaver Beacon" })
        table.insert(teleporters, { itemID = 103678, itemName = "Time-Lost Artifact" })
    end
    -- Section WoD
    if isRetail then
        table.insert(teleporters, { itemID = 110560, itemName = "Garrison Hearthstone" })
        table.insert(teleporters, { itemID = 112059, itemName = "Wormhole Centrifuge" })
        table.insert(teleporters, { itemID = 117389, itemName = "Draenor Archaeologist's Lodestone" })
        table.insert(teleporters, { itemID = 118662, itemName = "Bladespire Relic" })
        table.insert(teleporters, { itemID = 118663, itemName = "Relic of Karabor" })
        table.insert(teleporters, { itemID = 118907, itemName = "Pit Fighter's Punching Ring (Bizmo's Brawlpub)" })
        table.insert(teleporters, { itemID = 118908, itemName = "Pit Fighter's Punching Ring (Brawl'gar Arena)" })
        table.insert(teleporters, { itemID = 119183, itemName = "Scroll of Risky Recall" })
        table.insert(teleporters, { itemID = 128502, itemName = "Hunter's Seeking Crystal" })
        table.insert(teleporters, { itemID = 128503, itemName = "Master Hunter's Seeking Crystal" })
        table.insert(teleporters, { itemID = 128353, itemName = "Admiral's Compass" })
    end
    -- Section Legion
    if isRetail then
        table.insert(teleporters, { itemID = 129276, itemName = "Beginner's Guide to Dimensional Rifting" })
        table.insert(teleporters, { itemID = 132119, itemName = "Orgrimmar Portal Stone" })
        table.insert(teleporters, { itemID = 132120, itemName = "Stormwind Portal Stone" })
        table.insert(teleporters, { itemID = 132517, itemName = "Intra-Dalaran Wormhole Generator" })
        table.insert(teleporters, { itemID = 132523, itemName = "Reaves Battery" })
        table.insert(teleporters, { itemID = 138448, itemName = "Emblem of Margoss" })
        table.insert(teleporters, { itemID = 139590, itemName = "Scroll of Teleport: Ravenholdt" })
        table.insert(teleporters, { itemID = 139599, itemName = "Empowered Ring of the Kirin Tor" })
        table.insert(teleporters, { itemID = 140192, itemName = "Dalaran Hearthstone" })
        table.insert(teleporters, { itemID = 140493, itemName = "Adept's Guide to Dimensional Rifting" })
        table.insert(teleporters, { itemID = 141013, itemName = "Scroll of Town Portal: Shala'nir" })
        table.insert(teleporters, { itemID = 141014, itemName = "Scroll of Town Portal: Sashj'tar" })
        table.insert(teleporters, { itemID = 141015, itemName = "Scroll of Town Portal: Kal'delar" })
        table.insert(teleporters, { itemID = 141016, itemName = "Scroll of Town Portal: Faronaar" })
        table.insert(teleporters, { itemID = 141017, itemName = "Scroll of Town Portal: Lian'tril" })
        table.insert(teleporters, { itemID = 141324, itemName = "Talisman of the Shal'dorei" })
        table.insert(teleporters, { itemID = 141605, itemName = "Flight Master's Whistle" })
        table.insert(teleporters, { itemID = 142298, itemName = "Astonishingly Scarlet Slippers" })
        table.insert(teleporters, { itemID = 142469, itemName = "Violet Seal of the Grand Magus" })
        table.insert(teleporters, { itemID = 142542, itemName = "Tome of Town Portal (Diablo 3 event)" })
        table.insert(teleporters, { itemID = 142543, itemName = "Scroll of Town Portal (Diablo 3 event)" })
        table.insert(teleporters, { itemID = 144341, itemName = "Rechargeable Reaves Battery" })
        table.insert(teleporters, { itemID = 144391, itemName = "Pugilist's Powerful Punching Ring (Alliance)" })
        table.insert(teleporters, { itemID = 144392, itemName = "Pugilist's Powerful Punching Ring (Horde)" })
        table.insert(teleporters, { itemID = 150733, itemName = "Scroll of Town Portal (Ar'gorok in Arathi)" })
        table.insert(teleporters, { itemID = 151652, itemName = "Wormhole Generator: Argus" })
    end
    -- Section BFA
    if isRetail then
        table.insert(teleporters, { itemID = 159224, itemName = "Zuldazar Hearthstone" })
        table.insert(teleporters, { itemID = 160219, itemName = "Scroll of Town Portal (Stromgarde in Arathi)" })
        table.insert(teleporters, { itemID = 162973, itemName = "Greatfather Winter's Hearthstone" })
        table.insert(teleporters, { itemID = 163045, itemName = "Headless Horseman's Hearthstone" })
        table.insert(teleporters, { itemID = 163694, itemName = "Scroll of Luxurious Recall" })
        table.insert(teleporters, { itemID = 166559, itemName = "Commander's Signet of Battle" })
        table.insert(teleporters, { itemID = 166560, itemName = "Captain's Signet of Command" })
        table.insert(teleporters, { itemID = 165669, itemName = "Lunar Elder's Hearthstone" })
        table.insert(teleporters, { itemID = 165670, itemName = "Peddlefeet's Lovely Hearthstone" })
        table.insert(teleporters, { itemID = 165802, itemName = "Noble Gardener's Hearthstone" })
        table.insert(teleporters, { itemID = 166746, itemName = "Fire Eater's Hearthstone" })
        table.insert(teleporters, { itemID = 166747, itemName = "Brewfest Reveler's Hearthstone" })
        table.insert(teleporters, { itemID = 167075, itemName = "Ultrasafe Transporter: Mechagon" })
        table.insert(teleporters, { itemID = 168807, itemName = "Wormhole Generator: Kul Tiras" })
        table.insert(teleporters, { itemID = 168808, itemName = "Wormhole Generator: Zandalar" })
        table.insert(teleporters, { itemID = 168862, itemName = "G.E.A.R. Tracking Beacon" })
        table.insert(teleporters, { itemID = 168907, itemName = "Holographic Digitalization Hearthstone" })
        table.insert(teleporters, { itemID = 169064, itemName = "Montebank's Colorful Cloak" })
        table.insert(teleporters, { itemID = 169297, itemName = "Stormpike Insignia" })
        table.insert(teleporters, { itemID = 169862, itemName = "Alluring Bloom" })
    end
    -- Section Shadowlands
    if isRetail then
        table.insert(teleporters, { itemID = 172179, itemName = "Eternal Traveler's Hearthstone" })
        table.insert(teleporters, { itemID = 172203, itemName = "Cracked Hearthstone" })
        table.insert(teleporters, { itemID = 172924, itemName = "Wormhole Generator: Shadowlands" })
        table.insert(teleporters, { itemID = 173373, itemName = "Faol's Hearthstone" })
        table.insert(teleporters, { itemID = 173430, itemName = "Nexus Teleport Scroll" })
        table.insert(teleporters, { itemID = 173532, itemName = "Tirisfal Camp Scroll" })
        table.insert(teleporters, { itemID = 173528, itemName = "Gilded Hearthstone" })
        table.insert(teleporters, { itemID = 173537, itemName = "Glowing Hearthstone" })
        table.insert(teleporters, { itemID = 173716, itemName = "Mossy Hearthstone" })
        table.insert(teleporters, { itemID = 180290, itemName = "Night Fae Hearthstone" })
        table.insert(teleporters, { itemID = 180817, itemName = "Cypher of Relocation (Ve'nari's Refuge)" })
        table.insert(teleporters, { itemID = 181163, itemName = "Scroll of Teleport: Theater of Pain" })
        table.insert(teleporters, { itemID = 182773, itemName = "Necrolord's Hearthstone" })
        table.insert(teleporters, { itemID = 183716, itemName = "Venthyr Sinstone" })
        table.insert(teleporters, { itemID = 184353, itemName = "Kyrian Hearthstone" })
        table.insert(teleporters, { itemID = 184500, itemName = "Attendant's Pocket Portal: Bastion" })
        table.insert(teleporters, { itemID = 184501, itemName = "Attendant's Pocket Portal: Revendreth" })
        table.insert(teleporters, { itemID = 184502, itemName = "Attendant's Pocket Portal: Maldraxxus" })
        table.insert(teleporters, { itemID = 184503, itemName = "Attendant's Pocket Portal: Ardenweald" })
        table.insert(teleporters, { itemID = 184504, itemName = "Attendant's Pocket Portal: Oribos" })
        table.insert(teleporters, { itemID = 188952, itemName = "Dominated Hearthstone" })
        table.insert(teleporters, { itemID = 189827, itemName = "Cartel Xy's Proof of Initiation" })
        table.insert(teleporters, { itemID = 190196, itemName = "Enlightened Hearthstone" })
        table.insert(teleporters, { itemID = 190237, itemName = "Broker Translocation Matrix" })
        table.insert(teleporters, { itemID = 191029, itemName = "Lilian's Hearthstone" })
    end
    -- Section Dragonflight
    if isRetail then
        table.insert(teleporters, { itemID = 193000, itemName = "Ring-Bound Hourglass" })
        table.insert(teleporters, { itemID = 193588, itemName = "Timewalker's Hearthstone" })
        table.insert(teleporters, { itemID = 198156, itemName = "Wyrmhole Generator: Dragon Isles" })
        table.insert(teleporters, { itemID = 200613, itemName = "Aylaag Windstone Fragment" })
        table.insert(teleporters, { itemID = 200630, itemName = "Ohn'ir Windsage's Hearthstone" })
        table.insert(teleporters, { itemID = 201957, itemName = "Thrall's Hearthstone" })
        table.insert(teleporters, { itemID = 202046, itemName = "Lucky Tortollan Charm" })
        table.insert(teleporters, { itemID = 204481, itemName = "Morqut Hearth Totem" })
        table.insert(teleporters, { itemID = 204802, itemName = "Scroll of Teleport: Zskera Vaults" })
        table.insert(teleporters, { itemID = 205255, itemName = "Niffen Diggin' Mitts" })
        table.insert(teleporters, { itemID = 205456, itemName = "Lost Dragonscale (1)" })
        table.insert(teleporters, { itemID = 205458, itemName = "Lost Dragonscale (2)" })
        table.insert(teleporters, { itemID = 206195, itemName = "Path of the Naaru" })
        table.insert(teleporters, { itemID = 209035, itemName = "Hearthstone of the Flame" })
        table.insert(teleporters, { itemID = 210455, itemName = "Draenic Hologem" })
        table.insert(teleporters, { itemID = 211788, itemName = "Tess's Peacebloom" })
        table.insert(teleporters, { itemID = 212337, itemName = "Stone of the Hearth" })
        table.insert(teleporters, { itemID = 219222, itemName = "Time-Lost Artifact (Remix)" })
    end
    -- Section The War Within
    if isRetail then
        table.insert(teleporters, { itemID = 208704, itemName = "Deepdweller's Earthen Hearthstone" })
        table.insert(teleporters, { itemID = 223988, itemName = "Dalaran Hearthstone (Quest Item)" })
        table.insert(teleporters, { itemID = 228940, itemName = "Notorious Thread's Hearthstone" })
        table.insert(teleporters, { itemID = 228996, itemName = "Relic of Crystal Connections" })
        table.insert(teleporters, { itemID = 235016, itemName = "Redeployment Module" })
        table.insert(teleporters, { itemID = 230850, itemName = "Delve-O-Bot 7001" })
        table.insert(teleporters, { itemID = 236687, itemName = "Explosive Hearthstone" })
        table.insert(teleporters, { itemID = 234389, itemName = "Gallagio Loyalty Rewards Card: Silver" })
        table.insert(teleporters, { itemID = 234390, itemName = "Gallagio Loyalty Rewards Card: Gold" })
        table.insert(teleporters, { itemID = 234391, itemName = "Gallagio Loyalty Rewards Card: Platinum" })
        table.insert(teleporters, { itemID = 234392, itemName = "Gallagio Loyalty Rewards Card: Black" })
        table.insert(teleporters, { itemID = 234393, itemName = "Gallagio Loyalty Rewards Card: Diamond" })
        table.insert(teleporters, { itemID = 234394, itemName = "Gallagio Loyalty Rewards Card: Legendary" })
    end
    if interfaceVersion >= 110200 then
        table.insert(teleporters, { itemID = 243056, itemName = "Delver's Mana-Bound Ethergate" })
        table.insert(teleporters, { itemID = 245970, itemName = "P.O.S.T. Master's Express Hearthstone" })
        table.insert(teleporters, { itemID = 246565, itemName = "Cosmic Hearthstone" })
    end
end

function Teleporters:addTeleportersToCategory()
    local ctx = Context:New('BBTeleporters_AddItemToCategory')
    -- Loop through list of teleporters and add to category.
    for _, item in ipairs(teleporters) do
        Categories:AddItemToCategory(ctx, item.itemID, L:G("Teleporters"))
        --[==[@debug@
        print("Added " .. item.itemName .. " to category " .. L:G("Teleporters"))
        --@end-debug@]==]
    end
end

-- On plugin load, wipe the Categories we've added
function Teleporters:OnInitialize()
    self.db = AceDB:New("BetterBags_TeleportersDB", defaults)
    self.db:SetProfile("global")
    db = self.db.profile

    self:addTeleportersConfig()
    self:clearTeleportCategory()
    self:addTeleportItemsToTable()
    self:addTeleportersToCategory()
end
