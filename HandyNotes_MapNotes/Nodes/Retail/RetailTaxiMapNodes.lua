local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

function ns.LoadTaxiMapNodesLocationinfo(self)
local db = ns.Addon.db.profile
local nodes = ns.nodes
ns._currentSourceFile = "RetailTaxiMapNodes.lua"

    if not db.activate.HideMapNote then

        if self.db.profile.showTaxiMapNodes then
    -- Legion
        -- Broken Isles
            nodes[993][28423416] = { id = 740, type = "Dungeon", showInZone = true } -- Black Rook Hold
            nodes[993][33957188] = { id = 707, type = "Dungeon", showInZone = true } -- Vault of the Wardens
            nodes[993][38285817] = { id = 716, type = "Dungeon", showInZone = true } -- Eye of Azshara
            nodes[993][46296781] = { id = 777, type = "Dungeon", showInZone = true } -- Assault on Violet Hold
            nodes[993][56086098] = { id = 900, type = "Dungeon", showInZone = true } -- Cathedral of Eternal Night
            nodes[993][36492786] = { id = 762, type = "Dungeon", showInZone = true } -- Darkheart Thicket
            nodes[993][49444938] = { id = 800, type = "Dungeon", showInZone = true } -- Court of Stars
            nodes[993][47864933] = { id = 726, type = "Dungeon", showInZone = true } -- The Arcway
            nodes[993][45932857] = { id = 767, type = "Dungeon", showInZone = true } -- Neltharion's Lair
            nodes[993][59243069] = { id = 727, type = "Dungeon", showInZone = true } -- Maw of Souls
            nodes[993][65503711] = { id = 721, type = "Dungeon", showInZone = true } -- Halls of Valor
            nodes[993][55986339] = { id = 875, type = "Raid", showInZone = true } -- Tomb of Sargeras
            nodes[993][48454777] = { id = 786, type = "Raid", showInZone = true } -- The Nighthold
            nodes[993][34752937] = { id = 768, type = "Raid", showInZone = true } -- The Emerald Nightmare
            nodes[993][64083891] = { id = 861, type = "Raid", showInZone = true } -- Trial of Valor
        -- Argus
            nodes[994][33793542] = { id = 945, type = "Dungeon", showInZone = true } -- Seat of the Triumvirate
            nodes[994][22528337] = { id = 946, type = "Raid", showInZone = true } -- Antorus, the Burning Throne
            
    -- Shadowlands
        -- Shadowlands
            nodes[1647][68845981] = { id = 1182, type = "Dungeon", showInZone = true } -- The Necrotic Wake
            nodes[1647][74075232] = { id = 1186, type = "Dungeon", showInZone = true } -- Spires of Ascension
            nodes[1647][65142530] = { id = 1183, type = "Dungeon", showInZone = true } -- Plaguefall
            nodes[1647][63252202] = { id = 1187, type = "Dungeon", showInZone = true } -- Theater of Pain
            nodes[1647][44348287] = { id = 1184, type = "Dungeon", showInZone = true } -- Mists of Tirna Scithe
            nodes[1647][54338521] = { id = 1188, type = "Dungeon", showInZone = true } -- The Other Side
            nodes[1647][30995278] = { id = 1185, type = "Dungeon", showInZone = true } -- Halls of Atonement
            nodes[1647][25224904] = { id = 1189, type = "Dungeon", showInZone = true } -- Sanguine Depths
            nodes[1647][30787741] = { id = 1194, type = "Dungeon", showInZone = true } -- Tazavesh, the Veiled Market
            nodes[1647][23735036] = { id = 1190, type = "Raid", showInZone = true } -- Castle Nathria
            nodes[1647][27910861] = { id = 1193, type = "Raid", showInZone = true } -- Sanctum of Domination
        -- Bastion
            nodes[1569][39715521] = { id = 1182, type = "Dungeon", showInZone = true } -- The Necrotic Wake
            nodes[1569][58562847] = { id = 1186, type = "Dungeon", showInZone = true } -- Spires of Ascension
        -- Maldraxxus
            nodes[1741][57826229] = { id = 1183, type = "Dungeon", showInZone = true } -- Plaguefall
            nodes[1741][53205314] = { id = 1187, type = "Dungeon", showInZone = true } -- Theater of Pain
        -- Ardenweald
            nodes[1740][35625390] = { id = 1184, type = "Dungeon", showInZone = true } -- Mists of Tirna Scithe
            nodes[1740][68166412] = { id = 1188, type = "Dungeon", showInZone = true } -- The Other Side
        -- Revendreth
            nodes[1742][78204871] = { id = 1185, type = "Dungeon", showInZone = true } -- Halls of Atonement
            nodes[1742][51243157] = { id = 1189, type = "Dungeon", showInZone = true } -- Sanguine Depths
            nodes[1742][46944137] = { id = 1190, type = "Raid", showInZone = true } -- Castle Nathria
        -- Zereth Morthis
            nodes[2046][80685337] = { id = 1195, type = "Raid", showInZone = true } -- Sepulcher of the First Ones 

    -- Dragonflight
        -- Dragon Isles
            nodes[2057][43625184] = { id = 1198, type = "Dungeon", showInZone = true } -- The Nokhud Offensive
            nodes[2057][38896459] = { id = 1203, type = "Dungeon", showInZone = true } -- The Azure Vault
            nodes[2057][34667598] = { id = 1196, type = "Dungeon", showInZone = true } -- Brackenhide Hollow
            nodes[2057][63655934] = { id = 1209, type = "Dungeon", showInZone = true } -- Dawn of the Infinite
            nodes[2057][63324926] = { id = 1204, type = "Dungeon", showInZone = true } -- Halls of Infusion
            nodes[2057][62774192] = { id = 1201, type = "Dungeon", showInZone = true } -- Algeth'ar Academy
            nodes[2057][53084176] = { id = 1202, type = "Dungeon", showInZone = true } -- Ruby Life Pools
            nodes[2057][42463449] = { id = 1199, type = "Dungeon", showInZone = true } -- Neltharus
            nodes[2057][31075615] = { id = 1207, type = "Raid", showInZone = true } -- Amirdrassil, the Dream's Hope
            nodes[2057][70534613] = { id = 1200, type = "Raid", showInZone = true } -- Vault of the Incarnates
            nodes[2057][87017348] = { id = 1208, type = "Raid", showInZone = true } -- Aberrus, the Shadowed Crucible    
            nodes[2175][48451191] = { id = 1208, type = "Raid", showInZone = true } -- Aberrus, the Shadowed Crucible    
            nodes[2175][86588282] = { id = { 1207, 1200, 1198, 1203, 1196, 1209, 1204, 1201, 1202, 1199 }, type = "MultipleM", showInZone = true } -- all instances without Aberrus    
            nodes[2241][27123042] = { id = 1207, type = "Raid", showInZone = true } -- Amirdrassil, the Dream's Hope

    -- The war Within
        -- Khaz Algar
            nodes[2276][60244695] = { id = 1210, type = "Dungeon", showInZone = true } -- Darkflame Cleft
            nodes[2276][34935330] = { id = 1267, type = "Dungeon", showInZone = true } -- Priory of the Sacred Flame
            nodes[2276][40845861] = { id = 1270, type = "Dungeon", showInZone = true } -- The Dawnbreaker
            nodes[2276][53244131] = { id = 1269, type = "Dungeon", showInZone = true } -- The Stonevault
            nodes[2276][52735580] = { id = 1298, type = "Dungeon", showInZone = true } -- Operation: Floodgate
            nodes[2276][69881888] = { id = 1268, type = "Dungeon", showInZone = true } -- The Rookery
            nodes[2276][84172009] = { id = 1272, type = "Dungeon", showInZone = true } -- Cinderbrew Meadery
            nodes[2276][43578504] = { id = 1271, type = "Dungeon", showInZone = true } -- Ara-Kara, City of Echoes
            nodes[2276][43408075] = { id = 1274, type = "Dungeon", showInZone = true } -- City of Threads
            nodes[2276][41388856] = { id = 1273, type = "Raid", showInZone = true } -- Nerub-ar Palace
        -- Undermine
            nodes[2374][40295066] = { id = 1296, type = "Raid", showInZone = true } -- Liberation of Undermine
        -- K'aresh
            nodes[2398][65196877] = { id = 1303, type = "Dungeon", showInZone = true } -- Eco-Dome Al'dani
            nodes[2398][63657119] = { id = 1194, type = "Dungeon", showInZone = true } -- Tazavesh, the Veiled Market
            nodes[2398][42402157] = { id = 1302, type = "Raid", showInZone = true } -- Manaforge Omega

        end
    end
end