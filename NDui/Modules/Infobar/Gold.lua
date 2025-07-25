﻿local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Gold then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Gold", C.Infobar.GoldPos)

local slotString = L["Bags"]..": %s%d"
local profit, spent, oldMoney = 0, 0, 0
local myName, myRealm = DB.MyName, DB.MyRealm
myRealm = string.gsub(myRealm, "%s", "") -- fix for multi words realm name

StaticPopupDialogs["RESETGOLD"] = {
	text = L["Are you sure to reset the gold count?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		table.wipe(NDuiADB["totalGold"])
		if not NDuiADB["totalGold"][myRealm] then NDuiADB["totalGold"][myRealm] = {} end
		NDuiADB["totalGold"][myRealm][myName] = {GetMoney(), DB.MyClass}
	end,
	whileDead = 1,
}

local menuList = {
	{text = B.HexRGB(1, 1, 0)..REMOVE_WORLD_MARKERS.."!!!", notCheckable = true, func = function() StaticPopup_Show("RESETGOLD") end},
}

local function getClassIcon(class)
	local tL, tR, tT, tB = unpack(CLASS_ICON_TCOORDS[class])
	tL, tR, tT, tB = math.floor((tL+.025)*64), math.ceil((tR-.025)*64), math.floor((tT+.025+0.025)*64), math.ceil((tB-.025-0.025)*64)
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:12:18:0:1:64:64:"..tL..":"..tR..":"..tT..":"..tB.."|t "
	return classStr or ""
end

local function getSlotString()
	local num = CalculateTotalNumberOfFreeBagSlots()
	if num < 10 then
		return format(slotString, "|cffFF0000", num)
	else
		return format(slotString, "|cff00FF00", num)
	end
end

info.eventList = {
	"ACCOUNT_MONEY",
	"CHAT_MSG_MONEY",
	"PLAYER_MONEY",
	"PLAYER_TRADE_MONEY",
	"SEND_MAIL_COD_CHANGED",
	"SEND_MAIL_MONEY_CHANGED",
	"TRADE_MONEY_CHANGED",
}

info.onEvent = function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		oldMoney = GetMoney()
		self:UnregisterEvent(event)

		if NDuiADB["ShowSlots"] then
			self:RegisterEvent("BAG_UPDATE")
		end
	elseif event == "BAG_UPDATE" then
		if arg1 < 0 or arg1 > 4 then return end
	end

	local newMoney = GetMoney()
	local change = newMoney - oldMoney	-- Positive if we gain money
	if oldMoney > newMoney then			-- Lost Money
		spent = spent - change
	else								-- Gained Moeny
		profit = profit + change
	end
	if NDuiADB["ShowSlots"] then
		self.text:SetText(getSlotString())
	else
		self.text:SetText(module:GetMoneyString(newMoney, true))
	end

	if not NDuiADB["totalGold"][myRealm] then NDuiADB["totalGold"][myRealm] = {} end
	if not NDuiADB["totalGold"][myRealm][myName] then NDuiADB["totalGold"][myRealm][myName] = {} end
	NDuiADB["totalGold"][myRealm][myName][1] = GetMoney()
	NDuiADB["totalGold"][myRealm][myName][2] = DB.MyClass

	oldMoney = newMoney
end

local RebuildCharList

local function clearCharGold(_, realm, name)
	NDuiADB["totalGold"][realm][name] = nil
	DropDownList1:Hide()
	RebuildCharList()
end

function RebuildCharList()
	for i = 2, #menuList do
		if menuList[i] then table.wipe(menuList[i]) end
	end

	local index = 1
	for realm, data in pairs(NDuiADB["totalGold"]) do
		for name, value in pairs(data) do
			if not (realm == myRealm and name == myName) then
				index = index + 1
				if not menuList[index] then menuList[index] = {} end
				menuList[index].text = B.HexRGB(B.ClassColor(value[2]))..Ambiguate(name.."-"..realm, "none")
				menuList[index].notCheckable = true
				menuList[index].arg1 = realm
				menuList[index].arg2 = name
				menuList[index].func = clearCharGold
			end
		end
	end
end

info.onMouseUp = function(self, btn)
	if btn == "RightButton" then
		if IsControlKeyDown() then
			if not menuList[1].created then
				RebuildCharList()
				menuList[1].created = true
			end
			EasyMenu(menuList, B.EasyMenu, self, -80, 100, "MENU", 1)
		else
			NDuiADB["ShowSlots"] = not NDuiADB["ShowSlots"]
			if NDuiADB["ShowSlots"] then
				self:RegisterEvent("BAG_UPDATE")
			else
				self:UnregisterEvent("BAG_UPDATE")
			end
			self:onEvent()
		end
	elseif btn == "MiddleButton" then
		NDuiADB["AutoSell"] = not NDuiADB["AutoSell"]
		self:onEnter()
	else
		if NDuiADB["ShowSlots"] then
			ToggleAllBags()
		else
			if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
			ToggleCharacter("TokenFrame")
		end
	end
end

local title

info.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CURRENCY, 0,1,1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(L["Session"], 0,1,1)
	GameTooltip:AddDoubleLine(L["Earned"], module:GetMoneyString(profit), 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(L["Spent"], module:GetMoneyString(spent), 1,1,1, 1,1,1)
	if profit < spent then
		GameTooltip:AddDoubleLine(L["Deficit"], module:GetMoneyString(spent-profit), 1,0,0, 1,1,1)
	elseif profit > spent then
		GameTooltip:AddDoubleLine(L["Profit"], module:GetMoneyString(profit-spent), 0,1,0, 1,1,1)
	end
	GameTooltip:AddLine(" ")

	local totalGold = 0
	GameTooltip:AddLine(L["RealmCharacter"], 0,1,1)

	if NDuiADB["totalGold"][myRealm] then
		for k, v in pairs(NDuiADB["totalGold"][myRealm]) do
			local name = Ambiguate(k.."-"..myRealm, "none")
			local gold, class = unpack(v)
			local r, g, b = B.ClassColor(class)
			GameTooltip:AddDoubleLine(getClassIcon(class)..name, module:GetMoneyString(gold, true), r,g,b, 1,1,1)
			totalGold = totalGold + gold
		end
	end

	for realm, data in pairs(NDuiADB["totalGold"]) do
		if realm ~= myRealm then
			for k, v in pairs(data) do
				local gold, class = unpack(v)
				local name = Ambiguate(k.."-"..realm, "none")
				local r, g, b = B.ClassColor(class)
				GameTooltip:AddDoubleLine(getClassIcon(class)..name, module:GetMoneyString(gold, true), r,g,b, 1,1,1)
				totalGold = totalGold + gold
			end
		end
	end

	local accountmoney = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(CHARACTER..":", module:GetMoneyString(totalGold, true), 0,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(ACCOUNT_BANK_PANEL_TITLE..":", module:GetMoneyString(accountmoney, true), 0,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(TOTAL..":", module:GetMoneyString(totalGold + accountmoney, true), 0,1,1, 1,1,1)

	title = false
	local chargeInfo = C_CurrencyInfo.GetCurrencyInfo(3116) -- Tier charges
	if chargeInfo then
		if not title then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(CURRENCY..":", 0,1,1)
			title = true
		end
		local r, g, b = B.SmoothColor(chargeInfo.quantity, chargeInfo.maxQuantity)
		local iconTexture = " |T"..chargeInfo.iconFileID..":12:18:0:1:64:64:5:59:16:48|t"
		GameTooltip:AddDoubleLine(chargeInfo.name, chargeInfo.quantity.." / "..chargeInfo.maxQuantity..iconTexture, 1,1,1, r,g,b)
	end

	for i = 1, 10 do -- seems unlimit, but use 10 for now, needs review
		local currencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
		if not currencyInfo then break end
		local name, count, icon, currencyID = currencyInfo.name, currencyInfo.quantity, currencyInfo.iconFileID, currencyInfo.currencyTypesID
		if name and count then
			if not title then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(CURRENCY..":", 0,1,1)
				title = true
			end
			local total = C_CurrencyInfo.GetCurrencyInfo(currencyID).maxQuantity
			local iconTexture = " |T"..icon..":12:18:0:1:64:64:5:59:16:48|t"
			if total > 0 then
				local r, g, b = B.SmoothColor(count, total)
				GameTooltip:AddDoubleLine(name, count.." / "..total..iconTexture, 1,1,1, r,g,b)
			else
				GameTooltip:AddDoubleLine(name, count..iconTexture, 1,1,1, 1,1,1)
			end
		end
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Switch Mode"].." ", 1,1,1, 0,1,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["AutoSell Junk"]..": "..(NDuiADB["AutoSell"] and DB.EnableString or DB.DisableString).." ", 1,1,1, 0,1,1)
	GameTooltip:AddDoubleLine(" ", "CTRL +"..DB.RightButton..L["Reset Gold"].." ", 1,1,1, 0,1,1)
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

-- Auto selljunk
local stop, cache = true, {}
local errorText = _G.ERR_VENDOR_DOESNT_BUY
local BAG = B:GetModule("Bags")

local function startSelling()
	if stop then return end
	for bag = 0, 5 do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			if stop then return end
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.hyperlink and (not info.hasNoValue) and (not cache["b"..bag.."s"..slot]) and (not BAG:IsSpecialJunk(info.itemID)) then
				if (info.quality and info.quality <= 0) or NDuiADB["CustomJunkList"][info.itemID] then
					cache["b"..bag.."s"..slot] = true
					C_Container.UseContainerItem(bag, slot)
					C_Timer.After(.15, startSelling)
					return
				end
			end
		end
	end
end

local function updateSelling(event, ...)
	if not NDuiADB["AutoSell"] then return end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then return end
		stop = false
		table.wipe(cache)
		startSelling()
		B:RegisterEvent("UI_ERROR_MESSAGE", updateSelling)
	elseif event == "UI_ERROR_MESSAGE" and arg == errorText or event == "MERCHANT_CLOSED" then
		stop = true
	end
end
B:RegisterEvent("MERCHANT_SHOW", updateSelling)
B:RegisterEvent("MERCHANT_CLOSED", updateSelling)