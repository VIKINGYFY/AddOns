local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:GetModule("GUI")

local function sortBars(barTable)
	local num = 1
	for _, bar in pairs(barTable) do
		bar:SetPoint("TOPLEFT", 10, -10 - 35*(num-1))
		num = num + 1
	end
end

local extraGUIs = {}
local function toggleExtraGUI(guiName)
	for name, frame in pairs(extraGUIs) do
		if name == guiName then
			B:TogglePanel(frame)
		else
			frame:Hide()
		end
	end
end

local function hideExtraGUIs()
	for _, frame in pairs(extraGUIs) do
		frame:Hide()
	end
end

local function createExtraGUI(parent, name, title, bgFrame)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetSize(300, 600)
	frame:SetPoint("TOPLEFT", parent:GetParent(), "TOPRIGHT", 3, 0)
	B.SetBD(frame)

	if title then
		B.CreateFS(frame, 14, title, "system", "TOPLEFT", 20, -25)
	end

	if bgFrame then
		frame.bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
		frame.bg:SetSize(280, 540)
		frame.bg:SetPoint("TOPLEFT", 10, -50)
		B.CreateBD(frame.bg, .25)
	end

	if not parent.extraGUIHook then
		parent:HookScript("OnHide", hideExtraGUIs)
		parent.extraGUIHook = true
	end
	extraGUIs[name] = frame

	return frame
end

local function clearEdit(options)
	for i = 1, #options do
		G:ClearEdit(options[i])
	end
end

local function toggleOptionsPanel(option)
	local dd = option.__owner
	for i = 1, #dd.panels do
		dd.panels[i]:SetShown(i == option.index)
	end
end

local function updateRaidDebuffs()
	B:GetModule("UnitFrames"):UpdateRaidDebuffs()
end

local function AddNewDungeon(dungeons, dungeonID)
	local name = EJ_GetInstanceInfo(dungeonID)
	if name then
		table.insert(dungeons, name)
	end
end

