local _, ns = ...
local B, C, L, DB = unpack(ns)

local module = B:RegisterModule("Bags")
local cargBags = ns.cargBags

local CHAR_BANK_TYPE = Enum.BankType.Character or 0
local ACCOUNT_BANK_TYPE = Enum.BankType.Account or 2

local sortCache = {}
function module:ReverseSort()
	for bag = 0, 4 do
		local numSlots = C_Container.GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			local texture = info and info.iconFileID
			local locked = info and info.isLocked
			if (slot <= numSlots/2) and texture and not locked and not sortCache["b"..bag.."s"..slot] then
				C_Container.PickupContainerItem(bag, slot)
				C_Container.PickupContainerItem(bag, numSlots+1 - slot)
				sortCache["b"..bag.."s"..slot] = true
			end
		end
	end

	module.Bags.isSorting = false
	module:UpdateAllBags()
end

local anchorCache = {}

local function CheckForBagReagent(name)
	return not (name == "BagReagent" and C_Container.GetContainerNumSlots(5) == 0)
end

function module:UpdateBagsAnchor(parent, bags)
	table.wipe(anchorCache)

	local index = 1
	local perRow = C.db["Bags"]["BagsPerRow"]
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 and CheckForBagReagent(bag.name) then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if (index-1) % perRow == 0 then
				bag:SetPoint("BOTTOMRIGHT", anchorCache[index-perRow], "BOTTOMLEFT", -DB.margin, 0)
			else
				bag:SetPoint("BOTTOMLEFT", anchorCache[index-1], "TOPLEFT", 0, DB.margin)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

function module:UpdateBankAnchor(parent, bags)
	table.wipe(anchorCache)

	local index = 1
	local perRow = C.db["Bags"]["BankPerRow"]
	if parent:GetName() == "NDui_BackpackAccount" then
		perRow = C.db["Bags"]["BankPerRow"] + 1
	end
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if index <= perRow then
				bag:SetPoint("BOTTOMLEFT", anchorCache[index-1], "TOPLEFT", 0, DB.margin)
			elseif index == perRow+1 then
				bag:SetPoint("TOPLEFT", anchorCache[index-1], "TOPRIGHT", DB.margin, 0)
			elseif (index-1) % perRow == 0 then
				bag:SetPoint("TOPLEFT", anchorCache[index-perRow], "TOPRIGHT", DB.margin, 0)
			else
				bag:SetPoint("TOPLEFT", anchorCache[index-1], "BOTTOMLEFT", 0, -DB.margin)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

local function highlightFunction(button, match)
	button.searchOverlay:SetShown(not match)
end

local function IsItemMatched(str, text)
	if not str or str == "" then return end
	return string.match(string.lower(str), text)
end

local BagSmartFilter = {
	default = function(item, text)
		text = string.lower(text)
		if text == "boe" then
			return item.bindOn == "equip"
		elseif text == "aoe" then
			return item.bindOn == "accountequip"
		else
			return IsItemMatched(item.subType, text) or IsItemMatched(item.equipLoc, text) or IsItemMatched(item.name, text) or IsItemMatched((item.expacID or 0) + 1, text)
		end
	end,
	_default = "default",
}

function module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 12, 0)
	infoFrame:SetSize(140, 32)
	local icon = infoFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAtlas("talents-search-match")
	icon:SetSize(52, 52)
	icon:SetPoint("LEFT", -15, 0)
	icon:SetVertexColor(DB.r, DB.g, DB.b)
	local hl = infoFrame:CreateTexture(nil, "HIGHLIGHT")
	hl:SetBlendMode("ADD")
	hl:SetAtlas("talents-search-match")
	hl:SetSize(52, 52)
	hl:SetPoint("LEFT", -15, 0)

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	local bg = B.CreateBDFrame(search, 0, true)
	B.UpdateSize(bg, -6, -6, 6, 6)
	search.textFilters = BagSmartFilter

	infoFrame.title = SEARCH
	B.AddTooltip(infoFrame, "ANCHOR_TOPLEFT", L["BagSearchTip"], "info")
end

