
-------------------------------------
-- 小队或团队 装备等级
-- Author: M
-------------------------------------
local B, C, L, DB = unpack(NDui)

local LibEvent = LibStub:GetLibrary("LibEvent.7000")
local LibSchedule = LibStub:GetLibrary("LibSchedule.7000")

local members, numMembers = {}, 0

--是否觀察完畢
local function InspectDone()
	for guid, v in pairs(members) do
		if (not v.done) then
			return false
		end
	end
	return true
end

--人員信息 @trigger GROUP_MEMBER_CHANGED
local function GetMembers(num, unitprefix)
	local unit, guid
	local temp = {}
	for i = 1, num do
		unit = unitprefix .. i
		guid = UnitGUID(unit)
		if (guid) then temp[guid] = unit end
	end
	for guid, v in pairs(members) do
		if (not temp[guid]) then
			members[guid] = nil
		end
	end
	for guid, unit in pairs(temp) do
		if (members[guid]) then
			members[guid].unit = unit
			members[guid].class = select(2, UnitClass(unit))
			members[guid].role  = UnitGroupRolesAssigned(unit)
			members[guid].done  = GetInspectInfo(unit, 0, true)
		else
			members[guid] = {
				done   = false,
				guid   = guid,
				unit   = unit,
				class  = select(2, UnitClass(unit)),
				role   = UnitGroupRolesAssigned(unit),
				ilevel = -1,
			}
		end
		members[guid].name, members[guid].realm = UnitName(unit)
		if (not members[guid].realm) then
			members[guid].realm = GetRealmName()
		end
	end
	LibEvent:trigger("GROUP_MEMBER_CHANGED", members)
end

--觀察 @trigger GROUP_MEMBER_INSPECT_STARTED
local function SendInspect(unit)
	if (GetInspecting()) then return end
	if (unit and UnitIsVisible(unit) and CanInspect(unit)) then
		ClearInspectPlayer()
		NotifyInspect(unit)
		LibEvent:trigger("GROUP_MEMBER_INSPECT_STARTED", members[UnitGUID(unit)])
		return
	end
	for guid, v in pairs(members) do
		if ((not v.done or v.ilevel <= 0) and UnitIsVisible(v.unit) and CanInspect(v.unit)) then
			ClearInspectPlayer()
			NotifyInspect(v.unit)
			LibEvent:trigger("GROUP_MEMBER_INSPECT_STARTED", v)
			return v
		end
	end
end

local SendAddonMessage = C_ChatInfo and C_ChatInfo.SendAddonMessage or function() end

--发送自己的信息
local function SendPlayerInfo(channel)
	local ilvl = select(2, GetAverageItemLevel()) or -1
	local spec = select(2, GetSpecializationInfo(GetSpecialization())) or ""
	local class = select(2,UnitClass("player")) or ""

	SendAddonMessage("TinyInspect", format("%s|%s|%s|%s", "LV", ilvl, spec, class), channel)
end

--解析发送的信息 @trigger GROUP_MEMBER_INSPECT_READY
LibEvent:attachEvent("CHAT_MSG_ADDON", function(self, prefix, text, channel, sender)
	if (prefix == "TinyInspect") then
		local flag, ilvl, spec, class = string.split("|", text)
		if (flag ~= "LV") then return end
		local name, realm = string.split("-", sender)
		for guid, v in pairs(members) do
			if (v.name == name and v.realm == realm) then
				v.ilevel = tonumber(ilvl) or -1
				v.done = true
				if (class and class ~= "") then v.class = class end
				if (spec and spec ~= "") then v.spec = spec end
				LibEvent:trigger("GROUP_MEMBER_INSPECT_READY", v)
			end
		end
	end
end)

--@see InspectCore.lua @trigger RAID_INSPECT_READY
LibEvent:attachTrigger("UNIT_INSPECT_READY", function(self, data)
	local member = members[data.guid]
	if (member) then
		member.role = UnitGroupRolesAssigned(data.unit)
		member.ilevel = data.ilevel
		member.spec = data.spec
		member.name = data.name
		member.class = data.class
		member.realm = data.realm
		member.done = true
		LibEvent:trigger("GROUP_MEMBER_INSPECT_READY", member)
	end
end)