function G:SetupRaidDebuffs(parent)
	local guiName = "NDuiGUI_RaidDebuffs"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["RaidFrame Debuffs"].."*", true)
	panel:SetScript("OnHide", updateRaidDebuffs)

	local setupBars
	local frame = panel.bg
	local bars, options = {}, {}

	local iType = G:CreateDropdown(frame, L["Type*"], 10, -30, {DUNGEONS, RAID, OTHER}, L["Instance Type"])
	for i = 1, 3 do
		iType.options[i]:HookScript("OnClick", function()
			for j = 1, 2 do
				G:ClearEdit(options[j])
				if i == j then
					options[j]:Show()
				else
					options[j]:Hide()
				end
			end

			for k = 1, #bars do
				bars[k]:Hide()
			end

			if i == 3 then
				setupBars(0) -- add OTHER spells
			end
		end)
	end

	--local maxLevel = UnitLevel("player") > 70

	local dungeons = {}
	for dungeonID = 1267, 1274 do
		if dungeonID ~= 1273 then
			AddNewDungeon(dungeons, dungeonID)
		end
	end
	AddNewDungeon(dungeons, 1210) -- 暗焰裂口
	--AddNewDungeon(dungeons, 71) -- 格瑞姆巴托
	--AddNewDungeon(dungeons, 1023) -- 围攻伯拉勒斯
	--AddNewDungeon(dungeons, 1182) -- 通灵战潮
	--AddNewDungeon(dungeons, 1184) -- 塞兹仙林的迷雾

	AddNewDungeon(dungeons, 1298) -- 水闸行动
	AddNewDungeon(dungeons, 1187) -- 伤逝剧场
	AddNewDungeon(dungeons, 1178) -- 麦卡贡行动
	AddNewDungeon(dungeons, 1012) -- 暴富矿区！！

	local raids = {
		[1] = EJ_GetInstanceInfo(1273), -- 尼鲁巴尔王宫
		[2] = EJ_GetInstanceInfo(1296), -- Liberation of Undermine
	}
	if DB.isNewPatch then
		AddNewDungeon(dungeons, 1303) -- 奥尔达尼生态圆顶
		AddNewDungeon(dungeons, 1185) -- 赎罪大厅
		AddNewDungeon(dungeons, 1194) -- 集市
		raids[3] = EJ_GetInstanceInfo(1302) -- 法力熔炉：欧米伽
	end

	options[1] = G:CreateDropdown(frame, DUNGEONS.."*", 120, -30, dungeons, L["Dungeons Intro"], 130, 30)
	options[1]:Hide()
	options[2] = G:CreateDropdown(frame, RAID.."*", 120, -30, raids, L["Raid Intro"], 130, 30)
	options[2]:Hide()

	options[3] = G:CreateEditbox(frame, "ID*", 10, -90, L["ID Intro"])
	options[4] = G:CreateEditbox(frame, L["Priority"], 120, -90, L["Priority Intro"])

	local function analyzePrio(priority)
		priority = priority or 2
		priority = math.min(priority, 6)
		priority = math.max(priority, 1)
		return priority
	end

	local function isAuraExisted(instName, spellID)
		local localPrio = C.RaidDebuffs[instName][spellID]
		local savedPrio = NDuiADB["RaidDebuffs"][instName] and NDuiADB["RaidDebuffs"][instName][spellID]
		if (localPrio and savedPrio and savedPrio == 0) or (not localPrio and not savedPrio) then
			return false
		end
		return true
	end

	local function addClick(options)
		local dungeonName, raidName, spellID, priority = options[1].Text:GetText(), options[2].Text:GetText(), tonumber(options[3]:GetText()), tonumber(options[4]:GetText())
		local instName = dungeonName or raidName or (iType.Text:GetText() == OTHER and 0)
		if not instName or not spellID then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
		if spellID and not C_Spell.GetSpellName(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if isAuraExisted(instName, spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		priority = analyzePrio(priority)
		if not NDuiADB["RaidDebuffs"][instName] then NDuiADB["RaidDebuffs"][instName] = {} end
		NDuiADB["RaidDebuffs"][instName][spellID] = priority
		setupBars(instName)
		G:ClearEdit(options[3])
		G:ClearEdit(options[4])
	end

	local scroll = G:CreateScroll(frame, 240, 350)
	scroll.reset = B.CreateButton(frame, 70, 25, RESET)
	scroll.reset:SetPoint("TOPLEFT", 10, -140)
	StaticPopupDialogs["RESET_NDUI_RAIDDEBUFFS"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			NDuiADB["RaidDebuffs"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_RAIDDEBUFFS")
	end)
	scroll.add = B.CreateButton(frame, 70, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -10, -140)
	scroll.add:SetScript("OnClick", function()
		addClick(options)
	end)
	scroll.clear = B.CreateButton(frame, 70, 25, KEY_NUMLOCK_MAC)
	scroll.clear:SetPoint("RIGHT", scroll.add, "LEFT", -10, 0)
	scroll.clear:SetScript("OnClick", function()
		clearEdit(options)
	end)

	local function iconOnEnter(self)
		local spellID = self:GetParent().spellID
		if not spellID then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:SetSpellByID(spellID)
		GameTooltip:Show()
	end

	local function createBar(index, texture)
		local bar = CreateFrame("Frame", nil, scroll.child, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		bar.index = index

		local icon, close = G:CreateBarWidgets(bar, texture)
		icon:SetScript("OnEnter", iconOnEnter)
		icon:SetScript("OnLeave", B.HideTooltip)
		bar.icon = icon

		close:SetScript("OnClick", function()
			bar:Hide()
			if C.RaidDebuffs[bar.instName][bar.spellID] then
				if not NDuiADB["RaidDebuffs"][bar.instName] then NDuiADB["RaidDebuffs"][bar.instName] = {} end
				NDuiADB["RaidDebuffs"][bar.instName][bar.spellID] = 0
			else
				NDuiADB["RaidDebuffs"][bar.instName][bar.spellID] = nil
			end
			setupBars(bar.instName)
		end)

		local spellName = B.CreateFS(bar, 14, "", false, "LEFT", 30, 0)
		spellName:SetWidth(120)
		bar.spellName = spellName

		local prioBox = B.CreateEditBox(bar, 30, 24)
		prioBox:SetPoint("RIGHT", close, "LEFT", -15, 0)
		prioBox:SetTextInsets(10, 0, 0, 0)
		prioBox:SetMaxLetters(1)
		prioBox:SetTextColor(0, 1, 0)
		prioBox:HookScript("OnEscapePressed", function(self)
			self:SetText(bar.priority)
		end)
		prioBox:HookScript("OnEnterPressed", function(self)
			local prio = analyzePrio(tonumber(self:GetText()))
			if not NDuiADB["RaidDebuffs"][bar.instName] then NDuiADB["RaidDebuffs"][bar.instName] = {} end
			NDuiADB["RaidDebuffs"][bar.instName][bar.spellID] = prio
			self:SetText(prio)
		end)
		B.AddTooltip(prioBox, "ANCHOR_TOPRIGHT", L["Prio Editbox"], "info", true)
		bar.prioBox = prioBox

		return bar
	end

	local function applyData(index, instName, spellID, priority)
		local name, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
		if not bars[index] then
			bars[index] = createBar(index, texture)
		end
		bars[index].instName = instName
		bars[index].spellID = spellID
		bars[index].priority = priority
		bars[index].spellName:SetText(name)
		bars[index].prioBox:SetText(priority)
		bars[index].icon.Icon:SetTexture(texture)
		bars[index]:Show()
	end

	function setupBars(self)
		local instName = tonumber(self) or self.text or self
		local index = 0

		if C.RaidDebuffs[instName] then
			for spellID, priority in pairs(C.RaidDebuffs[instName]) do
				if not (NDuiADB["RaidDebuffs"][instName] and NDuiADB["RaidDebuffs"][instName][spellID]) then
					index = index + 1
					applyData(index, instName, spellID, priority)
				end
			end
		end

		if NDuiADB["RaidDebuffs"][instName] then
			for spellID, priority in pairs(NDuiADB["RaidDebuffs"][instName]) do
				if priority > 0 then
					index = index + 1
					applyData(index, instName, spellID, priority)
				end
			end
		end

		for i = 1, #bars do
			if i > index then
				bars[i]:Hide()
			end
		end

		for i = 1, index do
			bars[i]:SetPoint("TOPLEFT", 10, -10 - 35*(i-1))
		end
	end

	for i = 1, 2 do
		for j = 1, #options[i].options do
			options[i].options[j]:HookScript("OnClick", setupBars)
		end
	end

	local function autoSelectInstance()
		local instName, instType = GetInstanceInfo()
		if instType == "none" then return end
		for i = 1, 2 do
			local option = options[i]
			for j = 1, #option.options do
				local name = option.options[j].text
				if instName == name then
					iType.options[i]:Click()
					options[i].options[j]:Click()
				end
			end
		end
	end
	autoSelectInstance()
	panel:HookScript("OnShow", autoSelectInstance)
end

function G:SetupClickCast(parent)
	local guiName = "NDuiGUI_ClickCast"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["Add ClickSets"], true)

	local keyToLocale = {
		["LMB"] = L["LeftButon"],
		["RMB"] = L["RightButton"],
		["MMB"] = L["MiddleButton"],
		["MB4"] = L["Button4"],
		["MB5"] = L["Button5"],
		["MWU"] = L["WheelUp"],
		["MWD"] = L["WheelDown"],
	}
	local textIndex, barTable = {
		["target"] = TARGET,
		["focus"] = SET_FOCUS,
		["follow"] = FOLLOW,
	}, {}

	local function createBar(parent, fullkey, value)
		local key = string.sub(fullkey, -3)
		local modKey = string.match(fullkey, "(.+)%-%w+")
		local texture
		if tonumber(value) then
			texture = C_Spell.GetSpellTexture(value)
		else
			value = textIndex[value] or value
			local itemID = string.match(value, "item:(%d+)")
			if itemID then
				texture = C_Item.GetItemIconByID(itemID)
			else
				texture = 136243
			end
		end

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[fullkey] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", value, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			NDuiADB["ClickSets"][DB.MyClass][fullkey] = nil
			barTable[fullkey] = nil
			sortBars(barTable)
		end)

		local key1 = B.CreateFS(bar, 14, keyToLocale[key], "info", "LEFT", 30, 0)
		if modKey then
			local key2 = B.CreateFS(bar, 14, modKey, "green", "RIGHT", -25, 0)
		end

		sortBars(barTable)
	end

	local frame = panel.bg
	local keyList = {"LMB", "RMB", "MMB", "MB4", "MB5", "MWU", "MWD"}
	local options = {}

	local function optionOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(keyToLocale[self.text], 1,1,0)
		GameTooltip:Show()
	end

	options[1] = G:CreateEditbox(frame, L["Action*"], 10, -30, L["Action Intro"], 260, 30)
	options[2] = G:CreateDropdown(frame, L["Key*"], 10, -90, keyList, L["Key Intro"], 85, 30)
	for i = 1, #keyList do
		options[2].options[i]:HookScript("OnEnter", optionOnEnter)
		options[2].options[i]:HookScript("OnLeave", B.HideTooltip)
	end
	options[3] = G:CreateDropdown(frame, L["Modified Key"], 105, -90, {NONE, "ALT", "CTRL", "SHIFT", "ALT-CTRL", "ALT-SHIFT", "CTRL-SHIFT", "ALT-CTRL-SHIFT"}, L["ModKey Intro"], 165, 30)

	local scroll = G:CreateScroll(frame, 240, 350)
	scroll.reset = B.CreateButton(frame, 70, 25, RESET)
	scroll.reset:SetPoint("TOPLEFT", 10, -140)
	StaticPopupDialogs["RESET_NDUI_CLICKSETS"] = {
		text = L["Reset your click sets?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			table.wipe(NDuiADB["ClickSets"][DB.MyClass])
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_CLICKSETS")
	end)

	local function addClick(scroll, options)
		local value, key, modKey = options[1]:GetText(), options[2].Text:GetText(), options[3].Text:GetText()
		local numValue = tonumber(value)
		if not value or not key then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incomplete Input"]) return end
		if numValue and not C_Spell.GetSpellName(value) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if (not numValue) and (not textIndex[value]) and not string.match(value, "/") then UIErrorsFrame:AddMessage(DB.InfoColor..L["Invalid Input"]) return end
		if not modKey or modKey == NONE then modKey = "" end
		local fullkey = (modKey == "" and key or modKey.."-"..key)
		if NDuiADB["ClickSets"][DB.MyClass][fullkey] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ClickSet"]) return end

		NDuiADB["ClickSets"][DB.MyClass][fullkey] = numValue or value
		createBar(scroll.child, fullkey, value)
		clearEdit(options)
	end

	scroll.add = B.CreateButton(frame, 70, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -10, -140)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll, options)
	end)

	scroll.clear = B.CreateButton(frame, 70, 25, KEY_NUMLOCK_MAC)
	scroll.clear:SetPoint("RIGHT", scroll.add, "LEFT", -10, 0)
	scroll.clear:SetScript("OnClick", function()
		clearEdit(options)
	end)

	for fullkey, value in pairs(NDuiADB["ClickSets"][DB.MyClass]) do
		createBar(scroll.child, fullkey, value)
	end
end

local function refreshNameplateFilters()
	B:GetModule("UnitFrames"):RefreshNameplateFilters()
end

function G:SetupNameplateFilter(parent)
	local guiName = "NDuiGUI_NameplateFilter"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName)
	panel:SetScript("OnHide", refreshNameplateFilters)

	local frameData = {
		[1] = {text = L["WhiteList"].."*", offset = -25, barList = {}},
		[2] = {text = L["BlackList"].."*", offset = -315, barList = {}},
	}

	local function createBar(parent, index, spellID)
		local name, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		frameData[index].barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			if index == 1 then
				if C.WhiteList[spellID] then
					NDuiADB["NameplateWhite"][spellID] = false
				else
					NDuiADB["NameplateWhite"][spellID] = nil
				end
			elseif index == 2 then
				if C.BlackList[spellID] then
					NDuiADB["NameplateBlack"][spellID] = false
				else
					NDuiADB["NameplateBlack"][spellID] = nil
				end
			end
			frameData[index].barList[spellID] = nil
			sortBars(frameData[index].barList)
		end)

		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		if index == 2 then spellName:SetTextColor(1, 0, 0) end

		sortBars(frameData[index].barList)
	end

	local function isAuraExisted(index, spellID)
		local key = index == 1 and "NameplateWhite" or "NameplateBlack"
		local modValue = NDuiADB[key][spellID]
		local locValue = (index == 1 and C.WhiteList[spellID]) or (index == 2 and C.BlackList[spellID])
		return modValue or (modValue == nil and locValue)
	end

	local function addClick(parent, index)
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not C_Spell.GetSpellName(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if isAuraExisted(index, spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		local key = index == 1 and "NameplateWhite" or "NameplateBlack"
		NDuiADB[key][spellID] = true
		createBar(parent.child, index, spellID)
		parent.box:SetText("")
	end

	local UF = B:GetModule("UnitFrames")

	local filterIndex
	StaticPopupDialogs["RESET_NDUI_NAMEPLATEFILTER"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			local key = filterIndex == 1 and "NameplateWhite" or "NameplateBlack"
			table.wipe(NDuiADB[key])
			ReloadUI()
		end,
		whileDead = 1,
	}

	for index, value in ipairs(frameData) do
		B.CreateFS(panel, 14, value.text, "system", "TOPLEFT", 20, value.offset)
		local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
		frame:SetSize(280, 250)
		frame:SetPoint("TOPLEFT", 10, value.offset - 25)
		B.CreateBD(frame, .25)

		local scroll = G:CreateScroll(frame, 240, 200)
		scroll.box = B.CreateEditBox(frame, 160, 25)
		scroll.box:SetPoint("TOPLEFT", 10, -10)
		B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

		scroll.add = B.CreateButton(frame, 45, 25, ADD)
		scroll.add:SetPoint("TOPRIGHT", -8, -10)
		scroll.add:SetScript("OnClick", function()
			addClick(scroll, index)
		end)

		scroll.reset = B.CreateButton(frame, 45, 25, RESET)
		scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
		scroll.reset:SetScript("OnClick", function()
			filterIndex = index
			StaticPopup_Show("RESET_NDUI_NAMEPLATEFILTER")
		end)

		local key = index == 1 and "NameplateWhite" or "NameplateBlack"
		for spellID, value in pairs(UF[key]) do
			if value then
				createBar(scroll.child, index, spellID)
			end
		end
	end
end

local function updateCornerSpells()
	B:GetModule("UnitFrames"):UpdateCornerSpells()
end

function G:SetupSpellsIndicator(parent)
	local guiName = "NDuiGUI_SpellsIndicator"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["BuffIndicator"].."*")
	panel:SetScript("OnHide", updateCornerSpells)

	local barList = {}

	local decodeAnchor = {
		["TL"] = "TOPLEFT",
		["T"] = "TOP",
		["TR"] = "TOPRIGHT",
		["L"] = "LEFT",
		["R"] = "RIGHT",
		["BL"] = "BOTTOMLEFT",
		["B"] = "BOTTOM",
		["BR"] = "BOTTOMRIGHT",
	}
	local anchors = {"TL", "T", "TR", "L", "R", "BL", "B", "BR"}

	local function createBar(parent, spellID, anchor, r, g, b, showAll)
		local name, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			local value = C.CornerBuffs[DB.MyClass][spellID]
			if value then
				NDuiADB["CornerSpells"][DB.MyClass][spellID] = {}
			else
				NDuiADB["CornerSpells"][DB.MyClass][spellID] = nil
			end
			barList[spellID] = nil
			sortBars(barList)
		end)

		name = L[anchor] or name
		local text = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		text:SetWidth(180)
		if anchor then text:SetTextColor(r, g, b) end
		if showAll then B.CreateFS(bar, 14, "ALL", false, "RIGHT", -30, 0) end

		sortBars(barList)
	end

	local function addClick(parent)
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not C_Spell.GetSpellName(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		local anchor, r, g, b, showAll
		anchor, r, g, b = parent.dd.Text:GetText(), parent.swatch.tex:GetColor()
		showAll = parent.showAll:GetChecked() or nil
		local modValue = NDuiADB["CornerSpells"][DB.MyClass][spellID]
		if (modValue and next(modValue)) or (C.CornerBuffs[DB.MyClass][spellID] and not modValue) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
		anchor = decodeAnchor[anchor]
		NDuiADB["CornerSpells"][DB.MyClass][spellID] = {anchor, {r, g, b}, showAll}
		createBar(parent.child, spellID, anchor, r, g, b, showAll)
		parent.box:SetText("")
	end

	StaticPopupDialogs["RESET_NDUI_RaidBuffsWhite"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			table.wipe(NDuiADB["CornerSpells"][DB.MyClass])
			ReloadUI()
		end,
		whileDead = 1,
	}

	local function optionOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L[decodeAnchor[self.text]], 1,1,1)
		GameTooltip:Show()
	end

	local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	frame:SetSize(280, 540)
	frame:SetPoint("TOPLEFT", 10, -50)
	B.CreateBD(frame, .25)

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = B.CreateEditBox(frame, 50, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	scroll.box:SetMaxLetters(8) -- might have 8 digits for spellID
	B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	scroll.add = B.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll)
	end)

	scroll.reset = B.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_RaidBuffsWhite")
	end)

	scroll.dd = B.CreateDropDown(frame, 60, 25, anchors)
	scroll.dd:SetPoint("TOPLEFT", 10, -10)
	scroll.dd.options[1]:Click()

	for i = 1, 8 do
		scroll.dd.options[i]:HookScript("OnEnter", optionOnEnter)
		scroll.dd.options[i]:HookScript("OnLeave", B.HideTooltip)
	end
	scroll.box:SetPoint("TOPLEFT", scroll.dd, "TOPRIGHT", 5, 0)

	local swatch = B.CreateColorSwatch(frame)
	swatch:SetPoint("LEFT", scroll.box, "RIGHT", 5, 0)
	scroll.swatch = swatch

	local showAll = B.CreateCheckBox(frame, true)
	showAll:SetPoint("LEFT", swatch, "RIGHT", 2, 0)
	B.AddTooltip(showAll, "ANCHOR_TOPRIGHT", L["ShowAllTip"], "info", true)
	scroll.showAll = showAll

	local UF = B:GetModule("UnitFrames")
	for spellID, value in pairs(UF.CornerSpells) do
		local r, g, b = unpack(value[2])
		createBar(scroll.child, spellID, value[1], r, g, b, value[3])
	end
