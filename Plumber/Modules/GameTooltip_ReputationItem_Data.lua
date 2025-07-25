--Look up SpellEffect. Effect = 103 (Reputation), EffectMiscValue_0 is the factionID
--Note: these items can go into your bags. There are other items that auto consumed on pickup (See spell 1221237)
--https://wago.tools/db2/SpellEffect?filter%5BEffect%5D=103&page=1


local _, addon = ...

local SpellFaction = {};

local GetItemSpell = C_Item.GetItemSpell;
local ItemFaction = {};

local function GetFactionGrantedByItem(itemID)
    if ItemFaction[itemID] then
        return ItemFaction[itemID]
    end

    local _, spellID = GetItemSpell(itemID);
    if spellID and SpellFaction[spellID] then
        local factionID = SpellFaction[spellID];
        ItemFaction[itemID] = factionID;
        return factionID
    end
end
addon.GetFactionGrantedByItem = GetFactionGrantedByItem;


SpellFaction = {
    [89789] = 1177,
    [89791] = 1178,
    [89835] = 1177,
    [89836] = 1178,
    [91290] = 1173,
    [92385] = 1177,
    [92386] = 1177,
    [99337] = 1178,
    [99338] = 1177,
    [100764] = 1134,
    [100765] = 1133,
    [73843] = 1156,
    [127322] = 1345,
    [129671] = 1345,
    [131047] = 1272,
    [132278] = 1269,
    [132279] = 1269,
    [132645] = 1228,
    [136375] = 1228,
    [138417] = 1270,
    [138418] = 1337,
    [138419] = 1341,
    [138420] = 1269,
    [139699] = 1435,
    [139700] = 1435,
    [139701] = 1435,
    [139702] = 1435,
    [139703] = 1435,
    [139704] = 1435,
    [139705] = 1435,
    [139706] = 1435,
    [139708] = 1435,
    [139709] = 1435,
    [139710] = 1435,
    [139711] = 1435,
    [140143] = 1388,
    [140144] = 1388,
    [140145] = 1387,
    [140147] = 1387,
    [140152] = 1435,
    [140242] = 1435,
    [148318] = 1359,
    [149304] = 1359,
    [150647] = 1710,
    [150649] = 1708,
    [160922] = 1358,
    [163570] = 92,
    [167748] = 1682,
    [167749] = 1681,
    [172929] = 1515,
    [175093] = 1682,
    [175094] = 1682,
    [177780] = 1681,
    [177781] = 1682,
    [177782] = 1681,
    [177783] = 1682,
    [184833] = 1156,
    [189389] = 1850,
    [192858] = 1860,
    [194553] = 1090,
    [194558] = 1098,
    [194559] = 1106,
    [194561] = 1119,
    [194562] = 1091,
    [194568] = 933,
    [194569] = 935,
    [194570] = 947,
    [194574] = 946,
    [194575] = 942,
    [194576] = 989,
    [194578] = 1011,
    [194609] = 1052,
    [194613] = 1037,
    [200706] = 1204,
    [200707] = 1177,
    [200708] = 1172,
    [200709] = 1158,
    [200710] = 1178,
    [200711] = 1173,
    [200712] = 1135,
    [200713] = 1171,
    [200714] = 1174,
    [217291] = 1975,
    [219392] = 1975,
    [219527] = 1948,
    [219528] = 1883,
    [219529] = 1900,
    [219530] = 1828,
    [219531] = 1894,
    [219532] = 1859,
    [219605] = 1948,
    [219607] = 1828,
    [219609] = 1894,
    [223041] = 1859,
    [228211] = 1859,
    [228613] = 1900,
    [228614] = 1883,
    [228615] = 1828,
    [228616] = 1859,
    [228617] = 1948,
    [228618] = 1894,
    [230349] = 2018,
    [230381] = 2018,
    [234502] = 1337,
    [234503] = 1270,
    [234504] = 1269,
    [234505] = 1341,
    [234506] = 1388,
    [234507] = 1387,
    [234509] = 1272,
    [234510] = 1271,
    [234511] = 1375,
    [234512] = 1376,
    [234513] = 1435,
    [234514] = 1302,
    [234515] = 1492,
    [235260] = 970,
    [238308] = 0,
    [240032] = 1948,
    [240033] = 1883,
    [240034] = 1900,
    [240035] = 1828,
    [240036] = 1894,
    [240037] = 1859,
    [240039] = 2045,
    [240593] = 2097,
    [240677] = 2099,
    [240678] = 2102,
    [240679] = 2098,
    [240680] = 2101,
    [240681] = 2100,
    [241221] = 1894,
    [241222] = 1900,
    [241223] = 1883,
    [241224] = 1828,
    [241225] = 1859,
    [241226] = 1948,
    [241228] = 1859,
    [241232] = 1859,
    [242603] = 2045,
    [246819] = 2135,
    [246827] = 2135,
    [246828] = 2135,
    [253894] = 2170,
    [253895] = 2170,
    [253896] = 2165,
    [253897] = 2165,
    [254344] = 2170,
    [264060] = 2156,
    [264061] = 2156,
    [264062] = 2158,
    [264063] = 2160,
    [264066] = 2161,
    [264069] = 2162,
    [264072] = 2163,
    [264073] = 2164,
    [264076] = 2157,
    [264077] = 2159,
    [265692] = 2233,
    [265710] = 2233,
    [266094] = 2233,
    [267099] = 2233,
    [275036] = 2160,
    [276881] = 2233,
    [276883] = 2233,
    [276885] = 2233,
    [276886] = 2233,
    [284900] = 2375,
    [287570] = 2163,
    [292986] = 2370,
    [292987] = 2370,
    [294666] = 1515,
    [294671] = 1849,
    [294675] = 1711,
    [294678] = 1850,
    [294680] = 1445,
    [294702] = 1731,
    [294704] = 1708,
    [294705] = 1710,
    [295101] = 1848,
    [295102] = 1847,
    [298151] = 2391,
    [299397] = 2395,
    [299398] = 2395,
    [299399] = 2395,
    [299402] = 2396,
    [299403] = 2396,
    [299404] = 2396,
    [299405] = 2398,
    [299406] = 2398,
    [299407] = 2398,
    [299408] = 2397,
    [299409] = 2397,
    [299410] = 2397,
    [301205] = 2375,
    [301206] = 2376,
    [301207] = 2377,
    [302257] = 2375,
    [303325] = 2400,
    [303334] = 2373,
    [303362] = 2390,
    [303426] = 2376,
    [303685] = 2395,
    [303856] = 2373,
    [303857] = 2400,
    [308236] = 2398,
    [309298] = 2381,
    [311646] = 2415,
    [311647] = 2417,
    [312169] = 2391,
    [313157] = 2400,
    [313158] = 2373,
    [315613] = 2164,
    [315616] = 2158,
    [315623] = 2161,
    [315627] = 2160,
    [315628] = 2162,
    [315629] = 2156,
    [315638] = 2159,
    [315649] = 2157,
    [315663] = 2103,
    [315682] = 2163,
    [317766] = 2432,
    [318138] = 2427,
    [318322] = 2427,
    [318323] = 2427,
    [318324] = 2427,
    [318325] = 2427,
    [318326] = 2427,
    [318348] = 2427,
    [325776] = 2165,
    [326813] = 2431,
    [326814] = 2431,
    [326815] = 2431,
    [326816] = 2431,
    [326818] = 2431,
    [326819] = 2431,
    [326820] = 2431,
    [326821] = 2431,
    [331869] = 2465,
    [315986] = 2439,
    [344508] = 2413,
    [344509] = 2413,
    [344511] = 2407,
    [344512] = 2465,
    [344513] = 2410,
    [343015] = 2432,
    [347290] = 2439,
    [351332] = 2469,
    [351375] = 2469,
    [357545] = 2410,
    [357548] = 2407,
    [357552] = 2465,
    [357562] = 2413,
    [356931] = 2472,
    [356934] = 2472,
    [356937] = 2472,
    [356936] = 2472,
    [356935] = 2472,
    [356940] = 2472,
    [356939] = 2472,
    [356938] = 2472,
    [367293] = 2478,
    [368389] = 2478,
    [370356] = 2478,
    [372022] = 2507,
    [372023] = 2507,
    [384328] = 2550,
    [384890] = 2544,
    [388165] = 2503,
    [388166] = 2507,
    [388167] = 2511,
    [388168] = 2510,
    [388169] = 2503,
    [388170] = 2507,
    [388171] = 2511,
    [388172] = 2510,
    [389241] = 2518,
    [389254] = 2517,
    [389256] = 2518,
    [389305] = 2517,
    [389500] = 2507,
    [389502] = 2511,
    [389504] = 2503,
    [389506] = 2510,
    [389664] = 2507,
    [389667] = 2511,
    [389668] = 2503,
    [389669] = 2510,
    [393090] = 2510,
    [394704] = 2510,
    [394713] = 2510,
    [394716] = 2507,
    [394718] = 2511,
    [395658] = 2507,
    [395659] = 2511,
    [395660] = 2503,
    [395661] = 2510,
    [396830] = 2507,
    [396832] = 2511,
    [396834] = 2510,
    [396835] = 2503,
    [409074] = 2564,
    [409092] = 2510,
    [409125] = 2507,
    [409490] = 2564,
    [409643] = 2564,
    [411580] = 2564,
    [411602] = 2564,
    [420222] = 2391,
    [420223] = 1098,
    [420225] = 76,
    [420226] = 72,
    [425586] = 2574,
    [425587] = 2574,
    [425588] = 2574,
    [425590] = 2574,
    [425591] = 2564,
    [426729] = 2574,
    [427475] = 2574,
    [427623] = 2574,
    [428818] = 2574,
    [428836] = 2574,
    [428839] = 2574,
    [428890] = 2574,
    [428913] = 2574,
    [428974] = 2574,
    [428977] = 2574,
    [428979] = 2574,
    [428980] = 2574,
    [429240] = 2574,
    [432669] = 2601,
    [434577] = 2601,
    [434583] = 2601,
    [434804] = 2601,
    [434805] = 2601,
    [434806] = 2601,
    [434807] = 2601,
    [443045] = 2601,
    [448393] = 2640,
    [453215] = 59,
    [453217] = 270,
    [453218] = 510,
    [453219] = 509,
    [453220] = 529,
    [453221] = 576,
    [453223] = 589,
    [453225] = 630,
    [453226] = 729,
    [453227] = 730,
    [453228] = 749,
    [453229] = 889,
    [453230] = 890,
    [453231] = 910,
    [456025] = 2605,
    [461172] = 2640,
    [461173] = 2640,
    [461174] = 2640,
    [464873] = 2640,
    [1217109] = 2640,
    [1217110] = 2640,
    [1217111] = 2640,
    [1217548] = 2640,
    [1226352] = 2161,
    [1226353] = 2160,
    [1226356] = 2162,
    [1226361] = 2159,
    [1226379] = 2400,
    [1226390] = 2156,
    [1226391] = 2158,
    [1226392] = 2157,
    [1226399] = 2103,
    [1226400] = 2373,
    [1226403] = 2164,
    [1226405] = 2163,
    [1226410] = 2391,
    [1226419] = 2417,
    [1228437] = 2640,
    [1239894] = 2640,
    [1240103] = 2415,
    [17047] = 529,
    [17451] = 289,
    [17452] = 46,
    [21187] = 730,
    [21647] = 729,
    [21829] = 730,
    [23961] = 729,
    [23962] = 730,
    [23963] = 729,
    [24226] = 270,
    [24377] = 270,
    [25992] = 910,
    [26001] = 609,
    [26125] = 67,
    [26126] = 469,
    [26161] = 72,
    [26162] = 76,
    [27290] = 529,
    [28303] = 922,
    [28393] = 87,
    [28394] = 87,
    [28396] = 87,
    [28397] = 87,
    [39456] = 1011,
    [39457] = 935,
    [39460] = 942,
    [39474] = 933,
    [39475] = 989,
    [39476] = 970,
    [61306] = 1090,
    [61308] = 1091,
    [61311] = 1106,
    [61312] = 1098,
    [63832] = 69,
    [63833] = 930,
    [63834] = 54,
    [63835] = 47,
    [63836] = 72,
    [63837] = 76,
    [63838] = 530,
    [63839] = 911,
    [63840] = 81,
    [63841] = 68,
    [69757] = 1119,
};


SpellFaction[1221237] = 2600;       --Severed Threads