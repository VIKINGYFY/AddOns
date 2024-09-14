local B, C, L, DB = unpack(LightAO)

-- Pixel
C.mult = 1
local function multUpdate()
	if C_AddOns.IsAddOnLoaded("NDui") then
		local NB, NC, NL, NDB = unpack(_G.NDui)
		C.mult = NC.mult
		B.CreateMF = NB.CreateMF
	elseif C_AddOns.IsAddOnLoaded("ElvUI") then
		local EE, EL, EV, EP, EG = unpack(_G.ElvUI)
		C.mult = EE.mult
		B.CreateMF = EE.CreateMover
	end
end
B:RegisterEvent("PLAYER_LOGIN", multUpdate)

-- Colors
DB.InfoColor = "|cff00CCFF"
DB.MyClass = select(2, UnitClass("player"))
DB.ClassColors = {}
local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class, value in pairs(colors) do
	DB.ClassColors[class] = {}
	DB.ClassColors[class].r = value.r
	DB.ClassColors[class].g = value.g
	DB.ClassColors[class].b = value.b
	DB.ClassColors[class].colorStr = value.colorStr
end
DB.cr, DB.cg, DB.cb = DB.ClassColors[DB.MyClass].r, DB.ClassColors[DB.MyClass].g, DB.ClassColors[DB.MyClass].b

-- Fonts
DB.Font = {STANDARD_TEXT_FONT, 12, "OUTLINE"}

-- Textures
DB.bgTex = "Interface\\Addons\\LightAO\\Media\\bgTex"
DB.glowTex = "Interface\\Addons\\LightAO\\Media\\glowTex"
DB.closeTex = "Interface\\Addons\\LightAO\\Media\\closeTex"
DB.bdTex = "Interface\\ChatFrame\\ChatFrameBackground"

-- Item Stats
DB.ItemStats = {
	--["ITEM_MOD_CRIT_RATING_SHORT"] = true,    -- 爆击
	--["ITEM_MOD_HASTE_RATING_SHORT"] = true,   -- 急速
	--["ITEM_MOD_MASTERY_RATING_SHORT"] = true, -- 精通
	--["ITEM_MOD_VERSATILITY"] = true,          -- 全能

	["ITEM_MOD_CR_AVOIDANCE_SHORT"] = true,     -- 闪避
	["ITEM_MOD_CR_LIFESTEAL_SHORT"] = true,     -- 吸血
	["ITEM_MOD_CR_SPEED_SHORT"] = true,         -- 加速
	["ITEM_MOD_CR_STURDINESS_SHORT"] = true,    -- 永不磨损
}

-- Item IDs
DB.MiscIDs = {
	[Enum.ItemClass.Miscellaneous] = true,
}

DB.CollectionIDs = {
	[Enum.ItemMiscellaneousSubclass.CompanionPet] = true,
	[Enum.ItemMiscellaneousSubclass.Mount] = true,
}

DB.EquipmentIDs = {
	[Enum.ItemClass.Weapon] = true,
	[Enum.ItemClass.Armor] = true,
}

DB.ExcludeIDs = {
	[Enum.ItemClass.Tradegoods] = true,
}

-- Item Types
DB.ConduitTypes = {
	[CONDUIT_TYPE_ENDURANCE] = CONDUIT_ENDURANCE,
	[CONDUIT_TYPE_FINESSE] = CONDUIT_FINESSE,
	[CONDUIT_TYPE_POTENCY] = CONDUIT_POTENCY,
}

DB.BindTypes = {
	[ITEM_ACCOUNTBOUND] = "BoA",
	[ITEM_BIND_TO_ACCOUNT] = "BoA",
	[ITEM_BIND_TO_BNETACCOUNT] = "BoA",
	[ITEM_BNETACCOUNTBOUND] = "BoA",
	[ITEM_BIND_ON_EQUIP] = "BoE",
	[ITEM_BIND_ON_USE] = "BoU",
}

