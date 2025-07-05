local instanceToMap = {
    [249] = 760, --"Onyxia's Lair"
    [329] = 1292, --"Stratholme"
    [532] = 745, --"Karazhan"
    [550] = 749, --"Tempest Keep"
    [556] = 252, --"Sethekk Halls"
    [575] = 286, --"Utgarde Pinnacle"
    [585] = 249, --"Magisters' Terrace"
    [603] = 759, --"Ulduar"
    [616] = 756, --"The Eye of Eternity"
    [624] = 753, --"Vault of Archavon"
    [631] = 758, --"Icecrown Citadel"
    [657] = 68, --"The Vortex Pinnacle"
    [720] = 78, --"Firelands"
    [725] = 67, --"The Stonecore"
    [754] = 74, --"Throne of the Four Winds"
    [859] = 76, --"Zul'Gurub"
    [967] = 187, --"Dragon Soul"
    [1008] = 317, --"Mogu'shan Vaults"
    [1098] = 362, --"Throne of Thunder"
    [1136] = 369, --"Siege of Orgrimmar"
    [1205] = 457, --"Blackrock Foundry"
    [1448] = 669, --"Hellfire Citadel"
    [1530] = 786, --"The Nighthold"
    [1651] = 860, --"Return to Karazhan"
    [1676] = 875, --"Tomb of Sargeras"
    [1712] = 946, --"Antorus, the Burning Throne"
    [1754] = 1001, --"Freehold"
    [1762] = 1041, --"Kings' Rest"
    [1841] = 1022, --"The Underrot"
    [2070] = 1176, --"Battle of Dazar'alor"
    [2217] = 1180, --"Ny'alotha, the Waking City"
    [2286] = 1182, --"The Necrotic Wake"
    [2441] = 1194, --"Tazavesh, the Veiled Market"
    [2450] = 1193, --"Sanctum of Domination"
    [2481] = 1195, --"Sepulcher of the First Ones"
}

local instanceOrderList = {
    249, 329, 532, 550, 556, 575, 585, 603, 616, 624, 631, 657, 720, 725,
    754, 859, 967, 1008, 1098, 1136, 1205, 1448, 1530, 1651, 1676, 1712,
    1754, 1762, 1841, 2070, 2217, 2286, 2441, 2450, 2481
}

local instanceOrderMap = {}
for i, id in ipairs(instanceOrderList) do
    instanceOrderMap[id] = i
end

