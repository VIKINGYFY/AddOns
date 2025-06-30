local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

function M:RaidTool_Visibility(frame)
	if IsInGroup() then
		frame:Show()
	else
		frame:Hide()
	end
end

function M:RaidTool_Header()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:SetSize(120, 28)
	frame:SetFrameLevel(2)
	B.ReskinMenuButton(frame)
	B.Mover(frame, L["Raid Tool"], "RaidManager", C.Skins.RMPos)

	M:RaidTool_Visibility(frame)
	B:RegisterEvent("GROUP_ROSTER_UPDATE", function()
		M:RaidTool_Visibility(frame)
	end)

	frame:RegisterForClicks("AnyDown")
	frame:SetScript("OnClick", function(self, btn)
		if btn == "LeftButton" then
			local menu = self.menu
			B:TogglePanel(menu)

			if menu:IsShown() then
				menu:ClearAllPoints()
				if M:IsFrameOnTop(self) then
					menu:SetPoint("TOP", self, "BOTTOM", 0, -DB.margin)
				else
					menu:SetPoint("BOTTOM", self, "TOP", 0, DB.margin)
				end

				self.buttons[2].text:SetText(IsInRaid() and CONVERT_TO_PARTY or CONVERT_TO_RAID)
			end
		else
			SendChatMessage(format(L["BR Text"], self.resFrame.Count:GetText(), self.resFrame.Timer:GetText()), B.GetMSGChannel())
		end
	end)
	frame:SetScript("OnDoubleClick", function(_, btn)
		if btn == "RightButton" and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
			C_PartyInfo.LeaveParty()
		end
	end)
	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Raid Tool"], 0,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(DB.LeftButton..DB.InfoColor..ACCESSIBILITY_LABEL)
		GameTooltip:AddDoubleLine(DB.RightButton..DB.InfoColor..L["BR Send"])
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", B.HideTooltip)

	return frame
end

function M:IsFrameOnTop(frame)
	local y = select(2, frame:GetCenter())
	local screenHeight = UIParent:GetTop()
	return y > screenHeight/2
end

function M:GetRaidMaxGroup()
	local instanceName, instanceType, difficultyID, difficultyName, maxPlayers = GetInstanceInfo()
	if instanceType == "none" and IsInRaid() then
		return 8
	elseif instanceType == "none" then
		return 1
	else
		return maxPlayers / 5
	end
end

function M:RaidTool_RoleCount(parent)
	local roleIndex = {"TANK", "HEALER", "DAMAGER"}

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	local role = {}
	for i = 1, 3 do
		role[i] = frame:CreateTexture(nil, "OVERLAY")
		role[i]:SetPoint("LEFT", 36*i-30, 0)
		role[i]:SetSize(15, 15)
		B.ReskinSmallRole(role[i], roleIndex[i])
		role[i].text = B.CreateFS(frame, 13, "0")
		role[i].text:ClearAllPoints()
		role[i].text:SetPoint("CENTER", role[i], "RIGHT", 12, 0)
	end

	local raidCounts = {
		totalTANK = 0,
		totalHEALER = 0,
		totalDAMAGER = 0
	}

	local function updateRoleCount()
		for k in pairs(raidCounts) do
			raidCounts[k] = 0
		end

		local maxgroup = M:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= "NONE" then
				raidCounts["total"..assignedRole] = raidCounts["total"..assignedRole] + 1
			end
		end

		role[1].text:SetText(raidCounts.totalTANK)
		role[2].text:SetText(raidCounts.totalHEALER)
		role[3].text:SetText(raidCounts.totalDAMAGER)
	end

	local eventList = {
		"GROUP_ROSTER_UPDATE",
		"UPDATE_ACTIVE_BATTLEFIELD",
		"UNIT_FLAGS",
		"PLAYER_FLAGS_CHANGED",
		"PLAYER_ENTERING_WORLD",
	}
	for _, event in next, eventList do
		B:RegisterEvent(event, updateRoleCount)
	end

	parent.roleFrame = frame
