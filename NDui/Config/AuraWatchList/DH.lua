local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "DEMONHUNTER" then return end

-- DH的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID = 258920, UnitID = "player"}, -- 献祭光环
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID = 179057, UnitID = "target", Caster = "player"}, -- 混乱新星
		{AuraID = 185245, UnitID = "target", Caster = "player"}, -- 折磨
		{AuraID = 204490, UnitID = "target", Caster = "player"}, -- 沉默咒符
		{AuraID = 204598, UnitID = "target", Caster = "player"}, -- 烈焰咒符
		{AuraID = 204843, UnitID = "target", Caster = "player"}, -- 锁链咒符
		{AuraID = 207685, UnitID = "target", Caster = "player"}, -- 悲苦咒符
		{AuraID = 207771, UnitID = "target", Caster = "player"}, -- 烈火烙印
		{AuraID = 211881, UnitID = "target", Caster = "player"}, -- 邪能爆发
		{AuraID = 217832, UnitID = "target", Caster = "player"}, -- 禁锢
		{AuraID = 258883, UnitID = "target", Caster = "player"}, -- 毁灭之痕
		{AuraID = 320338, UnitID = "target", Caster = "player"}, -- 精华破碎
		{AuraID = 370969, UnitID = "target", Caster = "player"}, -- 恶魔追击
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID = 162264, UnitID = "player"}, -- 恶魔变形
		{AuraID = 187827, UnitID = "player"}, -- 恶魔变形
		{AuraID = 196555, UnitID = "player"}, -- 虚空行走
		{AuraID = 203819, UnitID = "player"}, -- 恶魔尖刺
		{AuraID = 208628, UnitID = "player"}, -- 势如破竹
		{AuraID = 212800, UnitID = "player"}, -- 疾影
		{AuraID = 212988, UnitID = "player"}, -- 痛苦使者
		{AuraID = 343312, UnitID = "player"}, -- 狂怒凝视
		{AuraID = 347462, UnitID = "player"}, -- 释放混沌
		{AuraID = 389890, UnitID = "player"}, -- 战术撤退
		{AuraID = 390145, UnitID = "player"}, -- 内心之魔
		{AuraID = 390195, UnitID = "player"}, -- 混沌理论
		{AuraID = 390212, UnitID = "player"}, -- 无休猎手
		{AuraID = 391171, UnitID = "player"}, -- 钙化尖刺
		{AuraID = 391215, UnitID = "player"}, -- 先发制人
		{AuraID = 391234, UnitID = "player", Value = true}, -- 贩卖灵魂
		{AuraID = 427641, UnitID = "player"}, -- 冲撞惯性
	},
}

module:AddNewAuraWatch("DEMONHUNTER", list)