--------------------------------
-- FreebAutoRez, by Freebaser
-- NDui MOD
--------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF

local classList = {
	["DRUID"] = {
		combat = C_Spell.GetSpellName(20484),		-- 复生
		oneres = C_Spell.GetSpellName(50769),		-- 起死回生
	},
	["PALADIN"] = {
		combat = C_Spell.GetSpellName(391054),		-- 代祷
		oneres = C_Spell.GetSpellName(7328),		-- 救赎
	},
	["DEATHKNIGHT"] = {
		combat = C_Spell.GetSpellName(61999),		-- 复活盟友
	},
	["WARLOCK"] = {
		combat = C_Spell.GetSpellName(20707),		-- 灵魂石
	},
	["EVOKER"] = {
		oneres = C_Spell.GetSpellName(361227),		-- 生还
	},
	["MONK"] = {
		oneres = C_Spell.GetSpellName(115178),		-- 轮回转世
	},
	["PRIEST"] = {
		oneres = C_Spell.GetSpellName(2006),		-- 复活术
	},
	["SHAMAN"] = {
		oneres = C_Spell.GetSpellName(2008),		-- 先祖之魂
	},
}

local body = ""
local function macroBody(class)
	body = "/stopmacro [@mouseover,nodead]\n"
	body = "/stopcasting\n"

	local combatSpell = classList[class].combat
	local oneresSpell = classList[class].oneres

	if combatSpell and oneresSpell then
		body = body.."/cast [combat,@mouseover,help,dead][combat,help,dead] "..combatSpell.."; [nocombat,@mouseover,help,dead][nocombat,help,dead] "..oneresSpell.."\n"
	elseif oneresSpell then
		body = body.."/cast [nocombat,@mouseover,help,dead][nocombat,help,dead] "..oneresSpell.."\n"
	elseif combatSpell then
		body = body.."/cast [@mouseover,help,dead][help,dead] "..combatSpell.."\n"
	end

	return body
end

local function setupAttribute(self)
	if InCombatLockdown() then return end

	if classList[DB.MyClass] and not C_AddOns.IsAddOnLoaded("Clique") then
		self:SetAttribute("*type3", "macro")
		self:SetAttribute("macrotext3", macroBody(DB.MyClass))
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", setupAttribute)
	end
end

local function Enable(self)
	if not C.db["UFs"]["AutoRes"] then return end

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", setupAttribute, true)
	else
		setupAttribute(self)
	end
end

local function Disable(self)
	if C.db["UFs"]["AutoRes"] then return end

	self:SetAttribute("*type3", nil)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", setupAttribute)
end

oUF:AddElement("AutoResurrect", nil, Enable, Disable)