end

function M:RaidTool_UpdateRes(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local chargeInfo = C_Spell.GetSpellCharges(20484)
		local charges = chargeInfo and chargeInfo.currentCharges
		local started = chargeInfo and chargeInfo.cooldownStartTime
		local duration = chargeInfo and chargeInfo.cooldownDuration

		if chargeInfo then
			local timer = duration - (GetTime() - started)
			if timer > 0 then
				self.Timer:SetFormattedText("%d:%.2d", timer/60, timer%60)
			end
			self.Count:SetText(charges)
			if charges == 0 then
				self.Name:SetTextColor(1, 0, 0)
				self.Count:SetTextColor(1, 0, 0)
				self.Timer:SetTextColor(1, 0, 0)
			else
				self.Name:SetTextColor(0, 1, 0)
				self.Count:SetTextColor(0, 1, 0)
				self.Timer:SetTextColor(0, 1, 0)
			end
			self.__owner.resFrame:SetAlpha(1)
			self.__owner.roleFrame:SetAlpha(0)
		else
			self.__owner.resFrame:SetAlpha(0)
			self.__owner.roleFrame:SetAlpha(1)
		end

		self.elapsed = 0
	end
end

function M:RaidTool_CombatRes(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	frame.__owner = parent

	frame.Name = B.CreateFS(frame, 16, C_Spell.GetSpellName(20484), false, "LEFT", 5, -1)
	frame.Timer = B.CreateFS(frame, 16, "--:--", false, "RIGHT", -5, -1)
	frame.Count = B.CreateFS(frame, 16, "--")
	frame.Count:ClearAllPoints()
	frame.Count:SetPoint("LEFT", frame.Name, "RIGHT", 5, 0)

	frame:SetScript("OnUpdate", M.RaidTool_UpdateRes)

	parent.resFrame = frame
end

function M:RaidTool_ReadyCheck(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOP", parent, "BOTTOM", 0, -DB.margin)
	frame:SetSize(120, 50)
	frame:Hide()
	frame:SetScript("OnMouseUp", function(self) self:Hide() end)
	B.SetBD(frame)
	B.CreateFS(frame, 14, READY_CHECK, true, "TOP", 0, -8)
	local rc = B.CreateFS(frame, 14, "", false, "BOTTOM", 0, 8)

	local count, total
	local function hideRCFrame()
		frame:Hide()
		rc:SetText("")
		count, total = 0, 0
	end

	local function updateReadyCheck(event)
		if event == "READY_CHECK_FINISHED" then
			if count == total then
				rc:SetTextColor(0, 1, 0)
			else
				rc:SetTextColor(1, 0, 0)
			end
			C_Timer.After(5, hideRCFrame)
		else
			count, total = 0, 0

			frame:ClearAllPoints()
			if M:IsFrameOnTop(parent) then
				frame:SetPoint("TOP", parent, "BOTTOM", 0, -DB.margin)
			else
				frame:SetPoint("BOTTOM", parent, "TOP", 0, DB.margin)
			end
			frame:Show()

			local maxgroup = M:GetRaidMaxGroup()
			for i = 1, GetNumGroupMembers() do
				local name, _, subgroup, _, _, _, _, online = GetRaidRosterInfo(i)
				if name and online and subgroup <= maxgroup then
					total = total + 1
					local status = GetReadyCheckStatus(name)
					if status and status == "ready" then
						count = count + 1
					end
				end
			end
			rc:SetText(count.." / "..total)
			if count == total then
				rc:SetTextColor(0, 1, 0)
			else
				rc:SetTextColor(1, 1, 0)
			end
		end
	end
	B:RegisterEvent("READY_CHECK", updateReadyCheck)
	B:RegisterEvent("READY_CHECK_CONFIRM", updateReadyCheck)
	B:RegisterEvent("READY_CHECK_FINISHED", updateReadyCheck)
end

function M:RaidTool_BuffChecker(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetPoint("RIGHT", parent, "LEFT", -DB.margin, 0)
	frame:SetSize(28, 28)
	B.ReskinMenuButton(frame)

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetOutside(nil, 5, 5)
	icon:SetAtlas("GM-icon-readyCheck")

	local BuffName = {L["Flask"], L["Food"], SPELL_STAT4_NAME, RAID_BUFF_2, RAID_BUFF_3, RUNES}
	local NoBuff, numGroups, numPlayer = {}, 6, 0
	for i = 1, numGroups do NoBuff[i] = {} end

	local function sendMsg(text)
		if DB.isDeveloper then
			print(text)
		else
			SendChatMessage(text, B.GetMSGChannel())
		end
	end

	local function sendResult(i)
		local count = #NoBuff[i]
		if count > 0 then
			if count >= numPlayer then
				sendMsg(L["Lack"]..BuffName[i]..": "..ALL..PLAYER)
			elseif count >= 5 and i > 2 then
				sendMsg(L["Lack"]..BuffName[i]..": "..format(L["Player Count"], count))
			else
				local str = L["Lack"]..BuffName[i]..": "
				for j = 1, count do
					str = str..NoBuff[i][j]..(j < #NoBuff[i] and ", " or "")
					if #str > 230 then
						sendMsg(str)
						str = ""
					end
				end
				sendMsg(str)
			end
		end
	end

	local function scanBuff()
		for i = 1, numGroups do table.wipe(NoBuff[i]) end
		numPlayer = 0

		local maxgroup = M:GetRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead then
				numPlayer = numPlayer + 1
				for j = 1, numGroups do
					local HasBuff
					local buffTable = DB.BuffList[j]
					for k = 1, #buffTable do
						local buffName = C_Spell.GetSpellName(buffTable[k])
						if buffName and C_UnitAuras.GetAuraDataBySpellName(name, buffName) then
							HasBuff = true
							break
						end
					end
					if not HasBuff then
						name = string.split("-", name)	-- remove realm name
						table.insert(NoBuff[j], name)
					end
				end
			end
		end
		if not C.db["Misc"]["RMRune"] then NoBuff[numGroups] = {} end

		if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 and #NoBuff[4] == 0 and #NoBuff[5] == 0 and #NoBuff[6] == 0 then
			sendMsg(L["Buffs Ready"])
		else
			sendMsg(L["Raid Buff Check"])
			for i = 1, 5 do sendResult(i) end
			if C.db["Misc"]["RMRune"] then sendResult(numGroups) end
		end
	end

	local potionCheck = C_AddOns.IsAddOnLoaded("MRT")

	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Raid Tool"], 0,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(DB.LeftButton..DB.InfoColor..L["Check Status"])
		if potionCheck then
			GameTooltip:AddDoubleLine(DB.RightButton..DB.InfoColor..L["MRT Potioncheck"])
		end
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", B.HideTooltip)

	local reset = true
	B:RegisterEvent("PLAYER_REGEN_ENABLED", function() reset = true end)

	frame:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			scanBuff()
		elseif potionCheck then
			SlashCmdList["mrtSlash"]("potionchat")
		end
	end)
end

function M:RaidTool_CountDown(parent)
	local frame = CreateFrame("Button", nil, parent)
	frame:SetPoint("LEFT", parent, "RIGHT", DB.margin, 0)
	frame:SetSize(28, 28)
	B.ReskinMenuButton(frame)

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetOutside(nil, 5, 5)
	icon:SetAtlas("GM-icon-countdown")

	frame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L["Raid Tool"], 0,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(DB.LeftButton..DB.InfoColor..READY_CHECK)
		GameTooltip:AddDoubleLine(DB.RightButton..DB.InfoColor..L["Count Down"])
		GameTooltip:Show()
	end)
	frame:HookScript("OnLeave", B.HideTooltip)

	local reset = true
	B:RegisterEvent("PLAYER_REGEN_ENABLED", function() reset = true end)

	frame:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				DoReadyCheck()
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		else
			if IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				if reset then
					C_PartyInfo.DoCountdown(C.db["Misc"]["DBMCount"])
				else
					C_PartyInfo.DoCountdown(0)
				end
				reset = not reset
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end
	end)
end

function M:RaidTool_CreateMenu(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOP", parent, "BOTTOM", 0, -DB.margin)
	frame:SetSize(182, 70)
	B.SetBD(frame)
	frame:Hide()

	local function updateDelay(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > .1 then
			if not frame:IsMouseOver() then
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.elapsed = 0
		end
	end

	frame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", updateDelay)
	end)

	StaticPopupDialogs["Group_Disband"] = {
		text = L["Disband Info"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
			if IsInRaid() then
				SendChatMessage(L["Disband Process"], "RAID")
				for i = 1, GetNumGroupMembers() do
					local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
					if online and name ~= DB.MyName then
						UninviteUnit(name)
					end
				end
			else
				for i = MAX_PARTY_MEMBERS, 1, -1 do
					if UnitExists("party"..i) then
						UninviteUnit(UnitName("party"..i))
					end
				end
			end
			C_PartyInfo.LeaveParty()
		end,
		timeout = 0,
		whileDead = 1,
	}

	local buttons = {
		{TEAM_DISBAND, function()
			if UnitIsGroupLeader("player") then
				StaticPopup_Show("Group_Disband")
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{CONVERT_TO_RAID, function()
			if UnitIsGroupLeader("player") and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
				if IsInRaid() then C_PartyInfo.ConvertToParty() else C_PartyInfo.ConvertToRaid() end
				frame:Hide()
				frame:SetScript("OnUpdate", nil)
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{ROLE_POLL, function()
			if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
				InitiateRolePoll()
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{RAID_CONTROL, function() ToggleFriendsFrame(3) end},
	}

	local bu = {}
	local offset = DB.margin*2
	for i, j in pairs(buttons) do
		bu[i] = B.CreateButton(frame, 84, 28, j[1], 12)
		bu[i]:SetPoint(mod(i, 2) == 0 and "TOPRIGHT" or "TOPLEFT", mod(i, 2) == 0 and -offset or offset, i > 2 and -(offset*6) or -offset)
		bu[i]:SetScript("OnClick", j[2])
	end

	parent.menu = frame
	parent.buttons = bu
end

function M:RaidTool_EasyMarker()
	-- TODO: replace with the newest dropdown template
	local menuList = {}

	local function GetMenuTitle(text, ...)
		return (... and B.HexRGB(...) or "")..text
	end

	local function SetRaidTargetByIndex(_, arg1)
		SetRaidTarget("target", arg1)
	end

	local mixins = {
		UnitPopupRaidTarget8ButtonMixin,
		UnitPopupRaidTarget7ButtonMixin,
		UnitPopupRaidTarget6ButtonMixin,
		UnitPopupRaidTarget5ButtonMixin,
		UnitPopupRaidTarget4ButtonMixin,
		UnitPopupRaidTarget3ButtonMixin,
		UnitPopupRaidTarget2ButtonMixin,
		UnitPopupRaidTarget1ButtonMixin,
		UnitPopupRaidTargetNoneButtonMixin
	}
	for index, mixin in pairs(mixins) do
		local t1, t2, t3, t4 = mixin:GetTextureCoords()
		menuList[index] = {
			text = GetMenuTitle(mixin:GetText(), mixin:GetColor()),
			icon = mixin:GetIcon(),
			tCoordLeft = t1,
			tCoordRight = t2,
			tCoordTop = t3,
			tCoordBottom = t4,
			arg1 = 9 - index,
			func = SetRaidTargetByIndex,
		}
	end

	local function GetModifiedState()
		local index = C.db["Misc"]["EasyMarkKey"]
		if index == 1 then
			return IsControlKeyDown()
		elseif index == 2 then
			return IsAltKeyDown()
		elseif index == 3 then
			return IsShiftKeyDown()
		elseif index == 4 then
			return false
		end
	end

	WorldFrame:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" and GetModifiedState() and UnitExists("mouseover") then
			if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				local index = GetRaidTargetIndex("mouseover")
				for i = 1, 8 do
					local menu = menuList[i]
					if menu.arg1 == index then
						menu.checked = true
					else
						menu.checked = false
					end
				end
				EasyMenu(menuList, B.EasyMenu, "cursor", 0, 0, "MENU", 1)
			end
		end
	end)
end

function M:RaidTool_WorldMarker()
	local iconTexture = {
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
		"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
		"Interface\\Buttons\\UI-GroupLoot-Pass-Up",
	}

	local frame = CreateFrame("Frame", "NDui_WorldMarkers", UIParent)
	frame:SetPoint("RIGHT", -100, 0)
	B.CreateMF(frame, nil, true)
	B.RestoreMF(frame)
	B.SetBD(frame)
	frame.buttons = {}

	for i = 1, 9 do
		local button = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
		button:SetSize(28, 28)
		B.PixelIcon(button, iconTexture[i], true)
		button.Icon:SetTexture(iconTexture[i])

		if i ~= 9 then
			button:RegisterForClicks("AnyDown")
			button:SetAttribute("type", "macro")
			button:SetAttribute("macrotext1", format("/wm %d", i))
			button:SetAttribute("macrotext2", format("/cwm %d", i))
		else
			button:SetScript("OnClick", ClearRaidMarker)
		end
		frame.buttons[i] = button
	end

	M:RaidTool_UpdateGrid()
end

local markerTypeToRow = {
	[1] = 3,
	[2] = 9,
	[3] = 1,
	[4] = 3,
}
function M:RaidTool_UpdateGrid()
	local frame = _G["NDui_WorldMarkers"]
	if not frame then return end

	local size, margin = C.db["Misc"]["MarkerSize"], DB.margin
	local showType = C.db["Misc"]["ShowMarkerBar"]
	local perRow = markerTypeToRow[showType]

	for i = 1, 9 do
		local button = frame.buttons[i]
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", frame, margin, -margin)
		elseif mod(i-1, perRow) == 0 then
			button:SetPoint("TOP", frame.buttons[i-perRow], "BOTTOM", 0, -margin)
		else
			button:SetPoint("LEFT", frame.buttons[i-1], "RIGHT", margin, 0)
		end
	end

	local column = math.min(9, perRow)
	local rows = math.ceil(9/perRow)
	frame:SetWidth(column*size + (column-1)*margin + 2*margin)
	frame:SetHeight(size*rows + (rows-1)*margin + 2*margin)
	frame:SetShown(showType ~= 4)
end

function M:RaidTool_Misc()
	-- UIWidget reanchor
	if not UIWidgetTopCenterContainerFrame:IsMovable() then -- can be movable for some addons, eg BattleInfo
		UIWidgetTopCenterContainerFrame:ClearAllPoints()
		UIWidgetTopCenterContainerFrame:SetPoint("TOP", 0, -35)
	end
end

function M:RaidTool_Init()
	if not C.db["Misc"]["RaidTool"] then return end

	local frame = M:RaidTool_Header()
	M:RaidTool_RoleCount(frame)
	M:RaidTool_CombatRes(frame)
	M:RaidTool_ReadyCheck(frame)
	M:RaidTool_BuffChecker(frame)
	M:RaidTool_CreateMenu(frame)
	M:RaidTool_CountDown(frame)

	M:RaidTool_EasyMarker()
	M:RaidTool_WorldMarker()
	M:RaidTool_Misc()
end
M:RegisterMisc("RaidTool", M.RaidTool_Init)