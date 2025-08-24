local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Durability then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Dura", C.Infobar.DurabilityPos)

local repairCostString = string.gsub(REPAIR_COST, HEADER_COLON, ":")
local lowDurabilityCap = 25
local needToRepair

local localSlots = {
	[1] = {1, INVTYPE_HEAD, 1000},
	[2] = {3, INVTYPE_SHOULDER, 1000},
	[3] = {5, INVTYPE_CHEST, 1000},
	[4] = {6, INVTYPE_WAIST, 1000},
	[5] = {7, INVTYPE_LEGS, 1000},
	[6] = {8, INVTYPE_FEET, 1000},
	[7] = {9, INVTYPE_WRIST, 1000},
	[8] = {10, INVTYPE_HAND, 1000},
	[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
	[10] = {17, INVTYPE_WEAPONOFFHAND, 1000}
}

local function hideAlertWhileCombat()
	if InCombatLockdown() then
		info:RegisterEvent("PLAYER_REGEN_ENABLED")
		info:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	end
end

local lowDurabilityInfo = {
	text = L["Low Durability"],
	buttonStyle = HelpTip.ButtonStyle.Okay,
	targetPoint = HelpTip.Point.TopEdgeCenter,
	onAcknowledgeCallback = hideAlertWhileCombat,
	offsetY = 10,
}

local function sortSlots(a, b)
	if a and b then
		return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
	end
end

local function UpdateAllSlots()
	local numSlots = 0
	for i = 1, 10 do
		localSlots[i][3] = 1000
		local index = localSlots[i][1]
		if GetInventoryItemLink("player", index) then
			local current, maximum = GetInventoryItemDurability(index)
			if current then
				localSlots[i][3] = tonumber(current/maximum*100)
				numSlots = numSlots + 1
			end
			local iconTexture = GetInventoryItemTexture("player", index) or 134400
			localSlots[i][4] = "|T"..iconTexture..":12:18:0:1:64:64:5:59:16:48|t " or ""
		end
	end
	table.sort(localSlots, sortSlots)

	return numSlots
end

local function isLowDurability()
	for i = 1, 10 do
		if localSlots[i][3] < lowDurabilityCap then
			return true
		end
	end
end

info.eventList = {
	"UPDATE_INVENTORY_DURABILITY",
}

info.onEvent = function(self, event)
	if UpdateAllSlots() > 0 then
		self.text:SetFormattedText("%s%s", B.ColorPerc(localSlots[1][3], true), DURABILITY)
	else
		self.text:SetFormattedText("%s%s", DB.MyColor..NONE.."|r", DURABILITY)
	end

	if isLowDurability() then
		HelpTip:Show(info, lowDurabilityInfo)
		needToRepair = true
	else
		HelpTip:Hide(info, L["Low Durability"])
		needToRepair = false
	end
end

info.onMouseUp = function(self, btn)
	if btn == "MiddleButton" then
		NDuiADB["RepairType"] = (NDuiADB["RepairType"] + 1) % 3
		self:onEnter()
	else
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleCharacter("PaperDollFrame")
	end
end

local repairlist = {
	[0] = DB.DisableString,
	[1] = DB.EnableString,
	[2] = "|cffFFFF00"..L["NFG"].."|r"
}

info.onEnter = function(self)
	local total, equipped = GetAverageItemLevel()
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(DURABILITY, format("%.1f / %.1f", equipped, total), 0,1,1, 0,1,1)
	GameTooltip:AddLine(" ")

	local totalCost = 0
	for i = 1, 10 do
		if localSlots[i][3] < 1000 then
			local r, g, b = B.SmoothColor(localSlots[i][3], 100, true)
			GameTooltip:AddDoubleLine(localSlots[i][4]..localSlots[i][2], B.Perc(localSlots[i][3]), 1,1,1, r,g,b)

			local slot = localSlots[i][1]
			local data = C_TooltipInfo.GetInventoryItem("player", slot)
			if data and data.repairCost then
				totalCost = totalCost + data.repairCost
			end
		end
	end

	if totalCost > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(repairCostString, module:GetMoneyString(totalCost), 0,1,1, 1,1,1)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Player Panel"].." ", 1,1,1, 0,1,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..L["Auto Repair"]..": "..repairlist[NDuiADB["RepairType"]].." ", 1,1,1, 0,1,1)
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

-- Auto repair
local isShown, isBankEmpty, autoRepair, repairAllCost, canRepair

local function delayFunc()
	if isBankEmpty then
		autoRepair(true)
	else
		print(format("%s: %s", DB.InfoColor..L["Guild repair"].."|r", module:GetMoneyString(repairAllCost)))
	end
end

function autoRepair(override)
	if isShown and not override then return end
	isShown = true
	isBankEmpty = false

	local myMoney = GetMoney()
	repairAllCost, canRepair = GetRepairAllCost()

	if canRepair and repairAllCost > 0 then
		if (not override) and NDuiADB["RepairType"] == 1 and IsInGuild() and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= repairAllCost then
			RepairAllItems(true)
		else
			if myMoney > repairAllCost then
				RepairAllItems()
				print(format("%s: %s", DB.InfoColor..L["Repair cost"].."|r", module:GetMoneyString(repairAllCost)))
				return
			else
				print(DB.InfoColor..L["Repair error"])
				return
			end
		end

		C_Timer.After(.5, delayFunc)
	end
end

local function checkBankFund(_, msgType)
	if msgType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		isBankEmpty = true
	end
end

local function merchantClose()
	isShown = false
	B:UnregisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	B:UnregisterEvent("MERCHANT_CLOSED", merchantClose)
end

local autoRepairInfo = {
	text = L["AutoRepairInfo"],
	buttonStyle = HelpTip.ButtonStyle.GotIt,
	targetPoint = HelpTip.Point.RightEdgeCenter,
	onAcknowledgeCallback = B.HelpInfoAcknowledge,
	callbackArg = "AutoRepair",
}

local function merchantShow()
	if not NDuiADB["Help"]["AutoRepair"] then
		HelpTip:Show(MerchantFrame, autoRepairInfo)
	end

	if IsShiftKeyDown() or NDuiADB["RepairType"] == 0 or not CanMerchantRepair() then return end
	autoRepair()
	B:RegisterEvent("UI_ERROR_MESSAGE", checkBankFund)
	B:RegisterEvent("MERCHANT_CLOSED", merchantClose)
end
B:RegisterEvent("MERCHANT_SHOW", merchantShow)

local repairGossipIDs = {
	[37005] = true, -- 基维斯
	[44982] = true, -- 里弗斯
}
B:RegisterEvent("GOSSIP_SHOW", function()
	if IsShiftKeyDown() then return end
	if not needToRepair then return end

	local options = C_GossipInfo.GetOptions()
	for i = 1, #options do
		local option = options[i]
		if repairGossipIDs[option.gossipOptionID] then
			C_GossipInfo.SelectOption(option.gossipOptionID)
		end
	end
end)