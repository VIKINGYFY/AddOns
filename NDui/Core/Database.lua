local _, ns = ...
local B, C, L, DB = unpack(ns)

local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001

DB.Version = C_AddOns.GetAddOnMetadata("NDui", "Version")
DB.Support = C_AddOns.GetAddOnMetadata("NDui", "X-Support")
DB.Client = GetLocale()
DB.ScreenWidth, DB.ScreenHeight = GetPhysicalScreenSize()
DB.isNewPatch = select(4, GetBuildInfo()) >= 110200 -- 11.2.0

-- Deprecated
do
	local function EasyMenu_Initialize( frame, level, menuList )
		for index = 1, #menuList do
			local value = menuList[index]
			if (value.text) then
				value.index = index
				UIDropDownMenu_AddButton( value, level )
			end
		end
	end

	function EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay )
		if ( displayMode == "MENU" ) then
			menuFrame.displayMode = displayMode
		end
		UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
		ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
	end
end

-- Colors
DB.MyName = UnitName("player")
DB.MyRealm = GetRealmName()
DB.MyFullName = DB.MyName.."-"..DB.MyRealm
DB.MyClass = select(2, UnitClass("player"))
DB.MyFaction = UnitFactionGroup("player")
DB.ClassList = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	DB.ClassList[v] = k
end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	DB.ClassList[v] = k
end
DB.ClassColors = {}
for class, value in pairs(RAID_CLASS_COLORS) do
	DB.ClassColors[class] = {}
	DB.ClassColors[class] = {r = value.r, g = value.g, b = value.b, colorStr = value.colorStr}
end
DB.ClassColors[NONE] = {r = .5, g = .5, b = .5}

DB.QualityColors = {}
for index, value in pairs(ITEM_QUALITY_COLORS) do
	DB.QualityColors[index] = {}
	DB.QualityColors[index] = {r = value.r, g = value.g, b = value.b}
end
DB.QualityColors[-1] = {r = 0, g = 0, b = 0}
DB.QualityColors[-2] = {r = .5, g = .5, b = .5}
DB.QualityColors[-3] = {r = 1, g = 0, b = 0}
DB.QualityColors[-4] = {r = 1, g = .8, b = 0}

DB.r, DB.g, DB.b = DB.ClassColors[DB.MyClass].r, DB.ClassColors[DB.MyClass].g, DB.ClassColors[DB.MyClass].b
DB.MyColor = format("|cff%02x%02x%02x", DB.r*255, DB.g*255, DB.b*255)
DB.InfoColor = "|cff00FFFF"
DB.GreyColor = "|cff808080"
DB.GreenColor = "|cff00FF00"

-- Other
DB.margin = 3
DB.padding = 3
DB.alpha = .75

-- Fonts
DB.Font = {STANDARD_TEXT_FONT, 12, "OUTLINE"}
DB.LineString = DB.GreyColor.."---------------"
DB.NDuiString = "|cff0080FFNDui:|r"
DB.Separator = DB.MyColor.." | |r"
DB.EnableString = "|cff00FF00"..VIDEO_OPTIONS_ENABLED.."|r"
DB.DisableString = "|cffFF0000"..VIDEO_OPTIONS_DISABLED.."|r"

-- Textures
local Media = "Interface\\Addons\\NDui\\Media\\"
DB.bdTex = "Interface\\ChatFrame\\ChatFrameBackground"
DB.glowTex = Media.."glowTex"
DB.normTex = Media.."normTex"
DB.gradTex = Media.."gradTex"
DB.flatTex = Media.."flatTex"
DB.bgTex = Media.."bgTex"
DB.tpTex = Media.."tpTex"
DB.pushedTex = Media.."pushed"
DB.targetTex = Media.."TargetArrow"
DB.flagTex = Media.."Hutu\\flag"
DB.MicroTex = Media.."Hutu\\Menu\\"
DB.chatLogo = Media.."Hutu\\logoSmall"
DB.logoTex = Media.."Hutu\\logo"
DB.closeTex = Media.."Hutu\\close"
DB.afdianTex = Media.."Hutu\\Afdian"
DB.patreonTex = Media.."Hutu\\Patreon"
DB.curseforgeTex = Media.."Hutu\\CURSEFORGE"
DB.boxTex = Media.."Hutu\\Box"
DB.arrowTex = Media.."Arrow\\arrowTex_"