DB.EquipmentTypes = {
	["INVTYPE_HOLDABLE"] = SECONDARYHANDSLOT,
	["INVTYPE_SHIELD"] = SHIELDSLOT,
}

DB.ConsumableTypes = {
	[10] = "效能",
	[11] = "战斗",
}

DB.ContainerTypes = {
	[0] = "背包",
	[1] = "灵魂",
	[2] = "草药",
	[3] = "附魔",
	[4] = "工程",
	[5] = "珠宝",
	[6] = "采矿",
	[7] = "制皮",
	[8] = "铭文",
	[9] = "工具",
	[10] = "烹饪",
	[11] = "材料",
}

DB.ItemEnhancementTypes = {
	[0] = INVTYPE_HEAD,
	[1] = INVTYPE_NECK,
	[2] = INVTYPE_SHOULDER,
	[3] = INVTYPE_CLOAK,
	[4] = INVTYPE_CHEST,
	[5] = INVTYPE_WRIST,
	[6] = INVTYPE_HAND,
	[7] = INVTYPE_WAIST,
	[8] = INVTYPE_LEGS,
	[9] = INVTYPE_FEET,
	[10] = INVTYPE_FINGER,
	[11] = INVTYPE_WEAPON,
	[12] = INVTYPE_2HWEAPON,
	[13] = INVTYPE_WEAPONOFFHAND,
	[14] = AUCTION_SUBCATEGORY_OTHER,
}

DB.RecipeTypes = {
	[0] = "书籍",
	[1] = "制皮",
	[2] = "裁缝",
	[3] = "工程",
	[4] = "锻造",
	[5] = "烹饪",
	[6] = "炼金",
	[7] = "急救",
	[8] = "附魔",
	[9] = "钓鱼",
	[10] = "珠宝",
	[11] = "铭文",
}

DB.KeyTypes = {
	[0] = "钥匙",
	[1] = "开锁",
}

DB.ProfessionTypes = {
	[0] = "锻造",
	[1] = "制皮",
	[2] = "炼金",
	[3] = "草药",
	[4] = "烹饪",
	[5] = "采矿",
	[6] = "裁缝",
	[7] = "工程",
	[8] = "附魔",
	[9] = "钓鱼",
	[10] = "剥皮",
	[11] = "珠宝",
	[12] = "铭文",
	[13] = "考古",
}

DB.MiscellaneousTypes = {
	[2] = PETS,
	[5] = MOUNTS,
	[6] = EQUIPSET_EQUIP,
}

DB.DeliverRelic = {
	[356931] = true,
	[356933] = true,
	[356934] = true,
	[356935] = true,
	[356936] = true,
	[356937] = true,
	[356938] = true,
	[356939] = true,
	[356940] = true,
}

DB.AncientMana = {
	[192922] = true,
	[193080] = true,
	[193081] = true,
	[211161] = true,
	[211171] = true,
	[216918] = true,
	[222333] = true,
	[222334] = true,
	[222335] = true,
	[222336] = true,
	[222929] = true,
	[222942] = true,
	[222945] = true,
	[222947] = true,
	[222950] = true,
	[223677] = true,
	[224379] = true,
	[224380] = true,
	[224381] = true,
	[224382] = true,
	[227729] = true,
	[233126] = true,
	[233232] = true,
}

DB.Experience = {
	[180419] = true,
	[225517] = true,
	[255249] = true,
	[347495] = true,
	[347496] = true,
	[347497] = true,
	[347498] = true,
	[347499] = true,
	[353852] = true,
	[357445] = true,
	[357447] = true,
	[357448] = true,
	[362986] = true,
}

DB.PetTrashCurrenies = {
	[3300] = true,
	[3670] = true,
	[6150] = true,
	[11406] = true,
	[11944] = true,
	[25402] = true,
	[36812] = true,
	[62072] = true,
	[67410] = true,
}

DB.PrimordialStone = {}
for id = 204000, 204030 do
	DB.PrimordialStone[id] = true
end
