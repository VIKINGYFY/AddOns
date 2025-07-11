local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

-- 角标的相关法术 [spellID] = {anchor, {r, g, b}, ALL}
C.CornerBuffs = {
	["PRIEST"] = {
		[ 194384] = {"TOPRIGHT", {1, 1, .66}}, -- 救赎
		[ 214206] = {"TOPRIGHT", {1, 1, .66}}, -- 救赎(PvP)
		[  41635] = {"BOTTOMRIGHT", {.2, .7, .2}}, -- 愈合导言
		[ 193065] = {"BOTTOMRIGHT", {.54, .21, .78}}, -- 忍辱负重
		[    139] = {"TOPLEFT", {.4, .7, .2}}, -- 恢复
		[     17] = {"TOPLEFT", {.7, .7, .7}}, -- 真言术盾
		[  47788] = {"LEFT", {.86, .45, 0}, true}, -- 守护之魂
		[  33206] = {"LEFT", {.47, .35, .74}, true}, -- 痛苦压制
		[   6788] = {"TOP", {.86, .11, .11}, true}, -- 虚弱灵魂
	},
	["DRUID"] = {
		[    774] = {"TOPRIGHT", {.8, .4, .8}}, -- 回春
		[ 155777] = {"RIGHT", {.6, .4, .8}}, -- 萌芽
		[   8936] = {"LEFT", {.2, .8, .2}}, -- 愈合
		[  33763] = {"TOPLEFT", {.4, .8, .2}}, -- 生命绽放
		[ 188550] = {"TOPLEFT", {.4, .8, .2}}, -- 生命绽放，橙装
		[  48438] = {"BOTTOMRIGHT", {.8, .4, 0}}, -- 野性成长
		[  29166] = {"TOP", {0, .4, 1}}, -- 激活
		[ 391891] = {"TOP", {0, .8, .4}}, -- 激变蜂群
		[ 102351] = {"BOTTOM", {.2, .8, .8}}, -- 结界
		[ 102352] = {"BOTTOM", {.2, .8, .8}}, -- 结界(HoT)
		[ 200389] = {"BOTTOM", {1, 1, .4}}, -- 栽培
	},
	["EVOKER"] = {
		[ 355941] = {"TOPLEFT", {.4, .7, .2}}, -- 梦境吐息
		[ 364343] = {"TOPRIGHT", {0, .8, .8}}, -- 回响
		[ 366155] = {"RIGHT", {1,.9, .5}}, -- 逆转
		[ 370888] = {"TOP", {0, .4, 1}}, -- 双生护卫
		[ 357170] = {"LEFT", {.47, .35, .74}, true}, -- 时间膨胀
	},
	["PALADIN"] = {
		[ 287280] = {"TOPLEFT", {1, .8, 0}}, -- 圣光闪烁
		[  53563] = {"TOPRIGHT", {.7, .3, .7}}, -- 道标
		[ 156910] = {"TOPRIGHT", {.7, .3, .7}}, -- 信仰道标
		[ 200025] = {"TOPRIGHT", {.7, .3, .7}}, -- 美德道标
		[   1022] = {"BOTTOMRIGHT", {.2, .2, 1}, true}, -- 保护
		[   1044] = {"BOTTOMRIGHT", {.89, .45, 0}, true}, -- 自由
		[   6940] = {"BOTTOMRIGHT", {.89, .1, .1}, true}, -- 牺牲
		[ 223306] = {"BOTTOM", {.7, .7, .3}}, -- 赋予信仰
		[  25771] = {"TOP", {.86, .11, .11}, true}, -- 自律
	},
	["SHAMAN"] = {
		[  61295] = {"TOPRIGHT", {.2, .8, .8}}, -- 激流
		[    974] = {"BOTTOMRIGHT", {1, .8, 0}}, -- 大地之盾
		[ 383648] = {"BOTTOMRIGHT", {1, .8, 0}}, -- 大地之盾
	},
	["MONK"] = {
		[ 119611] = {"TOPLEFT", {.3, .8, .6}}, -- 复苏之雾
		[ 116849] = {"TOP", {.2, .8, .2}, true}, -- 作茧缚命
		[ 124682] = {"TOPRIGHT", {.8, .8, .25}}, -- 氤氲之雾
		[ 191840] = {"BOTTOMRIGHT", {.27, .62, .7}}, -- 精华之泉
	},
	["ROGUE"] = {
		[  57934] = {"BOTTOMRIGHT", {.9, .1, .1}}, -- 嫁祸
	},
	["WARRIOR"] = {
		[ 114030] = {"TOPLEFT", {.2, .2, 1}}, -- 警戒
	},
	["HUNTER"] = {
		[  34477] = {"BOTTOMRIGHT", {.9, .1, .1}}, -- 误导
		[  90361] = {"TOPLEFT", {.4, .8, .2}}, -- 灵魂治愈
	},
	["WARLOCK"] = {
		[  20707] = {"BOTTOMRIGHT", {.8, .4, .8}, true}, -- 灵魂石
	},
	["DEMONHUNTER"] = {},
	["MAGE"] = {},
	["DEATHKNIGHT"] = {},
}

