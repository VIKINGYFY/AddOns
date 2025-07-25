local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Chat")

local lines, menu, frame, editBox = {}

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then return id end
end

local function isMessageProtected(msg)
	return msg and (msg ~= string.gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function replaceMessage(msg, r, g, b)
	local hexRGB = B.HexRGB(r, g, b)
	--msg = string.gsub(msg, "|T(.-):.-|t", "%1") -- accept texture path or id
	--msg = string.gsub(msg, "|A(.-):.-|a", "%1") -- accept atlas path or id, needs review
	msg = string.gsub(msg, "|T(.-):.-|t", "")
	msg = string.gsub(msg, "|A(.-):.-|a", "")
	return format("%s%s|r", hexRGB, msg)
end

function module:GetChatLines()
	local index = 1
	for i = 1, self:GetNumMessages() do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not isMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = replaceMessage(msg, r, g, b)
			lines[index] = tostring(msg)
			index = index + 1
		end
	end

	return index - 1
end

function module:ChatCopy_OnClick(btn)
	if btn == "LeftButton" then
		if not frame:IsShown() then
			frame:Show()

			local lineCt = module.GetChatLines(_G.SELECTED_DOCK_FRAME)
			local text = table.concat(lines, "\n", 1, lineCt)
			editBox:SetText(text)
		else
			frame:Hide()
		end
	elseif btn == "RightButton" then
		B:TogglePanel(menu)
		C.db["Chat"]["ChatMenu"] = menu:IsShown()
	end
end

local function ResetChatAlertJustify(frame)
	frame:SetJustification("LEFT")
end

function module:ChatCopy_CreateMenu()
	menu = CreateFrame("Frame", nil, UIParent)
	menu:SetSize(25, 100)
	menu:SetPoint("TOPLEFT", _G.ChatFrame1.Background, "TOPRIGHT", 0, 0)
	menu:SetShown(C.db["Chat"]["ChatMenu"])

	_G.ChatFrameMenuButton:ClearAllPoints()
	_G.ChatFrameMenuButton:SetPoint("TOP", menu)
	_G.ChatFrameMenuButton:SetParent(menu)
	_G.ChatFrameChannelButton:ClearAllPoints()
	_G.ChatFrameChannelButton:SetPoint("TOP", _G.ChatFrameMenuButton, "BOTTOM", 0, -DB.margin)
	_G.ChatFrameChannelButton:SetParent(menu)
	_G.ChatFrameToggleVoiceDeafenButton:SetParent(menu)
	_G.ChatFrameToggleVoiceMuteButton:SetParent(menu)
	_G.QuickJoinToastButton:SetParent(menu)

	_G.ChatAlertFrame:ClearAllPoints()
	_G.ChatAlertFrame:SetPoint("BOTTOMLEFT", _G.ChatFrame1Tab, "TOPLEFT", 5, 25)
	ResetChatAlertJustify(_G.ChatAlertFrame)
	hooksecurefunc(_G.ChatAlertFrame, "SetChatButtonSide", ResetChatAlertJustify)
end

function module:ChatCopy_Create()
	frame = CreateFrame("Frame", "NDuiChatCopy", UIParent)
	frame:SetFrameStrata("DIALOG")
	frame:SetPoint("CENTER")
	frame:SetSize(800, 400)
	frame:Hide()

	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame)

	local scrollArea = CreateFrame("ScrollFrame", "ChatCopyScrollFrame", frame, "UIPanelScrollFrameTemplate, BackdropTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -30, 10)

	editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFont(DB.Font[1], 12, "")
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(scrollArea:GetHeight())
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then return end
		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		for i = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(editBox)

	local copy = CreateFrame("Button", "NDuiChatCopyButton", UIParent)
	copy:SetPoint("BOTTOMLEFT", _G.ChatFrame1.Background, "BOTTOMRIGHT", DB.margin, DB.margin)
	copy:SetSize(16, 16)
	copy:SetAlpha(.5)
	copy.Icon = copy:CreateTexture(nil, "ARTWORK")
	copy.Icon:SetAllPoints()
	copy.Icon:SetTexture(DB.copyTex)
	copy:RegisterForClicks("AnyDown")
	copy:SetScript("OnClick", self.ChatCopy_OnClick)
	local copyStr = format(L["Chat Copy"], DB.LeftButton, DB.RightButton)
	B.AddTooltip(copy, "ANCHOR_RIGHT", copyStr)
	copy:HookScript("OnEnter", function() copy:SetAlpha(1) end)
	copy:HookScript("OnLeave", function() copy:SetAlpha(.5) end)

	B.CreateMF(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.close)
	B.ReskinScroll(ChatCopyScrollFrameScrollBar)
end

function module:ChatCopy()
	self:ChatCopy_CreateMenu()
	self:ChatCopy_Create()
end