end

local function refreshBuffsIndicator()
	B:GetModule("UnitFrames"):UpdateRaidBuffsWhite()
end

function G:SetupBuffsIndicator(parent)
	local guiName = "NDuiGUI_BuffsIndicator"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["WhiteList"].."*")
	panel:SetScript("OnHide", refreshBuffsIndicator)

	local barList = {}

	local function createBar(parent, spellID, isNew)
		local name, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			if C.RaidBuffsWhite[spellID] then
				NDuiADB["RaidBuffsWhite"][spellID] = false
			else
				NDuiADB["RaidBuffsWhite"][spellID] = nil
			end
			barList[spellID] = nil
			sortBars(barList)
		end)

		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		if isNew then spellName:SetTextColor(0, 1, 0) end

		sortBars(barList)
	end

	local function isAuraExisted(spellID)
		local modValue = NDuiADB["RaidBuffsWhite"][spellID]
		local locValue = C.RaidBuffsWhite[spellID]
		return modValue or (modValue == nil and locValue)
	end

	local function addClick(parent)
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not C_Spell.GetSpellName(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if isAuraExisted(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		NDuiADB["RaidBuffsWhite"][spellID] = true
		createBar(parent.child, spellID, true)
		parent.box:SetText("")
	end

	StaticPopupDialogs["RESET_NDUI_BUFFS_WHITE"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			table.wipe(NDuiADB["RaidBuffsWhite"])
			ReloadUI()
		end,
		whileDead = 1,
	}

	local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	frame:SetSize(280, 540)
	frame:SetPoint("TOPLEFT", 10, -50)
	B.CreateBD(frame, .25)

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = B.CreateEditBox(frame, 160, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	scroll.add = B.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll)
	end)

	scroll.reset = B.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_BUFFS_WHITE")
	end)

	local UF = B:GetModule("UnitFrames")
	for spellID, value in pairs(UF.RaidBuffsWhite) do
		if value then
			createBar(scroll.child, spellID)
		end
	end

	local box = B.CreateCheckBox(frame)
	box:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 5)
	box:SetChecked(C.db["UFs"]["AutoBuffs"])
	box:SetScript("OnClick", function()
		C.db["UFs"]["AutoBuffs"] = box:GetChecked()
	end)
	local text = B.CreateFS(box, 24, "|cffFF0000???")
	text:ClearAllPoints()
	text:SetPoint("RIGHT", box, "LEFT")
	B.AddTooltip(box, "ANCHOR_TOPRIGHT", L["AutoBuffsTip"], "info", true)
end

local function refreshDebuffsIndicator()
	B:GetModule("UnitFrames"):UpdateRaidDebuffsBlack()
end

