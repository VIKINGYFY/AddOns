local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:GetModule("Extras")

local LAB = LibStub("LibActionButton-1.0-NDui")
local ActionButtons = LAB.actionButtons

local ActionBarSpells = {
	["DEATHKNIGHT"] = {
		[ 43265] = -188290, -- 枯萎凋零
		[ 49028] = true, -- 符文刃舞
		[152279] = true, -- 冰龙吐息
		[194844] = 188290, -- 白骨风暴
		[196770] = true, -- 冷酷严冬
		[219809] = 188290, -- 墓石
		[274156] = true, -- 吞噬
		[279302] = true, -- 冰霜巨龙之怒
		[305392] = true, -- 寒冰连结
		[383269] = true, -- 憎恶附肢
		[439843] = true, -- 死神印记
	},
	["DEMONHUNTER"] = {
		[198013] = true, -- 眼棱
		[204596] = true, -- 烈焰咒符
		[212084] = true, -- 邪能毁灭
		[258920] = true, -- 献祭光环
		[342817] = true, -- 战刃风暴
		[370965] = true, -- 恶魔追击
		[390163] = true, -- 极乐敕令
	},
	["HUNTER"] = {
		[  2643] = -268877, -- 多重射击 兽王
		[ 19574] = true, -- 狂野怒火
		[120679] = true, -- 凶暴野兽
		[212431] = true, -- 爆炸射击
		[257044] = true, -- 急速射击
		[260243] = true, -- 乱射
	},
}

function EX:ActionBarGlow_Update()
	local isUsable = self:IsUsable()
	local spellID = self:GetSpellId()
	local _, spellCD = self:GetCooldown()
	local buffID = EX.ActionBars[spellID]

	if buffID then
		if InCombatLockdown() and isUsable and spellID and spellCD < 2 then
			local isBuffID = type(buffID) == "number"
			local hasBuffID = isBuffID and C_UnitAuras.GetPlayerAuraBySpellID(math.abs(buffID))
			if (not isBuffID) or (isBuffID and buffID > 0 and hasBuffID) or (isBuffID and buffID < 0 and not hasBuffID) then
				B.ShowOverlayGlow(self)
			else
				B.HideOverlayGlow(self)
			end
		else
			B.HideOverlayGlow(self)
		end
	end
end

function EX:ActionBarGlow_OnEvent()
	for button in next, ActionButtons do
		if button:IsVisible() then
			EX.ActionBarGlow_Update(button)
		end
	end
end

function EX:ActionBarGlow()
	EX.ActionBars = ActionBarSpells[DB.MyClass]
	if not EX.ActionBars then return end

	B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", EX.ActionBarGlow_OnEvent)
end