--人員增加時觸發 @trigger GROUP_MEMBER_INSPECT_TIMEOUT @trigger GROUP_MEMBER_INSPECT_DONE
LibEvent:attachEvent("GROUP_ROSTER_UPDATE", function(self)
	local unitprefix = (IsInRaid() and "raid") or "party"
	local numCurrent = (IsInRaid() and GetNumGroupMembers()) or GetNumSubgroupMembers()

	if (numCurrent ~= numMembers) then
		GetMembers(numCurrent, unitprefix)
		members[UnitGUID("player")] = {
			name   = UnitName("player"),
			class  = select(2, UnitClass("player")),
			ilevel = select(2, GetAverageItemLevel()),
			done   = true,
			unit   = "player",
			spec   = select(2, GetSpecializationInfo(GetSpecialization())),
		}
		SendPlayerInfo(unitprefix)
		LibSchedule:AddTask({
			override  = true,
			identity  = "InspectGroupMember",
			timer     = 1,
			elasped   = 1,
			begined   = GetTime() + 2,
			expired   = GetTime() + (unitprefix == "party" and 30 or 900),
			onTimeout = function(self) LibEvent:trigger("GROUP_MEMBER_INSPECT_TIMEOUT", members) end,
			onExecute = function(self)
				if (not IsInGroup()) then return true end
				if (InspectDone()) then
					LibEvent:trigger("GROUP_MEMBER_INSPECT_DONE", members)
					return true
				end
				SendInspect()
			end,
		})
	end
	numMembers = numCurrent

	if IsInGroup() then
		if not TinyInspectiLvlFrame:IsShown() then
			TinyInspectiLvlFrame:Show()
		end
	else
		if TinyInspectiLvlFrame:IsShown() then
			TinyInspectiLvlFrame:Hide()
		end
	end
end)

LibEvent:attachEvent("VARIABLES_LOADED", function()
	LibEvent:event("GROUP_ROSTER_UPDATE")
end)

----------------
-- 界面處理
----------------

local memberslist = {}

local frame = CreateFrame("Frame", "TinyInspectiLvlFrame", UIParent)
frame:SetPoint("TOP", 0, -100)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:SetSize(120, 22)
frame:Hide()

frame.sortOn = true
frame.sortWay = "DESC"

frame.label = CreateFrame("Button", nil, frame)
frame.label:SetAlpha(0.9)
frame.label:SetPoint("TOPLEFT")
frame.label:SetPoint("BOTTOMRIGHT")
frame.label:RegisterForDrag("LeftButton")
frame.label:SetHitRectInsets(0, 0, 0, 0)
frame.label:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)
frame.label:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
frame.label:SetScript("OnClick", function(self)
	local parent = self:GetParent()
	if (parent.panel:IsShown()) then
		parent.panel:Hide()
		parent:SetWidth(120)
		parent:SetAlpha(0.8)
		self:SetHitRectInsets(0, 0, 0, 0)
	else
		parent.panel:Show()
		parent:SetWidth(230)
		parent:SetAlpha(1.0)
		self:SetHitRectInsets(72, 32, 0, 0)
	end
end)
frame.label.text = B.CreateFS(frame.label, 13, ITEM_LEVEL_ABBR, true)
frame.label.progress = CreateFrame("StatusBar", nil, frame.label)
frame.label.progress:SetFrameLevel(frame.label:GetFrameLevel())
frame.label.progress:SetStatusBarTexture(DB.normTex)
frame.label.progress:SetStatusBarColor(0.1, 0.9, 0.1)
frame.label.progress:SetMinMaxValues(0, 100)
frame.label.progress:SetValue(0)
frame.label.progress:SetAlpha(0.5)

--創建條目
local function GetButton(parent, index)
	if (not parent["button"..index]) then
		local button = CreateFrame("Button", nil, parent)
		button:SetHighlightTexture("Interface\\Buttons\\UI-ListBox-Highlight", "ADD")
		button:SetID(index)
		button:SetHeight(16)
		button:SetWidth(224)
		if (index == 1) then
			button:SetPoint("TOPLEFT", parent, "TOPLEFT", 3, -22)
		else
			button:SetPoint("TOP", parent["button"..(index-1)], "BOTTOM", 0, 0)
		end
		button.bg = button:CreateTexture(nil, "BORDER")
		button.bg:SetAtlas("UI-Character-Info-Line-Bounce")
		button.bg:SetPoint("TOPLEFT", 0, 2)
		button.bg:SetPoint("BOTTOMRIGHT", 0, -3)
		button.bg:SetAlpha(0.2)
		button.bg:SetShown(index%2~=0)

		button.role = button:CreateTexture(nil, "ARTWORK")
		button.role:SetSize(14, 14)
		button.role:SetPoint("LEFT", 6, 0)
		button.role:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")

		button.ilevel = B.CreateFS(button, 13, "", false, "LEFT", 18, -1)
		button.ilevel:SetSize(50, 13)
		button.ilevel:SetJustifyH("CENTER")
		button.ilevel:SetTextColor(1, 0.8, 0)

		button.name = B.CreateFS(button, 13, "", false, "LEFT", 66, -1)
		button.name:SetJustifyH("LEFT")

		button.spec = B.CreateFS(button, 11, "", false, "RIGHT", -8, 0)
		button.spec:SetJustifyH("RIGHT")
		button.spec:SetTextColor(0.8, 0.9, 0.9)
		button:SetScript("OnDoubleClick", function(self)
			local ilevel = self.ilevel:GetText()
			local name = self.name:GetText()
			local spec = self.spec:GetText()
			if (ilevel and tonumber(ilevel)) then
				ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
				ChatEdit_InsertLink(ilevel.." "..name.." "..spec)
			end
		end)
		parent["button"..index] = button
	end
	return parent["button"..index]
