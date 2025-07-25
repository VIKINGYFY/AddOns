local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Guild then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Guild", C.Infobar.GuildPos)

info.guildTable = {}
local cr, cg, cb = DB.r, DB.g, DB.b
local infoFrame, gName, gOnline, gRank, prevTime

local function rosterButtonOnClick(self, btn)
	local name = info.guildTable[self.index][3]
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			C_PartyInfo.InviteUnit(name)
		elseif IsShiftKeyDown() then
			if MailFrame:IsShown() then
				MailFrameTab_OnClick(nil, 2)
				SendMailNameEditBox:SetText(name)
				SendMailNameEditBox:HighlightText()
			else
				ChatFrame_OpenChat(name)
			end
		end
	else
		ChatFrame_SendTell(name)
	end
end

function info:GuildPanel_CreateButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(305, 20)
	button:SetPoint("TOPLEFT", 0, - (index-1) *20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(cr, cg, cb, .25)

	button.level = B.CreateFS(button, 13, "Level")
	button.level:SetPoint("TOP", button, "TOPLEFT", 16, -4)
	button.class = button:CreateTexture(nil, "ARTWORK")
	button.class:SetPoint("LEFT", 36, 0)
	button.class:SetSize(16, 16)
	button.class:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
	button.name = B.CreateFS(button, 13, "Name", false, "LEFT", 65, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 185, 0)
	button.zone = B.CreateFS(button, 13, "Zone", false, "RIGHT", -2, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -120, 0)

	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", rosterButtonOnClick)

	return button
end

function info:GuildPanel_UpdateButton(button)
	local index = button.index
	local level, class, name, zone, status, guid = unpack(info.guildTable[index])

	local levelcolor = B.HexRGB(GetCreatureDifficultyColor(level))
	button.level:SetFormattedText("%s%s|r", levelcolor, level)

	B.ClassIconTexCoord(button.class, class)

	local namecolor = B.HexRGB(B.ClassColor(class))
	local isTimerunning = guid and C_ChatInfo.IsTimerunningPlayer(guid)
	local playerName = isTimerunning and TimerunningUtil.AddSmallIcon(name) or name
	button.name:SetFormattedText("%s%s%s|r", namecolor, playerName, status)

	local zonecolor = DB.GreyColor
	if UnitInRaid(name) or UnitInParty(name) then
		zonecolor = DB.InfoColor
	elseif GetAreaText() == zone then
		zonecolor = DB.GreenColor
	end
	button.zone:SetFormattedText("%s%s|r", zonecolor, zone)
end

function info:GuildPanel_Update()
	local scrollFrame = NDuiGuildInfobarScrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numMemberButtons = infoFrame.numMembers
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numMemberButtons then
			button.index = index
			info:GuildPanel_UpdateButton(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, numMemberButtons*height, usedHeight)
end

function info:GuildPanel_OnMouseWheel(delta)
	local scrollBar = self.scrollBar
	local step = delta*self.buttonHeight
	if IsShiftKeyDown() then
		step = step*15
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	info:GuildPanel_Update()
end

local function sortRosters(a, b)
	if a and b then
		if NDuiADB["GuildSortOrder"] then
			return a[NDuiADB["GuildSortBy"]] < b[NDuiADB["GuildSortBy"]]
		else
			return a[NDuiADB["GuildSortBy"]] > b[NDuiADB["GuildSortBy"]]
		end
	end
end

function info:GuildPanel_SortUpdate()
	table.sort(info.guildTable, sortRosters)
	info:GuildPanel_Update()
end

local function sortHeaderOnClick(self)
	NDuiADB["GuildSortBy"] = self.index
	NDuiADB["GuildSortOrder"] = not NDuiADB["GuildSortOrder"]
	info:GuildPanel_SortUpdate()
end

local function isPanelCanHide(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > .1 then
		if not infoFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function updateInfoFrameAnchor(frame)
	local relFrom, relTo, offset = module:GetTooltipAnchor(info)
	frame:ClearAllPoints()
	frame:SetPoint(relFrom, info, relTo, 0, offset)
end

function info:GuildPanel_Init()
	if infoFrame then
		infoFrame:Show()
		updateInfoFrameAnchor(infoFrame)
		return
	end

	infoFrame = CreateFrame("Frame", "NDuiGuildInfobar", info)
	infoFrame:SetSize(335, 495)
	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("HIGH")
	updateInfoFrameAnchor(infoFrame)
	B.SetBD(infoFrame)

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)

	gName = B.CreateFS(infoFrame, 16, "Guild", "info", "TOPLEFT", 15, -10)
	gRank = B.CreateFS(infoFrame, 14, "Rank", "info", "TOPLEFT", 15, -40)
	gOnline = B.CreateFS(infoFrame, 14, "Online", "info", "TOPRIGHT", -15, -40)

	local bu = {}
	local width = {30, 36, 126, 126}
	for i = 1, 4 do
		bu[i] = CreateFrame("Button", nil, infoFrame)
		bu[i]:SetSize(width[i], 22)
		if i == 1 then
			bu[i]:SetPoint("TOPLEFT", gRank, "BOTTOMLEFT", -10, -10)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", -3, 0)
		end
		bu[i].HL = bu[i]:CreateTexture(nil, "HIGHLIGHT")
		bu[i].HL:SetAllPoints(bu[i])
		bu[i].HL:SetColorTexture(cr, cg, cb, .25)
		bu[i].index = i
		bu[i]:SetScript("OnClick", sortHeaderOnClick)
	end
	B.CreateFS(bu[1], 13, LEVEL_ABBR)
	B.CreateFS(bu[2], 13, CLASS_ABBR)
	B.CreateFS(bu[3], 13, NAME, false, "LEFT", 5, 0)
	B.CreateFS(bu[4], 13, ZONE, false, "RIGHT", -5, 0)

	B.CreateFS(infoFrame, 13, DB.LineString, false, "BOTTOMRIGHT", -12, 58)
	B.CreateFS(infoFrame, 13, DB.RightButton..L["Whisper"], "info", "BOTTOMRIGHT", -15, 42)
	B.CreateFS(infoFrame, 13, "ALT +"..DB.LeftButton..L["Invite"], "info", "BOTTOMRIGHT", -15, 26)
	B.CreateFS(infoFrame, 13, "SHIFT +"..DB.LeftButton..L["Copy Name"], "info", "BOTTOMRIGHT", -15, 10)

	local scrollFrame = CreateFrame("ScrollFrame", "NDuiGuildInfobarScrollFrame", infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(305, 330)
	scrollFrame:SetPoint("TOPLEFT", bu[1], "BOTTOMLEFT", 1, -3)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	B.ReskinScroll(scrollBar)
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 16 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = info:GuildPanel_CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = info.GuildPanel_Update
	scrollFrame:SetScript("OnMouseWheel", info.GuildPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)
end

C_Timer.After(5, function()
	if IsInGuild() then C_GuildInfo.GuildRoster() end
end)

function info:GuildPanel_Refresh()
	local thisTime = GetTime()
	if not prevTime or (thisTime-prevTime > 5) then
		C_GuildInfo.GuildRoster()
		prevTime = thisTime
	end

	table.wipe(info.guildTable)
	local count = 0
	local total, numOnline, allOnline = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")

	gName:SetFormattedText("<%s>", guildName)
	gOnline:SetFormattedText("%s: %d / %d", GUILD_ONLINE_LABEL, (allOnline or numOnline), total)
	gRank:SetFormattedText("%s: %s", RANK, (guildRank or ""))

	for i = 1, total do
		local name, _, _, level, _, zone, _, _, connected, status, class, _, _, mobile, _, _, guid = GetGuildRosterInfo(i)
		if connected or mobile then
			if mobile and not connected then
				zone = REMOTE_CHAT
				if status == 1 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t"
				elseif status == 2 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t"
				else
					status = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
				end
			else
				if status == 1 then
					status = DB.AFKTex
				elseif status == 2 then
					status = DB.DNDTex
				else
					status = " "
				end
			end
			if not zone then zone = UNKNOWN end

			count = count + 1

			if not info.guildTable[count] then info.guildTable[count] = {} end
			info.guildTable[count][1] = level
			info.guildTable[count][2] = class
			info.guildTable[count][3] = Ambiguate(name, "none")
			info.guildTable[count][4] = zone
			info.guildTable[count][5] = status
			info.guildTable[count][6] = guid
		end
	end

	infoFrame.numMembers = count
end

info.eventList = {
	"GUILD_ROSTER_UPDATE",
	"PLAYER_GUILD_UPDATE",
}

info.onEvent = function(self, event, arg1)
	if not IsInGuild() then
		self.text:SetFormattedText("%s: %s", GUILD, DB.MyColor..NONE)
		return
	end

	if event == "GUILD_ROSTER_UPDATE" then
		if arg1 then
			C_GuildInfo.GuildRoster()
		end
	end

	local _, numOnline, allOnline = GetNumGuildMembers()
	self.text:SetFormattedText("%s: %s", GUILD, DB.MyColor..(allOnline or numOnline))

	if infoFrame and infoFrame:IsShown() then
		info:GuildPanel_Refresh()
		info:GuildPanel_SortUpdate()
	end
end

info.onEnter = function()
	if not IsInGuild() then return end
	if NDuiFriendsFrame and NDuiFriendsFrame:IsShown() then
		NDuiFriendsFrame:Hide()
	end

	info:GuildPanel_Init()
	info:GuildPanel_Refresh()
	info:GuildPanel_SortUpdate()
end

local function delayLeave()
	if MouseIsOver(infoFrame) then return end
	infoFrame:Hide()
end

info.onLeave = function()
	if not infoFrame then return end
	C_Timer.After(.1, delayLeave)
end

info.onMouseUp = function()
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel

	if not IsInGuild() then return end
	infoFrame:Hide()
	if not CommunitiesFrame then C_AddOns.LoadAddOn("Blizzard_Communities") end
	if CommunitiesFrame then ToggleFrame(CommunitiesFrame) end
end