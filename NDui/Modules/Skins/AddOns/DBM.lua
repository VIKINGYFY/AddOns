local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local buttonsize = 20

local function ReskinDBMIcon(icon, frame)
	if not icon then return end

	if not icon.styled then
		icon:SetSize(buttonsize, buttonsize)
		icon.SetSize = B.Dummy

		B.ReskinIcon(icon, true)

		icon.styled = true
	end

	B.UpdatePoint(icon, "BOTTOMRIGHT", frame, "BOTTOMLEFT", -DB.margin, C.mult)
end

local function ReskinDBMBar(bar, frame)
	if not bar then return end

	if not bar.styled then
		B.StripTextures(bar, 6)
		B.SetBD(bar)
		bar:SetStatusBarTexture(DB.normTex)

		bar.styled = true
	end

	bar:SetInside(frame)
end

local function HideDBMSpark(self)
	B.GetObject(self.frame, "BarSpark"):Hide()
end

local function ApplyDBMStyle(self)
	local frame = self.frame
	local tbar = B.GetObject(frame, "Bar")
	local name = B.GetObject(frame, "BarName")
	local icon1 = B.GetObject(frame, "BarIcon1")
	local icon2 = B.GetObject(frame, "BarIcon2")
	local spark = B.GetObject(frame, "BarSpark")
	local timer = B.GetObject(frame, "BarTimer")
	local texture = B.GetObject(frame, "BarTexture")
	local variance = B.GetObject(frame, "BarVariance")

	if self.enlarged then
		frame:SetWidth(self.owner.Options.HugeWidth)
		tbar:SetWidth(self.owner.Options.HugeWidth)
	else
		frame:SetWidth(self.owner.Options.Width)
		tbar:SetWidth(self.owner.Options.Width)
	end

	frame:SetScale(1)
	frame:SetHeight(buttonsize/2)

	ReskinDBMBar(tbar, frame)

	if icon1 then
		ReskinDBMIcon(icon1, frame)
	elseif icon2 then
		ReskinDBMIcon(icon2, frame)
	else
		ReskinDBMIcon(icon1, frame)
		ReskinDBMIcon(icon2, frame)
	end
	if texture then
		texture:SetTexture(DB.normTex)
	end
	if variance then
		variance:SetTexture(nil)
	end

	name:SetWordWrap(false)
	name:SetJustifyH("LEFT")
	name:SetWidth(tbar:GetWidth()*.8)
	B.SetFontSize(name, 14)
	B.UpdatePoint(name, "LEFT", tbar, "TOPLEFT", DB.margin, 0)

	timer:SetJustifyH("RIGHT")
	timer:SetWidth(tbar:GetWidth()*.2)
	B.SetFontSize(timer, 14)
	B.UpdatePoint(timer, "RIGHT", tbar, "TOPRIGHT", -DB.margin, 0)
end

function S:DBMSkin()
	-- Default notice message
	local RaidNotice_AddMessage_ = RaidNotice_AddMessage
	RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
		if string.find(textString, "|T") then
			if string.match(textString, ":(%d+):(%d+)") then
				local size1, size2 = string.match(textString, ":(%d+):(%d+)")
				size1, size2 = size1 + 3, size2 + 3
				textString = string.gsub(textString,":(%d+):(%d+)",":"..size1..":"..size2..":0:0:64:64:5:59:5:59")
			elseif string.match(textString, ":(%d+)|t") then
				local size = string.match(textString, ":(%d+)|t")
				size = size + 3
				textString = string.gsub(textString,":(%d+)|t",":"..size..":"..size..":0:0:64:64:5:59:5:59|t")
			end
		end
		return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
	end

	if not C_AddOns.IsAddOnLoaded("DBM-Core") then return end
	if not C.db["Skins"]["DBM"] then return end

	hooksecurefunc(DBT, "CreateBar", function(self)
		for bar in self:GetBarIterator() do
			if not bar.injected then
				hooksecurefunc(bar, "Update", HideDBMSpark)
				hooksecurefunc(bar, "ApplyStyle", ApplyDBMStyle)
				bar:ApplyStyle()

				bar.injected = true
			end
		end
	end)

	hooksecurefunc(DBM.RangeCheck, "Show", function()
		if DBMRangeCheckRadar and not DBMRangeCheckRadar.styled then
			B.ReskinTooltip(DBMRangeCheckRadar)
			DBMRangeCheckRadar.styled = true
		end

		if DBMRangeCheck and not DBMRangeCheck.styled then
			B.ReskinTooltip(DBMRangeCheck)
			DBMRangeCheck.styled = true
		end
	end)

	if DBM.InfoFrame then
		DBM.InfoFrame:Show(5, "test")
		DBM.InfoFrame:Hide()
		DBMInfoFrame:HookScript("OnShow", B.ReskinTooltip)
	end

	-- Force Settings
	if not DBM_AllSavedOptions["Default"] then DBM_AllSavedOptions["Default"] = {} end
	DBM_AllSavedOptions["Default"]["BlockVersionUpdateNotice"] = true
	DBM_AllSavedOptions["Default"]["EventSoundVictory"] = "None"
	DBM_AllSavedOptions["Default"]["EventSoundVictory2"] = "None"

	if C_AddOns.IsAddOnLoaded("DBM-VPVV") then
		DBM_AllSavedOptions["Default"]["ChosenVoicePack2"] = "VV"
		DBM_AllSavedOptions["Default"]["CountdownVoice"] = "VP: VV"
		DBM_AllSavedOptions["Default"]["CountdownVoice2"] = "VP: VV"
		DBM_AllSavedOptions["Default"]["CountdownVoice3"] = "VP: VV"
		DBM_AllSavedOptions["Default"]["PullVoice"] = "VP: VV"
	end

	if not DBT_AllPersistentOptions["Default"] then DBT_AllPersistentOptions["Default"] = {} end
	DBT_AllPersistentOptions["Default"]["DBM"]["BarYOffset"] = 5
	DBT_AllPersistentOptions["Default"]["DBM"]["HugeBarYOffset"] = 5
	DBT_AllPersistentOptions["Default"]["DBM"]["ExpandUpwards"] = true
	DBT_AllPersistentOptions["Default"]["DBM"]["ExpandUpwardsLarge"] = true
end