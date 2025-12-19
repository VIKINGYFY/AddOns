
-------------------------------------
-- 小队或团队 装备等级 Author: M
-------------------------------------
local B, C, L, DB = unpack(NDui)

local LibEvent = LibStub:GetLibrary("LibEvent-NDui-MOD")
local LibSchedule = LibStub:GetLibrary("LibSchedule-NDui-MOD")

local members, numMembers = {}, 0
local membersList = {}

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
local function GetMembers(numCurrent, unitPrefix)
	local unit, guid
	local temp = {}
	for i = 1, numCurrent do
		unit = unitPrefix .. i
		guid = UnitGUID(unit)
		if (guid) and not UnitInPartyIsAI(unit) then temp[guid] = unit end
	end
	for guid, v in pairs(members) do
		if (not temp[guid] and v.unit ~= "player") then
			members[guid] = nil
		end
	end
	for guid, unit in pairs(temp) do
		local class = select(2, UnitClass(unit))
		local role = UnitGroupRolesAssigned(unit)
		local done = GetInspectInfo(unit, 0, true)
		if (members[guid]) then
			members[guid].done = done
			members[guid].unit = unit
			members[guid].class = class
			members[guid].role = role
		else
			members[guid] = {
				done = false,
				unit = unit,
				class = class,
				role = role,
				guid = guid,
				ilvl = -1,
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
		if ((not v.done or v.ilvl <= 0) and UnitIsVisible(v.unit) and CanInspect(v.unit)) then
			ClearInspectPlayer()
			NotifyInspect(v.unit)
			LibEvent:trigger("GROUP_MEMBER_INSPECT_STARTED", v)
			return v
		end
	end
end

--发送自己的信息
local function SendPlayerInfo(channel)
	local class = select(2, UnitClass("player")) or ""
	local ilvl = select(2, GetAverageItemLevel()) or -1
	local spec = select(2, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())) or ""
	local role = select(5, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())) or ""

	C_ChatInfo.SendAddonMessage("TinyInspect", format("%s|%s|%s|%s|%s", "LV", class, ilvl, spec, role), channel)
end

--解析发送的信息 @trigger GROUP_MEMBER_INSPECT_READY
LibEvent:attachEvent("CHAT_MSG_ADDON", function(self, prefix, text, channel, sender)
	if (prefix == "TinyInspect") then
		local flag, ilvl, spec, class, role = string.split("|", text)
		if (flag ~= "LV") then return end
		local name, realm = string.split("-", sender)
		for guid, v in pairs(members) do
			if (v.name == name and v.realm == realm) then
				v.class = class and class or ""
				v.ilvl = ilvl and tonumber(ilvl) or -1
				v.spec = spec and spec or ""
				v.role = role and role or ""
				v.done = true
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
		member.ilvl = data.ilevel
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
	local unitPrefix = (IsInRaid() and "raid") or "party"
	local numCurrent = (IsInRaid() and GetNumGroupMembers()) or GetNumSubgroupMembers()

	if (numCurrent ~= numMembers) then
		members[UnitGUID("player")] = {
			done = true,
			unit = "player",
			name = UnitName("player"),
			class = select(2, UnitClass("player")),
			ilvl = select(2, GetAverageItemLevel()),
			spec = select(2, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())),
			role = select(5, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())),
		}
		GetMembers(numCurrent, unitPrefix)
		SendPlayerInfo(unitPrefix)
		LibSchedule:AddTask({
			override = true,
			identity = "InspectGroupMember",
			timer = 1,
			elasped = 1,
			begined = GetTime() + 2,
			expired = GetTime() + (unitPrefix == "party" and 30 or 900),
			onTimeout = function(self)
				LibEvent:trigger("GROUP_MEMBER_INSPECT_TIMEOUT", members)
			end,
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
		if not NDui_iLvlFrame:IsShown() then
			NDui_iLvlFrame:Show()
		end
	else
		if NDui_iLvlFrame:IsShown() then
			NDui_iLvlFrame:Hide()
		end
	end
end)

LibEvent:attachEvent("PLAYER_LOGIN", function()
	LibEvent:event("GROUP_ROSTER_UPDATE")
end)

----------------
-- 界面處理
----------------

local frame = CreateFrame("Frame", "NDui_iLvlFrame", UIParent)
frame:SetPoint("TOP", 0, -100)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:SetSize(120, 22)
frame:Hide()

frame.label = CreateFrame("Button", nil, frame)
frame.label:SetAllPoints()
frame.label:RegisterForDrag("LeftButton")
frame.label:SetHitRectInsets(0, 0, 0, 0)
frame.label:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)
frame.label:SetScript("OnDragStart", function(self) self:GetParent():StartMoving() end)
frame.label:SetScript("OnClick", function(self)
	local parent = self:GetParent()
	if (parent.panel:IsShown()) then
		parent.panel:Hide()
		parent:SetWidth(120)
	else
		parent.panel:Show()
		parent:SetWidth(240)
	end
end)
frame.label.text = B.CreateFS(frame.label, 14, ITEM_LEVEL_ABBR, true)
frame.label.progress = CreateFrame("StatusBar", nil, frame.label)
frame.label.progress:SetInside()
frame.label.progress:SetFrameLevel(frame.label:GetFrameLevel())
frame.label.progress:SetStatusBarTexture(DB.normTex)
frame.label.progress:SetStatusBarColor(0, 1, 0)
frame.label.progress:SetMinMaxValues(0, 100)
frame.label.progress:SetValue(0)
frame.label.progress:SetAlpha(0.5)

