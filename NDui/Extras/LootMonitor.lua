local _, ns = ...
local B, C, L, DB = unpack(ns)
local EX = B:GetModule("Extras")

local frameWidth, buttonHeight = 200, 16
local maxLines, minQuality, inGroup = 20, 3, false
local lootItemIDs = {
	[248142] = true, -- 地下堡行者的奖赏
}

local LootMonitor = CreateFrame("Frame", "LootMonitor", UIParent, "BackdropTemplate")
LootMonitor:SetFrameStrata("HIGH")
LootMonitor:RegisterEvent("PLAYER_LOGIN")
LootMonitor:RegisterEvent("CHAT_MSG_LOOT")

LootMonitor:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

LootMonitor:SetScript("OnEnter", function(self)
	self:StopTimer()
end)

LootMonitor:SetScript("OnLeave", function(self)
	self:StartTimer()
end)

local function UnitClassColor(unit)
	local r, g, b = B.UnitColor(unit)
	return B.HexRGB(r, g, b, unit)
end

local function Button_OnClick(self, button)
	if button == "RightButton" then
		C_ChatInfo.SendChatMessage(string.format(LootMonitor.message[random(4)], LootMonitor.reports[self.index]["link"]), "WHISPER", nil, LootMonitor.reports[self.index]["player"])
	else
		ChatFrameUtil.OpenChat(LootMonitor.reports[self.index]["link"])
	end
end

local function Button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 10, 0)
	GameTooltip:SetHyperlink(LootMonitor.reports[self.index]["link"])
end

local function Button_OnLeave(self)
	GameTooltip:Hide()
end

local function CreateLMButton(index)
	if not LootMonitor.buttons[index] then
		local button = CreateFrame("Button", "LootMonitorButton"..index, LootMonitor)
		button:SetHeight(buttonHeight)
		button:SetPoint("RIGHT", LootMonitor, "RIGHT", -10, 0)
		button:SetPoint("TOPLEFT", LootMonitor.Title, "BOTTOMLEFT", 0, -(DB.margin + (index - 1) * (buttonHeight + 1)))

		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("OnClick", Button_OnClick)
		button:SetScript("OnEnter", Button_OnEnter)
		button:SetScript("OnLeave", Button_OnLeave)
		button.index = index

		local glow = button:CreateTexture(nil, "HIGHLIGHT")
		glow:SetAllPoints()
		glow:SetBlendMode("ADD")
		glow:SetColorTexture(1, 1, 1, .5)
		button.glow = glow

		local text = B.CreateFS(button, buttonHeight-2, "", false, "LEFT", 0, 0)
		button.text = text

		LootMonitor.buttons[index] = button
	end

	return LootMonitor.buttons[index]
end

function LootMonitor:StopTimer()
	if self.timer then
		self.timer:Cancel()
		self.timer = nil
	end

	self.Timer:SetText("")
	self.Timer:SetTextColor(0, 1, 0)
end

function LootMonitor:StartTimer()
	self:StopTimer()

	self.remainingTime = self.autoCloseTime
	self.Timer:SetText(self.remainingTime)
	self.Timer:SetTextColor(0, 1, 0)

	self.timer = C_Timer.NewTicker(1, function()
		if self.remainingTime <= 0 then
			self:CloseSelf()
		else
			local r, g, b = B.SmoothColor(self.remainingTime, self.autoCloseTime, true)
			self.remainingTime = self.remainingTime - 1
			self.Timer:SetText(self.remainingTime)
			self.Timer:SetTextColor(r, g, b)
		end
	end)
end

function LootMonitor:CloseSelf()
	table.wipe(self.reports)

	for _, button in ipairs(self.buttons) do
		button.text:SetText("")
		button:Hide()
	end

	self.Count:SetText("")
	self:SetSize(frameWidth, buttonHeight*4)

	self:StopTimer()
	self:Hide()
end

