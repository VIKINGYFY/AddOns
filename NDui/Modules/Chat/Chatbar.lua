local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local chatSwitchInfo = {
	text = L["ChatSwitchHelp"],
	buttonStyle = HelpTip.ButtonStyle.GotIt,
	targetPoint = HelpTip.Point.TopEdgeCenter,
	offsetY = 50,
	onAcknowledgeCallback = B.HelpInfoAcknowledge,
	callbackArg = "ChatSwitch",
}

local function chatSwitchTip()
	if not NDuiADB["Help"]["ChatSwitch"] then
		HelpTip:Show(ChatFrame1, chatSwitchInfo)
	end
end

function module:Chatbar()
	if not C.db["Chat"]["Chatbar"] then return end

	local chatFrame = SELECTED_DOCK_FRAME
	local width, height, padding, buttonList = 40, 8, DB.margin*2, {}

	local Chatbar = CreateFrame("Frame", "NDui_ChatBar", UIParent)
	Chatbar:SetSize(width, height)

	local function AddButton(r, g, b, text, func)
		local bu = CreateFrame("Button", nil, Chatbar, "SecureActionButtonTemplate, BackdropTemplate")
		bu:SetSize(width, height)
		B.PixelIcon(bu, DB.normTex, true)
		B.CreateSD(bu.bg)
		bu.Icon:SetVertexColor(r, g, b)
		bu:RegisterForClicks("AnyDown")
		if text then B.AddTooltip(bu, "ANCHOR_TOP", B.HexRGB(r, g, b)..text) end
		if func then
			bu:SetScript("OnClick", func)
			bu:HookScript("OnClick", chatSwitchTip)
		end

		table.insert(buttonList, bu)
		return bu
	end

	-- Create Chatbars
	local buttonInfo = {
		{1, 1, 1, SAY.." / "..YELL, function(_, btn)
			if btn == "RightButton" then
				ChatFrameUtil.OpenChat("/y ", chatFrame)
			else
				ChatFrameUtil.OpenChat("/s ", chatFrame)
			end
		end},
		{1, .5, 1, WHISPER.." / "..REPLY_MESSAGE, function(_, btn)
			if btn == "RightButton" then
				ChatFrameUtil.ReplyTell(chatFrame)
			else
				if UnitExists("target") and UnitName("target") and UnitIsPlayer("target") and GetDefaultLanguage("player") == GetDefaultLanguage("target") then
					local name = GetUnitName("target", true)
					ChatFrameUtil.SendTell(name)
				else
					UIErrorsFrame:AddMessage(DB.InfoColor..ERR_GENERIC_NO_TARGET)
				end
			end
		end},
		{.65, .65, 1, PARTY, function() ChatFrameUtil.OpenChat("/p ", chatFrame) end},
		{1, .5, 0, INSTANCE.." / "..RAID, function()
			if IsPartyLFG() or C_PartyInfo.IsPartyWalkIn() then
				ChatFrameUtil.OpenChat("/i ", chatFrame)
			else
				ChatFrameUtil.OpenChat("/raid ", chatFrame)
			end
		end},
		{.25, 1, .25, GUILD.." / "..OFFICER, function(_, btn)
			if btn == "RightButton" and C_GuildInfo.IsGuildOfficer() then
				ChatFrameUtil.OpenChat("/o ", chatFrame)
			else
				ChatFrameUtil.OpenChat("/g ", chatFrame)
			end
		end},
	}
	for _, info in pairs(buttonInfo) do AddButton(unpack(info)) end

	-- ROLL
	local roll = AddButton(.5, 1, .5, LOOT_ROLL)
	roll:SetAttribute("type", "macro")
	roll:SetAttribute("macrotext", "/roll")
	roll:RegisterForClicks("AnyDown")

	-- COMBATLOG
	local combat = AddButton(1, 1, 0, BINDING_NAME_TOGGLECOMBATLOG)
	combat:SetAttribute("type", "macro")
	combat:SetAttribute("macrotext", "/combatlog")
	combat:RegisterForClicks("AnyDown")

	-- WORLD CHANNEL
	if GetCVar("portal") == "CN" then
		local channelName = "大脚世界频道"
		local wcButton = AddButton(1, .75, .75, L["World Channel"])

		local function updateChannelInfo()
			local id = GetChannelName(channelName)
			if not id or id == 0 then
				module.InWorldChannel = false
				module.WorldChannelID = nil
				wcButton.Icon:SetVertexColor(1, .1, .1)
			else
				module.InWorldChannel = true
				module.WorldChannelID = id
				wcButton.Icon:SetVertexColor(1, .75, .75)
			end
		end

		local function checkChannelStatus()
			C_Timer.After(.2, updateChannelInfo)
		end
		checkChannelStatus()
		B:RegisterEvent("CHANNEL_UI_UPDATE", checkChannelStatus)
		hooksecurefunc("ChatConfigChannelSettings_UpdateCheckboxes", checkChannelStatus) -- toggle in chatconfig

		wcButton:SetScript("OnClick", function(_, btn)
			if module.InWorldChannel then
				if btn == "RightButton" then
					LeaveChannelByName(channelName)
					print(format("|cffFF0000%s|r |cff00FFFF%s|r", QUIT, L["World Channel"]))

					module.InWorldChannel = false
				elseif module.WorldChannelID then
					ChatFrameUtil.OpenChat("/"..module.WorldChannelID, chatFrame)
				end
			else
				JoinPermanentChannel(channelName, nil, 1)
				ChatFrameUtil.AddChannel(ChatFrame1, channelName)
				print(format("|cff00FF00%s|r |cff00FFFF%s|r", JOIN, L["World Channel"]))

				module.InWorldChannel = true
			end
		end)
	end

	-- Order Postions
	for i = 1, #buttonList do
		if i == 1 then
			buttonList[i]:SetPoint("LEFT")
		else
			buttonList[i]:SetPoint("LEFT", buttonList[i-1], "RIGHT", padding, 0)
		end
	end

	-- Mover
	local width = #buttonList * (width + padding) - padding
	local mover = B.Mover(Chatbar, L["Chatbar"], "Chatbar", {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", padding, 3}, width, height*2)
	Chatbar:ClearAllPoints()
	Chatbar:SetPoint("LEFT", mover, "LEFT")

	module:ChatBarBackground()
end

function module:ChatBarBackground()
	local parent = _G["NDui_ChatBar"]
	local width, height = 450, 18
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("LEFT", parent, "LEFT", -DB.margin*2, 0)
	frame:SetSize(width, height)

	local tex = B.SetGradient(frame, "H", 0, 0, 0, DB.alpha, 0, width, height)
	tex:SetPoint("CENTER")
	local bottomLine = B.SetGradient(frame, "H", DB.r, DB.g, DB.b, DB.alpha, 0, width, C.mult)
	bottomLine:SetPoint("TOP", frame, "BOTTOM")
	local topLine = B.SetGradient(frame, "H", DB.r, DB.g, DB.b, DB.alpha, 0, width, C.mult)
	topLine:SetPoint("BOTTOM", frame, "TOP")
end