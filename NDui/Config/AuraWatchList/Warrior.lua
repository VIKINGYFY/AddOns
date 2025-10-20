local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "WARRIOR" then return end

-- 战士的法术监控
local list = {
	["Player Aura"] = { -- 玩家光环组
		{AuraID =   32216, UnitID = "player"}, -- 胜利
		{AuraID =  202164, UnitID = "player"}, -- 腾跃步伐
		{AuraID =  262232, UnitID = "player"}, -- 战争机器
	},
	["Target Aura"] = { -- 目标光环组
		{AuraID =     355, UnitID = "target", Caster = "player"}, -- 嘲讽
		{AuraID =    1160, UnitID = "target", Caster = "player"}, -- 挫志怒吼
		{AuraID =  132168, UnitID = "target", Caster = "player"}, -- 震荡波
		{AuraID =  132169, UnitID = "target", Caster = "player"}, -- 风暴之锤
		{AuraID =  385954, UnitID = "target", Caster = "player"}, -- 盾牌冲锋
		{AuraID =  386071, UnitID = "target", Caster = "player"}, -- 瓦解怒吼
		{AuraID =  397364, UnitID = "target", Caster = "player"}, -- 雷鸣之吼

	},
	["Special Aura"] = { -- 玩家重要光环组
		{AuraID =     871, UnitID = "player"}, -- 盾墙
		{AuraID =   12975, UnitID = "player"}, -- 破釜沉舟
		{AuraID =   18499, UnitID = "player"}, -- 狂暴之怒
		{AuraID =   23920, UnitID = "player"}, -- 法术反射
		{AuraID =  107574, UnitID = "player"}, -- 天神下凡
		{AuraID =  132404, UnitID = "player"}, -- 盾牌格挡
		{AuraID =  190456, UnitID = "player", Value = true}, -- 无视苦痛
		{AuraID =  386397, UnitID = "player", Flash = true}, -- 历战老兵
	},
}

module:AddNewAuraWatch("WARRIOR", list)