function LootMonitor:UpdateSelf()
	local maxWidth, maxReport = 0, #self.reports
	local maxHeight = (buttonHeight + 1) * (maxReport + 3) + DB.margin

	for _, button in ipairs(self.buttons) do
		if button:IsShown() then
			local textWidth = (button.text:GetWidth() + 20) or 0
			maxWidth = math.max(maxWidth, textWidth)
		end
	end

	self.Count:SetText(maxReport)
	self:SetSize(maxWidth, maxHeight)

	self:StartTimer()

	if not self:IsShown() then
		self:Show()
	end
end

function LootMonitor:PLAYER_LOGIN()
	self.mover = B.Mover(self, "拾取监控", "LootMonitor", {"LEFT", UIParent, "LEFT", DB.margin*2, 0}, frameWidth, buttonHeight*4)
	self:ClearAllPoints()
	self:SetPoint("LEFT", self.mover, "LEFT")

	B.CreateBG(self)
	B.CreateMF(self)

	self.autoCloseTime = 30
	self.remainingTime = 0

	self.buttons = {}
	self.reports = {}
	self.message = {
		"你好！能让一下%s吗？谢谢！",
		"你好！请问%s有需求吗？没有的话能让给我吗？谢谢！",
		"老哥！求个%s啊，刷了很久了！谢谢！",
		"老哥！求个%s！毕业的！谢谢！",
	}

	self.Close = B.CreateButton(self, 18, 18, true, DB.closeTex)
	self.Close:SetScript("OnClick", function() self:CloseSelf() end)

	self.Title = B.CreateFS(self, buttonHeight-2, "拾取监控", true, "TOPLEFT", 10, -10)
	self.Info = B.CreateFS(self, buttonHeight-2, DB.LeftButton.."发送"..DB.RightButton.."密语", true, "BOTTOMRIGHT", -10, 10)
	self.Count = B.CreateFS(self, buttonHeight-2, "", "info")
	self.Timer = B.CreateFS(self, buttonHeight-2, "", "green")

	B.UpdatePoint(self.Close, "TOPRIGHT", self, "TOPRIGHT", -6, -6)
	B.UpdatePoint(self.Count, "LEFT", self.Title, "RIGHT", DB.margin, 0)
	B.UpdatePoint(self.Timer, "RIGHT", self.Close, "LEFT", -DB.margin, 0)

	for index = 1, maxLines do
		CreateLMButton(index)
	end

	self:CloseSelf()
end

function LootMonitor:CHAT_MSG_LOOT(event, ...)
	if inGroup and not IsInGroup() then return end

	local lootText, lootPlayer = ...
	local itemLink
	for link in string.gmatch(lootText, "|c.-|h%[.-%]|h|r") do
		if link then itemLink = link end
	end

	if not itemLink or string.len(lootPlayer) < 1 then return end

	local itemQuality = C_Item.GetItemQualityByID(itemLink)
	local itemID, _, _, _, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(itemLink)

	if lootItemIDs[itemID] or EX.isCollection(itemID, itemClassID, itemSubClassID) or (EX.isEquipment(itemID, itemClassID) and itemQuality >= minQuality) then
		local lootTime = DB.InfoColor..GameTime_GetGameTime(true).."|r"
		local lootName = UnitClassColor(string.split("-", lootPlayer))

		local itemInfo, hasStat, hasMisc = B.GetItemExtra(itemLink)
		if hasStat then
			itemInfo = "|cff00FF00"..itemInfo.."|r"
		elseif hasMisc then
			itemInfo = "|cff00FFFF"..itemInfo.."|r"
		end

		if #self.reports >= maxLines then table.remove(self.reports, 1) end

		table.insert(self.reports, {time = lootTime, name = lootName, link = itemLink, info = itemInfo, player = lootPlayer})

		for index = 1, #self.reports do
			self.buttons[index].text:SetFormattedText("%s %s %s %s", self.reports[index]["time"], self.reports[index]["name"], self.reports[index]["link"], self.reports[index]["info"])
			self.buttons[index]:Show()
		end
	end

	self:UpdateSelf()
end