DB.starTex = "Bonus-Objective-Star"
DB.questTex = "adventureguide-microbutton-alert"
DB.objectTex = "Warfronts-BaseMapIcons-Horde-Barracks-Minimap"

DB.mailTex = "Interface\\Minimap\\Tracking\\Mailbox"
DB.gearTex = "Interface\\WorldMap\\Gear_64"
DB.eyeTex = "Interface\\Minimap\\Raid_Icon"		-- blue: \\Dungeon_Icon
DB.garrTex = "Interface\\HelpFrame\\HelpIcon-ReportLag"
DB.copyTex = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"
DB.binTex = "Interface\\HelpFrame\\ReportLagIcon-Loot"
DB.creditTex = "Interface\\HelpFrame\\HelpIcon-KnowledgeBase"
DB.newItemFlash = "Interface\\Cooldown\\star4"
DB.sparkTex = "Interface\\CastingBar\\UI-CastingBar-Spark"
DB.TexCoord = {.08, .92, .08, .92}
DB.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:1:512:512:12:66:230:307|t "
DB.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:1:512:512:12:66:333:410|t "
DB.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:1:512:512:12:66:127:204|t "
DB.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
DB.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

-- Flags
function DB:IsMyPet(flags)
	return bit.band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end
DB.PartyPetFlags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)
DB.RaidPetFlags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_RAID, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PET)

-- RoleUpdater
local function CheckRole()
	local tree = GetSpecialization()
	if not tree then return end

	local _, _, _, _, role, stat = GetSpecializationInfo(tree)
	if role == "TANK" then
		DB.Role = "Tank"
	elseif role == "HEALER" then
		DB.Role = "Healer"
	elseif role == "DAMAGER" then
		if stat == 4 then	--1力量，2敏捷，4智力
			DB.Role = "Caster"
		else
			DB.Role = "Melee"
		end
	end

	if stat then
		DB.mainID = stat
		DB.mainStat = _G["SPELL_STAT"..stat.."_NAME"]
	end
end
B:RegisterEvent("PLAYER_LOGIN", CheckRole)
B:RegisterEvent("PLAYER_TALENT_UPDATE", CheckRole)

-- Raidbuff Checklist
DB.BuffList = {
	[1] = {		-- 合剂
		431971, -- 淬火侵攻合剂
		431972, -- 淬火矫健合剂
		431973, -- 淬火全能合剂
		431974, -- 淬火精通合剂
		432021, -- 炼金混沌合剂
	},
	[2] = {     -- 食物
		104273, -- 进食充分
		462210, -- 丰盛进食充分
	},
	[3] = {     -- 10%智力
		1459,
		264760,
	},
	[4] = {     -- 10%耐力
		21562,
		264764,
	},
	[5] = {     -- 10%攻强
		6673,
		264761,
	},
	[6] = {     -- 符文
		453250, -- 晶化强化符文
	},
}

