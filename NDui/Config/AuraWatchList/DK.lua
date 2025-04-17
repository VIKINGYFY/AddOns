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
		{AuraID = 374585, UnitID = "player"}, -- 符文掌握
		{AuraID = 383269, UnitID = "player"}, -- 憎恶附肢
		{AuraID = 444347, UnitID = "player"}, -- 死亡冲锋
		{AuraID = 434242, UnitID = "pet", Value = true}, -- 血凝固结

	},
	["Target Aura"] = {		-- 目标光环组
		{AuraID =  45524, UnitID = "target", Caster = "player"}, -- 寒冰锁链
		{AuraID =  51714, UnitID = "target", Caster = "player"}, -- 锋锐之霜
		{AuraID =  55078, UnitID = "target", Caster = "player"}, -- 血之疫病
		{AuraID =  55095, UnitID = "target", Caster = "player"}, -- 冰霜疫病
		{AuraID =  56222, UnitID = "target", Caster = "player"}, -- 黑暗命令
		{AuraID = 207167, UnitID = "target", Caster = "player"}, -- 致盲冰雨
		{AuraID = 374557, UnitID = "target", Caster = "player"}, -- 羸弱
		{AuraID = 392490, UnitID = "target", Caster = "player"}, -- 衰弱
		{AuraID = 434765, UnitID = "target", Caster = "player"}, -- 死神印记
		{AuraID = 440772, UnitID = "target", Caster = "player"}, -- 灵魂迸裂
		{AuraID = 443404, UnitID = "target", Caster = "player"}, -- 灵魂浪潮
		{AuraID = 444633, UnitID = "target", Caster = "player"}, -- 死灵
		{AuraID = 444828, UnitID = "target", Caster = "player"}, -- 寒冰锁链
		{AuraID = 448229, UnitID = "target", Caster = "player"}, -- 灵魂收割
		{AuraID = 454824, UnitID = "target", Caster = "player"}, -- 镇压攫握
		{AuraID = 458478, UnitID = "target", Caster = "player"}, -- 煽动惊恐
		{AuraID = 458687, UnitID = "target", Caster = "player"}, -- 饮血者

	},
	["Special Aura"] = {	-- 玩家重要光环组
		{AuraID =  51124, UnitID = "player"}, -- 杀戮机器
		{AuraID =  51271, UnitID = "player"}, -- 冰霜之柱
		{AuraID =  55233, UnitID = "player"}, -- 吸血鬼之血
		{AuraID =  59052, UnitID = "player"}, -- 白霜
		{AuraID =  77535, UnitID = "player", Value = true}, -- 鲜血护盾
		{AuraID =  81256, UnitID = "player"}, -- 符文刃舞
		{AuraID = 116888, UnitID = "player", Value = true, Flash = true}, -- 炼狱蔽体
		{AuraID = 152279, UnitID = "player", Flash = true}, -- 冰龙吐息
		{AuraID = 194844, UnitID = "player"}, -- 白骨风暴
		{AuraID = 195181, UnitID = "player"}, -- 白骨之盾
		{AuraID = 196770, UnitID = "player"}, -- 冷酷严冬
		{AuraID = 211805, UnitID = "player"}, -- 风暴汇聚
		{AuraID = 219809, UnitID = "player", Value = true}, -- 墓石
		{AuraID = 273947, UnitID = "player"}, -- 鲜血禁闭
		{AuraID = 274156, UnitID = "player"}, -- 吞噬
		{AuraID = 377103, UnitID = "player"}, -- 断裂之痕
		{AuraID = 377195, UnitID = "player"}, -- 历久弥坚
		{AuraID = 377253, UnitID = "player"}, -- 冰霜雏龙之援
		{AuraID = 391481, UnitID = "player"}, -- 凝血
		{AuraID = 391527, UnitID = "player", Value = true}, -- 永恒脐带
		{AuraID = 433925, UnitID = "player"}, -- 鲜血女王的精华
		{AuraID = 441416, UnitID = "player"}, -- 破灭
		{AuraID = 454871, UnitID = "player", Flash = true}, -- 抽血
		{AuraID = 456370, UnitID = "player"}, -- 低温冰冻
		{AuraID = 458745, UnitID = "player"}, -- 骨化锋刺
		{AuraID = 460049, UnitID = "player"}, -- 苦痛凌虐
		{AuraID = 469169, UnitID = "player"}, -- 凄惨痛快
		{AuraID = 460500, UnitID = "player"}, -- 染血利刃

	},
}

module:AddNewAuraWatch("DEATHKNIGHT", list)