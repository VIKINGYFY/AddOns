local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("AurasTable")

if DB.MyClass ~= "DEATHKNIGHT" then return end

-- DK的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		{AuraID =   3714, UnitID = "player"}, -- 冰霜之路
		{AuraID =  47568, UnitID = "player"}, -- 符文武器增效
		{AuraID =  48265, UnitID = "player"}, -- 死亡脚步
		{AuraID =  48707, UnitID = "player", Value = true}, -- 反魔法护罩
		{AuraID =  48792, UnitID = "player"}, -- 冰封之韧
		{AuraID =  49039, UnitID = "player"}, -- 巫妖之躯
		{AuraID =  53365, UnitID = "player"}, -- 不洁之力
		{AuraID = 101568, UnitID = "player"}, -- 黑暗援助
		{AuraID = 111673, UnitID = "pet"}, -- 控制亡灵
		{AuraID = 188290, UnitID = "player", Flash = true}, -- 枯萎凋零
		{AuraID = 194879, UnitID = "player"}, -- 冰冷之爪
		{AuraID = 212552, UnitID = "player"}, -- 幻影步
		{AuraID = 326808, UnitID = "player"}, -- 鲜血符文
		{AuraID = 326867, UnitID = "player", Value = true}, -- 护咒符文
		{AuraID = 326868, UnitID = "player"}, -- 倦怠
		{AuraID = 326918, UnitID = "player"}, -- 癔狂符文
		{AuraID = 326984, UnitID = "player"}, -- 无尽渴求符文
		{AuraID = 383269, UnitID = "player"}, -- 憎恶附肢
	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID =  45524, UnitID = "target", Caster = "player"}, -- 寒冰锁链
		{AuraID =  55078, UnitID = "target", Caster = "player"}, -- 血之疫病
		{AuraID =  55095, UnitID = "target", Caster = "player"}, -- 冰霜疫病
		{AuraID =  56222, UnitID = "target", Caster = "player"}, -- 黑暗命令
		{AuraID = 207167, UnitID = "target", Caster = "player"}, -- 致盲冰雨
		{AuraID = 374554, UnitID = "target", Caster = "player"}, -- 羸弱
		{AuraID = 376974, UnitID = "target", Caster = "player"}, -- 永冻之冰
		{AuraID = 377048, UnitID = "target", Caster = "player"}, -- 绝对零度
		{AuraID = 392490, UnitID = "target", Caster = "player"}, -- 衰弱
		{AuraID = 458687, UnitID = "target", Caster = "player"}, -- 饮血者
	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID =  51124, UnitID = "player"}, -- 杀戮机器
		{AuraID =  55233, UnitID = "player"}, -- 吸血鬼之血
		{AuraID =  59052, UnitID = "player"}, -- 白霜
		{AuraID =  77535, UnitID = "player", Value = true}, -- 鲜血护盾
		{AuraID =  81141, UnitID = "player"}, -- 赤色天灾
		{AuraID =  81256, UnitID = "player"}, -- 符文刃舞
		{AuraID = 116888, UnitID = "player", Value = true, Flash = true}, -- 炼狱蔽体
		{AuraID = 152279, UnitID = "player", Flash = true}, -- 冰龙吐息
		{AuraID = 195181, UnitID = "player"}, -- 白骨之盾
		{AuraID = 196770, UnitID = "player"}, -- 冷酷严冬
		{AuraID = 211805, UnitID = "player"}, -- 风暴汇聚
		{AuraID = 219809, UnitID = "player", Value = true}, -- 墓石
		{AuraID = 274156, UnitID = "player"}, -- 吞噬
		{AuraID = 374748, UnitID = "player"}, -- 黑锋骑士团之毅
		{AuraID = 377103, UnitID = "player"}, -- 挫骨扬尘
		{AuraID = 377195, UnitID = "player"}, -- 历久弥坚
		{AuraID = 377253, UnitID = "player"}, -- 冰霜雏龙之援
		{AuraID = 377656, UnitID = "player"}, -- 裂心
		{AuraID = 391481, UnitID = "player"}, -- 凝血
		{AuraID = 391527, UnitID = "player", Value = true}, -- 永恒脐带
		{AuraID = 454871, UnitID = "player", Flash = true}, -- 抽血
	},
}

module:AddNewAuraWatch("DEATHKNIGHT", list)