local function ToggleWidgetButtons(self)
	C.db["Bags"]["HideWidgets"] = not C.db["Bags"]["HideWidgets"]

	local buttons = self.__owner.widgetButtons

	for index, button in pairs(buttons) do
		if index > 2 then
			button:SetShown(not C.db["Bags"]["HideWidgets"])
		end
	end

	if C.db["Bags"]["HideWidgets"] then
		self:SetPoint("RIGHT", buttons[2], "LEFT", -1, 0)
		B.SetupArrow(self.__texture, "left")
		self.tag:Show()
	else
		self:SetPoint("RIGHT", buttons[#buttons], "LEFT", -1, 0)
		B.SetupArrow(self.__texture, "right")
		self.tag:Hide()
	end
	self:Show()
end

function module:CreateCollapseArrow()
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(20, 20)
	B.SetupTexture(bu, "right")

	local tag = self:SpawnPlugin("TagDisplay", "[money]", self)
	tag:SetFont(unpack(DB.Font))
	tag:SetPoint("RIGHT", bu, "LEFT", -12, 0)
	bu.tag = tag

	bu.__owner = self
	C.db["Bags"]["HideWidgets"] = not C.db["Bags"]["HideWidgets"] -- reset before toggle
	ToggleWidgetButtons(bu)
	bu:SetScript("OnClick", ToggleWidgetButtons)

	self.widgetArrow = bu
end

local function updateBagBar(bar)
	local spacing = DB.margin
	local offset = DB.margin*2
	local width, height = bar:LayoutButtons("grid", bar.columns, spacing, offset, -offset)
	bar:SetSize(width + offset*2, height + offset*2)
end

function module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	B.CreateBG(bagBar)
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()
	bagBar.columns = columns
	bagBar.UpdateAnchor = updateBagBar
	bagBar:UpdateAnchor()

	self.BagBar = bagBar
end

function module:CreateBagTab(settings, columns, account)
	local bagTab = self:SpawnPlugin("BagTab", settings.Bags, account)
	bagTab:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	B.CreateBG(bagTab)
	bagTab.highlightFunction = highlightFunction
	bagTab.isGlobal = true
	bagTab:Hide()
	bagTab.columns = columns
	bagTab.UpdateAnchor = updateBagBar
	bagTab:UpdateAnchor()

	if account then
		local purchaseButton = CreateFrame("Button", "NDui_BankPurchaseButton", bagTab, "InsecureActionButtonTemplate")
		purchaseButton:SetSize(120, 22)
		purchaseButton:SetPoint("TOP", bagTab, "BOTTOM", 0, -5)
		B.CreateFS(purchaseButton, 14, PURCHASE, "info")
		B.ReskinButton(purchaseButton)
		purchaseButton:Hide()

		purchaseButton:RegisterForClicks("AnyUp", "AnyDown")
		purchaseButton:SetAttribute("type", "click")
		purchaseButton:SetAttribute("clickbutton", _G.BankFrame.BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton)
	end

	self.BagBar = bagTab
end

local function CloseOrRestoreBags(self, btn)
	if btn == "RightButton" then
		local bag = self.__owner.main
		local bank = self.__owner.bank
		local account = self.__owner.accountbank
		C.db["TempAnchor"][bag:GetName()] = nil
		C.db["TempAnchor"][bank:GetName()] = nil
		C.db["TempAnchor"][account:GetName()] = nil
		bag:ClearAllPoints()
		bag:SetPoint(unpack(bag.__anchor))
		bank:ClearAllPoints()
		bank:SetPoint(unpack(bank.__anchor))
		account:ClearAllPoints()
		account:SetPoint(unpack(bank.__anchor))
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	else
		module:CloseBags()
	end
end

function module:CreateCloseButton(f)
	local bu = B.CreateButton(self, 22, 22, true, DB.closeTex)
	bu:RegisterForClicks("AnyUp")
	bu.__owner = f
	bu:SetScript("OnClick", CloseOrRestoreBags)
	bu.title = CLOSE.." / "..RESET
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateAccountBankButton(f)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\Factionchange")
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", function(_, btn)
		if not C_Bank.CanViewBank(ACCOUNT_BANK_TYPE) then return end

		if BankFrame.BankPanel:ShouldShowLockPrompt() then
			UIErrorsFrame:AddMessage(DB.InfoColor..ACCOUNT_BANK_LOCKED_PROMPT)
		else
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
			BankFrame.BankPanel:SetBankType(ACCOUNT_BANK_TYPE)
		end
	end)
	bu.title = ACCOUNT_BANK_PANEL_TITLE
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateAccountMoney()
	local frame = CreateFrame("Button", nil, self)
	frame:SetSize(50, 22)

	local tag = self:SpawnPlugin("TagDisplay", "[accountmoney]", self)
	tag:SetFont(unpack(DB.Font))
	tag:SetPoint("RIGHT", frame, -2, 0)
	frame.tag = tag

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			StaticPopup_Hide("BANK_MONEY_DEPOSIT")
			if StaticPopup_Visible("BANK_MONEY_WITHDRAW") then
				StaticPopup_Hide("BANK_MONEY_WITHDRAW")
			else
				StaticPopup_Show("BANK_MONEY_WITHDRAW", nil, nil, {bankType = ACCOUNT_BANK_TYPE})
			end
		else
			StaticPopup_Hide("BANK_MONEY_WITHDRAW")
			if StaticPopup_Visible("BANK_MONEY_DEPOSIT") then
				StaticPopup_Hide("BANK_MONEY_DEPOSIT")
			else
				StaticPopup_Show("BANK_MONEY_DEPOSIT", nil, nil, {bankType = ACCOUNT_BANK_TYPE})
			end
		end
	end)
	frame.title = DB.LeftButton..BANK_DEPOSIT_MONEY_BUTTON_LABEL.."|n"..DB.RightButton..BANK_WITHDRAW_MONEY_BUTTON_LABEL
	B.AddTooltip(frame, "ANCHOR_TOP")

	return frame
end

function module:CreateBankButton(f)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\Battleground_Strongbox_Gold_"..DB.MyFaction)
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", function()
		if not C_Bank.CanViewBank(CHAR_BANK_TYPE) then return end

		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		BankFrame.BankPanel:SetBankType(CHAR_BANK_TYPE)
	end)
	bu.title = BANK
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function updateAccountBankDeposit(bu)
	if GetCVarBool("bankAutoDepositReagents") then
		bu.bg:SetBackdropBorderColor(1, 1, 0)
	else
		B.SetBorderColor(bu.bg)
	end
end