function G:SetupDebuffsIndicator(parent)
	local guiName = "NDuiGUI_DebuffsIndicator"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["BlackList"].."*")
	panel:SetScript("OnHide", refreshDebuffsIndicator)

	local barList = {}

	local function createBar(parent, spellID, isNew)
		local name, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barList[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID)
		close:SetScript("OnClick", function()
			bar:Hide()
			if C.RaidDebuffsBlack[spellID] then
				NDuiADB["RaidDebuffsBlack"][spellID] = false
			else
				NDuiADB["RaidDebuffsBlack"][spellID] = nil
			end
			barList[spellID] = nil
			sortBars(barList)
		end)

		local spellName = B.CreateFS(bar, 14, name, false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		if isNew then spellName:SetTextColor(0, 1, 0) end

		sortBars(barList)
	end

	local function isAuraExisted(spellID)
		local modValue = NDuiADB["RaidDebuffsBlack"][spellID]
		local locValue = C.RaidDebuffsBlack[spellID]
		return modValue or (modValue == nil and locValue)
	end

	local function addClick(parent)
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not C_Spell.GetSpellName(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if isAuraExisted(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end

		NDuiADB["RaidDebuffsBlack"][spellID] = true
		createBar(parent.child, spellID, true)
		parent.box:SetText("")
	end

	StaticPopupDialogs["RESET_NDUI_DEBUFFS_BLACK"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			table.wipe(NDuiADB["RaidDebuffsBlack"])
			ReloadUI()
		end,
		whileDead = 1,
	}

	local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	frame:SetSize(280, 540)
	frame:SetPoint("TOPLEFT", 10, -50)
	B.CreateBD(frame, .25)

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = B.CreateEditBox(frame, 160, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	scroll.add = B.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add:SetScript("OnClick", function()
		addClick(scroll)
	end)

	scroll.reset = B.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_DEBUFFS_BLACK")
	end)

	local UF = B:GetModule("UnitFrames")
	for spellID, value in pairs(UF.RaidDebuffsBlack) do
		if value then
			createBar(scroll.child, spellID)
		end
	end
end

local function createOptionTitle(parent, title, offset)
	B.CreateFS(parent, 14, title, "system", "TOP", 0, offset)
	local line = B.SetGradient(parent, "H", 1, 1, 1, DB.alpha, DB.alpha, 200, C.mult)
	line:SetPoint("TOPLEFT", 30, offset-20)
end

local function toggleOptionCheck(self)
	C.db[self.__key][self.__value] = self:GetChecked()
	if self.__callback then self:__callback() end
end

local function createOptionCheck(parent, offset, text, key, value, callback, tooltip)
	local box = B.CreateCheckBox(parent)
	box:SetPoint("TOPLEFT", 10, offset)
	box:SetChecked(C.db[key][value])
	box.__key = key
	box.__value = value
	box.__callback = callback
	B.CreateFS(box, 14, text, nil, "LEFT", 30, 0)
	box:SetScript("OnClick", toggleOptionCheck)
	if tooltip then
		B.AddTooltip(box, "ANCHOR_RIGHT", tooltip, "info", true)
	end

	return box
end

local function sliderValueChanged(self, v)
	local current = tonumber(format("%.0f", v))
	self.value:SetText(current)
	C.db[self.__key][self.__value] = current
	if self.__update then self.__update() end
end

local function createOptionSlider(parent, title, minV, maxV, defaultV, yOffset, value, func, key)
	local slider = B.CreateSlider(parent, title, minV, maxV, 1, 30, yOffset)
	if not key then key = "UFs" end
	slider:SetValue(C.db[key][value])
	slider.value:SetText(C.db[key][value])
	slider.__key = key
	slider.__value = value
	slider.__update = func
	slider.__default = defaultV
	slider:SetScript("OnValueChanged", sliderValueChanged)
end

local function updateDropdownHighlight(self)
	local dd = self.__owner
	for i = 1, #dd.__options do
		local option = dd.options[i]
		if i == C.db[dd.__key][dd.__value] then
			option:SetBackdropColor(1, 1, 0, .25)
			option.selected = true
		else
			option:SetBackdropColor(0, 0, 0, .25)
			option.selected = false
		end
	end
end

local function updateDropdownState(self)
	local dd = self.__owner
	C.db[dd.__key][dd.__value] = self.index
	if dd.__func then dd.__func() end
end

local function createOptionDropdown(parent, title, yOffset, options, tooltip, key, value, default, func)
	local dd = G:CreateDropdown(parent, title, 40, yOffset, options, nil, 180, 28)
	dd.__key = key
	dd.__value = value
	dd.__default = default
	dd.__options = options
	dd.__func = func
	dd.Text:SetText(options[C.db[key][value]])

	if tooltip then
		B.AddTooltip(dd, "ANCHOR_TOP", tooltip, "info", true)
	end

	dd.button.__owner = dd
	dd.button:HookScript("OnClick", updateDropdownHighlight)

	for i = 1, #options do
		dd.options[i]:HookScript("OnClick", updateDropdownState)
	end
end

local function SetUnitFrameSize(self, unit)
	local width = C.db["UFs"][unit.."Width"]
	local healthHeight = C.db["UFs"][unit.."Height"]
	local powerHeight = C.db["UFs"][unit.."PowerHeight"]
	local height = healthHeight + powerHeight + C.mult
	self:SetSize(width, height)
	self.Health:SetHeight(healthHeight)
	if powerHeight == 0 then
		if self:IsElementEnabled("Power") then
			self:DisableElement("Power")
			if self.powerText then self.powerText:Hide() end
		end
	else
		if not self:IsElementEnabled("Power") then
			self:EnableElement("Power")
			self.Power:ForceUpdate()
			if self.powerText then self.powerText:Show() end
		end
		self.Power:SetHeight(powerHeight)
	end
end

function G:SetupUnitFrame(parent)
	local guiName = "NDuiGUI_UnitFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["UnitFrame Size"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local sliderRange = {
		["Player"] = {100, 500},
		["Focus"] = {100, 500},
		["Pet"] = {100, 500},
		["Boss"] = {100, 500},
	}

	local defaultData = { -- healthWidth, healthHeight, powerHeight, healthTag, powerTag
		["Player"] = {250, 30, 6, 2, 4},
		["Focus"] = {200, 24, 4, 2, 4},
		["Pet"] = {160, 20, 2, 4, 0},
		["Boss"] = {160, 24, 4, 5, 5},
	}

	local function createOptionGroup(parent, offset, value, func)
		createOptionTitle(parent, "", offset)
		createOptionDropdown(parent, L["HealthValueType"], offset-50, G.HealthValues, L["100PercentTip"], "UFs", value.."HPTag", defaultData[value][4], func)
		local mult = 0
		if value ~= "Pet" then
			mult = 60
			createOptionDropdown(parent, L["PowerValueType"], offset-50-mult, G.HealthValues, L["100PercentTip"], "UFs", value.."MPTag", defaultData[value][5], func)
		end
		createOptionSlider(parent, L["Width"], sliderRange[value][1], sliderRange[value][2], defaultData[value][1], offset-110-mult, value.."Width", func)
		createOptionSlider(parent, L["Height"], 15, 100, defaultData[value][2], offset-180-mult, value.."Height", func)
		createOptionSlider(parent, L["Power Height"], 0, 50, defaultData[value][3], offset-250-mult, value.."PowerHeight", func)
	end

	local UF = B:GetModule("UnitFrames")
	local mainFrames = {_G.oUF_Player, _G.oUF_Target}
	local function updatePlayerSize()
		for _, frame in pairs(mainFrames) do
			SetUnitFrameSize(frame, "Player")
			UF.UpdateFrameHealthTag(frame)
			UF.UpdateFramePowerTag(frame)
		end
		UF:UpdateUFAuras()
		UF:UpdateUFClassPower()
	end

	local function updateFocusSize()
		local frame = _G.oUF_Focus
		if frame then
			SetUnitFrameSize(frame, "Focus")
			UF.UpdateFrameHealthTag(frame)
			UF.UpdateFramePowerTag(frame)
		end
	end

	local subFrames = {_G.oUF_Pet, _G.oUF_ToT, _G.oUF_FoT}
	local function updatePetSize()
		for _, frame in pairs(subFrames) do
			SetUnitFrameSize(frame, "Pet")
			UF.UpdateFrameHealthTag(frame)
		end
	end

	local function updateBossSize()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.mystyle == "boss" or frame.mystyle == "arena" then
				SetUnitFrameSize(frame, "Boss")
				UF.UpdateFrameHealthTag(frame)
				UF.UpdateFramePowerTag(frame)
			end
		end
	end

	local options = {
		[1] = L["Player&Target"],
		[2] = L["FocusUF"],
		[3] = L["Pet&*Target"],
		[4] = L["Boss&Arena"],
	}
	local data = {
		[1] = {"Player", updatePlayerSize},
		[2] = {"Focus", updateFocusSize},
		[3] = {"Pet", updatePetSize},
		[4] = {"Boss", updateBossSize},
	}

	local dd = G:CreateDropdown(scroll.child, "", 40, -15, options, nil, 180, 28, true)
	dd.Text:SetText(options[1])
	dd.panels = {}

	for i = 1, #options do
		local panel = CreateFrame("Frame", nil, scroll.child)
		panel:SetSize(260, 1)
		panel:SetPoint("TOP", 0, -30)
		panel:Hide()
		createOptionGroup(panel, -10, data[i][1], data[i][2])

		dd.panels[i] = panel
		dd.options[i]:HookScript("OnClick", toggleOptionsPanel)
	end
	toggleOptionsPanel(dd.options[1])
end

function G:SetupRaidFrame(parent)
	local guiName = "NDuiGUI_RaidFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["RaidFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local UF = B:GetModule("UnitFrames")

	local defaultData = {80, 32, 2, 8, 1, 5}
	local options = {}
	for i = 1, 8 do
		options[i] = UF.RaidDirections[i].name
	end

	local function updateRaidDirection()
		if UF.CreateAndUpdateRaidHeader then
			UF:CreateAndUpdateRaidHeader(true)
			UF:UpdateRaidTeamIndex()
		end
	end

	local function resizeRaidFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.mystyle == "raid" and not frame.raidType then
				SetUnitFrameSize(frame, "Raid")
				UF.UpdateRaidTextAnchor(frame)
			end
		end
		if UF.CreateAndUpdateRaidHeader then
			UF:CreateAndUpdateRaidHeader()
		end
	end

	local function updateNumGroups()
		if UF.CreateAndUpdateRaidHeader then
			UF:CreateAndUpdateRaidHeader()
			UF:UpdateRaidTeamIndex()
			UF:UpdateAllHeaders()
		end
	end

	createOptionDropdown(scroll.child, L["GrowthDirection"], -30, options, L["RaidDirectionTip"], "UFs", "RaidDirec", 1, updateRaidDirection)
	createOptionSlider(scroll.child, L["Width"], 60, 200, defaultData[1], -100, "RaidWidth", resizeRaidFrame)
	createOptionSlider(scroll.child, L["Height"], 25, 60, defaultData[2], -180, "RaidHeight", resizeRaidFrame)
	createOptionSlider(scroll.child, L["Power Height"], 0, 30, defaultData[3], -260, "RaidPowerHeight", resizeRaidFrame)
	createOptionSlider(scroll.child, L["Num Groups"], 2, 8, defaultData[4], -340, "NumGroups", updateNumGroups)
	createOptionSlider(scroll.child, L["RaidRows"], 1, 8, defaultData[5], -420, "RaidRows", updateNumGroups)
	createOptionSlider(scroll.child, L["Spacing"], 0, 10, defaultData[6], -500, "RaidSpacing", updateNumGroups)
end

function G:SetupSimpleRaidFrame(parent)
	local guiName = "NDuiGUI_SimpleRaidFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["SimpleRaidFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local UF = B:GetModule("UnitFrames")

	local options = {}
	for i = 1, 4 do
		options[i] = UF.RaidDirections[i].name
	end
	local function updateSimpleModeGroupBy()
		if UF.UpdateSimpleModeHeader then
			UF:UpdateSimpleModeHeader()
		end
	end
	createOptionDropdown(scroll.child, L["GrowthDirection"], -30, options, L["SMRDirectionTip"], "UFs", "SMRDirec", 1) -- needs review, cannot live toggle atm due to blizz error
	createOptionDropdown(scroll.child, L["SimpleMode GroupBy"], -90, {GROUP, CLASS, ROLE}, nil, "UFs", "SMRGroupBy", 1, updateSimpleModeGroupBy)
	createOptionSlider(scroll.child, L["UnitsPerColumn"], 5, 40, 20, -160, "SMRPerCol", updateSimpleModeGroupBy)
	createOptionSlider(scroll.child, L["Num Groups"], 1, 8, 6, -240, "SMRGroups", updateSimpleModeGroupBy)

	local function resizeSimpleRaidFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.raidType == "simple" then
				local scale = C.db["UFs"]["SMRScale"]/10
				local frameWidth = 100*scale
				local frameHeight = 20*scale
				local powerHeight = 2*scale
				local healthHeight = frameHeight - powerHeight
				frame:SetSize(frameWidth, frameHeight)
				frame.Health:SetHeight(healthHeight)
				frame.Power:SetHeight(powerHeight)
				UF.UpdateRaidTextAnchor(frame)
			end
		end

		updateSimpleModeGroupBy()
	end
	createOptionSlider(scroll.child, L["SimpleMode Scale"], 8, 15, 10, -320, "SMRScale", resizeSimpleRaidFrame)
end

function G:SetupPartyFrame(parent)
	local guiName = "NDuiGUI_PartyFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["PartyFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local UF = B:GetModule("UnitFrames")

	local function resizePartyFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.raidType == "party" then
				SetUnitFrameSize(frame, "Party")
				UF.UpdateRaidTextAnchor(frame)
			end
		end
		if UF.CreateAndUpdatePartyHeader then
			UF:CreateAndUpdatePartyHeader()
		end
		UF:UpdatePartyElements()
	end

	local defaultData = {100, 32, 2, 5}
	local options = {}
	for i = 1, 4 do
		options[i] = UF.PartyDirections[i].name
	end
	createOptionCheck(scroll.child, -10, L["UFs PartyAltPower"], "UFs", "PartyAltPower", resizePartyFrame, L["PartyAltPowerTip"])
	createOptionCheck(scroll.child, -40, L["SortByRole"], "UFs", "SortByRole", resizePartyFrame, L["SortByRoleTip"])
	createOptionCheck(scroll.child, -70, L["SortAscending"], "UFs", "SortAscending", resizePartyFrame, L["SortAscendingTip"])
	createOptionDropdown(scroll.child, L["GrowthDirection"], -130, options, nil, "UFs", "PartyDirec", 1, resizePartyFrame)
	createOptionSlider(scroll.child, L["Width"], 80, 200, defaultData[1], -210, "PartyWidth", resizePartyFrame)
	createOptionSlider(scroll.child, L["Height"], 25, 60, defaultData[2], -290, "PartyHeight", resizePartyFrame)
	createOptionSlider(scroll.child, L["Power Height"], 0, 30, defaultData[3], -370, "PartyPowerHeight", resizePartyFrame)
	createOptionSlider(scroll.child, L["Spacing"], 0, 10, defaultData[4], -450, "PartySpacing", resizePartyFrame)
end

function G:SetupPartyPetFrame(parent)
	local guiName = "NDuiGUI_PartyPetFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["PartyPetFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local UF = B:GetModule("UnitFrames")

	local function updatePartyPetHeader()
		if UF.UpdatePartyPetHeader then
			UF:UpdatePartyPetHeader()
		end
	end

	local function resizePartyPetFrame()
		for _, frame in pairs(ns.oUF.objects) do
			if frame.raidType == "pet" then
				SetUnitFrameSize(frame, "PartyPet")
				UF.UpdateRaidTextAnchor(frame)
			end
		end

		updatePartyPetHeader()
	end

	local options = {}
	for i = 1, 8 do
		options[i] = UF.RaidDirections[i].name
	end

	createOptionDropdown(scroll.child, L["GrowthDirection"], -30, options, nil, "UFs", "PetDirec", 1, updatePartyPetHeader)
	createOptionDropdown(scroll.child, L["Visibility"], -90, {L["ShowInParty"], L["ShowInRaid"], L["ShowInGroup"]}, nil, "UFs", "PartyPetVsby", 1, UF.UpdateAllHeaders)
	createOptionSlider(scroll.child, L["Width"], 60, 200, 100, -150, "PartyPetWidth", resizePartyPetFrame)
	createOptionSlider(scroll.child, L["Height"], 20, 60, 22, -220, "PartyPetHeight", resizePartyPetFrame)
	createOptionSlider(scroll.child, L["Power Height"], 0, 30, 2, -290, "PartyPetPowerHeight", resizePartyPetFrame)
	createOptionSlider(scroll.child, L["UnitsPerColumn"], 5, 40, 5, -360, "PartyPetPerCol", updatePartyPetHeader)
	createOptionSlider(scroll.child, L["MaxColumns"], 1, 5, 1, -430, "PartyPetMaxCol", updatePartyPetHeader)
end

local function createOptionSwatch(parent, name, key, value, x, y)
	local swatch = B.CreateColorSwatch(parent, name, C.db[key][value])
	swatch:SetPoint("TOPLEFT", x, y)
	swatch.__default = G.DefaultSettings[key][value]
end

function G:SetupCastbar(parent)
	local guiName = "NDuiGUI_CastbarSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["Castbar Settings"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	createOptionTitle(scroll.child, L["Castbar Colors"], -10)
	createOptionSwatch(scroll.child, L["Interruptible Color"], "UFs", "CastingColor", 40, -40)
	createOptionSwatch(scroll.child, L["NotInterruptible Color"], "UFs", "NotInterruptColor", 40, -70)

	local defaultData = {
		["Player"] = {280, 20},
		["Target"] = {300, 20},
		["Focus"] = {320, 20},
	}

	local UF = B:GetModule("UnitFrames")

	local function toggleCastbar(self)
		local value = self.__value.."CB"
		C.db["UFs"][value] = not C.db["UFs"][value]
		self:SetChecked(C.db["UFs"][value])
		UF.ToggleCastBar(_G["oUF_"..self.__value], self.__value)
	end

	local function createOptionGroup(parent, title, offset, value, func)
		local box = B.CreateCheckBox(parent, true)
		box:SetPoint("TOPLEFT", parent, 30, offset + 6)
		box:SetChecked(C.db["UFs"][value.."CB"])
		box.__value = value
		box:SetScript("OnClick", toggleCastbar)
		B.AddTooltip(box, "ANCHOR_RIGHT", L["ToggleCastbarTip"], "info", true)

		createOptionTitle(parent, title, offset)
		createOptionSlider(parent, L["Width"], 100, 800, defaultData[value][1], offset-60, value.."CBWidth", func)
		createOptionSlider(parent, L["Height"], 10, 50, defaultData[value][2], offset-130, value.."CBHeight", func)
	end

	local function updatePlayerCastbar()
		local castbar = _G.oUF_Player and _G.oUF_Player.Castbar
		if castbar then
			local width, height = C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"]
			castbar:SetSize(width, height)
			castbar.Icon:SetSize(height, height)
			castbar.mover:Show()
			castbar.mover:SetSize(width+height+5, height+5)
		end
	end
	createOptionGroup(scroll.child, L["Player Castbar"], -120, "Player", updatePlayerCastbar)

	local function updateTargetCastbar()
		local castbar = _G.oUF_Target and _G.oUF_Target.Castbar
		if castbar then
			local width, height = C.db["UFs"]["TargetCBWidth"], C.db["UFs"]["TargetCBHeight"]
			castbar:SetSize(width, height)
			castbar.Icon:SetSize(height, height)
			castbar.mover:Show()
			castbar.mover:SetSize(width+height+5, height+5)
		end
	end
	createOptionGroup(scroll.child, L["Target Castbar"], -320, "Target", updateTargetCastbar)

	local function updateFocusCastbar()
		local castbar = _G.oUF_Focus and _G.oUF_Focus.Castbar
		if castbar then
			local width, height = C.db["UFs"]["FocusCBWidth"], C.db["UFs"]["FocusCBHeight"]
			castbar:SetSize(width, height)
			castbar.Icon:SetSize(height, height)
			castbar.mover:Show()
			castbar.mover:SetSize(width+height+5, height+5)
		end
	end
	createOptionGroup(scroll.child, L["Focus Castbar"], -520, "Focus", updateFocusCastbar)

	panel:HookScript("OnHide", function()
		local playerCB = _G.oUF_Player and _G.oUF_Player.Castbar
		if playerCB then
			playerCB.mover:Hide()
		end
		local targetCB = _G.oUF_Target and _G.oUF_Target.Castbar
		if targetCB then
			targetCB.mover:Hide()
		end
		local focusCB = _G.oUF_Focus and _G.oUF_Focus.Castbar
		if focusCB then
			focusCB.mover:Hide()
		end
	end)
end

function G:SetupSwingBars(parent)
	local guiName = "NDuiGUI_SwingSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["UFs SwingBar"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local parent, offset = scroll.child, -10
	local frame = _G.oUF_Player

	local function configureSwingBars()
		if not frame then return end

		local width, height = C.db["UFs"]["SwingWidth"], C.db["UFs"]["SwingHeight"]
		local swing = frame.Swing
		swing:SetSize(width, height)
		swing.Offhand:SetHeight(height)
		swing.mover:SetSize(width, height)
		swing.mover:Show()

		swing.Text:SetShown(C.db["UFs"]["SwingTimer"])
		swing.TextMH:SetShown(C.db["UFs"]["SwingTimer"])
		swing.TextOH:SetShown(C.db["UFs"]["SwingTimer"])

		swing.Offhand:ClearAllPoints()
		if C.db["UFs"]["OffOnTop"] then
			swing.Offhand:SetPoint("BOTTOMLEFT", swing, "TOPLEFT", 0, 3)
			swing.Offhand:SetPoint("BOTTOMRIGHT", swing, "TOPRIGHT", 0, 3)
		else
			swing.Offhand:SetPoint("TOPLEFT", swing, "BOTTOMLEFT", 0, -3)
			swing.Offhand:SetPoint("TOPRIGHT", swing, "BOTTOMRIGHT", 0, -3)
		end
	end

	createOptionCheck(parent, offset, L["UFs SwingTimer"], "UFs", "SwingTimer", configureSwingBars, L["SwingTimer Tip"])
	createOptionCheck(parent, offset-35, L["OffhandOnTop"], "UFs", "OffOnTop", configureSwingBars)
	createOptionSlider(parent, L["Width"], 50, 1000, 275, offset-105, "SwingWidth", configureSwingBars)
	createOptionSlider(parent, L["Height"], 1, 50, 3, offset-175, "SwingHeight", configureSwingBars)

	panel:HookScript("OnHide", function()
		local mover = frame and frame.Swing and frame.Swing.mover
		if mover then mover:Hide() end
	end)
end

function G:SetupBagFilter(parent)
	local guiName = "NDuiGUI_BagFilterSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["BagFilterSetup"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local filterOptions = {
		[1] = "FilterJunk",
		[2] = "FilterConsumable",
		[3] = "FilterEquipment",
		[4] = "FilterLegendary",
		[5] = "FilterCollection",
		[6] = "FilterFavourite",
		[7] = "FilterEquipSet",
		[8] = "FilterFeature",
		[9] = "FilterAuE",
		[10] = "FilterBoN",
	}

	local BAG = B:GetModule("Bags")
	local function updateAllBags()
		BAG:UpdateAllBags()
	end

	local offset = 10
	for _, value in ipairs(filterOptions) do
		createOptionCheck(scroll, -offset, L[value], "Bags", value, updateAllBags)
		offset = offset + 35
	end
end

local function refreshMajorSpells()
	B:GetModule("UnitFrames"):RefreshMajorSpells()
end

function G:PlateCastbarGlow(parent)
	local guiName = "NDuiGUI_PlateCastbarGlow"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["PlateCastbarGlow"].."*", true)
	panel:SetScript("OnHide", refreshMajorSpells)

	local barTable = {}

	local function createBar(parent, spellID)
		local spellName, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[spellID] = nil
			if C.MajorSpells[spellID] then
				NDuiADB["MajorSpells"][spellID] = false
			else
				NDuiADB["MajorSpells"][spellID] = nil
			end
			sortBars(barTable)
		end)

		local name = B.CreateFS(bar, 14, spellName, false, "LEFT", 30, 0)
		name:SetWidth(120)

		sortBars(barTable)
	end

	local frame = panel.bg
	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = B.CreateEditBox(frame, 160, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	local function addClick(button)
		local parent = button.__owner
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not C_Spell.GetSpellName(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		local modValue = NDuiADB["MajorSpells"][spellID]
		if modValue or modValue == nil and C.MajorSpells[spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
		NDuiADB["MajorSpells"][spellID] = true
		createBar(parent.child, spellID)
		parent.box:SetText("")
	end
	scroll.add = B.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = B.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_NDUI_MAJORSPELLS"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			NDuiADB["MajorSpells"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_MAJORSPELLS")
	end)

	local UF = B:GetModule("UnitFrames")
	for spellID, value in pairs(UF.MajorSpells) do
		if value then
			createBar(scroll.child, spellID)
		end
	end
end

function G:SetupNameplateSize(parent)
	local guiName = "NDuiGUI_PlateSizeSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["NameplateSize"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local UF = B:GetModule("UnitFrames")

	createOptionSlider(scroll.child, L["Width"], 50, 500, 200, -30, "PlateWidth", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["Height"], 5, 50, 10, -100, "PlateHeight", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["InteractWidth"], 50, 500, 200, -170, "InteractWidth", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["InteractHeight"], 5, 50, 50, -240, "InteractHeight", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["NameTextSize"], 10, 50, 14, -310, "NameTextSize", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["HealthTextSize"], 10, 50, 16, -380, "HealthTextSize", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["CastbarTextSize"], 10, 50, 16, -450, "CastBarTextSize", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["Plate Margin"], 0, 10, 5, -520, "PlateMargin", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["RaidTargetX"], -200, 200, 0, -590, "RaidTargetX", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(scroll.child, L["RaidTargetY"], -200, 200, 0, -660, "RaidTargetY", UF.RefreshAllPlates, "Nameplate")
end

function G:SetupNameOnlySize(parent)
	local guiName = "NDuiGUI_NameOnlySetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["NameOnlyMode"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)
	local parent, offset = scroll.child, -10

	local UF = B:GetModule("UnitFrames")
	createOptionCheck(parent, offset, L["ShowNPCTitle"], "Nameplate", "NameOnlyTitle", UF.RefreshAllPlates)
	createOptionCheck(parent, offset-35, L["ShowUnitGuild"], "Nameplate", "NameOnlyGuild", UF.RefreshAllPlates)
	createOptionSlider(parent, L["NameTextSize"], 10, 50, 14, offset-105, "NameOnlyTextSize", UF.RefreshAllPlates, "Nameplate")
	createOptionSlider(parent, L["TitleTextSize"], 10, 50, 12, offset-175, "NameOnlyTitleSize", UF.RefreshAllPlates, "Nameplate")
end

function G:SetupActionBar(parent)
	local guiName = "NDuiGUI_ActionBarSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ActionbarSetup"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local Bar = B:GetModule("Actionbar")
	local defaultData = {
		-- defaultSize, minButtons, maxButtons, defaultButtons, defaultPerRow, flyoutDirec
		["Bar1"] = {34, 1, 12, 12, 12, "UP"},
		["Bar2"] = {34, 1, 12, 12, 12, "UP"},
		["Bar3"] = {34, 1, 12, 12, 12, "UP"},
		["Bar4"] = {32, 1, 12, 12, 1, "LEFT"},
		["Bar5"] = {32, 1, 12, 12, 1, "LEFT"},
		["Bar6"] = {34, 1, 12, 12, 12, "UP"},
		["Bar7"] = {34, 1, 12, 12, 12, "UP"},
		["Bar8"] = {34, 1, 12, 12, 12, "UP"},
		["BarPet"] = {26, 1, 10, 10, 10},
	}
	local directions = {L["GO_UP"], L["GO_DOWN"], L["GO_LEFT"], L["GO_RIGHT"]}
	local function toggleBar(self)
		C.db["Actionbar"][self.__value] = self:GetChecked()
		Bar:UpdateVisibility()
	end
	local function createOptionGroup(parent, offset, value, color)
		if value ~= "BarPet" then
			local box = B.CreateCheckBox(parent, true)
			box:SetPoint("TOPLEFT", parent, 10, offset + 25)
			box:SetChecked(C.db["Actionbar"][value])
			box.__value = value
			box:SetScript("OnClick", toggleBar)
			B.AddTooltip(box, "ANCHOR_RIGHT", L["ToggleActionbarTip"], "info", true)
		end

		color = color or ""
		local data = defaultData[value]
		local function updateBarScale()
			Bar:UpdateActionSize(value)
		end
		createOptionTitle(parent, "", offset)
		createOptionSlider(parent, L["ButtonSize"], 20, 80, data[1], offset-60, value.."Size", updateBarScale, "Actionbar")
		createOptionSlider(parent, L["ButtonsPerRow"], 1, data[3], data[5], offset-130, value.."PerRow", updateBarScale, "Actionbar")
		createOptionSlider(parent, L["ButtonFontSize"], 8, 20, 12, offset-200, value.."Font", updateBarScale, "Actionbar")
		if value ~= "BarPet" then
			createOptionSlider(parent, color..L["MaxButtons"], data[2], data[3], data[4], offset-270, value.."Num", updateBarScale, "Actionbar")
			createOptionDropdown(parent, L["GrowthDirection"], offset-340, directions, nil, "Actionbar", value.."Flyout", data[6], Bar.UpdateBarConfig)
		end
	end

	local options = {}
	for i = 1, 8 do
		table.insert(options, L["Actionbar"]..i)
	end
	table.insert(options, L["Pet Actionbar"]) -- 9
	table.insert(options, L["LeaveVehicle"]) -- 10

	local dd = G:CreateDropdown(scroll.child, "", 40, -15, options, nil, 180, 28, true)
	dd.Text:SetText(options[1])
	dd.panels = {}

	for i = 1, #options do
		local panel = CreateFrame("Frame", nil, scroll.child)
		panel:SetSize(260, 1)
		panel:SetPoint("TOP", 0, -30)
		panel:Hide()
		if i == 9 then
			createOptionGroup(panel, -10, "BarPet")
		elseif i == 10 then
			createOptionTitle(panel, "", -10)
			createOptionSlider(panel, L["ButtonSize"], 20, 80, 34, -70, "VehButtonSize", Bar.UpdateVehicleButton, "Actionbar")
		else
			createOptionGroup(panel, -10, "Bar"..i)
		end

		dd.panels[i] = panel
		dd.options[i]:HookScript("OnClick", toggleOptionsPanel)
	end
	toggleOptionsPanel(dd.options[1])
end

function G:SetupMicroMenu(parent)
	local guiName = "NDuiGUI_MicroMenuSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["Menubar"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local Bar = B:GetModule("Actionbar")
	local parent, offset = scroll.child, -10
	createOptionTitle(parent, L["Menubar"], offset)
	createOptionSlider(parent, L["ButtonSize"], 20, 40, 22, offset-60, "MBSize", Bar.MicroMenu_Setup, "Actionbar")
	createOptionSlider(parent, L["ButtonsPerRow"], 1, 12, 12, offset-130, "MBPerRow", Bar.MicroMenu_Setup, "Actionbar")
end

function G:SetupStanceBar(parent)
	local guiName = "NDuiGUI_StanceBarSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ActionbarSetup"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local Bar = B:GetModule("Actionbar")
	local parent, offset = scroll.child, -10
	createOptionTitle(parent, L["StanceBar"], offset)
	createOptionSlider(parent, L["ButtonSize"], 20, 80, 30, offset-60, "BarStanceSize", Bar.UpdateStanceBar, "Actionbar")
	createOptionSlider(parent, L["ButtonsPerRow"], 1, 10, 10, offset-130, "BarStancePerRow", Bar.UpdateStanceBar, "Actionbar")
	createOptionSlider(parent, L["ButtonFontSize"], 8, 20, 12, offset-200, "BarStanceFont", Bar.UpdateStanceBar, "Actionbar")
end

function G:SetupUFAuras(parent)
	local guiName = "NDuiGUI_UnitFrameAurasSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ShowAuras"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local UF = B:GetModule("UnitFrames")

	local defaultData = {
		["Player"] = {1, 2, 8, 40, 40},
		["Target"] = {2, 2, 8, 40, 40},
		["Focus"] = {3, 3, 8, 40, 40},
		["ToT"] = {1, 2, 6, 6, 30},
		["Pet"] = {1, 2, 6, 6, 30},
		["Boss"] = {2, 3, 6, 6, 12},
	}
	local buffOptions = {DISABLE, L["ShowAll"], L["ShowDispell"]}
	local debuffOptions = {DISABLE, L["ShowAll"], L["BlockOthers"]}
	local growthOptions = {}
	for i = 1, 4 do
		growthOptions[i] = UF.AuraDirections[i].name
	end

	local function createOptionGroup(parent, offset, value, func, isBoss)
		local default = defaultData[value]
		createOptionTitle(parent, "", offset)
		if isBoss then
			offset = offset + 60
		else
			createOptionDropdown(parent, L["GrowthDirection"], offset-50, growthOptions, "", "UFs", value.."AuraDirec", 1, func)
		end
		createOptionDropdown(parent, L["BuffType"], offset-110, buffOptions, nil, "UFs", value.."BuffType", default[1], func)
		createOptionDropdown(parent, L["DebuffType"], offset-170, debuffOptions, nil, "UFs", value.."DebuffType", default[2], func)
		createOptionSlider(parent, L["MaxBuffs"], 1, 40, default[4], offset-240, value.."NumBuff", func)
		createOptionSlider(parent, L["MaxDebuffs"], 1, 40, default[5], offset-310, value.."NumDebuff", func)
		if isBoss then
			createOptionSlider(parent, "Buff "..L["IconsPerRow"], 5, 20, default[3], offset-380, value.."BuffPerRow", func)
			createOptionSlider(parent, "Debuff "..L["IconsPerRow"], 5, 20, default[3], offset-450, value.."DebuffPerRow", func)
		else
			createOptionSlider(parent, L["IconsPerRow"], 5, 20, default[3], offset-380, value.."AurasPerRow", func)
		end
	end

	local options = {
		[1] = L["PlayerUF"],
		[2] = L["TargetUF"],
		[3] = L["TotUF"],
		[4] = L["PetUF"],
		[5] = L["FocusUF"],
		[6] = L["BossFrame"],
	}
	local data = {
		[1] = "Player",
		[2] = "Target",
		[3] = "ToT",
		[4] = "Pet",
		[5] = "Focus",
		[6] = "Boss",
	}

	local dd = G:CreateDropdown(scroll.child, "", 40, -15, options, nil, 180, 28, true)
	dd.Text:SetText(options[1])
	dd.panels = {}

	for i = 1, #options do
		local panel = CreateFrame("Frame", nil, scroll.child)
		panel:SetSize(260, 1)
		panel:SetPoint("TOP", 0, -30)
		panel:Hide()
		createOptionGroup(panel, -10, data[i], UF.UpdateUFAuras, i == 6)

		dd.panels[i] = panel
		dd.options[i]:HookScript("OnClick", toggleOptionsPanel)
	end
	toggleOptionsPanel(dd.options[1])
end

function G:SetupActionbarStyle(parent)
	local maxButtons, size = 3, 30

	local frame = CreateFrame("Frame", "NDuiActionbarStyleFrame", parent.child)
	frame:SetSize((size+DB.margin)*maxButtons + DB.margin, size + 2*DB.margin)
	frame:SetPoint("TOPRIGHT", -85, -15)
	B.CreateBDFrame(frame, .25)

	local Bar = B:GetModule("Actionbar")

	local styleString = {
		[1] = "NAB:12:12:10:12:12:34:12:12:12:12:12:12:1:1:12:12:12:26:32:34:34:34:12:34:12:32:12:12:12:12:12:30:12:10:34:12:12:12:0B24:0B60:0B96:-35.1TR-278:-1TR-278:-35TR-278:0T-400:0T-436:0T-472:0B134",
	}
	local styleName = {
		[1] = _G.DEFAULT,
		[2] = L["Export"],
		[3] = L["Import"],
	}
	local tooltips = {
		[2] = L["ExportActionbarStyle"],
		[3] = L["ImportActionbarStyle"],
	}

	local function applyBarStyle(self)
		if not IsControlKeyDown() then return end
		local str = styleString[self.index]
		if not str then return end
		Bar:ImportActionbarStyle(str)
	end

	StaticPopupDialogs["NDUI_BARSTYLE_EXPORT"] = {
		text = L["Export"],
		button1 = OKAY,
		OnShow = function(self)
			self.editBox:SetText(Bar:ExportActionbarStyle())
			self.editBox:HighlightText()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		whileDead = 1,
		hasEditBox = 1,
		editBoxWidth = 250,
	}

	StaticPopupDialogs["NDUI_BARSTYLE_IMPORT"] = {
		text = L["Import"],
		button1 = OKAY,
		button2 = CANCEL,
		OnShow = function(self)
			self.button1:Disable()
		end,
		OnAccept = function(self)
			Bar:ImportActionbarStyle(self.editBox:GetText())
		end,
		EditBoxOnTextChanged = function(self)
			local button1 = self:GetParent().button1
			local text = self:GetText()
			local found = text and string.find(text, "^NAB:")
			if found then
				button1:Enable()
			else
				button1:Disable()
			end
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		whileDead = 1,
		showAlert = 1,
		hasEditBox = 1,
		editBoxWidth = 250,
	}

	local function exportBarStyle()
		StaticPopup_Hide("NDUI_BARSTYLE_IMPORT")
		StaticPopup_Show("NDUI_BARSTYLE_EXPORT")
	end

	local function importBarStyle()
		StaticPopup_Hide("NDUI_BARSTYLE_EXPORT")
		StaticPopup_Show("NDUI_BARSTYLE_IMPORT")
	end

	B:RegisterEvent("PLAYER_REGEN_DISABLED", function()
		StaticPopup_Hide("NDUI_BARSTYLE_EXPORT")
		StaticPopup_Hide("NDUI_BARSTYLE_IMPORT")
	end)

	local function styleOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.title)
		GameTooltip:AddLine(self.tip, 0,1,1, 1)
		GameTooltip:Show()
	end

	local ButtonIcon = {
		[1] = "|T"..DB.closeTex..":18|t",
		[2] = "|T"..DB.arrowTex.."max:18|t",
		[3] = "|T"..DB.arrowTex.."min:18|t",
	}

	for i = 1, maxButtons do
		local bu = B.CreateButton(frame, size, size, ButtonIcon[i])
		bu:SetPoint("LEFT", (i-1)*(size + DB.margin) + DB.margin, 0)
		bu.index = i
		bu.title = styleName[i]
		bu.tip = tooltips[i] or L["ApplyBarStyle"]
		if i == 2 then
			bu:SetScript("OnClick", exportBarStyle)
		elseif i == 3 then
			bu:SetScript("OnClick", importBarStyle)
		else
			bu:SetScript("OnClick", applyBarStyle)
		end
		bu:HookScript("OnEnter", styleOnEnter)
		bu:HookScript("OnLeave", B.HideTooltip)
	end
end

function G:SetupBuffFrame(parent)
	local guiName = "NDuiGUI_BuffFrameSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["BuffFrame"].."*")
	local scroll = G:CreateScroll(panel, 260, 540)

	local A = B:GetModule("Auras")
	local parent, offset = scroll.child, -10
	local defaultSize, defaultPerRow = 30, 16

	local function updateBuffFrame()
		if not A.settings then return end
		A:UpdateOptions()
		A:UpdateHeader(A.BuffFrame)
		A.BuffFrame.mover:SetSize(A.BuffFrame:GetSize())
	end

	local function updateDebuffFrame()
		if not A.settings then return end
		A:UpdateOptions()
		A:UpdateHeader(A.DebuffFrame)
		A.DebuffFrame.mover:SetSize(A.DebuffFrame:GetSize())
	end

	local function createOptionGroup(parent, title, offset, value, func)
		createOptionTitle(parent, title, offset)
		createOptionCheck(parent, offset-35, L["ReverseGrow"], "Auras", "Reverse"..value, func)
		createOptionSlider(parent, L["Auras Size"], 24, 50, defaultSize, offset-100, value.."Size", func, "Auras")
		if func then -- no func for private auras
			createOptionSlider(parent, L["IconsPerRow"], 10, 40, defaultPerRow, offset-170, value.."sPerRow", func, "Auras")
		end
	end

	createOptionGroup(parent, "Buffs*", offset, "Buff", updateBuffFrame)
	createOptionGroup(parent, "Debuffs*", offset-260, "Debuff", updateDebuffFrame)
	createOptionGroup(parent, "PrivateAuras", offset-520, "Private")
end

function G:NameplateColorDots(parent)
	local guiName = "NDuiGUI_NameplateColorDots"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ColorDotsList"].."*", true)

	local barTable = {}

	local function createBar(parent, spellID, isNew)
		local spellName, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[spellID] = bar

		local icon, close = G:CreateBarWidgets(bar, texture)
		B.AddTooltip(icon, "ANCHOR_RIGHT", spellID, "system")
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[spellID] = nil
			C.db["Nameplate"]["DotSpells"][spellID] = nil
			sortBars(barTable)
		end)

		local name = B.CreateFS(bar, 14, spellName, false, "LEFT", 30, 0)
		name:SetWidth(120)
		if isNew then name:SetTextColor(0, 1, 0) end

		sortBars(barTable)
	end

	local frame = panel.bg

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = B.CreateEditBox(frame, 135, 25)
	scroll.box:SetPoint("TOPLEFT", 35, -10)
	B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["ID Intro"], "info", true)

	local swatch = B.CreateColorSwatch(frame, nil, C.db["Nameplate"]["DotColor"])
	swatch:SetPoint("RIGHT", scroll.box, "LEFT", -5, 0)
	swatch.__default = G.DefaultSettings["Nameplate"]["DotColor"]

	local function addClick(button)
		local parent = button.__owner
		local spellID = tonumber(parent.box:GetText())
		if not spellID or not C_Spell.GetSpellName(spellID) then UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect SpellID"]) return end
		if C.db["Nameplate"]["DotSpells"][spellID] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
		C.db["Nameplate"]["DotSpells"][spellID] = true
		createBar(parent.child, spellID, true)
		parent.box:SetText("")
	end
	scroll.add = B.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = B.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_NDUI_DOTSPELLS"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			C.db["Nameplate"]["DotSpells"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_DOTSPELLS")
	end)

	for npcID in pairs(C.db["Nameplate"]["DotSpells"]) do
		createBar(scroll.child, npcID)
	end
