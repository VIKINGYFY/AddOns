local _, ns = ...
local B, C, L, DB = unpack(ns)

local function replaceGossipFormat(button, textFormat, text)
	local newFormat, count = string.gsub(textFormat, "000000", "ffffff")
	if count > 0 then
		button:SetFormattedText(newFormat, text)
	end
end

local replacedGossipColor = {
	["000000"] = "ffffff",
	["414141"] = "7b8489", -- lighter color for some gossip options
}
local function replaceGossipText(button, text)
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

local function replaceTextColor(text, r)
	if r ~= 1 then
		text:SetTextColor(1, 1, 1)
	end
end

C.OnLoginThemes["GossipFrame"] = function()

	QuestFont:SetTextColor(1, 1, 1)

	B.ReskinButton(GossipFrame.GreetingPanel.GoodbyeButton)
	B.ReskinScroll(GossipFrame.GreetingPanel.ScrollBar)

	hooksecurefunc(GossipFrame.GreetingPanel.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			if not button.styled then
				local buttonText = button.GreetingText or button.GetFontString and button:GetFontString()
				if buttonText then
					buttonText:SetTextColor(1, 1, 1)
					hooksecurefunc(buttonText, "SetTextColor", replaceTextColor)
				end
				if button.SetText then
					local buttonText = select(3, button:GetRegions()) -- no parentKey atm
					if buttonText and buttonText:IsObjectType("FontString") then
						replaceGossipText(button, button:GetText())
						hooksecurefunc(button, "SetText", replaceGossipText)
						hooksecurefunc(button, "SetFormattedText", replaceGossipFormat)
					end
				end

				button.styled = true
			end
		end
	end)

	local bar = GossipFrame.FriendshipStatusBar
	bar:ClearAllPoints()
	bar:SetPoint("TOP", GossipFrame, "TOP", 0, -40)
	B.ReskinStatusBar(bar, true)

	GossipFrameInset:Hide()
	if GossipFrame.Background then GossipFrame.Background:Hide() end
	B.ReskinFrame(GossipFrame)

	-- Text on QuestFrame
	QuestFrameGreetingPanel:HookScript("OnShow", function(self)
		for button in self.titleButtonPool:EnumerateActive() do
			if not button.styled then
				replaceGossipText(button, button:GetText())
				hooksecurefunc(button, "SetFormattedText", replaceGossipFormat)

				button.styled = true
			end
		end
	end)
end