-- Reminder Buffs Checklist
DB.ReminderBuffs = {
	ITEMS = {
		{	itemID = 190384, -- 9.0永久属性符文
			spells = {
				[393438] = true, -- 巨龙强化符文 itemID 201325
				[367405] = true, -- 永久符文buff
			},
			instance = true,
			disable = true, -- 禁用直到出了新符文
		},
		{	itemID = 194307, -- 巢穴守护者的诺言
			spells = {
				[394457] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		--[=[
		{	itemID = 178742, -- 瓶装毒素饰品
			spells = {
				[345545] = true,
			},
			equip = true,
			instance = true,
			combat = true,
		},
		{	itemID = 190958, -- 究极秘术
			spells = {
				[368512] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		]=]
	},
	MAGE = {
		{	spells = {	-- 奥术魔宠
				[210126] = true,
			},
			depend = 205022,
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	-- 奥术智慧
				[1459] = true,
			},
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
		{	spells = {	-- 真言术耐
				[21562] = true,
			},
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
		{	spells = {	-- 战斗怒吼
				[6673] = true,
			},
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
		{	spells = {
				[192106] = true, -- 闪电之盾
				[974] = true, -- 大地之盾
				[383648] = true, -- 大地之盾
				[52127] = true, -- 水之护盾
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {
				[33757] = true, -- 风怒武器
			},
			depend = 33757,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 1,
			spec = 2,
		},
		{	spells = {
				[318038] = true, -- 火舌武器
			},
			depend = 318038,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 2,
			spec = 2,
		},
		{	spells = {	-- 天怒
				[462854] = true,
			},
			depend = 462854,
			instance = true,
		},
	},
	ROGUE = {
		{	spells = {	-- 伤害类毒药
				[2823] = true, -- 致命药膏
				[8679] = true, -- 致伤药膏
				[315584] = true, -- 速效药膏
				[381664] = true, -- 增效药膏
			},
			texture = 132273,
			depend = 315584,
			combat = true,
			instance = true,
			pvp = true,
		},
		{	spells = {	-- 效果类毒药
				[3408] = true, -- 减速药膏
				[5761] = true, -- 迟钝药膏
				[381637] = true, -- 萎缩药膏
			},
			depend = 3408,
			pvp = true,
		},
	},
	EVOKER = {
		{	spells = {	-- 青铜龙的祝福
				[381748] = true,
			},
			depend = 364342,
			instance = true,
		},
	},
	DRUID = {
		{	spells = {	-- 野性印记
				[1126] = true,
			},
			depend = 1126,
			instance = true,
		},
	},
--[[
	DEATHKNIGHT = {
		{	spells = {	-- 测试
				[188290] = true,
			},
		},
	},
]]
}

-- Item Stats
DB.ItemStats = {
	--["ITEM_MOD_CRIT_RATING_SHORT"] = true, -- 爆击
	--["ITEM_MOD_HASTE_RATING_SHORT"] = true, -- 急速
	--["ITEM_MOD_MASTERY_RATING_SHORT"] = true, -- 精通
	--["ITEM_MOD_VERSATILITY"] = true, -- 全能

	["ITEM_MOD_CR_AVOIDANCE_SHORT"] = true, -- 闪避
	["ITEM_MOD_CR_LIFESTEAL_SHORT"] = true, -- 吸血
	["ITEM_MOD_CR_SPEED_SHORT"] = true, -- 加速
	["ITEM_MOD_CR_STURDINESS_SHORT"] = true, -- 永不磨损
}

-- Item IDs
DB.MiscellaneousIDs = {
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

DB.OutmodedIDs = {
	[Enum.ItemClass.Consumable] = true,
	[Enum.ItemClass.Gem] = true,
	[Enum.ItemClass.Reagent] = true,
	[Enum.ItemClass.Tradegoods] = true,
	[Enum.ItemClass.ItemEnhancement] = true,
}

DB.ExcludeIDs = {
	[Enum.ItemConsumableSubclass.Generic] = Enum.ItemClass.Consumable,
	[Enum.ItemConsumableSubclass.Elixir] = Enum.ItemClass.Consumable,
	[Enum.ItemConsumableSubclass.Other] = Enum.ItemClass.Consumable,
}

-- Item Types
DB.ConduitTypes = {
	[CONDUIT_TYPE_ENDURANCE] = "耐久",
	[CONDUIT_TYPE_FINESSE] = "灵巧",
	[CONDUIT_TYPE_POTENCY] = "效能",
}

DB.CurioTypes = {
	[DELVES_CONFIG_SLOT_COMBAT_CURIO] = "战斗",
	[DELVES_CONFIG_SLOT_UTILITY_CURIO] = "效能",
}

DB.BindTypes = {
	[ITEM_ACCOUNTBOUND] = "BoA",
	[ITEM_BNETACCOUNTBOUND] = "BoA",
	[ITEM_BIND_ON_EQUIP] = "BoE",
	[ITEM_BIND_ON_USE] = "BoU",
	[ITEM_BIND_TO_ACCOUNT] = "BoA",
	[ITEM_BIND_TO_BNETACCOUNT] = "BoA",
	[ITEM_ACCOUNTBOUND_UNTIL_EQUIP] = "AuE",
	[ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP] = "AuE",
}

DB.EquipmentTypes = {
	["INVTYPE_HOLDABLE"] = SECONDARYHANDSLOT,
	["INVTYPE_SHIELD"] = SHIELDSLOT,
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

DB.Studying = {
	[450698] = true,
	[450793] = true,
	[450818] = true,
	[450819] = true,
	[450821] = true,
	[450824] = true,
	[450827] = true,
	[450828] = true,
	[450835] = true,
	[450836] = true,
	[450840] = true,
	[452259] = true,
	[452260] = true,
	[453371] = true,
	[453372] = true,
	[453440] = true,
	[453443] = true,
	[453444] = true,
	[453447] = true,
	[453448] = true,
	[453450] = true,
	[453452] = true,
	[453453] = true,
	[453454] = true,
	[453455] = true,
	[453456] = true,
	[453880] = true,
	[454023] = true,
	[454355] = true,
	[454358] = true,
	[457715] = true,
	[457717] = true,
	[457718] = true,
	[457719] = true,
	[457720] = true,
	[457721] = true,
	[457722] = true,
	[457723] = true,
	[457724] = true,
	[457725] = true,
	[457726] = true,
	[458432] = true,
	[458477] = true,
	[458681] = true,
	[458690] = true,
	[458719] = true,
	[458722] = true,
	[458726] = true,
	[458728] = true,
	[458729] = true,
	[458731] = true,
	[458733] = true,
	[458734] = true,
	[458738] = true,
	[459885] = true,
	[459886] = true,
	[459887] = true,
	[459888] = true,
	[459889] = true,
	[459890] = true,
	[459891] = true,
	[459892] = true,
	[459893] = true,
	[459894] = true,
	[459895] = true,
	[459896] = true,
	[459897] = true,
	[459898] = true,
	[459899] = true,
	[459900] = true,
	[459901] = true,
	[459902] = true,
	[459903] = true,
	[459904] = true,
	[459905] = true,
	[459906] = true,
	[459907] = true,
	[459908] = true,
	[459909] = true,
	[459910] = true,
	[459911] = true,
	[459912] = true,
	[459913] = true,
	[459914] = true,
	[459915] = true,
	[459916] = true,
	[459917] = true,
	[460234] = true,
	[460240] = true,
	[460258] = true,
	[462138] = true,
	[462141] = true,
	[462142] = true,
	[462143] = true,
	[462144] = true,
	[462146] = true,
	[462902] = true,
	[462903] = true,
	[462904] = true,
	[462905] = true,
	[462906] = true,
	[462907] = true,
	[462908] = true,
	[462909] = true,
	[462910] = true,
	[462911] = true,
	[462912] = true,
	[462913] = true,
	[462914] = true,
	[462915] = true,
	[462916] = true,
	[462917] = true,
	[463199] = true,
	[463200] = true,
	[463201] = true,
	[463202] = true,
	[463203] = true,
	[463204] = true,
	[463205] = true,
}

DB.SpecialJunk = {
	[3300] = true, -- 幸运兔脚
	[3670] = true, -- 带粘液的骨头
	[6150] = true, -- 绳结
	[11406] = true, -- 腐烂的熊肉
	[11944] = true, -- 黑铁幼婴鞋
	[25402] = true, -- 有坚不摧之力
	[36812] = true, -- 基础零件
	[62072] = true, -- 罗波的摇头杖
	[67410] = true, -- 极其不祥的石头
	[221550] = true, -- 薮根伞菇
}

DB.PrimordialStone = {}
for id = 204000, 204030 do
	DB.PrimordialStone[id] = true
end
for id = 204573, 204579 do
	DB.PrimordialStone[id] = true
end
DB.PrimordialStone[203703] = true -- 棱光碎片