-- 大米词缀及赛季相关
local SEASON_SPELLS = {
	--[ 209858] = 2, -- 死疽
	--[ 240443] = 2, -- 爆裂
	--[ 240559] = 1, -- 重伤
	--[ 408556] = 2, -- 缠绕
	--[ 342494] = 2, -- 狂妄吹嘘，S1
	--[ 355732] = 2, -- 融化灵魂，S2
	--[ 356666] = 2, -- 刺骨之寒，S2
	--[ 356667] = 2, -- 刺骨之寒，S2
	--[ 356925] = 2, -- 屠戮，S2
	--[ 358777] = 2, -- 痛苦之链，S2
	--[ 366288] = 2, -- 猛力砸击，S3
	--[ 366297] = 2, -- 解构，S3
	--[ 396364] = 2, -- 狂风标记，DF S1
	--[ 396369] = 2, -- 闪电标记，DF S1
	[ 440313] = 2, -- 虚空裂隙，TWW S1
}
function module:RegisterSeasonSpells(tier, instance)
	for spellID, priority in pairs(SEASON_SPELLS) do
		module:RegisterDebuff(tier, instance, 0, spellID, priority)
	end
end

-- 团队框体减益指示器黑名单
C.RaidDebuffsBlack = {
	[ 206151] = true, -- 挑战者的负担
	[ 296847] = true, -- 压迫光环
	[ 338906] = true, -- 典狱长之链
}

-- 团队框体增益指示器白名单
C.RaidBuffsWhite = {
	[    642] = true, -- 圣盾术
	[    871] = true, -- 盾墙
	[   1022] = true, -- 保护祝福
	[   1044] = true, -- 自由祝福
	[   6940] = true, -- 牺牲祝福
	[  10060] = true, -- 能量灌注
	[  22812] = true, -- 树皮术
	[  61336] = true, -- 生存本能
	[  27827] = true, -- 救赎之魂
	[  31224] = true, -- 暗影斗篷
	[  33206] = true, -- 痛苦压制
	[  45438] = true, -- 冰箱
	[  47585] = true, -- 消散
	[  47788] = true, -- 守护之魂
	[  48792] = true, -- 冰封之韧
	[  86659] = true, -- 远古列王守卫
	[ 102342] = true, -- 铁木树皮
	[ 102558] = true, -- 熊化身
	[ 104773] = true, -- 不灭决心
	[ 108271] = true, -- 星界转移
	[ 110909] = true, -- 操控时间
	[ 115203] = true, -- 壮胆酒
	[ 116849] = true, -- 作茧缚命
	[ 118038] = true, -- 剑在人在
	[ 160029] = true, -- 正在复活
	[ 186265] = true, -- 灵龟守护
	[ 196555] = true, -- 虚空行走
	[ 204018] = true, -- 破咒祝福
	[ 204150] = true, -- 圣光护盾
	[ 264735] = true, -- 优胜劣汰
	[ 281195] = true, -- 优胜劣汰
	[ 374348] = true, -- 新生光焰
	[ 363916] = true, -- 黑曜鳞片
}