function module:CreateAccountBankDeposit()
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Paperdollinfoframe\\Character-Plus")
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			local isOn = GetCVarBool("bankAutoDepositReagents")
			SetCVar("bankAutoDepositReagents", isOn and 0 or 1)
			updateAccountBankDeposit(bu)
		elseif btn == "LeftButton" then
			C_Bank.AutoDepositItemsIntoBank(ACCOUNT_BANK_TYPE)
		end
	end)
	bu.title = ACCOUNT_BANK_DEPOSIT_BUTTON_LABEL
	B.AddTooltip(bu, "ANCHOR_TOP", L["AccountDepositTip"], "info")
	updateAccountBankDeposit(bu)

	return bu
end

function module:CreateBankDeposit()
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Paperdollinfoframe\\Character-Plus")
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			C_Bank.AutoDepositItemsIntoBank(CHAR_BANK_TYPE)
		end
	end)
	bu.title = CHARACTER_BANK_DEPOSIT_BUTTON_LABEL
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function ToggleBackpacks(self)
	local parent = self.__owner
	if not parent.BagBar then return end
	B:TogglePanel(parent.BagBar)
	if parent.BagBar:IsShown() then
		self.bg:SetBackdropBorderColor(1, 1, 0)
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	else
		B.SetBorderColor(self.bg)
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end
end

function module:CreateBagToggle(click)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\inv_misc_bag_08")
	bu.__owner = self
	bu:SetScript("OnClick", ToggleBackpacks)
	bu.title = BACKPACK_TOOLTIP
	B.AddTooltip(bu, "ANCHOR_TOP")
	if click then
		ToggleBackpacks(bu)
	end

	return bu
end