--進度
local function UpdateProgress(numCurrent, numTotal)
	local value = math.ceil(numCurrent*100 / math.max(1, numTotal))
	frame.label.progress:SetValue(value)
	frame.label.progress:SetStatusBarColor(0.5-value / 200, value / 100, 0)
end

--創建條目
local function GetButton(parent, index)
	if (not parent["button"..index]) then
		local button = CreateFrame("Button", nil, parent)
		button:SetHighlightTexture("Interface\\Buttons\\UI-ListBox-Highlight", "ADD")
		button:SetID(index)
		button:SetHeight(18)
		button:SetWidth(240)

		if (index == 1) then
			button:SetPoint("TOP", parent, "TOP", 0, 0)
		else
			button:SetPoint("TOP", parent["button"..(index-1)], "BOTTOM", 0, 0)
		end

		button.bg = button:CreateTexture(nil, "BORDER")
		button.bg:SetAtlas("UI-Character-Info-Line-Bounce")
		button.bg:SetPoint("TOPLEFT", 0, 2)
		button.bg:SetPoint("BOTTOMRIGHT", 0, -2)
		button.bg:SetAlpha(0.2)
		button.bg:SetShown(index%2~=0)

		button.role = button:CreateTexture(nil, "ARTWORK")
		button.role:SetSize(14, 14)
		button.role:SetPoint("LEFT", 6, -1)

		button.ilvl = B.CreateFS(button, 14, "", false, "LEFT", 24, -1)
		button.name = B.CreateFS(button, 14, "", false, "LEFT", 68, -1)
		button.spec = B.CreateFS(button, 14, "", false, "RIGHT", -6, -1)

		button:SetScript("OnDoubleClick", function(self)
			local ilvl = self.ilvl:GetText()
			local name = self.name:GetText()
			local spec = self.spec:GetText()
			if ilvl then
				ChatFrameUtil.OpenChat(ilvl.." "..name.." "..spec)
			end
		end)
		parent["button"..index] = button
	end
	return parent["button"..index]
end

--導表並顯示進度
local function MakeMembersList()
	local numCurrent, numTotal = 0, 0
	for k, _ in pairs(membersList) do
		membersList[k] = nil
	end
	for _, v in pairs(members) do
		table.insert(membersList, v)
		if (v.done) then numCurrent = numCurrent + 1 end
		numTotal = numTotal + 1
	end
	UpdateProgress(numCurrent, numTotal)
end

local roles = {
	["TANK"] = true,
	["HEALER"] = true,
	["DAMAGER"] = true,
}

--顯示
local function ShowMembersList()
	local i = 1
	local button, r, g, b
	local role = select(5, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization()))
	for _, v in pairs(membersList) do
		r, g, b = B.ClassColor(v.class)

		button = GetButton(frame.panel, i)
		button.guid = v.guid
		button.name:SetText(v.name)
		button.name:SetTextColor(r, g, b)
		button.spec:SetText(v.spec and v.spec or " - ")
		button.ilvl:SetText(v.ilvl > 0 and format("%.1f", v.ilvl) or " - ")
		button.role:SetAtlas(GetMicroIconForRole(roles[v.role] and v.role or role))
		button:Show()
		i = i + 1
	end

	frame.panel:SetHeight((i - 1) * 18)
	while (frame.panel["button"..i]) do
		frame.panel["button"..i]:Hide()
		i = i + 1
	end
end

--排序並顯示
local function SortAndShowMembersList()
	if (not frame.panel:IsShown()) then return end
	table.sort(membersList, function(a, b)
		return a.ilvl > b.ilvl
	end)
	ShowMembersList()
end

--團友列表
frame.panel = CreateFrame("Frame", nil, frame)
frame.panel:SetScript("OnShow", function(self) SortAndShowMembersList() end)
frame.panel:SetPoint("TOP", frame, "BOTTOM", 0, -DB.margin)
frame.panel:SetSize(240, 110)
frame.panel:Hide()

--團友變更或觀察到數據時更新顯示
LibEvent:attachTrigger("GROUP_MEMBER_CHANGED, GROUP_MEMBER_INSPECT_STARTED, GROUP_MEMBER_INSPECT_TIMEOUT, GROUP_MEMBER_INSPECT_READY, GROUP_MEMBER_INSPECT_DONE", function(self)
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
			button.ilvl:SetText("|cff00FF00...|r")
			break
		end
		i = i + 1
	end
end)

--初始化
LibEvent:attachEvent("PLAYER_LOGIN", function()
	B.SetBD(frame)
	B.SetBD(frame.panel)

	members[UnitGUID("player")] = {
		done = true,
		unit = "player",
		name = UnitName("player"),
		class = select(2, UnitClass("player")),
		ilvl = select(2, GetAverageItemLevel()),
		spec = select(2, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())),
		role = select(5, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())),
	}

	MakeMembersList()
	SortAndShowMembersList()
end)