local faction
local bossData = {
    [1] = { --difficultyID (1) Normal Dungeon
        [329] = { --instanceID
            {bossName = "Lord Aurius Rivendare", encounterID = 6, killed = false, mountID = 13335, journalMountID = 69, chance = 0.9, zoneID = 23, coordX = 0.4361, coordY = 0.1756},
        },
        [657] = { --instanceID
            {bossName = "Altairus", encounterID = 2, killed = false, mountID = 63040, journalMountID = 395, chance = 0.7, zoneID = 249, coordX = 0.7665, coordY = 0.8433},
        },
        [725] = { --instanceID
            {bossName = "Slabhide", encounterID = 2, killed = false, mountID = 63043, journalMountID = 397, chance = 0.7, zoneID = 207, coordX = 0.4743, coordY = 0.5254},
        },
    },
    [2] = { --difficultyID (2) Heroic Dungeon
        [556] = { --instanceID
            {bossName = "Anzu", encounterID = 2, killed = false, mountID = 32768, journalMountID = 185, chance = 1.6, zoneID = 108, coordX = 0.4455, coordY = 0.6549},
        },
        [585] = { --instanceID
            {bossName = "Kael'thas Sunstrider", encounterID = 4, killed = false, mountID = 35513, journalMountID = 213, chance = 4.0, zoneID = 122, coordX = 0.6082, coordY = 0.3077},
        },
        [575] = { --instanceID
            {bossName = "Skadi the Ruthless", encounterID = 3, killed = false, mountID = 44151, journalMountID = 264, chance = 0.8, zoneID = 117, coordX = 0.572, coordY = 0.4652},
        },
        [657] = { --instanceID
            {bossName = "Altairus", encounterID = 2, killed = false, mountID = 63040, journalMountID = 395, chance = 0.7, zoneID = 0, coordX = 0, coordY = 0},
        },
        [725] = { --instanceID
            {bossName = "Slabhide", encounterID = 2, killed = false, mountID = 63043, journalMountID = 397, chance = 0.7, zoneID = 0, coordX = 0, coordY = 0},
        },
        [859] = { --instanceID
            {bossName = "Bloodlord Mandokir", encounterID = 2, killed = false, mountID = 68823, journalMountID = 410, chance = 0.7, zoneID = 50, coordX = 0.7219, coordY = 0.3284},
            {bossName = "High Priestess Kilnara", encounterID = 7, killed = false, mountID = 68824, journalMountID = 411, chance = 0.9, zoneID = 50, coordX = 0.7219, coordY = 0.3284},
        },
        [2441] = { --instanceID
            {bossName = "So'leah", encounterID = 8, killed = false, mountID = 186638, journalMountID = 1481, chance = 2.0, zoneID = 1550, coordX = 0.3154, coordY = 0.7609},
        },
    },
    [3] = { --difficultyID (3) (10) Normal Raid
        [532] = { --instanceID
            {bossName = "Attumen the Huntsman", encounterID = 2, killed = false, mountID = 30480, journalMountID = 168, chance = 1.1, zoneID = 42, coordX = 0.4715, coordY = 0.7494},
        },
        [616] = { --instanceID
            {bossName = "Malygos", encounterID = 1, killed = false, mountID = 43952, journalMountID = 246, chance = 3.0, zoneID = 114, coordX = 0.2756, coordY = 0.2677},
            {bossName = "Malygos", encounterID = 1, killed = false, mountID = 43953, journalMountID = 247, chance = 4.0, zoneID = 114, coordX = 0.2756, coordY = 0.2677},
        },
        [624] = { --instanceID
            {bossName = "Archavon the Stone Watcher", encounterID = 1, killed = false, mountID = 43959, journalMountID = 286, chance = 1.1, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Emalon the Storm Watcher", encounterID = 2, killed = false, mountID = 43959, journalMountID = 286, chance = 1.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Koralon the Flame Watcher", encounterID = 3, killed = false, mountID = 43959, journalMountID = 286, chance = 1.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Toravon the Ice Watcher", encounterID = 4, killed = false, mountID = 43959, journalMountID = 286, chance = 0.8, zoneID = 123, coordX = 0.5008, coordY = 0.1189},
        },
        [249] = { --instanceID
            {bossName = "Onyxia", encounterID = 1, killed = false, mountID = 49636, journalMountID = 349, chance = 1.5, zoneID = 70, coordX = 0.5217, coordY = 0.7595},
        },
        [754] = { --instanceID
            {bossName = "Al'Akir", encounterID = 2, killed = false, mountID = 63041, journalMountID = 396, chance = 2.0, zoneID = 249, coordX = 0.3712, coordY = 0.8162},
        },
        [967] = { --instanceID
            {bossName = "Ultraxion", encounterID = 5, killed = false, mountID = 78919, journalMountID = 445, chance = 1.2, zoneID = 75, coordX = 0.6103, coordY = 0.2105},
            {bossName = "Madness of Deathwing", encounterID = 8, killed = false, mountID = 77067, journalMountID = 442, chance = 3.0, zoneID = 75, coordX = 0.6103, coordY = 0.2105},
        },
        [1008] = { --instanceID
            {bossName = "Elegon", encounterID = 5, killed = false, mountID = 87777, journalMountID = 478, chance = 4.0, zoneID = 379, coordX = 0.5967, coordY = 0.3963},
        },
        [1098] = { --instanceID
            {bossName = "Horridon", encounterID = 2, killed = false, mountID = 93666, journalMountID = 531, chance = 2.0, zoneID = 504, coordX = 0.6379, coordY = 0.3220},
            {bossName = "Ji-Kun", encounterID = 6, killed = false, mountID = 95059, journalMountID = 543, chance = 2.0, zoneID = 504, coordX = 0.6379, coordY = 0.3220},
        },
    },
    [4] = { --difficultyID (4) (25) Normal Raid
        [550] = { --instanceID
            {bossName = "Kael'thas Sunstrider", encounterID = 4, killed = false, mountID = 32458, journalMountID = 183, chance = 1.7, zoneID = 109, coordX = 0.7329, coordY = 0.6386},
        },
        [616] = { --instanceID
            {bossName = "Malygos", encounterID = 1, killed = false, mountID = 43952, journalMountID = 246, chance = 3.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Malygos", encounterID = 1, killed = false, mountID = 43953, journalMountID = 247, chance = 4.0, zoneID = 0, coordY = 0},
        },
        [624] = { --instanceID
            {bossName = "Archavon the Stone Watcher", encounterID = 1, killed = false, mountID = 43959, journalMountID = 286, chance = 1.1, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Emalon the Storm Watcher", encounterID = 2, killed = false, mountID = 43959, journalMountID = 286, chance = 1.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Koralon the Flame Watcher", encounterID = 3, killed = false, mountID = 43959, journalMountID = 286, chance = 1.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Toravon the Ice Watcher", encounterID = 4, killed = false, mountID = 43959, journalMountID = 286, chance = 0.8, zoneID = 0, coordX = 0, coordY = 0},
        },
        [249] = { --instanceID
            {bossName = "Onyxia", encounterID = 1, killed = false, mountID = 49636, journalMountID = 349, chance = 1.5, zoneID = 0, coordX = 0, coordY = 0},
        },
        [754] = { --instanceID
            {bossName = "Al'Akir", encounterID = 2, killed = false, mountID = 63041, journalMountID = 396, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [967] = { --instanceID
            {bossName = "Ultraxion", encounterID = 5, killed = false, mountID = 78919, journalMountID = 445, chance = 1.2, zoneID = 75, coordX = 0.6103, coordY = 0.2105},
            {bossName = "Madness of Deathwing", encounterID = 8, killed = false, mountID = 77067, journalMountID = 442, chance = 3.0, zoneID = 75, coordX = 0.6103, coordY = 0.2105},
            {bossName = "Madness of Deathwing", encounterID = 8, killed = false, mountID = 77069, journalMountID = 444, chance = 1.8, zoneID = 75, coordX = 0.6103, coordY = 0.2105},
        },
        [1008] = { --instanceID
            {bossName = "Elegon", encounterID = 5, killed = false, mountID = 87777, journalMountID = 478, chance = 4.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1098] = { --instanceID
            {bossName = "Horridon", encounterID = 2, killed = false, mountID = 93666, journalMountID = 531, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Ji-Kun", encounterID = 6, killed = false, mountID = 95059, journalMountID = 543, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
        },
    },
    [5] = { --difficultyID (5) (10) Heroic Raid
        [754] = { --instanceID
            {bossName = "Al'Akir", encounterID = 2, killed = false, mountID = 63041, journalMountID = 396, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [967] = { --instanceID
            {bossName = "Ultraxion", encounterID = 5, killed = false, mountID = 78919, journalMountID = 445, chance = 1.2, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Madness of Deathwing", encounterID = 8, killed = false, mountID = 77067, journalMountID = 442, chance = 3.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1008] = { --instanceID
            {bossName = "Elegon", encounterID = 5, killed = false, mountID = 87777, journalMountID = 478, chance = 4.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1098] = { --instanceID
            {bossName = "Horridon", encounterID = 2, killed = false, mountID = 93666, journalMountID = 531, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Ji-Kun", encounterID = 6, killed = false, mountID = 95059, journalMountID = 543, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
        },
    },
    [6] = { --difficultyID (6) (25) Heroic Raid
        [631] = { --instanceID
            {bossName = "The Lich King", encounterID = 12, killed = false, mountID = 50818, journalMountID = 363, chance = 0.8, zoneID = 118, coordX = 0.5391, coordY = 0.8729},
        },
        [754] = { --instanceID
            {bossName = "Al'Akir", encounterID = 2, killed = false, mountID = 63041, journalMountID = 396, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [967] = { --instanceID
            {bossName = "Ultraxion", encounterID = 5, killed = false, mountID = 78919, journalMountID = 445, chance = 1.2, zoneID = 71, coordX = 0.6528, coordY = 0.4815},
            {bossName = "Madness of Deathwing", encounterID = 8, killed = false, mountID = 77067, journalMountID = 442, chance = 3.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Madness of Deathwing", encounterID = 8, killed = false, mountID = 77069, journalMountID = 444, chance = 1.8, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1008] = { --instanceID
            {bossName = "Elegon", encounterID = 5, killed = false, mountID = 87777, journalMountID = 478, chance = 4.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1098] = { --instanceID
            {bossName = "Horridon", encounterID = 2, killed = false, mountID = 93666, journalMountID = 531, chance = 2.0, zoneID = 10, coordX = 49, coordY = 49},
            {bossName = "Ji-Kun", encounterID = 6, killed = false, mountID = 95059, journalMountID = 543, chance = 2.0, zoneID = 504, coordX = 0.6379, coordY = 0.3220},
        },
    },
    [14] = { --difficultyID (14) Normal Raid
        [603] = { --instanceID
            {bossName = "Yogg-Saron", encounterID = 13, killed = false, mountID = 45693, journalMountID = 304, chance = 1.0, zoneID = 120, coordX = 0.4179, coordY = 0.1754},
        },
        [720] = { --instanceID
            {bossName = "Alysrazor", encounterID = 3, killed = false, mountID = 71665, journalMountID = 425, chance = 2.0, zoneID = 198, coordX = 0.4647, coordY = 0.7812},
            {bossName = "Ragnaros", encounterID = 7, killed = false, mountID = 69224, journalMountID = 415, chance = 1.7, zoneID = 198, coordX = 0.4647, coordY = 0.7812},
        },
        [1530] = { --instanceID
            {bossName = "Gul'dan", encounterID = 10, killed = false, mountID = 137574, journalMountID = 791, chance = 0.5, zoneID = 680, coordX = 0.4349, coordY = 0.5707},
        },
        [1676] = { --instanceID
            {bossName = "Mistress Sassz'ine", encounterID = 5, killed = false, mountID = 143643, journalMountID = 899, chance = 0.2, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1712] = { --instanceID
            {bossName = "Felhounds of Sargeras", encounterID = 2, killed = false, mountID = 152816, journalMountID = 971, chance = 1.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [2070] = { --instanceID
            {bossName = "Mekkatorque", encounterID = 7, killed = false, mountID = 166518, journalMountID = 1217, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [2450] = { --instanceID
            {bossName = "The Nine", encounterID = 3, killed = false, mountID = 186656, journalMountID = 1500, chance = 0.3, zoneID = 0, coordX = 0, coordY = 0},
        },
    },
    [15] = { --difficultyID (14) Heroic Raid
        [720] = { --instanceID
            {bossName = "Alysrazor", encounterID = 3, killed = false, mountID = 71665, journalMountID = 425, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Ragnaros", encounterID = 7, killed = false, mountID = 69224, journalMountID = 415, chance = 1.7, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1530] = { --instanceID
            {bossName = "Gul'dan", encounterID = 10, killed = false, mountID = 137574, journalMountID = 791, chance = 0.5, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1676] = { --instanceID
            {bossName = "Mistress Sassz'ine", encounterID = 5, killed = false, mountID = 143643, journalMountID = 899, chance = 0.2, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1712] = { --instanceID
            {bossName = "Felhounds of Sargeras", encounterID = 2, killed = false, mountID = 152816, journalMountID = 971, chance = 1.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [2070] = { --instanceID
            {bossName = "Mekkatorque", encounterID = 7, killed = false, mountID = 166518, journalMountID = 1217, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
        },
        [2450] = { --instanceID
            {bossName = "The Nine", encounterID = 3, killed = false, mountID = 186656, journalMountID = 1500, chance = 0.3, zoneID = 0, coordX = 0, coordY = 0},
        },
    },
    [16] = { --difficultyID (16) Mythic Raid
        [1136] = { --instanceID
            {bossName = "Garrosh Hellscream", encounterID = 14, killed = false, mountID = 104253, journalMountID = 559, chance = 0.9, zoneID = 390, coordX = 0.7421, coordY = 0.4202},
        },
        [1205] = { --instanceID
            {bossName = "Blackhand", encounterID = 10, killed = false, mountID = 116660, journalMountID = 613, chance = 2.0, zoneID = 543, coordX = 0.5146, coordY = 0.2710},
        },
        [1448] = { --instanceID
            {bossName = "Archimonde", encounterID = 13, killed = false, mountID = 123890, journalMountID = 751, chance = 4.0, zoneID = 534, coordX = 0.4689, coordY = 0.5213},
        },
        [1530] = { --instanceID
            {bossName = "Gul'dan", encounterID = 10, killed = false, mountID = 137574, journalMountID = 791, chance = 0.5, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Gul'dan", encounterID = 10, killed = false, mountID = 137575, journalMountID = 633, chance = 8.0, zoneID = 680, coordX = 0.4349, coordY = 0.5707},
        },
        [1676] = { --instanceID
            {bossName = "Mistress Sassz'ine", encounterID = 5, killed = false, mountID = 143643, journalMountID = 899, chance = 0.2, zoneID = 0, coordX = 0, coordY = 0},
        },
        [1712] = { --instanceID
            {bossName = "Felhounds of Sargeras", encounterID = 2, killed = false, mountID = 152816, journalMountID = 971, chance = 1.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Argus the Unmaker", encounterID = 11, killed = false, mountID = 152789, journalMountID = 954, chance = 0.8, zoneID = 885, coordX = 0.5486, coordY = 0.6256},
        },
        [2070] = { --instanceID
            {bossName = "Mekkatorque", encounterID = 7, killed = false, mountID = 166518, journalMountID = 1217, chance = 2.0, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Lady Jaina Proudmoore", encounterID = 9, killed = false, mountID = 166705, journalMountID = 1219, chance = 0.6, zoneID = {895, 862}, coordX = {0.7444, 0.5421}, coordY = {0.2853, 0.2991}},
        },
        [2217] = { --instanceID
            {bossName = "N'Zoth the Corruptor", encounterID = 12, killed = false, mountID = 174872, journalMountID = 1293, chance = 0.6, zoneID = 0, coordX = 0, coordY = 0},
        },
        [2450] = { --instanceID
            {bossName = "The Nine", encounterID = 3, killed = false, mountID = 186656, journalMountID = 1500, chance = 0.3, zoneID = 0, coordX = 0, coordY = 0},
            {bossName = "Sylvanas Windrunner", encounterID = 10, killed = false, mountID = 186642, journalMountID = 1471, chance = 0.4, zoneID = 1543, coordX = 0.6974, coordY = 0.322},
        },
        [2481] = { --instanceID
            {bossName = "The Jailer", encounterID = 11, killed = false, mountID = 190768, journalMountID = 1587, chance = 0.5, zoneID = 1970, coordX = 0.8026, coordY = 0.5302},
        },
    },
    [23] = { --difficultyID (23) Mythic Dungeon
        [1651] = { --instanceID
            {bossName = "Attumen the Huntsman", encounterID = 5, killed = false, mountID = 142236, journalMountID = 875, chance = 0.9, zoneID = 42, coordX = 0.4715, coordY = 0.7494},
        },
        [1754] = { --instanceID
            {bossName = "Lord Harlan Sweete", encounterID = 4, killed = false, mountID = 159842, journalMountID = 995, chance = 0.8, zoneID = 895, coordX = 0.843, coordY = 0.7836},
        },
        [1762] = { --instanceID
            {bossName = "King Dazar", encounterID = 4, killed = false, mountID = 159921, journalMountID = 1040, chance = 0.7, zoneID = 862, coordX = 0.3712, coordY = 0.3938},
        },
        [1841] = { --instanceID
            {bossName = "Unbound Abomination", encounterID = 4, killed = false, mountID = 160829, journalMountID = 1053, chance = 0.7, zoneID = 863, coordX = 0.5125, coordY = 0.6472},
        },
        [2286] = { --instanceID
            {bossName = "Nalthor the Rimebinder", encounterID = 4, killed = false, mountID = 181819, journalMountID = 1406, chance = 0.8, zoneID = 1533, coordX = 0.4017, coordY = 0.5516},
        },
        [2441] = { --instanceID
            {bossName = "So'leah", encounterID = 8, killed = false, mountID = 186638, journalMountID = 1481, chance = 2.0, zoneID = 1550, coordX = 0.3154, coordY = 0.7609},
        },
    },
    [17] = { --difficultyID (17) LFR Raid
        [1676] = { --instanceID
            {bossName = "Mistress Sassz'ine", encounterID = 5, killed = false, mountID = 143643, journalMountID = 899, chance = 0.2, zoneID = 646, coordX = 0.6397, coordY = 0.2138, lfr = {619, 0.4647, 0.6488, 627}},
        },
        [1712] = { --instanceID
            {bossName = "Felhounds of Sargeras", encounterID = 2, killed = false, mountID = 152816, journalMountID = 971, chance = 1.0, zoneID = 885, coordX = 0.5486, coordY = 0.6256, lfr = {619, 0.4647, 0.6488, 627}},
        },
        [2070] = { --instanceID
            {bossName = "Lady Jaina Proudmoore", encounterID = 9, killed = false, mountID = 166518, journalMountID = 1217, chance = 2.0, zoneID = {895, 862}, coordX = {0.7444, 0.5421}, coordY = {0.2853, 0.2991}, lfr = {{1161, 0.7418, 0.135}, {1164, 0.6859, 0.3042}}},
        },
        [2450] = { --instanceID
            {bossName = "The Nine", encounterID = 3, killed = false, mountID = 186656, journalMountID = 1500, chance = 0.3, zoneID = 1543, coordX = 0.6974, coordY = 0.322, lfr = {1670, 0.4163, 0.711}},
        },
    },
}

local addonName = ...
MyMountTracker = {}
BountyHelperDB = {}

MyMountTracker.cachedMountNames = {}
MyMountTracker.mountDataIsLoading = false
MyMountTracker.mountDataLoaded = false

local hideOwned = false
local hideKilled = false
local hideButton = false
local currentScale = 1.0
local minimapButton = nil

MyMountTracker.Frames = {}
MyMountTracker.ContentFrames = {}
MyMountTracker.MountViewContentFrames = {}

local function safeGet(tbl, ...)
    local t = tbl
    for _, key in ipairs({...}) do
        if type(t) ~= "table" then return nil end
        t = t[key]
    end
    return t
end

local function sharedDifficulty(difficultyID, bossData, instanceID, encounterID)
    local sharedGroups = {
        {3, 4, 5, 6},
    }

    local targetGroup = nil
    for _, group in ipairs(sharedGroups) do
        for _, idInGroup in ipairs(group) do
            if idInGroup == difficultyID then
                targetGroup = group
                break
            end
        end
        if targetGroup then
            break
        end
    end

    if targetGroup then
        for _, sharedID in ipairs(targetGroup) do
            if sharedID ~= difficultyID then
                local sharedBossList = safeGet(bossData, sharedID, instanceID)
                if sharedBossList then
                    for _, bossEntry in ipairs(sharedBossList) do
                        if bossEntry.encounterID == encounterID then
                            bossEntry.killed = true
                        end
                    end
                end
            end
        end
    end
end

local difficultyInfo = {
    [1] = {name = "普通地下城", expanded = false},
    [2] = {name = "英雄地下城", expanded = false},
    [3] = {name = "普通10人团队", expanded = false},
    [4] = {name = "普通25人团队", expanded = false},
    [5] = {name = "英雄10人团队", expanded = false},
    [6] = {name = "英雄25人团队", expanded = false},
    [14] = {name = "普通团队", expanded = false},
    [15] = {name = "英雄团队", expanded = false},
    [16] = {name = "史诗团队", expanded = false},
    [17] = {name = "随机团队", expanded = false},
    [23] = {name = "史诗地下城", expanded = false},
    order = {17, 3, 4, 14, 5, 6, 15, 16, 1, 2, 23}
}

local COLORS = {
    GOLD = "|cffffd700", GREEN = "|cff00ff00", RED = "|cffff4040",
    GREY = "|cffb0b0b0", WHITE = "|cffffffff", BLUE = "|cff70aeff",
}

dbBH = {minimap = {hide = false}}
local buttonBH
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("BountyHelper",{
  icon = "Interface\\AddOns\\BountyHelper\\Assets\\icon",
  OnClick = function(self,button) if button == "LeftButton" then SlashCmdList["CBH"]() end end,
  OnTooltipShow = function(tooltip)
    tooltip:AddLine("|cffffffffBounty Helper")
    tooltip:AddLine(COLORS.GREEN .. "<Left Click to toggle>")
    tooltip:SetScale(GameTooltip:GetScale())
  end
})

function MyMountTracker:CreateUI()
    local f = CreateFrame("Frame", "MyMountTrackerFrame", UIParent, "BackdropTemplate")
    table.insert(UISpecialFrames, "MyMountTrackerFrame")
    f:SetSize(650, 600)
    f:SetFrameStrata("HIGH")
    f:SetPoint("CENTER")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnMouseDown", f.StartMoving)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)
    f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    f:SetBackdropColor(0.03, 0.03, 0.03, 0.825)
    f:Hide()
    MyMountTracker.Frames.Main = f

    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(COLORS.GOLD .. "Bounty Helper")

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -8, -8)
    closeButton:SetScript("OnClick", function(self)
        MyMountTracker.Frames.Main:Hide()
    end)

    local toMountViewButton = CreateFrame("Button", "MyMountTrackerToMountViewButton", f, "UIPanelButtonTemplate")
    toMountViewButton:SetPoint("TOPRIGHT", -45, -6)
    toMountViewButton:SetText("按坐骑排序")
    toMountViewButton:SetSize(120, 22)
    toMountViewButton:SetScale(1.2)
    toMountViewButton:SetScript("OnClick", function() MyMountTracker:ShowMountView() end)
    MyMountTracker.Frames.ToMountViewButton = toMountViewButton

    local toDifficultyViewButton = CreateFrame("Button", "MyMountTrackerToDifficultyViewButton", f, "UIPanelButtonTemplate")
    toDifficultyViewButton:SetPoint("TOPRIGHT", -45, -6)
    toDifficultyViewButton:SetText("按难度排序")
    toDifficultyViewButton:SetSize(120, 22)
    toDifficultyViewButton:SetScale(1.2)
    toDifficultyViewButton:SetScript("OnClick", function() MyMountTracker:ShowDifficultyView() end)
    MyMountTracker.Frames.ToDifficultyViewButton = toDifficultyViewButton

    local diffScrollFrame = CreateFrame("ScrollFrame", "MyMountTrackerScrollFrame", f, "UIPanelScrollFrameTemplate")
    diffScrollFrame:SetPoint("TOPLEFT", 12, -40)
    diffScrollFrame:SetPoint("BOTTOMRIGHT", -32, 42)
    MyMountTracker.Frames.ScrollFrame = diffScrollFrame

    local diffScrollChild = CreateFrame("Frame", "MyMountTrackerScrollChild")
    diffScrollChild:SetSize(f:GetWidth() - 44, 1)
    diffScrollFrame:SetScrollChild(diffScrollChild)
    MyMountTracker.Frames.ScrollChild = diffScrollChild

    local mountScrollFrame = CreateFrame("ScrollFrame", "MyMountTrackerMountViewScrollFrame", f, "UIPanelScrollFrameTemplate")
    mountScrollFrame:SetPoint("TOPLEFT", 12, -40)
    mountScrollFrame:SetPoint("BOTTOMRIGHT", -32, 42)
    MyMountTracker.Frames.MountViewScrollFrame = mountScrollFrame

    local mountScrollChild = CreateFrame("Frame", "MyMountTrackerMountViewScrollChild")
    mountScrollChild:SetSize(f:GetWidth() - 44, 1)
    mountScrollFrame:SetScrollChild(mountScrollChild)
    MyMountTracker.Frames.MountViewScrollChild = mountScrollChild
    
    local separator = f:CreateTexture(nil, "ARTWORK")
    separator:SetTexture("Interface\\Buttons\\WHITE8x8")
    separator:SetColorTexture(1, 0.7529411764705882, 0, 1)
    separator:SetHeight(2)
    separator:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 32)
    separator:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 32)
    
    local scaleSlider = CreateFrame("Slider", "MyMountTrackerScaleSlider", f, "UISliderTemplate")
    scaleSlider:SetPoint("BOTTOMLEFT", 8, 5)
    scaleSlider:SetWidth(150)
    scaleSlider:SetHeight(22)
    scaleSlider:SetMinMaxValues(0.5, 1.5)
    scaleSlider:SetValueStep(0.05)
    MyMountTracker.Frames.ScaleSlider = scaleSlider

    local scaleValueText = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    scaleValueText:SetFont(STANDARD_TEXT_FONT, 14)
    scaleValueText:SetPoint("LEFT", scaleSlider, "RIGHT", 8, 0)
    MyMountTracker.Frames.ScaleValueText = scaleValueText

    scaleSlider:SetScript("OnValueChanged", function(self, value)
        local roundedValue = tonumber(string.format("%.2f", value))
        MyMountTracker.Frames.ScaleValueText:SetText(string.format("UI缩放: %.2f", roundedValue))
    end)

    scaleSlider:SetScript("OnMouseUp", function(self)
        local value = self:GetValue()
        local roundedValue = tonumber(string.format("%.2f", value))
        MyMountTracker.Frames.Main:SetScale(roundedValue)
        currentScale = roundedValue
    end)

    local hideButtonCheckbox = CreateFrame("CheckButton", "MyMountTrackerHideButtonCheckbox", f, "UICheckButtonTemplate")
    hideButtonCheckbox:SetPoint("LEFT", scaleSlider, "RIGHT", 100, 0)
    hideButtonCheckbox.text = hideButtonCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    hideButtonCheckbox.text:SetFont(STANDARD_TEXT_FONT, 14)
    hideButtonCheckbox.text:SetPoint("LEFT", hideButtonCheckbox, "RIGHT", 0, 1)
    hideButtonCheckbox.text:SetText("隐藏小地图图标")
    hideButtonCheckbox:SetScript("OnClick", function(self)
        hideButton = self:GetChecked()
        buttonBH:SetShown(not hideButton)
        dbBH.minimap.hide = hideButton
        MyMountTracker:UpdateVisibleFrame()
    end)
    MyMountTracker.Frames.HideButtonCheckbox = hideButtonCheckbox
    
    local hideOwnedCheckbox = CreateFrame("CheckButton", "MyMountTrackerHideOwnedCheckbox", f, "UICheckButtonTemplate")
    hideOwnedCheckbox:SetPoint("LEFT", scaleSlider, "RIGHT", 238, 0)
    hideOwnedCheckbox.text = hideOwnedCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    hideOwnedCheckbox.text:SetFont(STANDARD_TEXT_FONT, 14)
    hideOwnedCheckbox.text:SetPoint("LEFT", hideOwnedCheckbox, "RIGHT", 0, 1)
    hideOwnedCheckbox.text:SetText("隐藏已拥有")
    hideOwnedCheckbox:SetScript("OnClick", function(self)
        hideOwned = self:GetChecked()
        MyMountTracker:UpdateVisibleFrame()
    end)
    MyMountTracker.Frames.HideOwnedCheckbox = hideOwnedCheckbox

    local hideKilledCheckbox = CreateFrame("CheckButton", "MyMountTrackerHideKilledCheckbox", f, "UICheckButtonTemplate")
    hideKilledCheckbox:SetPoint("LEFT", scaleSlider, "RIGHT", 365, 0)
    hideKilledCheckbox.text = hideKilledCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    hideKilledCheckbox.text:SetFont(STANDARD_TEXT_FONT, 14)
    hideKilledCheckbox.text:SetPoint("LEFT", hideKilledCheckbox, "RIGHT", 0, 1)
    hideKilledCheckbox.text:SetText("隐藏已击杀")
    hideKilledCheckbox:SetScript("OnClick", function(self)
        hideKilled = self:GetChecked()
        MyMountTracker:UpdateVisibleFrame()
    end)
    MyMountTracker.Frames.HideKilledCheckbox = hideKilledCheckbox
end

function MyMountTracker:CreateCategoryHeader(parent, difficultyID)
    local info = difficultyInfo[difficultyID]
    if not info then return nil end

    local header = CreateFrame("Button", nil, parent)
    header:SetSize(parent:GetWidth(), 32)
    header.isHeader = true
    header.bossRows = {}
    header.difficultyID = difficultyID

    local bg = header:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0, 0, 0, 0.9)

    local expander = header:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    expander:SetPoint("LEFT", 10, 0)
    header.expander = expander

    local title = header:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("LEFT", expander, "RIGHT", 8, 0)
    title:SetText(COLORS.BLUE .. info.name)
    title:SetJustifyH("LEFT")

    header:SetScript("OnClick", function(self)
        info.expanded = not info.expanded
        MyMountTracker:UpdateLayout()
    end)
    
    return header
end

function MyMountTracker:CreateBossRow(parent, bossData, header, instanceID)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 20, 52)
    row.bossData = bossData
    row.headerFrame = header
    local data = bossData
    local mapName = instanceToMap[instanceID] or "Unknown Map"

    local icon = CreateFrame("Button", nil, row)
    icon:SetSize(48, 48)
    icon:SetPoint("LEFT", 5, 0)
    icon:SetNormalTexture(GetItemIcon(data.mountID))
    icon:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:SetItemByID(data.mountID); GameTooltip:Show() end)
    icon:SetScript("OnLeave", GameTooltip_Hide)
    icon:SetScript("OnClick", function(_, button) if IsControlKeyDown() then DressUpMount(data.journalMountID) end end)

    local nameText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    nameText:SetWidth(150)
    nameText:SetWordWrap(false)
    nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 14, -10)
    nameText:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
    nameText:SetText(COLORS.WHITE .. data.bossName)
    nameText:SetJustifyH("LEFT")
    nameText:EnableMouse(true)
    nameText:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText(data.bossName)
        GameTooltip:Show()
    end)
    nameText:SetScript("OnLeave", GameTooltip_Hide)
    
    local mapNameText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    mapNameText:SetWidth(150)
    mapNameText:SetWordWrap(false)
    mapNameText:SetPoint("TOPLEFT", nameText, "RIGHT", 8, 0)
    mapNameText:SetFont(STANDARD_TEXT_FONT, 14)
    mapNameText:SetText(COLORS.BLUE .. mapName)
    mapNameText:SetJustifyH("LEFT")
    mapNameText:EnableMouse(true)
    mapNameText:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText(mapName)
        GameTooltip:Show()
    end)
    mapNameText:SetScript("OnLeave", GameTooltip_Hide)

    local statusText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    statusText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -3)
    statusText:SetFont(STANDARD_TEXT_FONT, 14)
    statusText:SetJustifyH("LEFT")
    row.statusText = statusText

    local chanceText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    chanceText:SetPoint("RIGHT", -15, 0)
    chanceText:SetFont(STANDARD_TEXT_FONT, 14)
    chanceText:SetJustifyH("RIGHT")
    chanceText:SetFormattedText( "掉率: %s%s|r -> %s%.2f%%|r", COLORS.GREY, (data.chance == 0) and "unknown" or string.format("%.2f%%", data.chance), COLORS.GREEN, data.chance + 5.0)
    
    return row
end


function MyMountTracker:PopulateList()
    local scrollChild = MyMountTracker.Frames.ScrollChild
    
    for _, frame in ipairs(MyMountTracker.ContentFrames) do
        frame:Hide()
    end
    wipe(MyMountTracker.ContentFrames)

    for _, difficultyID in ipairs(difficultyInfo.order) do
        local diffData = bossData[difficultyID]
        local info = difficultyInfo[difficultyID]

        if diffData and info then
            local header = MyMountTracker:CreateCategoryHeader(scrollChild, difficultyID)
            table.insert(MyMountTracker.ContentFrames, header)

            local sortedInstanceIDs = {}
            for instanceID in pairs(diffData) do
                table.insert(sortedInstanceIDs, instanceID)
            end

            table.sort(sortedInstanceIDs, function(a, b)
                local orderA = instanceOrderMap[a] or 9999
                local orderB = instanceOrderMap[b] or 9999
                return orderA < orderB
            end)

            for _, instanceID in ipairs(sortedInstanceIDs) do
                local bossList = diffData[instanceID]
                for _, bossEntryData in ipairs(bossList) do
                    local row = MyMountTracker:CreateBossRow(scrollChild, bossEntryData, header, instanceID)
                    table.insert(header.bossRows, row)
                    table.insert(MyMountTracker.ContentFrames, row)
                end
            end
        end
    end
end

function MyMountTracker:UpdateLayout()
    local scrollChild = MyMountTracker.Frames.ScrollChild
    local lastVisibleFrame = nil
    local totalHeight = 0
    local yPadding = 4
    local xIndent = 20

    for _, frame in ipairs(MyMountTracker.ContentFrames) do
        local isVisible = true
        if frame.isHeader then
            local info = difficultyInfo[frame.difficultyID]
            frame.expander:SetText(info.expanded and "-" or "+")
        else
            local data = frame.bossData
            local header = frame.headerFrame
            local categoryInfo = difficultyInfo[header.difficultyID]
            if not categoryInfo.expanded then isVisible = false end
            
            local isOwned = data.journalMountID and C_MountJournal.GetMountInfoByID(data.journalMountID) and select(11, C_MountJournal.GetMountInfoByID(data.journalMountID))

            if isVisible and hideOwned and isOwned then
                isVisible = false
            end
            if isVisible and hideKilled and data.killed and not isOwned then
                isVisible = false
            end

            if isOwned then
                frame.statusText:SetText(COLORS.GREEN .. "[已拥有] ✓")
            else
                frame.statusText:SetText(data.killed and (COLORS.GREEN .. "已击杀") or (COLORS.RED .. "未击杀"))
            end
        end
        frame:SetShown(isVisible)
    end

    for _, frame in ipairs(MyMountTracker.ContentFrames) do
        if frame:IsShown() then
            frame:ClearAllPoints()
            if not lastVisibleFrame then
                frame:SetPoint("TOP", scrollChild, "TOP", 0, 0)
            else
                frame:SetPoint("TOP", lastVisibleFrame, "BOTTOM", 0, -yPadding)
            end

            if frame.isHeader then
                frame:SetPoint("LEFT", scrollChild, "LEFT", 0, 0)
            else
                frame:SetPoint("LEFT", scrollChild, "LEFT", xIndent, 0)
            end
            
            lastVisibleFrame = frame
            totalHeight = totalHeight + frame:GetHeight() + yPadding
        end
    end

    scrollChild:SetHeight(math.max(1, totalHeight - yPadding + 10))
end

function MyMountTracker:GetUnsortedMountCentricData()
    local mountCentricData = {}
    for difficultyID, instances in pairs(bossData) do
        for instanceID, bosses in pairs(instances) do
            for _, bossEntry in ipairs(bosses) do
                local mountID = bossEntry.mountID
                if not mountCentricData[mountID] then
                    mountCentricData[mountID] = { sources = {}, journalMountID = bossEntry.journalMountID }
                end
                table.insert(mountCentricData[mountID].sources, {
                    difficultyID = difficultyID,
                    instanceID = instanceID,
                    originalData = bossEntry
                })
            end
        end
    end

    local orderMap = {}
    for i, id in ipairs(difficultyInfo.order) do
        orderMap[id] = i
    end

    for mountID, data in pairs(mountCentricData) do
        table.sort(data.sources, function(a, b)
            return (orderMap[a.difficultyID] or 999) < (orderMap[b.difficultyID] or 999)
        end)
    end
    
    return mountCentricData
end

function MyMountTracker:LoadMountData(onCompleteCallback)
    if self.mountDataLoaded then
        onCompleteCallback()
        return
    end
    if self.mountDataIsLoading then return end

    self.mountDataIsLoading = true

    local uniqueMountIDs = {}
    local seen = {}
    for _, instances in pairs(bossData) do
        for _, bosses in pairs(instances) do
            for _, bossEntry in ipairs(bosses) do
                if not seen[bossEntry.mountID] then
                    table.insert(uniqueMountIDs, bossEntry.mountID)
                    seen[bossEntry.mountID] = true
                end
            end
        end
    end

    if #uniqueMountIDs == 0 then
        self.mountDataIsLoading = false
        self.mountDataLoaded = true
        onCompleteCallback()
        return
    end

    local pendingLoads = #uniqueMountIDs
    for _, mountID in ipairs(uniqueMountIDs) do
        local item = Item:CreateFromItemID(mountID)
        item:ContinueOnItemLoad(function()
            self.cachedMountNames[mountID] = item:GetItemName() or ("Unknown Mount: " .. mountID)
            
            pendingLoads = pendingLoads - 1
            if pendingLoads == 0 then
                self.mountDataIsLoading = false
                self.mountDataLoaded = true
                onCompleteCallback()
            end
        end)
    end
end

function MyMountTracker:_BuildMountViewUI()
    local scrollChild = self.Frames.MountViewScrollChild
    
    for _, frame in ipairs(self.MountViewContentFrames) do frame:Hide() end
    wipe(self.MountViewContentFrames)

    local mountCentricData = self:GetUnsortedMountCentricData()

    local sortedKeys = {}
    for mountID in pairs(mountCentricData) do
        table.insert(sortedKeys, mountID)
    end
    
    table.sort(sortedKeys, function(a, b)
        local dataA = mountCentricData[a]
        local dataB = mountCentricData[b]

        local primarySourceA = dataA.sources and dataA.sources[1]
        local primarySourceB = dataB.sources and dataB.sources[1]

        if not primarySourceA and not primarySourceB then return false end
        if not primarySourceA then return false end
        if not primarySourceB then return true end

        local instanceIdA = primarySourceA.instanceID
        local instanceIdB = primarySourceB.instanceID
        
        local orderA = instanceOrderMap[instanceIdA] or 9999
        local orderB = instanceOrderMap[instanceIdB] or 9999

        if orderA ~= orderB then
            return orderA < orderB
        end

        local nameA = self.cachedMountNames[a] or ""
        local nameB = self.cachedMountNames[b] or ""
        return nameA < nameB
    end)
    
    for _, mountID in ipairs(sortedKeys) do
        local mountGroup = mountCentricData[mountID]
        
        local chance = 0
        if mountGroup.sources and #mountGroup.sources > 0 then
            chance = mountGroup.sources[1].originalData.chance
        end

        local headerRow = self:CreateMountHeaderRow(scrollChild, mountID, mountGroup.journalMountID, self.cachedMountNames[mountID], chance)
        
        if mountGroup.sources and #mountGroup.sources > 0 then
            local primarySource = mountGroup.sources[1].originalData
            local mountLink = select(2, GetItemInfo(mountID)) or tostring(mountID)

            headerRow:SetScript("OnEnter", function(self)
                if self.border then self.border:Show() end
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
                GameTooltip:SetText(COLORS.GREEN .. "<左键点击以添加地图标记>");
                GameTooltip:Show()
            end)
            headerRow:SetScript("OnLeave", function(self)
                if self.border then self.border:Hide() end
                GameTooltip_Hide()
            end)
            headerRow:SetScript("OnClick", function(self, button)
                if IsControlKeyDown() and mountGroup.journalMountID then
                    DressUpMount(mountGroup.journalMountID)
                elseif primarySource.zoneID and primarySource.zoneID ~= 0 then
                    if type(primarySource.zoneID) == "table" then
                        primarySource.zoneID = primarySource.zoneID[faction]
                        primarySource.coordX = primarySource.coordX[faction]
                        primarySource.coordY = primarySource.coordY[faction]
                    end
                    local waypoint = UiMapPoint.CreateFromCoordinates(primarySource.zoneID, primarySource.coordX, primarySource.coordY)
                    C_Map.SetUserWaypoint(waypoint)
                    C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                    if primarySource.zoneID == 1550 then
                        OpenWorldMap(2016)
                    else
                        OpenWorldMap(primarySource.zoneID)
                    end
                    print(string.format("%sBounty Helper:|r Waypoint set for %s", COLORS.GOLD, mountLink))
                else
                    print(string.format("%sBounty Helper:|r No location data available for %s", COLORS.GOLD, mountLink))
                end
            end)
        end
        
        table.insert(self.MountViewContentFrames, headerRow)

        for _, source in ipairs(mountGroup.sources) do
            local sourceRow = self:CreateMountSourceRow(scrollChild, source)
            table.insert(headerRow.sourceRows, sourceRow)
            table.insert(self.MountViewContentFrames, sourceRow)
        end
    end

    self:UpdateMountViewLayout()
end

function MyMountTracker:CreateMountHeaderRow(parent, mountID, journalMountID, mountName, chance)
    local row = CreateFrame("Button", nil, parent)
    
    row:SetClipsChildren(true)
    row:SetSize(parent:GetWidth(), 40)
    row.isMountHeader = true
    row.sourceRows = {}
    row.mountID = mountID
    row.journalMountID = journalMountID

    local border = CreateFrame("Frame", nil, row, "BackdropTemplate")
    border:SetFrameLevel(row:GetFrameLevel() - 1)
    border:SetPoint("TOPLEFT", row, "TOPLEFT", -2, 2)
    border:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 2, -2)
    border:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    border:SetBackdropColor(1, 0.7529411764705882, 0, 1)
    border:Hide()
    row.border = border

    local bg = CreateFrame("Frame", nil, row, "BackdropTemplate")
    bg:SetPoint("LEFT", row, 2, 0)
    bg:SetSize(parent:GetWidth() - 6, 36)
    bg:SetFrameLevel(row:GetFrameLevel())
    bg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    bg:SetBackdropColor(0.03, 0.03, 0.03, 1)

    local icon = CreateFrame("Button", nil, row)
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 5, 0)
    icon:SetNormalTexture(GetItemIcon(mountID))
    icon:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:SetItemByID(mountID); GameTooltip:Show() end)
    icon:SetScript("OnLeave", GameTooltip_Hide)
    icon:SetScript("OnClick", function(_, button) if IsControlKeyDown() then DressUpMount(row.journalMountID) end end)

    local nameText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    nameText:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    nameText:SetText(mountName or "Loading...")
    nameText:SetWidth(370)
    nameText:SetWordWrap(false)
    nameText:SetJustifyH("LEFT")

    local chanceText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    chanceText:SetPoint("RIGHT", -15, 0)
    chanceText:SetFont(STANDARD_TEXT_FONT, 14)
    chanceText:SetJustifyH("RIGHT")
    chanceText:SetFormattedText( "掉率: %s%s|r -> %s%.2f%%|r", COLORS.GREY, (chance == 0) and "unknown" or string.format("%.2f%%", chance), COLORS.GREEN, chance + 5.0)

    return row
end

function MyMountTracker:CreateMountSourceRow(parent, sourceData)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 20, 30)
    row.sourceData = sourceData
    local data = sourceData.originalData
    local mapName = instanceToMap[sourceData.instanceID] or "Unknown Map"

    local nameText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    nameText:SetPoint("LEFT", 10, 0)
    nameText:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
    nameText:SetText(COLORS.WHITE .. data.bossName)
    nameText:SetJustifyH("LEFT")
    if nameText:GetWidth() > 180 then
        nameText:SetWidth(180)
    end
    nameText:SetWordWrap(false)
    nameText:EnableMouse(true)
    nameText:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText(data.bossName)
        GameTooltip:Show()
    end)
    nameText:SetScript("OnLeave", GameTooltip_Hide)
    
    local mapNameText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    mapNameText:SetPoint("LEFT", nameText, "RIGHT", 6, 0)
    mapNameText:SetFont(STANDARD_TEXT_FONT, 14)
    mapNameText:SetText(COLORS.BLUE .. mapName)
    mapNameText:SetWordWrap(false)
    if mapNameText:GetWidth() > 180 then
        mapNameText:SetWidth(180)
    end
    mapNameText:SetJustifyH("LEFT")
    mapNameText:EnableMouse(true)
    mapNameText:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetText(mapName)
        GameTooltip:Show()
    end)
    mapNameText:SetScript("OnLeave", GameTooltip_Hide)

    local difficultyText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    difficultyText:SetPoint("LEFT", mapNameText, "RIGHT", 6, 0)
    difficultyText:SetFont(STANDARD_TEXT_FONT, 14)
    local shorterText
    if data.journalMountID == 69 then shorterText = "N Dungeon" end
    difficultyText:SetText(COLORS.GREY .. (shorterText or difficultyInfo[sourceData.difficultyID].name or "Unknown Difficulty"))
    difficultyText:SetWidth(150)
    difficultyText:SetWordWrap(false)
    difficultyText:SetJustifyH("LEFT")

    local statusText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    statusText:SetPoint("RIGHT", -15, 0)
    statusText:SetFont(STANDARD_TEXT_FONT, 14)
    statusText:SetJustifyH("RIGHT")
    row.statusText = statusText

    if sourceData.difficultyID == 17 then
        local arrow = CreateFrame("Button", nil, row)
        arrow:SetSize(32, 32)
        arrow:SetPoint("RIGHT", statusText, "LEFT", -8, 0)
        arrow.texture = arrow:CreateTexture(nil, "OVERLAY")
        arrow.texture:SetTexture("Interface\\AddOns\\BountyHelper\\Assets\\arrow")
        arrow.texture:SetVertexColor(1, 0.7529411764705882, 0)
        arrow.texture:SetAllPoints()
        arrow:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT");
            GameTooltip:SetText(COLORS.GREEN .. "<点击添加地图标记>");
            GameTooltip:Show()
            arrow.texture:SetVertexColor(1, 1, 1)
        end)
        arrow:SetScript("OnLeave", function()
            GameTooltip_Hide()
            arrow.texture:SetVertexColor(1, 0.7529411764705882, 0)
        end)
        arrow:SetScript("OnClick", function()
            if type(data.lfr[1]) == "table" then
                data.lfr = data.lfr[faction]
            end
            C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(unpack(data.lfr)))
            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            OpenWorldMap(data.lfr[4] or data.lfr[1])
            print(string.format("%sBounty Helper:|r Waypoint set", COLORS.GOLD))
        end)
    end
    
    return row
end

function MyMountTracker:UpdateMountViewLayout()
    local scrollChild = MyMountTracker.Frames.MountViewScrollChild
    local lastVisibleFrame = nil
    local totalHeight = 0
    local yPadding = 4
    local xIndent = 20

    for _, frame in ipairs(MyMountTracker.MountViewContentFrames) do
        if frame.isMountHeader then
            local isOwned = frame.journalMountID and C_MountJournal.GetMountInfoByID(frame.journalMountID) and select(11, C_MountJournal.GetMountInfoByID(frame.journalMountID))
            local visibleSourceCount = 0

            for _, sourceRow in ipairs(frame.sourceRows) do
                local data = sourceRow.sourceData.originalData
                local sourceIsVisible = true

                if isOwned then
                    sourceRow.statusText:SetText(COLORS.GREEN .. "已拥有")
                else
                    sourceRow.statusText:SetText(data.killed and (COLORS.GREEN .. "已击杀") or (COLORS.RED .. "未击杀"))
                end

                if hideOwned and isOwned then
                    sourceIsVisible = false
                end
                if sourceIsVisible and hideKilled and data.killed and not isOwned then
                    sourceIsVisible = false
                end
                
                sourceRow:SetShown(sourceIsVisible)
                if sourceIsVisible then visibleSourceCount = visibleSourceCount + 1 end
            end

            if (hideOwned and isOwned) or (visibleSourceCount == 0) then
                frame:SetShown(false)
            else
                frame:SetShown(true)
            end
        end
    end

    for _, frame in ipairs(MyMountTracker.MountViewContentFrames) do
        if frame:IsShown() then
            frame:ClearAllPoints()
            if not lastVisibleFrame then
                frame:SetPoint("TOP", scrollChild, "TOP", 2, -2)
            else
                local pad = frame.isMountHeader and -12 or -yPadding
                frame:SetPoint("TOP", lastVisibleFrame, "BOTTOM", 2, pad)
            end

            if frame.isMountHeader then
                frame:SetPoint("LEFT", scrollChild, "LEFT", 2, 0)
            else
                frame:SetPoint("LEFT", scrollChild, "LEFT", xIndent, 0)
            end
            
            lastVisibleFrame = frame
            totalHeight = totalHeight + frame:GetHeight() + (frame.isMountHeader and 12 or yPadding)
        end
    end
    scrollChild:SetHeight(math.max(1, totalHeight - yPadding + 10))
end

function MyMountTracker:Initialize()
    self:CreateUI()
    self:PopulateList()
    
    self:LoadMountData(function()
        self:_BuildMountViewUI()
    end)
end

function MyMountTracker:ShowDifficultyView()
    MyMountTracker.Frames.ScrollFrame:Show()
    MyMountTracker.Frames.ToMountViewButton:Show()
    
    MyMountTracker.Frames.MountViewScrollFrame:Hide()
    MyMountTracker.Frames.ToDifficultyViewButton:Hide()
    
    MyMountTracker:UpdateLayout()
    MyMountTracker.Frames.Main:Show()
end

function MyMountTracker:ShowMountView()
    MyMountTracker.Frames.ScrollFrame:Hide()
    MyMountTracker.Frames.ToMountViewButton:Hide()

    MyMountTracker.Frames.MountViewScrollFrame:Show()
    MyMountTracker.Frames.ToDifficultyViewButton:Show()
    
    MyMountTracker:UpdateMountViewLayout()
    MyMountTracker.Frames.Main:Show()
end

function MyMountTracker:Toggle()
    if MyMountTracker.Frames.Main:IsShown() then
        MyMountTracker.Frames.Main:Hide()
    else
        MyMountTracker:UpdateLayout()
        MyMountTracker:UpdateMountViewLayout()
        
        MyMountTracker.Frames.HideOwnedCheckbox:SetChecked(hideOwned)
        MyMountTracker.Frames.HideKilledCheckbox:SetChecked(hideKilled)
        MyMountTracker.Frames.HideButtonCheckbox:SetChecked(hideButton)
        MyMountTracker:ShowMountView()
    end
end

function MyMountTracker:UpdateVisibleFrame()
    if MyMountTracker.Frames.ScrollFrame:IsShown() then
        MyMountTracker:UpdateLayout()
    elseif MyMountTracker.Frames.MountViewScrollFrame:IsShown() then
        MyMountTracker:UpdateMountViewLayout()
    end
end

SLASH_CBH1 = "/bh"
SLASH_CBH2 = "/cbh"
SLASH_CBH3 = "/bounty"
SLASH_CBH4 = "/bountyhelper"
SlashCmdList["CBH"] = function() MyMountTracker:Toggle() end

function checkSaved()
    for i = 1, GetNumSavedInstances() do
        local _, _, reset, difficultyID, _, _, _, _, _, _, numEncounters, _, _, instanceID = GetSavedInstanceInfo(i)
        if reset ~= 0 then
            local bossList = safeGet(bossData, difficultyID, instanceID)
            if bossList then
                for j = 1, numEncounters do
                    for _, bossEntry in ipairs(bossList) do
                        local saved = C_RaidLocks.IsEncounterComplete(instanceID, bossEntry.encounterID, difficultyID)
                        if saved then
                            bossEntry.killed = true
                            sharedDifficulty(difficultyID, bossData, instanceID, bossEntry.encounterID)
                        end
                    end
                end
            end
        end
    end
end

local eventHandlerFrame = CreateFrame("Frame")
eventHandlerFrame:RegisterEvent("ADDON_LOADED")
eventHandlerFrame:RegisterEvent("FIRST_FRAME_RENDERED")
eventHandlerFrame:RegisterEvent("PLAYER_LOGOUT")
eventHandlerFrame:RegisterEvent("ENCOUNTER_END")

eventHandlerFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            BountyHelperDB = BountyHelperDB or {}
            hideOwned = BountyHelperDB.hideOwned or false
            hideKilled = BountyHelperDB.hideKilled or false
            hideButton = BountyHelperDB.hideButton or false
            currentScale = BountyHelperDB.scale or 1.0

            local LibDBIcon = LibStub("LibDBIcon-1.0")
            LibDBIcon:Register("BountyHelper", LDB, dbBH.minimap)
            buttonBH = LibDBIcon:GetMinimapButton("BountyHelper")
        end
    
    elseif event == "FIRST_FRAME_RENDERED" then
        faction = (UnitFactionGroup("player") == "Alliance") and 1 or 2

        for difficultyID, instances in pairs(bossData) do
            for instanceID, bosses in pairs(instances) do
                for i, boss in ipairs(bosses) do
                    EJ_SelectInstance(instanceToMap[instanceID])
                    boss.bossName, _, _, _, _, _, boss.encounterID = EJ_GetEncounterInfoByIndex(boss.encounterID)
                end
            end
        end

        for i, id in pairs(instanceToMap) do
            instanceToMap[i] = EJ_GetInstanceInfo(id)
        end

        MyMountTracker:Initialize()
        MyMountTracker.Frames.Main:SetScale(currentScale)
        MyMountTracker.Frames.ScaleSlider:SetValue(currentScale)
        MyMountTracker.Frames.ScaleValueText:SetText(string.format("UI缩放: %.2f", currentScale))
        
        checkSaved()
        self:UnregisterEvent("FIRST_FRAME_RENDERED")
        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_LOGOUT" then
        BountyHelperDB.hideOwned = hideOwned
        BountyHelperDB.hideKilled = hideKilled
        BountyHelperDB.hideButton = hideButton
        BountyHelperDB.scale = currentScale

    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, difficultyID, _, success = ...
        if success == 1 then
            local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()

            local bossList = safeGet(bossData, difficultyID, instanceID)
            
            --print(difficultyID)
            --print(instanceID)
            if bossList then
                local closeMainFrame = false
                if not MyMountTracker.Frames.Main:IsShown() then
                    closeMainFrame = true
                    MyMountTracker:ShowMountView()
                end
                local bossFound = false
                --print(encounterName)
                for i, bossEntry in ipairs(bossList) do
                    if bossEntry.encounterID == encounterID then
                        --print(string.format("%sBounty Helper:|r Detected kill for %s%s|r on difficulty %s.", COLORS.GOLD, COLORS.GREEN, encounterName, difficultyID))
                        --bossEntry.killed = true
                        bossList[i].killed = true
                        bossFound = true
                        
                        sharedDifficulty(difficultyID, bossData, instanceID, encounterID)
                    end
                end

                MyMountTracker:UpdateLayout()
                MyMountTracker:UpdateMountViewLayout()
                if closeMainFrame then MyMountTracker.Frames.Main:Hide() end
            end
        end
    end
end)