function module:CreateSortButton(name)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\Inv_Pet_Broom")
	bu:SetScript("OnClick", function()
		if name == "Bank" then
			C_Container.SortBankBags()
		elseif name == "Account" then
			C_Container.SortAccountBankBags()
		else
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
				return
			end
			if C.db["Bags"]["BagSortMode"] == 1 then
				C_Container.SortBags()
			elseif C.db["Bags"]["BagSortMode"] == 2 then
				C_Container.SortBags()
				table.wipe(sortCache)
				module.Bags.isSorting = true
				C_Timer.After(.5, module.ReverseSort)
			end
		end
	end)
	bu.title = L["Sort"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:GetContainerEmptySlot(bagID)
	for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
		if not C_Container.GetContainerItemID(bagID, slotID) then
			return slotID
		end
	end
end

function module:GetEmptySlot(name)
	if name == "Bag" then
		for bagID = 0, 4 do
			local slotID = module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Bank" then
		for bagID = 6, 11 do
			local slotID = module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "BagReagent" then
		local slotID = module:GetContainerEmptySlot(5)
		if slotID then
			return 5, slotID
		end
	elseif name == "Account" then
		for bagID = 12, 16 do
			local slotID = module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	end
end

function module:FreeSlotOnDrop()
	local bagID, slotID = module:GetEmptySlot(self.__name)
	if slotID then
		C_Container.PickupContainerItem(bagID, slotID)
	end
end

local freeSlotContainer = {
	["Bag"] = true,
	["Bank"] = true,
	["BagReagent"] = true,
	["Account"] = true,
}

function module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then return end

	local slot = CreateFrame("Button", name.."FreeSlot", self, "BackdropTemplate")
	slot:SetSize(self.iconSize, self.iconSize)
	slot:SetScript("OnMouseUp", module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", module.FreeSlotOnDrop)
	B.CreateBD(slot, .25)
	B.ReskinHLTex(slot, slot)
	B.AddTooltip(slot, "ANCHOR_RIGHT", L["FreeSlots"])
	slot.__name = name

	local tag = self:SpawnPlugin("TagDisplay", "[space]", slot)
	B.SetFontSize(tag, C.db["Bags"]["FontSize"] + 2)
	tag:SetTextColor(0, 1, 1)
	tag:SetPoint("CENTER", 1, 0)
	tag.__name = name
	slot.tag = tag

	self.freeSlot = slot
end

local toggleButtons = {}
function module:SelectToggleButton(id)
	for index, button in pairs(toggleButtons) do
		if index ~= id then
			button.__turnOff()
		end
	end
end

local splitEnable
local function saveSplitCount(self)
	local count = self:GetText() or ""
	C.db["Bags"]["SplitCount"] = tonumber(count) or 1
end

function module:CreateSplitButton()
	local enabledText = DB.InfoColor..L["SplitMode Enabled"]

	local splitFrame = CreateFrame("Frame", nil, self)
	splitFrame:SetSize(100, 50)
	splitFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
	B.CreateFS(splitFrame, 14, L["SplitCount"], "system", "TOP", 1, -5)
	B.CreateBG(splitFrame)
	splitFrame:Hide()
	local editbox = B.CreateEditBox(splitFrame, 90, 20)
	editbox:SetPoint("BOTTOMLEFT", 5, 5)
	editbox:SetJustifyH("CENTER")
	editbox:SetScript("OnTextChanged", saveSplitCount)

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\Ability_Monk_CounteractMagic")
	bu.__turnOff = function()
		B.SetBorderColor(bu.bg)
		bu.text = nil
		splitFrame:Hide()
		splitEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		module:SelectToggleButton(1)
		splitEnable = not splitEnable
		if splitEnable then
			self.bg:SetBackdropBorderColor(1, 1, 0)
			self.text = enabledText
			splitFrame:Show()
			editbox:SetText(C.db["Bags"]["SplitCount"])
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["QuickSplit"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[1] = bu

	return bu
end

local function splitOnClick(self)
	if not splitEnable then return end

	C_Container.PickupContainerItem(self.bagId, self.slotId)

	local info = C_Container.GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local itemCount = info and info.stackCount
	local locked = info and info.isLocked

	if texture and not locked and itemCount and itemCount > C.db["Bags"]["SplitCount"] then
		C_Container.SplitContainerItem(self.bagId, self.slotId, C.db["Bags"]["SplitCount"])

		local bagID, slotID = module:GetEmptySlot("Bag")
		if slotID then
			C_Container.PickupContainerItem(bagID, slotID)
		end
	end
end

local favouriteEnable

local function GetCustomGroupTitle(index)
	return C.db["Bags"]["CustomNames"][index] or (FAVORITES.." "..index)
end

StaticPopupDialogs["NDUI_RENAMECUSTOMGROUP"] = {
	text = BATTLE_PET_RENAME,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		local index = module.selectGroupIndex
		local text = self.EditBox:GetText()
		C.db["Bags"]["CustomNames"][index] = text ~= "" and text or nil

		module.CustomMenu[index+2].text = GetCustomGroupTitle(index)
		module.ContainerGroups["Bag"][index].label:SetText(GetCustomGroupTitle(index))
		module.ContainerGroups["Bank"][index].label:SetText(GetCustomGroupTitle(index))
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	whileDead = 1,
	showAlert = 1,
	hasEditBox = 1,
	editBoxWidth = 250,
}

function module:RenameCustomGroup(index)
	module.selectGroupIndex = index
	StaticPopup_Show("NDUI_RENAMECUSTOMGROUP")
end

function module:MoveItemToCustomBag(index)
	local itemID = module.selectItemID
	if index == 0 then
		if C.db["Bags"]["CustomItems"][itemID] then
			C.db["Bags"]["CustomItems"][itemID] = nil
		end
	else
		C.db["Bags"]["CustomItems"][itemID] = index
	end
	module:UpdateAllBags()
end

function module:IsItemInCustomBag()
	local index = self.arg1
	local itemID = module.selectItemID
	return (index == 0 and not C.db["Bags"]["CustomItems"][itemID]) or (C.db["Bags"]["CustomItems"][itemID] == index)
end

function module:CreateFavouriteButton()
	local menuList = {
		{text = "", icon = 134400, isTitle = true, notCheckable = true, tCoordLeft = .08, tCoordRight = .92, tCoordTop = .08, tCoordBottom = .92},
		{text = NONE, arg1 = 0, func = module.MoveItemToCustomBag, checked = module.IsItemInCustomBag},
	}
	for i = 1, 5 do
		table.insert(menuList, {
			text = GetCustomGroupTitle(i), arg1 = i, func = module.MoveItemToCustomBag, checked = module.IsItemInCustomBag, hasArrow = true,
			menuList = {{text = BATTLE_PET_RENAME, arg1 = i, func = module.RenameCustomGroup}}
		})
	end
	module.CustomMenu = menuList

	local enabledText = DB.InfoColor..L["FavouriteMode Enabled"]

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\PetBattle_Health")
	bu.__turnOff = function()
		B.SetBorderColor(bu.bg)
		bu.text = nil
		favouriteEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		module:SelectToggleButton(2)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self.bg:SetBackdropBorderColor(1, 1, 0)
			self.text = enabledText
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["FavouriteMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[2] = bu

	return bu
end

local function favouriteOnClick(self)
	if not favouriteEnable then return end

	local info = C_Container.GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local quality = info and info.quality
	local link = info and info.hyperlink
	local itemID = info and info.itemID

	if texture and quality > Enum.ItemQuality.Poor then
		ClearCursor()
		module.selectItemID = itemID
		module.CustomMenu[1].text = link
		module.CustomMenu[1].icon = texture
		EasyMenu(module.CustomMenu, B.EasyMenu, self, 0, 0, "MENU")
	end
end

StaticPopupDialogs["NDUI_WIPE_JUNK_LIST"] = {
	text = L["Reset junklist warning"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		table.wipe(NDuiADB["CustomJunkList"])
	end,
	whileDead = 1,
}
local customJunkEnable
function module:CreateJunkButton()
	local enabledText = DB.InfoColor..L["JunkMode Enabled"]

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\Spell_ChargePositive")
	bu.__turnOff = function()
		B.SetBorderColor(bu.bg)
		bu.text = nil
		customJunkEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		if IsAltKeyDown() and IsControlKeyDown() then
			StaticPopup_Show("NDUI_WIPE_JUNK_LIST")
			return
		end

		module:SelectToggleButton(3)
		customJunkEnable = not customJunkEnable
		if customJunkEnable then
			self.bg:SetBackdropBorderColor(1, 1, 0)
			self.text = enabledText
		else
			bu.__turnOff()
		end
		module:UpdateAllBags()
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["CustomJunkMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[3] = bu

	return bu
end

local function customJunkOnClick(self)
	if not customJunkEnable then return end

	local info = C_Container.GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local itemID = info and info.itemID

	local price = select(11, C_Item.GetItemInfo(itemID))
	if texture and price > 0 then
		if NDuiADB["CustomJunkList"][itemID] then
			NDuiADB["CustomJunkList"][itemID] = nil
		else
			NDuiADB["CustomJunkList"][itemID] = true
		end
		ClearCursor()
		module:UpdateAllBags()
	end
end

local deleteEnable
function module:CreateDeleteButton()
	local enabledText = DB.InfoColor..L["DeleteMode Enabled"]

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\Spell_ChargeNegative")
	bu.__turnOff = function()
		B.SetBorderColor(bu.bg)
		bu.text = nil
		deleteEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		module:SelectToggleButton(4)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self.bg:SetBackdropBorderColor(1, 1, 0)
			self.text = enabledText
		else
			bu.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["ItemDeleteMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[4] = bu

	return bu
end

local function deleteButtonOnClick(self)
	if not deleteEnable then return end

	local info = C_Container.GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local quality = info and info.quality

	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < Enum.ItemQuality.Rare or quality == Enum.ItemQuality.Heirloom) then
		C_Container.PickupContainerItem(self.bagId, self.slotId)
		DeleteCursorItem()
	end
end

function module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then return end
	splitOnClick(self)
	favouriteOnClick(self)
	customJunkOnClick(self)
	deleteButtonOnClick(self)
end

function module:UpdateAllBags()
	if self.Bags and self.Bags:IsShown() then
		self.Bags:BAG_UPDATE()
	end
end

function module:OpenBags()
	OpenAllBags(true)
end

function module:CloseBags()
	if self.Bags and self.Bags:IsShown() then
		ToggleAllBags()
	end
end

function module:OnLogin()
	if not C.db["Bags"]["Enable"] then return end

	-- Settings
	local iconSize = C.db["Bags"]["IconSize"]
	local hasCanIMogIt = C_AddOns.IsAddOnLoaded("CanIMogIt")
	local hasPawn = C_AddOns.IsAddOnLoaded("Pawn")

	-- Init
	local Backpack = cargBags:NewImplementation("NDui_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
	Backpack:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)

	module.Bags = Backpack
	module.BagsType = {}
	module.BagsType[0] = 0	-- backpack

	local f = {}
	local filters = module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	module.ContainerGroups = {["Bag"] = {}, ["Bank"] = {}, ["Account"] = {}}

	local function AddNewContainer(bagType, index, name, filter)
		local newContainer = MyContainer:New(name, {BagType = bagType, Index = index})
		newContainer:SetFilter(filter, true)
		module.ContainerGroups[bagType][index] = newContainer
	end

	local function AddBankFilter(bankType)
		local bank = bankType:lower()
		for i = 1, 5 do
			AddNewContainer(bankType, i, bankType.."Custom"..i, filters[bank.."Custom"..i])
		end
		AddNewContainer(bankType, 15, bankType.."Junk", filters[bank.."Junk"])
		AddNewContainer(bankType, 14, bankType.."Feature", filters[bank.."Feature"])
		AddNewContainer(bankType, 13, bankType.."Collection", filters[bank.."Collection"])
		AddNewContainer(bankType, 12, bankType.."BoN", filters[bank.."BoN"])
		AddNewContainer(bankType, 11, bankType.."Consumable", filters[bank.."Consumable"])
		AddNewContainer(bankType, 10, bankType.."Tradegoods", filters[bank.."Tradegoods"])
		AddNewContainer(bankType, 9, bankType.."AuE", filters[bank.."AuE"])
		AddNewContainer(bankType, 8, bankType.."Legendary", filters[bank.."Legendary"])
		AddNewContainer(bankType, 7, bankType.."EquipSet", filters[bank.."EquipSet"])
		AddNewContainer(bankType, 6, bankType.."Equipment", filters[bank.."Equipment"])
	end

	function Backpack:OnInit()
		for i = 1, 5 do
			AddNewContainer("Bag", i, "BagCustom"..i, filters["bagCustom"..i])
		end
		AddNewContainer("Bag", 15, "BagJunk", filters.bagJunk)
		AddNewContainer("Bag", 14, "BagFeature", filters.bagFeature)
		AddNewContainer("Bag", 13, "BagCollection", filters.bagCollection)
		AddNewContainer("Bag", 12, "BagBoN", filters.bagBoN)
		AddNewContainer("Bag", 11, "BagConsumable", filters.bagConsumable)
		AddNewContainer("Bag", 10, "BagAuE", filters.bagAuE)
		AddNewContainer("Bag", 9, "BagLegendary", filters.bagLegendary)
		AddNewContainer("Bag", 8, "BagEquipSet", filters.bagEquipSet)
		AddNewContainer("Bag", 7, "BagEquipment", filters.bagEquipment)
		AddNewContainer("Bag", 6, "BagReagent", filters.onlyBagReagent)

		f.main = MyContainer:New("Bag", {Bags = "bags", BagType = "Bag"})
		f.main.__anchor = {"BOTTOMRIGHT", -100, 150}
		f.main:SetPoint(unpack(f.main.__anchor))
		f.main:SetFilter(filters.onlyBags, true)

		AddBankFilter("Bank")

		f.bank = MyContainer:New("Bank", {Bags = "bank", BagType = "Bank"})
		f.bank.__anchor = {"BOTTOMLEFT", 50, 100}
		f.bank:SetPoint(unpack(f.bank.__anchor))
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:Hide()

		AddBankFilter("Account")

		f.accountbank = MyContainer:New("Account", {Bags = "accountbank", BagType = "Account"})
		f.accountbank:SetFilter(filters.accountbank, true)
		f.accountbank:SetPoint(unpack(f.bank.__anchor))
		f.accountbank:Hide()

		for bagType, groups in pairs(module.ContainerGroups) do
			for _, container in ipairs(groups) do
				local parent = Backpack.contByName[bagType]
				container:SetParent(parent)
				B.CreateMF(container, parent, true)
			end
		end
	end

	local initBagType
	function Backpack:OnBankOpened()
		BankFrame:Show()
		BankFrame.BankPanel:Show()

		if not initBagType then
			module:UpdateBagSize()
			initBagType = true
		end
	end

	function Backpack:OnBankClosed()
		BankFrame:Hide()
		BankFrame.BankPanel:Hide()

		self:GetContainer("Bank"):Hide()
		self:GetContainer("Account"):Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetSize(iconSize, iconSize)

		B.CleanTextures(self)
		B.CreateBD(self, .25)
		B.ReskinHLTex(self, self)

		self.Icon:SetInside()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.Count:SetPoint("BOTTOMRIGHT", -1, 0)
		self.Count:SetJustifyH("RIGHT")
		B.SetFontSize(self.Count, C.db["Bags"]["FontSize"])
		self.Cooldown:SetInside()
		self.IconOverlay:SetInside()
		self.IconOverlay2:SetInside()
		self.Favourite = self:CreateTexture(nil, "OVERLAY")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(30, 30)
		self.Favourite:SetPoint("TOPRIGHT", 8, 4)

		self.QuestTag = B.CreateFS(self, 30, "!", "system", "LEFT", 3, 0)
		self.iLvl = B.CreateFS(self, C.db["Bags"]["FontSize"], "", false, "BOTTOMLEFT", 1, 0)
		self.iSlot = B.CreateFS(self, C.db["Bags"]["FontSize"], "", false, "TOPRIGHT", 0, -2)
		self.glowFrame = B.CreateGlowFrame(self)

		self.TierOverlay = self:CreateTexture(nil, "OVERLAY")
		self.TierOverlay:SetPoint("TOPLEFT", -1, 2)
		self.TierOverlay:SetAtlas(nil)

		self:HookScript("OnClick", module.ButtonOnClick)

		if hasCanIMogIt then
			self.canIMogIt = self:CreateTexture(nil, "OVERLAY")
			self.canIMogIt:SetSize(13, 13)
			self.canIMogIt:SetPoint(unpack(CanIMogIt.ICON_LOCATIONS[CanIMogItOptions["iconLocation"]]))
		end
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame then
			B.HideOverlayGlow(self.glowFrame)
			C_NewItems.RemoveNewItem(self.bagId, self.slotId)
		end
	end

	local function GetIconOverlayAtlas(item)
		if not item.link then return end

		if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.link) then
			return "AzeriteIconFrame"
		elseif C_Item.IsCosmeticItem(item.link) then
			return "CosmeticIconFrame"
		elseif C_Soulbinds.IsItemConduitByItemInfo(item.link) then
			return "ConduitIconFrame", "ConduitIconFrame-Corners"
		end
	end

	local function UpdateCanIMogIt(self, item)
		if not self.canIMogIt then return end

		local text, unmodifiedText = CanIMogIt:GetTooltipText(nil, item.bagId, item.slotId)
		if text and text ~= "" then
			local icon = CanIMogIt.tooltipOverlayIcons[unmodifiedText]
			self.canIMogIt:SetTexture(icon)
			self.canIMogIt:Show()
		else
			self.canIMogIt:Hide()
		end
	end

	local function UpdatePawnArrow(self, item)
		if not hasPawn then return end
		if not PawnIsContainerItemAnUpgrade then return end

		if self.UpgradeIcon then
			self.UpgradeIcon:SetShown(PawnIsContainerItemAnUpgrade(item.bagId, item.slotId))
		end
	end

	function MyButton:OnUpdateButton(item)
		if self.JunkIcon then
			if item.hasPrice and not module:IsSpecialJunk(item.id) and (item.quality == Enum.ItemQuality.Poor or NDuiADB["CustomJunkList"][item.id]) then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		self.TierOverlay:SetAtlas(nil)
		local itemTier = item.link and C_TradeSkillUI.GetItemReagentQualityByItemInfo(item.link)
		if itemTier then
			self.TierOverlay:SetAtlas(format("Professions-Icon-Quality-Tier%d-Inv", itemTier), true)
		end

		self.IconOverlay:SetVertexColor(1, 1, 1)
		self.IconOverlay:SetAtlas(nil)
		self.IconOverlay2:SetAtlas(nil)
		self.IconOverlay:Hide()
		self.IconOverlay2:Hide()
		local atlas, secondAtlas = GetIconOverlayAtlas(item)
		if atlas then
			self.IconOverlay:SetAtlas(atlas)
			self.IconOverlay:Show()
			if secondAtlas then
				local r, g, b = C_Item.GetItemQualityColor(item.quality)
				self.IconOverlay:SetVertexColor(r, g, b)
				self.IconOverlay2:SetAtlas(secondAtlas)
				self.IconOverlay2:Show()
			end
		end

		if C.db["Bags"]["CustomItems"][item.id] and not C.db["Bags"]["ItemFilter"] then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		self.iLvl:SetText("")
		self.iSlot:SetText("")
		self.iLvl:SetTextColor(1, 1, 1)
		self.iSlot:SetTextColor(1, 1, 1)
		if item.link and (item.quality and item.quality > 0) or (item.id and DB.SpecialJunk[item.id]) then
			local r, g, b = C_Item.GetItemQualityColor(item.quality)
			local slot = B.GetItemType(item.link, item.bagId ~= -1 and item.bagId, item.slotId)
			local level = item.level or item.ilvl
			if not level then level = "" end

			self.iLvl:SetText(level)
			self.iSlot:SetText(slot)

			if module:IsSpecialJunk(item.id) then
				self.iLvl:SetTextColor(DB.r, DB.g, DB.b)
				self.iSlot:SetTextColor(DB.r, DB.g, DB.b)
			elseif NDuiADB["CustomJunkList"][item.id] then
				self.iLvl:SetTextColor(.5, .5, .5)
				self.iSlot:SetTextColor(.5, .5, .5)
			end
		end

		if self.glowFrame then
			if C_NewItems.IsNewItem(item.bagId, item.slotId) then
				B.ShowOverlayGlow(self.glowFrame)
			else
				B.HideOverlayGlow(self.glowFrame)
			end
		end

		-- Hide empty tooltip
		if not item.texture and GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end

		-- Support CanIMogIt
		UpdateCanIMogIt(self, item)

		-- Support Pawn
		UpdatePawnArrow(self, item)
	end

	function MyButton:OnUpdateQuest(item)
		if item.questID and not item.questActive then
			self.QuestTag:Show()
		else
			self.QuestTag:Hide()
		end

		if item.questID or item.isQuestItem then
			self:SetBackdropBorderColor(1, 1, 0)
		elseif item.quality and item.quality > -1 then
			local r, g, b = C_Item.GetItemQualityColor(item.quality)
			self:SetBackdropBorderColor(r, g, b)
		else
			B.SetBorderColor(self)
		end
	end

	function module:UpdateAllAnchors()
		module:UpdateBagsAnchor(f.main, module.ContainerGroups["Bag"])
		module:UpdateBankAnchor(f.bank, module.ContainerGroups["Bank"])
		module:UpdateBankAnchor(f.accountbank, module.ContainerGroups["Account"])
	end

	function module:GetContainerColumns(bagType)
		if bagType == "Bag" then
			return C.db["Bags"]["BagsWidth"]
		else
			return C.db["Bags"]["BankWidth"]
		end
	end

	function MyContainer:OnContentsChanged(gridOnly)
		self:SortButtons("bagSlot")

		local columns = module:GetContainerColumns(self.Settings.BagType)
		local offset = 36
		local spacing = DB.margin
		local xOffset = DB.margin*2
		local yOffset = -offset + xOffset
		local _, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		local width = columns * (iconSize+spacing)-spacing
		if self.freeSlot then
			if C.db["Bags"]["GatherEmpty"] then
				local numSlots = #self.buttons + 1
				local row = math.ceil(numSlots / columns)
				local col = numSlots % columns
				if col == 0 then col = columns end
				local xPos = (col-1) * (iconSize + spacing)
				local yPos = -1 * (row-1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos+xOffset, yPos+yOffset)
				self.freeSlot:Show()

				if height < 0 then
					height = iconSize
				elseif col == 1 then
					height = height + iconSize + spacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(width + xOffset*2, height + offset)

		if not gridOnly then
			module:UpdateAllAnchors()
		end
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		B.CreateBG(self)
		if settings.Bags then
			B.CreateMF(self, nil, true)
		end

		self.iconSize = iconSize
		module.CreateFreeSlots(self)

		local label
		if string.match(name, "Equipment") then
			label = BAG_FILTER_EQUIPMENT
		elseif string.match(name, "EquipSet") then
			label = EQUIPMENT_MANAGER
		elseif string.match(name, "Legendary") then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif string.match(name, "Consumable") then
			label = BAG_FILTER_CONSUMABLES
		elseif string.match(name, "Tradegoods") then
			label = BAG_FILTER_REAGENTS
		elseif string.match(name, "Junk") then
			label = BAG_FILTER_JUNK
		elseif string.match(name, "Collection") then
			label = COLLECTIONS
		elseif string.match(name, "Custom%d") then
			label = GetCustomGroupTitle(settings.Index)
		elseif string.match(name, "Feature") then
			label = FEATURES_LABEL
		elseif string.match(name, "AuE") then
			label = ITEM_ACCOUNTBOUND_UNTIL_EQUIP
		elseif string.match(name, "BoN") then
			label = L["BoN Item"]
		elseif string.match(name, "BagReagent") then
			label = SPECIAL..BAGSLOT
		end
		if label then
			self.label = B.CreateFS(self, 14, label, true, "TOPLEFT", 5, -9)
			return
		end

		module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = module.CreateCloseButton(self, f)
		buttons[2] = module.CreateSortButton(self, name)
		if name == "Bag" then
			module.CreateBagBar(self, settings, 5)
			buttons[3] = module.CreateBagToggle(self)
			buttons[4] = module.CreateSplitButton(self)
			buttons[5] = module.CreateFavouriteButton(self)
			buttons[6] = module.CreateJunkButton(self)
			buttons[7] = module.CreateDeleteButton(self)
		elseif name == "Bank" then
			module.CreateBagTab(self, settings, 6)
			buttons[3] = module.CreateBagToggle(self)
			buttons[4] = module.CreateBankDeposit(self)
			buttons[5] = module.CreateAccountBankButton(self, f)
		elseif name == "Account" then
			module.CreateBagTab(self, settings, 5, "account")
			buttons[3] = module.CreateBagToggle(self)
			buttons[4] = module.CreateAccountBankDeposit(self)
			buttons[5] = module.CreateBankButton(self, f)
			buttons[6] = module.CreateAccountMoney(self)
		end

		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu then break end
			if i == 1 then
				bu:SetPoint("TOPRIGHT", -(DB.margin*2), -(DB.margin*2))
			else
				bu:SetPoint("RIGHT", buttons[i-1], "LEFT", -DB.margin, 0)
			end
		end
		self.widgetButtons = buttons

		if name == "Bag" then module.CreateCollapseArrow(self) end

		self:HookScript("OnShow", B.RestoreMF)
	end

	local function updateBagSize(button)
		button:SetSize(iconSize, iconSize)
		if button.glowFrame then
			button.glowFrame:SetOutside(button, 3, 3)
		end
		B.SetFontSize(button.Count, C.db["Bags"]["FontSize"])
		B.SetFontSize(button.iLvl, C.db["Bags"]["FontSize"])
	end

	function module:UpdateBagSize()
		iconSize = C.db["Bags"]["IconSize"]
		for _, container in pairs(Backpack.contByName) do
			container:ApplyToButtons(updateBagSize)
			if container.freeSlot then
				container.freeSlot:SetSize(iconSize, iconSize)
				B.SetFontSize(container.freeSlot.tag, C.db["Bags"]["FontSize"]+2)
			end
			if container.BagBar then
				for _, bagButton in pairs(container.BagBar.buttons) do
					bagButton:SetSize(iconSize, iconSize)
				end
				container.BagBar:UpdateAnchor()
			end
			container:OnContentsChanged(true)
		end
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetSize(iconSize, iconSize)

		B.CleanTextures(self)
		B.CreateBD(self, .25)
		B.ReskinHLTex(self, self)

		self.Icon:SetInside()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
	end

	function BagButton:OnUpdateButton()
		B.SetBorderColor(self)

		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not id then return end
		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = C_Item.GetItemInfo(id)
		if not quality or quality == 1 then quality = 0 end
		local r, g, b = C_Item.GetItemQualityColor(quality)
		if not self.hidden and not self.notBought then
			self:SetBackdropBorderColor(r, g, b)
		end

		if classID == Enum.ItemClass.Container then
			module.BagsType[self.bagId] = subClassID or 0
		else
			module.BagsType[self.bagId] = 0
		end
	end

	-- Sort order
	C_Container.SetSortBagsRightToLeft(C.db["Bags"]["BagSortMode"] == 1)
	C_Container.SetInsertItemsLeftToRight(false)

	-- Init
	C.db["Bags"]["GatherEmpty"] = not C.db["Bags"]["GatherEmpty"]
	ToggleAllBags()
	C.db["Bags"]["GatherEmpty"] = not C.db["Bags"]["GatherEmpty"]
	ToggleAllBags()
	module.initComplete = true

	B:RegisterEvent("TRADE_SHOW", module.OpenBags)
	B:RegisterEvent("TRADE_CLOSED", module.CloseBags)

	-- Update infobar slots
	local INFO = B:GetModule("Infobar")
	if INFO and INFO.modules then
		for _, info in pairs(INFO.modules) do
			if info.name == "Gold" then
				Backpack.OnOpen = function()
					if not NDuiADB["ShowSlots"] then return end
					info:onEvent()
				end
				break
			end
		end
	end

	-- Fixes
	local passedSystems = {
		["TutorialReagentBag"] = true,
	}
	hooksecurefunc(HelpTip, "Show", function(self, _, info)
		if info and passedSystems[info.system] then
			self:HideAllSystem(info.system)
		end
	end)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, true)

	SetCVar("professionToolSlotsExampleShown", 1)
	SetCVar("professionAccessorySlotsExampleShown", 1)

	-- Bank frame paging
	hooksecurefunc(BankFrame.BankPanel, "SetBankType", function(self, bankType)
		module.Bags:GetContainer("Bank"):SetShown(bankType == CHAR_BANK_TYPE)
		module.Bags:GetContainer("Account"):SetShown(bankType == ACCOUNT_BANK_TYPE)
		module:UpdateAllBags()
		if _G["NDui_BankPurchaseButton"] then
			_G["NDui_BankPurchaseButton"]:SetShown(bankType == ACCOUNT_BANK_TYPE and C_Bank.CanPurchaseBankTab(ACCOUNT_BANK_TYPE))
		end
	end)

	-- Delay updates for data jam
	local updater = CreateFrame("Frame", nil, f.main)
	updater:Hide()
	updater:SetScript("OnUpdate", function(self, elapsed)
		self.delay = self.delay - elapsed
		if self.delay < 0 then
			module:UpdateAllBags()
			self:Hide()
		end
	end)

	B:RegisterEvent("GET_ITEM_INFO_RECEIVED", function()
		if module.Bags and module.Bags:IsShown() then
			updater.delay = 1
			updater:Show()
		end
	end)
end