end

local function refreshUnitTable()
	B:GetModule("UnitFrames"):CreateUnitTable()
end

function G:NameplateUnitFilter(parent)
	local guiName = "NDuiGUI_NameplateUnitFilter"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["UnitColor List"].."*", true)
	panel:SetScript("OnHide", refreshUnitTable)

	local barTable = {}

	local function createBar(parent, text, isNew)
		local npcID = tonumber(text)

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[text] = bar

		local icon, close = G:CreateBarWidgets(bar, npcID and 136243 or 132288)
		if npcID then
			B.AddTooltip(icon, "ANCHOR_RIGHT", "ID: "..npcID, "system")
		end
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[text] = nil
			if C.CustomUnits[text] then
				C.db["Nameplate"]["CustomUnits"][text] = false
			else
				C.db["Nameplate"]["CustomUnits"][text] = nil
			end
			sortBars(barTable)
		end)

		local name = B.CreateFS(bar, 14, text, false, "LEFT", 30, 0)
		name:SetWidth(190)
		if isNew then name:SetTextColor(0, 1, 0) end
		if npcID then
			B.GetNPCName(npcID, function(npcName)
				name:SetText(npcName)
				if npcName == UNKNOWN then
					name:SetTextColor(1, 0, 0)
				end
			end)
		end

		sortBars(barTable)
	end

	local frame = panel.bg

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = B.CreateEditBox(frame, 135, 25)
	scroll.box:SetPoint("TOPLEFT", 35, -10)
	B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["NPCID or Name"], "info", true)

	local swatch = B.CreateColorSwatch(frame, nil, C.db["Nameplate"]["CustomColor"])
	swatch:SetPoint("RIGHT", scroll.box, "LEFT", -5, 0)
	swatch.__default = G.DefaultSettings["Nameplate"]["CustomColor"]

	local function addClick(button)
		local parent = button.__owner
		local text = tonumber(parent.box:GetText()) or parent.box:GetText()
		if text and text ~= "" then
			local modValue = C.db["Nameplate"]["CustomUnits"][text]
			if modValue or modValue == nil and C.CustomUnits[text] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
			C.db["Nameplate"]["CustomUnits"][text] = true
			createBar(parent.child, text, true)
			parent.box:SetText("")
		end
	end
	scroll.add = B.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = B.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_NDUI_UNITFILTER"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			C.db["Nameplate"]["CustomUnits"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_UNITFILTER")
	end)

	local UF = B:GetModule("UnitFrames")
	for npcID in pairs(UF.CustomUnits) do
		createBar(scroll.child, npcID)
	end