end

--進度
local function UpdateProgress(num, total)
	local value = ceil(num*100/max(1,total))
	frame.label.progress:SetValue(value)
	frame.label.progress:SetStatusBarColor(0.5-value/200, value/100, 0)
end

--導表並顯示進度
local function MakeMembersList()
	local num, total = 0, 0
	for k, _ in pairs(memberslist) do
		memberslist[k] = nil
	end
	for _, v in pairs(members) do
		table.insert(memberslist, v)
		if (v.done) then num = num + 1 end
		total = total + 1
	end
	UpdateProgress(num, total)
end

--顯示
local function ShowMembersList()
	local i = 1
	local button, role, r, g, b
	for _, v in pairs(memberslist) do
		button = GetButton(frame.panel, i)
		button.guid = v.guid
		role = v.role or UnitGroupRolesAssigned(v.unit)
		r, g, b = GetClassColor(v.class)
		if (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
			button.role:SetAtlas(GetMicroIconForRole(role))
			button.role:Show()
		else
			button.role:Hide()
		end
		button.ilevel:SetText(v.ilevel > 0 and format("%.1f",v.ilevel) or " - ")
		button.name:SetText(v.name)
		button.name:SetTextColor(r, g, b)
		button.spec:SetText(v.spec and v.spec or " - ")
		button:Show()
		i = i + 1
	end
	if (i > 25) then
		frame.panel:SetHeight(424+(i-1-25) * 16)
	else
		frame.panel:SetHeight(max(106,424-15-(25-i)*16))
	end
	while (frame.panel["button"..i]) do
		frame.panel["button"..i]:Hide()
		i = i + 1
	end
end

--排序並顯示
local function SortAndShowMembersList()
	if (not frame.panel:IsShown()) then return end
	if (frame.sortOn) then
		table.sort(memberslist, function(a, b)
			if (frame.sortWay == "ASC") then
				return a.ilevel < b.ilevel
			else
				return a.ilevel > b.ilevel
			end
		end)
	end
	ShowMembersList()
end

--團友列表
frame.panel = CreateFrame("Frame", nil, frame)
frame.panel:SetScript("OnShow", function(self) SortAndShowMembersList() end)
frame.panel:SetPoint("TOP", frame, "BOTTOM", 0, -1)
frame.panel:SetSize(230, 106)
frame.panel:Hide()

--排序按鈕
local function sortOnClick(self)
	local text = self.text
	if frame.sortWay == "DESC" then
		frame.sortWay = "ASC"
	else
		frame.sortWay = "DESC"
	end
	self.sortCount = (self.sortCount or 0) + 1
	if self.sortCount%3 == 0 then
		frame.sortOn = false
		text:SetText("升序")
	else
		frame.sortOn = true
		text:SetText("降序")
	end
	SortAndShowMembersList()
end

--重新掃描按鈕
local function rescanOnClick(self)
	self:SetAlpha(0.3)
	LibSchedule:AddTask({
		identity  = "InspectRescanGroupMember",
		elasped   = 4,
		onTimeout = function() self:SetAlpha(1) end,
		onStart = function()
			if (not IsInGroup()) then
				return GetMembers(0)
			end
			for _, v in pairs(members) do
				v.done = false
			end
			LibEvent:event("GROUP_ROSTER_UPDATE")
		end,
	})
end

--團友變更或觀察到數據時更新顯示
LibEvent:attachTrigger("GROUP_MEMBER_CHANGED, GROUP_MEMBER_INSPECT_TIMEOUT, GROUP_MEMBER_INSPECT_READY, GROUP_MEMBER_INSPECT_DONE", function(self)
	MakeMembersList()
	SortAndShowMembersList()
end)

--高亮正在讀取的人員
LibEvent:attachTrigger("GROUP_MEMBER_INSPECT_STARTED", function(self, data)
	if (not frame.panel:IsShown()) then return end
	local i = 1
	local button
	while (frame.panel["button"..i]) do
		button = frame.panel["button"..i]
		if (button.guid == data.guid) then
			button.ilevel:SetText("|cff22ff22...|r")
			break
		end
		i = i + 1
	end
end)

--初始化美化API
LibEvent:attachEvent("PLAYER_LOGIN", function()
	B.SetBD(frame)
	B.SetBD(frame.panel)

	frame.label.progress:SetPoint("TOPLEFT", C.mult, -C.mult)
	frame.label.progress:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)

	frame.panel.sortButton = B.CreateButton(frame.panel, 34, 16, "升序", 12)
	frame.panel.sortButton:SetPoint("TOPRIGHT", -10, -4)
	frame.panel.sortButton:SetScript("OnClick", sortOnClick)

	frame.panel.rescanButton = B.CreateButton(frame.panel, 34, 16, "扫描", 12)
	frame.panel.rescanButton:SetPoint("TOPLEFT", 10, -4)
	frame.panel.rescanButton:SetScript("OnClick", rescanOnClick)
end)