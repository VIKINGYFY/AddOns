local _, ns = ...
local B, C, L, DB = unpack(ns)

local replacedGossipColor = {
	["000000"] = "ffffff",
	["414141"] = "7b8489", -- lighter color for some gossip options
}

local function Replace_GossipFormat(button, textFormat, text)
	local newFormat, count = string.gsub(textFormat, "000000", "ffffff")
	if count > 0 then
		button:SetFormattedText(newFormat, text)
	end
end

local function Replace_GossipText(button, text)
	if text and text ~= "" then
		local newText, count = string.gsub(text, ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59") -- replace icon texture
		if count > 0 then
			text = newText
			button:SetFormattedText("%s", text)
		end

		local colorStr, rawText = string.match(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
		colorStr = replacedGossipColor[colorStr]
		if colorStr and rawText then
			button:SetFormattedText("|cff%s%s|r", colorStr, rawText)
		end
	end
end

local function Replace_TextColor(text, r)
	if r ~= 1 then
		text:SetTextColor(1, 1, 1)
	end
end

local function Reskin_ButtonOnUpdate(self)
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if not button.styled then
			local buttonText = button.GreetingText or button.GetFontString and button:GetFontString()
			if buttonText then
				buttonText:SetTextColor(1, 1, 1)
				hooksecurefunc(buttonText, "SetTextColor", Replace_TextColor)
			end
			if button.SetText then
				local buttonText = select(3, button:GetRegions()) -- no parentKey atm
				if buttonText and buttonText:IsObjectType("FontString") then
					Replace_GossipText(button, button:GetText())
					hooksecurefunc(button, "SetText", Replace_GossipText)
					hooksecurefunc(button, "SetFormattedText", Replace_GossipFormat)
				end
			end

			button.styled = true
		end
	end
end

local function Reskin_ButtonOnShow(self)
	for button in self.titleButtonPool:EnumerateActive() do
		if not button.styled then
			Replace_GossipText(button, button:GetText())
			hooksecurefunc(button, "SetFormattedText", Replace_GossipFormat)

			button.styled = true
		end
	end
end

C.OnLoginThemes["GossipFrame"] = function()
	B.ReskinFrame(GossipFrame)
	B.ReskinButton(GossipFrame.GreetingPanel.GoodbyeButton)
	B.ReskinScroll(GossipFrame.GreetingPanel.ScrollBar)

	hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, "Update", Reskin_ButtonOnUpdate)

	local bar = GossipFrame.FriendshipStatusBar
	B.UpdatePoint(bar, "TOP", GossipFrame, "TOP", 0, -40)
	B.ReskinStatusBar(bar, true)

	local barIcon = bar.icon
	if barIcon then
		B.UpdatePoint(barIcon, "RIGHT", bar, "LEFT", -DB.margin, 0)
		B.ReskinIcon(barIcon)
	end

	QuestFrameGreetingPanel:HookScript("OnShow", Reskin_ButtonOnShow)
end