end

local function refreshPowerUnitTable()
	B:GetModule("UnitFrames"):CreatePowerUnitTable()
end

function G:NameplatePowerUnits(parent)
	local guiName = "NDuiGUI_NameplatePowerUnits"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = createExtraGUI(parent, guiName, L["ShowPowerList"].."*", true)
	panel:SetScript("OnHide", refreshPowerUnitTable)

	local barTable = {}

	local function createBar(parent, text, isNew)
		local npcID = tonumber(text)

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(220, 30)
		B.CreateBD(bar, .25)
		barTable[text] = bar

		local icon, close = G:CreateBarWidgets(bar, npcID and 136243 or 132288)
		if npcID then
			B.AddTooltip(icon, "ANCHOR_RIGHT", "ID: "..npcID, "system")
		end
		close:SetScript("OnClick", function()
			bar:Hide()
			barTable[text] = nil
			if C.PowerUnits[text] then
				C.db["Nameplate"]["PowerUnits"][text] = false
			else
				C.db["Nameplate"]["PowerUnits"][text] = nil
			end
			sortBars(barTable)
		end)

		local name = B.CreateFS(bar, 14, text, false, "LEFT", 30, 0)
		name:SetWidth(190)
		if isNew then name:SetTextColor(0, 1, 0) end
		if npcID then
			B.GetNPCName(npcID, function(npcName)
				name:SetText(npcName)
				if npcName == UNKNOWN then
					name:SetTextColor(1, 0, 0)
				end
			end)
		end

		sortBars(barTable)
	end

	local frame = panel.bg

	local scroll = G:CreateScroll(frame, 240, 485)
	scroll.box = B.CreateEditBox(frame, 160, 25)
	scroll.box:SetPoint("TOPLEFT", 10, -10)
	B.AddTooltip(scroll.box, "ANCHOR_TOPRIGHT", L["NPCID or Name"], "info", true)

	local function addClick(button)
		local parent = button.__owner
		local text = tonumber(parent.box:GetText()) or parent.box:GetText()
		if text and text ~= "" then
			local modValue = C.db["Nameplate"]["PowerUnits"][text]
			if modValue or modValue == nil and C.PowerUnits[text] then UIErrorsFrame:AddMessage(DB.InfoColor..L["Existing ID"]) return end
			C.db["Nameplate"]["PowerUnits"][text] = true
			createBar(parent.child, text, true)
			parent.box:SetText("")
		end
	end
	scroll.add = B.CreateButton(frame, 45, 25, ADD)
	scroll.add:SetPoint("TOPRIGHT", -8, -10)
	scroll.add.__owner = scroll
	scroll.add:SetScript("OnClick", addClick)

	scroll.reset = B.CreateButton(frame, 45, 25, RESET)
	scroll.reset:SetPoint("RIGHT", scroll.add, "LEFT", -5, 0)
	StaticPopupDialogs["RESET_NDUI_POWERUNITS"] = {
		text = L["Reset to default list"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			C.db["Nameplate"]["PowerUnits"] = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	scroll.reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_POWERUNITS")
	end)

	local UF = B:GetModule("UnitFrames")
	for npcID in pairs(UF.PowerUnits) do
		createBar(scroll.child, npcID)
	end
end

local myFullName = DB.MyFullName
function G:SetupAvada()
	local guiName = "NDuiGUI_AvadaSetup"
	toggleExtraGUI(guiName)
	if extraGUIs[guiName] then return end

	local panel = CreateFrame("Frame", guiName, UIParent, "BackdropTemplate")
	panel:SetSize(620, 295)
	panel:SetPoint("CENTER")
	B.SetBD(panel)
	B.CreateMF(panel)
	extraGUIs[guiName] = panel

	local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
	frame:SetSize(610, 250)
	frame:SetPoint("BOTTOM", 0, 5)
	B.CreateBDFrame(frame, .25)

	local UF = B:GetModule("UnitFrames")
	local profileButtons = {}
	local iconString = "|T%s:20:20:0:0:64:64:5:59:5:59|t"
	local EMPTY_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
	if not NDuiADB["AvadaIndex"][myFullName] then
		NDuiADB["AvadaIndex"][myFullName] = {}
	end
	local prevSpecID = 0
	local currentID = 1
	local refreshAllFrames
	local currentSpecID

	local function updateProfileButtons()
		local activeID = NDuiADB["AvadaIndex"][myFullName][currentSpecID] or 1
		if currentSpecID ~= prevSpecID then -- refresh button when spec changed
			currentID = activeID
			prevSpecID = currentSpecID
		end

		for i = 1, 10 do
			local bu = profileButtons[i]
			if bu then
				if activeID == i then
					bu.bg:SetBackdropColor(0, 1, 0, .25)
				else
					bu.bg:SetBackdropColor(0, 0, 0, .25)
				end
				if currentID == i then
					bu.bg:SetBackdropBorderColor(1, 1, 0)
				else
					B.SetBorderColor(bu.bg)
				end
			end
		end
	end

	local spellData = {}
	local function stringParserByIndex(index)
		table.wipe(spellData)

		local str
		if index == 1 then
			str = UF.DefaultAvada[currentSpecID]
		else
			str = NDuiADB["AvadaProfile"][currentSpecID] and NDuiADB["AvadaProfile"][currentSpecID][index] or ""
		end

		for result in string.gmatch(str, "[^N]+") do
			local iconIndex, unit, iconType, spellID = string.match(result, "(%d+)Z(%w+)Z(%w+)Z(%d+)")
			iconIndex = tonumber(iconIndex)
			spellData[iconIndex] = {index = iconIndex, unit = unit, type = iconType, spellID = tonumber(spellID)}
		end
	end

	local function updateOptionGroup()
		for i = 1, 6 do
			local bu = frame.buttons[i]
			if bu then
				bu.spellID = spellData[i] and spellData[i].spellID
				local spellType = spellData[i] and spellData[i].type
				local texture = bu.spellID and C_Spell.GetSpellTexture(bu.spellID)
				if spellType == "item" then
					texture = bu.spellID and C_Item.GetItemIconByID(bu.spellID)
				end
				bu.spellType = spellType
				bu.Icon:SetTexture(texture or EMPTY_ICON)
				bu.options[1].Text:SetText(spellData[i] and spellData[i].unit or "")
				bu.options[2].Text:SetText(spellType or "")
				bu.options[3]:SetText(spellData[i] and spellData[i].spellID or "")
			end
		end
	end

	local function buttonSelected(self)
		currentID = self:GetID()
		refreshAllFrames()
	end

	local function showCurrentSpells(self)
		stringParserByIndex(self:GetID())

		local toolipText = ""
		if next(spellData) then
			for i = 1, 6 do
				local spellID = spellData[i] and spellData[i].spellID
				if spellID then
					local texture = C_Spell.GetSpellTexture(spellID)
					local spellName = C_Spell.GetSpellName(spellID) or spellID
					if spellData[i].type == "item" then
						spellName = C_Item.GetItemInfo(spellID) or spellID
						texture = C_Item.GetItemIconByID(spellID)
					end
					toolipText = toolipText..format(iconString, texture or EMPTY_ICON)..spellName.."\n"
				end
			end
		end
		if toolipText == "" then toolipText = NONE end

		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(toolipText)
		GameTooltip:Show()
	end

	for i = 1, 10 do
		local bu = B.CreateButton(panel, 30, 30, true)
		bu:SetPoint("TOPLEFT", 5 + (i-1)*35, -5)
		bu:SetID(i)
		B.CreateFS(bu, 20, i, "info", "CENTER", 0, -1)
		bu:SetScript("OnClick", buttonSelected)
		bu:SetScript("OnEnter", showCurrentSpells)
		bu:SetScript("OnLeave", B.HideTooltip)

		profileButtons[i] = bu
	end

	local close = B.CreateButton(panel, 30, 30, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -5, -5)
	close:SetScript("OnClick", function()
		panel:Hide()
	end)

	local load = B.CreateButton(panel, 30, 30, true, "Atlas:Garr_Building-AddFollowerPlus")
	load:SetPoint("LEFT", profileButtons[10], "RIGHT", 5, 0)
	load.title = L["LoadProfile"]
	B.AddTooltip(load, "ANCHOR_RIGHT", L["LoadProfileTip"], "info")
	load:SetScript("OnClick", function()
		if currentID ~= 1 and (NDuiADB["AvadaProfile"][currentSpecID] and NDuiADB["AvadaProfile"][currentSpecID][currentID]) then
			NDuiADB["AvadaIndex"][myFullName][currentSpecID] = currentID
			UIErrorsFrame:AddMessage(DB.InfoColor..format(L["LoadProfileIndex"], currentID))
		else
			NDuiADB["AvadaIndex"][myFullName][currentSpecID] = nil
			UIErrorsFrame:AddMessage(DB.InfoColor..L["LoadProfileDefault"])
		end
		UF:Avada_RefreshAll()
		updateProfileButtons()
	end)

	local save = B.CreateButton(panel, 30, 30, true, "Atlas:common-icon-checkmark")
	save:SetPoint("LEFT", load, "RIGHT", 5, 0)
	save.title = L["SaveProfile"]
	B.AddTooltip(save, "ANCHOR_RIGHT", L["SaveProfileTip"], "info")
	save:SetScript("OnClick", function()
		if currentID == 1 then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Profile1Warning"])
			return
		end
		local str = ""
		for i = 1, 6 do
			local unitStr = frame.buttons[i].options[1].Text:GetText()
			local typeStr = frame.buttons[i].options[2].Text:GetText()
			local spellID = frame.buttons[i].options[3]:GetText()
			if unitStr and typeStr and spellID then
				str = str..i.."Z"..unitStr.."Z"..typeStr.."Z"..spellID.."N"
			end
		end
		if not NDuiADB["AvadaProfile"][currentSpecID] then NDuiADB["AvadaProfile"][currentSpecID] = {} end
		NDuiADB["AvadaProfile"][currentSpecID][currentID] = str ~= "" and str or nil
	end)

	local undo = B.CreateButton(panel, 30, 30, true, "Atlas:common-icon-redx")
	undo:SetPoint("LEFT", save, "RIGHT", 5, 0)
	undo.title = L["ClearProfile"]
	B.AddTooltip(undo, "ANCHOR_RIGHT", L["ClearProfileTip"], "info")
	undo:SetScript("OnClick", function()
		if currentID == 1 then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Profile1Warning"])
			return
		end
		for i = 1, 6 do
			frame.buttons[i].Icon:SetTexture(EMPTY_ICON)
			frame.buttons[i].options[1].Text:SetText()
			frame.buttons[i].options[2].Text:SetText()
			frame.buttons[i].options[3]:SetText("")
		end
	end)

	StaticPopupDialogs["NDUI_AVADA_EXPORT"] = {
		text = L["Export"],
		button1 = OKAY,
		OnShow = function(self)
			local text
			if currentID == 1 then
				text = UF.DefaultAvada[currentSpecID]
			else
				text = NDuiADB["AvadaProfile"][currentSpecID] and NDuiADB["AvadaProfile"][currentSpecID][currentID] or ""
			end
			self.editBox:SetText(text or "")
			self.editBox:HighlightText()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		whileDead = 1,
		hasEditBox = 1,
		editBoxWidth = 250,
	}

	local function strTestFailed(str)
		local iconIndex, unit, iconType, spellID
		for result in string.gmatch(str, "[^N]+") do
			iconIndex, unit, iconType, spellID = string.match(result, "(%d+)Z(%w+)Z(%w+)Z(%d+)")
			if not (iconIndex and unit and iconType and spellID) then
				return true
			end
		end
	end

	StaticPopupDialogs["NDUI_AVADA_IMPORT"] = {
		text = L["Import"],
		button1 = OKAY,
		button2 = CANCEL,
		OnAccept = function(self)
			if currentID == 1 then
				UIErrorsFrame:AddMessage(DB.InfoColor..L["Profile1Warning"])
				return
			end
			local text = self.editBox:GetText()
			if strTestFailed(text) then
				UIErrorsFrame:AddMessage(DB.InfoColor..L["Data Exception"])
				return
			end
			if not NDuiADB["AvadaProfile"][currentSpecID] then NDuiADB["AvadaProfile"][currentSpecID] = {} end
			NDuiADB["AvadaProfile"][currentSpecID][currentID] = text
			refreshAllFrames()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		whileDead = 1,
		showAlert = 1,
		hasEditBox = 1,
		editBoxWidth = 250,
	}

	local function exportAvadaStyle()
		StaticPopup_Hide("NDUI_AVADA_IMPORT")
		StaticPopup_Show("NDUI_AVADA_EXPORT")
	end

	local function importAvadaStyle()
		StaticPopup_Hide("NDUI_AVADA_EXPORT")
		StaticPopup_Show("NDUI_AVADA_IMPORT")
	end

	B:RegisterEvent("PLAYER_REGEN_DISABLED", function()
		StaticPopup_Hide("NDUI_AVADA_EXPORT")
		StaticPopup_Hide("NDUI_AVADA_IMPORT")
	end)

	local export = B.CreateButton(panel, 30, 30, true,  DB.arrowTex.."max")
	export:SetPoint("LEFT", undo, "RIGHT", 5, 0)
	export:SetScript("OnClick", exportAvadaStyle)
	export.title = L["Export"]
	B.AddTooltip(export, "ANCHOR_RIGHT")

	local import = B.CreateButton(panel, 30, 30, true, DB.arrowTex.."min")
	import:SetPoint("LEFT", export, "RIGHT", 5, 0)
	import:SetScript("OnClick", importAvadaStyle)
	import.title = L["Import"]
	B.AddTooltip(import, "ANCHOR_RIGHT")

	frame.buttons = {}
	local unitOptions = {"player", "target", "pet"}
	local typeOptions = {"buff", "debuff", "cd", "item"}

	local function showTooltip(self)
		local spellID = self.spellID
		if not spellID then return end
		if self.spellType == "item" then
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
			GameTooltip:ClearLines()
			GameTooltip:SetItemByID(spellID)
			GameTooltip:Show()
		else
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
			GameTooltip:ClearLines()
			GameTooltip:SetSpellByID(spellID)
			GameTooltip:Show()
		end
	end

	local function createOptionGroup(parent, i)
		parent.options = {}

		local unitOption = G:CreateDropdown(parent, L["Unit*"], 1, 1, unitOptions, L["AvadaUnitOptionTip"], 88, 28)
		unitOption:ClearAllPoints()
		unitOption:SetPoint("TOP", parent, "BOTTOM", 0, -30)
		parent.options[1] = unitOption

		local typeOption = G:CreateDropdown(parent, L["Type*"], 1, 1, typeOptions, L["AvadaTypeOptionTip"], 88, 28)
		typeOption:ClearAllPoints()
		typeOption:SetPoint("TOP", parent, "BOTTOM", 0, -90)
		parent.options[2] = typeOption

		local spellOption = G:CreateEditbox(parent, "ID*", 1, 1, L["AvadaIDOptionTip"], 88, 28)
		spellOption:ClearAllPoints()
		spellOption:SetPoint("TOP", parent, "BOTTOM", 0, -150)
		spellOption:SetJustifyH("CENTER")
		parent.options[3] = spellOption
	end

	local function GetCursorID()
		local infoType, itemID, _, spellID = GetCursorInfo()
		return infoType == "item" and itemID or infoType == "spell" and spellID or nil
	end

	local function receiveCursor(button)
		if currentID == 1 then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["Profile1Warning"])
			return
		end
		if CursorHasItem() then
			local itemID = GetCursorID()
			if itemID then
				ClearCursor()
				button.spellID = itemID
				button.spellType = "item"
				button.Icon:SetTexture(C_Item.GetItemIconByID(itemID) or EMPTY_ICON)
				button.options[1].Text:SetText("player")
				button.options[2].Text:SetText("item")
				button.options[3]:SetText(itemID)
			end
		elseif CursorHasSpell() then
			local spellID = GetCursorID()
			if spellID then
				ClearCursor()
				button.spellID = spellID
				button.spellType = "cd"
				button.Icon:SetTexture(C_Spell.GetSpellTexture(spellID) or EMPTY_ICON)
				button.options[1].Text:SetText("player")
				button.options[2].Text:SetText("cd")
				button.options[3]:SetText(spellID)
			end
		end
	end

	for i = 1, 6 do
		local bu = B.CreateButton(frame, 50, 50, true, EMPTY_ICON)
		bu:SetPoint("TOPLEFT", 30 + (i-1)*100, -10)
		bu:SetScript("OnEnter", showTooltip)
		bu:SetScript("OnLeave", B.HideTooltip)
		bu:SetScript("OnMouseDown", receiveCursor)
		bu:SetScript("OnReceiveDrag", receiveCursor)
		createOptionGroup(bu, i)
		frame.buttons[i] = bu
	end

	function refreshAllFrames()
		local specIndex = GetSpecialization()
		if specIndex > 4 then specIndex = 1 end -- use 1st spec for lower level
		currentSpecID = GetSpecializationInfo(specIndex)

		if not panel:IsShown() then return end
		updateProfileButtons()
		stringParserByIndex(currentID)
		updateOptionGroup()
	end

	refreshAllFrames()
	B:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", refreshAllFrames)
	panel:HookScript("OnShow", refreshAllFrames)
end

SlashCmdList["NDUI_AVADACONFIG"] = G.SetupAvada
SLASH_NDUI_AVADACONFIG1 = "/aa"