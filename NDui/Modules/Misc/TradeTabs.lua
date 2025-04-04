local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION or 0
local RUNEFORGING_ID = 53428
local PICK_LOCK = 1804
local CHEF_HAT = 134020
local THERMAL_ANVIL = 87216
local tabList = {}

local onlyPrimary = {
	[171] = true, -- Alchemy
	[182] = true, -- Herbalism
	[186] = true, -- Mining
	[202] = true, -- Engineering
	[356] = true, -- Fishing
	[393] = true, -- Skinning
}

function M:UpdateProfessions()
	local prof1, prof2, _, fish, cook = GetProfessions()
	local profs = {prof1, prof2, fish, cook}

	if DB.MyClass == "DEATHKNIGHT" then
		M:TradeTabs_Create(RUNEFORGING_ID)
	elseif DB.MyClass == "ROGUE" and IsPlayerSpell(PICK_LOCK) then
		M:TradeTabs_Create(PICK_LOCK)
	end

	local isCook
	for _, prof in pairs(profs) do
		local _, _, _, _, numSpells, spelloffset, skillLine = GetProfessionInfo(prof)
		if skillLine == 185 then isCook = true end

		numSpells = onlyPrimary[skillLine] and 1 or numSpells
		if numSpells > 0 then
			for i = 1, numSpells do
				local slotID = i + spelloffset
				if not C_SpellBook.IsSpellBookItemPassive(slotID, BOOKTYPE_PROFESSION) then
					local spellID = C_SpellBook.GetSpellBookItemInfo(slotID, BOOKTYPE_PROFESSION).spellID
					if i == 1 then
						M:TradeTabs_Create(spellID)
					else
						M:TradeTabs_Create(spellID)
					end
				end
			end
		end
	end

	if isCook and PlayerHasToy(CHEF_HAT) then
		M:TradeTabs_Create(nil, CHEF_HAT)
	end
	if C_Item.GetItemCount(THERMAL_ANVIL) > 0 then
		M:TradeTabs_Create(nil, nil, THERMAL_ANVIL)
	end
end

function M:TradeTabs_Update()
	for _, tab in pairs(tabList) do
		local spellID = tab.spellID
		local itemID = tab.itemID

		if spellID and C_Spell.IsCurrentSpell(spellID) then
			tab:SetChecked(true)
			tab.cover:Show()
		else
			tab:SetChecked(false)
			tab.cover:Hide()
		end

		local start, duration
		if itemID then
			start, duration = C_Item.GetItemCooldown(itemID)
		else
			local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
			start = cooldownInfo and cooldownInfo.startTime
			duration = cooldownInfo and cooldownInfo.duration
		end
		if start and duration and duration > 1.5 then
			tab.CD:SetCooldown(start, duration)
		end
	end
end

function M:TradeTabs_ReskinButton()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	for _, tab in pairs(tabList) do
		tab:SetCheckedTexture(DB.pushedTex)
		B.CreateBDFrame(tab)
		local texture = tab:GetNormalTexture()
		if texture then texture:SetTexCoord(unpack(DB.TexCoord)) end
	end
end

local index = 1
function M:TradeTabs_Create(spellID, toyID, itemID)
	local name, _, texture
	if toyID then
		_, name, texture = C_ToyBox.GetToyInfo(toyID)
	elseif itemID then
		name, texture = C_Item.GetItemNameByID(itemID), C_Item.GetItemIconByID(itemID)
	else
		name, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
	end
	if not name then return end -- precaution

	local tab = CreateFrame("CheckButton", nil, ProfessionsFrame, "SecureActionButtonTemplate")
	tab:SetSize(32, 32)
	tab.tooltip = name
	tab.spellID = spellID
	tab.itemID = toyID or itemID
	tab.type = (toyID and "toy") or (itemID and "item") or "spell"
	tab:RegisterForClicks("AnyDown")
	if spellID == 818 then -- cooking fire
		tab:SetAttribute("type", "macro")
		tab:SetAttribute("macrotext", "/cast [@player]"..name)
	else
		tab:SetAttribute("type", tab.type)
		tab:SetAttribute(tab.type, spellID or name)
	end
	tab:SetNormalTexture(texture)
	tab:SetHighlightTexture(DB.bdTex)
	tab:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	tab:Show()

	tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
	tab.CD:SetAllPoints()

	tab.cover = CreateFrame("Frame", nil, tab)
	tab.cover:SetAllPoints()
	tab.cover:EnableMouse(true)

	tab:SetPoint("TOPLEFT", ProfessionsFrame, "TOPRIGHT", 3, -index*42)
	table.insert(tabList, tab)
	index = index + 1
end

function M:TradeTabs_FilterIcons()
	local buttonList = {
		[1] = {"Atlas:bags-greenarrow", TRADESKILL_FILTER_HAS_SKILL_UP, C_TradeSkillUI.GetOnlyShowSkillUpRecipes, C_TradeSkillUI.SetOnlyShowSkillUpRecipes},
		[2] = {"Interface\\RAIDFRAME\\ReadyCheck-Ready", CRAFT_IS_MAKEABLE, C_TradeSkillUI.GetOnlyShowMakeableRecipes, C_TradeSkillUI.SetOnlyShowMakeableRecipes},
	}

	local function filterClick(self)
		local value = self.__value
		if value[3]() then
			value[4](false)
			B.SetBorderColor(self.bg)
		else
			value[4](true)
			self.bg:SetBackdropBorderColor(1, 1, 0)
		end
	end

	local buttons = {}
	for index, value in pairs(buttonList) do
		local bu = CreateFrame("Button", nil, ProfessionsFrame.CraftingPage.RecipeList, "BackdropTemplate")
		bu:SetSize(22, 22)
		bu:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "TOPRIGHT", -(index-1)*26 + 7, 10)
		B.PixelIcon(bu, value[1], true)
		B.AddTooltip(bu, "ANCHOR_TOP", value[2])
		bu.__value = value
		bu:SetScript("OnClick", filterClick)

		buttons[index] = bu
	end

	local function updateFilterStatus()
		for index, value in pairs(buttonList) do
			if value[3]() then
				buttons[index].bg:SetBackdropBorderColor(1, 1, 0)
			else
				B.SetBorderColor(buttons[index].bg)
			end
		end
	end
	B:RegisterEvent("TRADE_SKILL_LIST_UPDATE", updateFilterStatus)
end

local init
function M:TradeTabs_OnLoad()
	init = true

	M:UpdateProfessions()

	M:TradeTabs_ReskinButton()
	M:TradeTabs_Update()
	B:RegisterEvent("TRADE_SKILL_SHOW", M.TradeTabs_Update)
	B:RegisterEvent("TRADE_SKILL_CLOSE", M.TradeTabs_Update)
	B:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", M.TradeTabs_Update)

	M:TradeTabs_FilterIcons()

	B:UnregisterEvent("PLAYER_REGEN_ENABLED", M.TradeTabs_OnLoad)
end

local function LoadTradeTabs()
	if init then return end
	if InCombatLockdown() then
		B:RegisterEvent("PLAYER_REGEN_ENABLED", M.TradeTabs_OnLoad)
	else
		M:TradeTabs_OnLoad()
	end
end

function M:TradeTabs()
	if not C.db["Misc"]["TradeTabs"] then return end
	if ProfessionsFrame then
		ProfessionsFrame:HookScript("OnShow", LoadTradeTabs)
	else
		B:RegisterEvent("ADDON_LOADED", function(_, addon)
			if addon == "Blizzard_Professions" then
				LoadTradeTabs()
			end
		end)
	end
end
M:RegisterMisc("TradeTabs", M.TradeTabs)