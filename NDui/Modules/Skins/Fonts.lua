local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinFont(font, size)
	if not font then
		if DB.isDeveloper then print("UNKNOWN FONT.") end
		return
	end

	local oldSize = select(2, font:GetFont())
	size = size or oldSize
	B.SetFontSize(font, size*C.db["Skins"]["FontScale"])
end

local function Fixed_UpdateStatusText(frame)
	if frame:IsForbidden() then return end
	if not frame.statusText then return end

	local options = DefaultCompactMiniFrameSetUpOptions
	frame.statusText:ClearAllPoints()
	frame.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 3, options.height/3 - 5)
	frame.statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, options.height/3 - 5)

	if not frame.fontStyled then
		ReskinFont(frame.statusText)
		B.ReskinText(frame.statusText, 1, 1, 1)

		frame.fontStyled = true
	end
end

C.OnLoginThemes["Fonts"] = function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	-- Text color
	local yellowList = {
		InvoiceTextFontNormal,
	}
	for _, font in pairs(yellowList) do
		B.ReskinText(font, 1, .8, 0)
	end

	local whiteList = {
		CoreAbilityFont,
		GameFontBlack,
		GameFontBlackMedium,
		InvoiceTextFontSmall,
		MailTextFontNormal,
		QuestFont,
	}
	for _, font in pairs(whiteList) do
		B.ReskinText(font, 1, 1, 1)
	end

	if not C.db["Skins"]["FontOutline"] then return end

	ReskinFont(RaidWarningFrame.slot1)
	ReskinFont(RaidWarningFrame.slot2)
	ReskinFont(RaidBossEmoteFrame.slot1)
	ReskinFont(RaidBossEmoteFrame.slot2)
	ReskinFont(AchievementFont_Small)
	ReskinFont(AchievementCriteriaFont)
	ReskinFont(AchievementDescriptionFont)
	ReskinFont(CoreAbilityFont)
	ReskinFont(DestinyFontMed)
	ReskinFont(DestinyFontHuge)
	ReskinFont(DestinyFontLarge)
	ReskinFont(FriendsFont_Normal)
	ReskinFont(FriendsFont_Small)
	ReskinFont(FriendsFont_Large)
	ReskinFont(FriendsFont_UserText)
	ReskinFont(FriendsFont_11)
	ReskinFont(GameFont_Gigantic)
	ReskinFont(InvoiceFont_Small)
	ReskinFont(InvoiceFont_Med)
	ReskinFont(MailFont_Large)
	ReskinFont(NumberFont_Small)
	ReskinFont(NumberFont_GameNormal)
	ReskinFont(NumberFont_Normal_Med)
	ReskinFont(NumberFont_Shadow_Tiny)
	ReskinFont(NumberFont_OutlineThick_Mono_Small)
	ReskinFont(NumberFont_Outline_Med)
	ReskinFont(NumberFont_Outline_Large)
	ReskinFont(NumberFont_Shadow_Med)
	ReskinFont(NumberFont_Shadow_Small)
	ReskinFont(Number12Font, 12)
	ReskinFont(Number15Font)
	ReskinFont(Number16Font)
	ReskinFont(Number13FontYellow)
	ReskinFont(Number13FontWhite)
	ReskinFont(Number13FontGray)
	ReskinFont(Number14FontWhite)
	ReskinFont(Number15FontWhite)
	ReskinFont(Number18FontWhite)
	ReskinFont(QuestFont_Shadow_Small)
	ReskinFont(QuestFont_Large)
	ReskinFont(QuestFont_Shadow_Huge)
	ReskinFont(QuestFont_Huge)
	ReskinFont(QuestFont_Super_Huge)
	ReskinFont(QuestFont_Enormous)
	ReskinFont(ReputationDetailFont)
	ReskinFont(SpellFont_Small)
	ReskinFont(SystemFont_InverseShadow_Small)
	ReskinFont(SystemFont_Large)
	ReskinFont(SystemFont_Huge1)
	ReskinFont(SystemFont_Huge2)
	ReskinFont(SystemFont_Med1)
	ReskinFont(SystemFont_Med2)
	ReskinFont(SystemFont_Med3)
	ReskinFont(SystemFont_OutlineThick_WTF)
	ReskinFont(SystemFont_OutlineThick_Huge2)
	ReskinFont(SystemFont_OutlineThick_Huge4)
	ReskinFont(SystemFont_Outline_Small)
	ReskinFont(SystemFont_Outline)
	ReskinFont(SystemFont_Shadow_Large, 16)
	ReskinFont(SystemFont_Shadow_Large_Outline)
	ReskinFont(SystemFont_Shadow_Large2, 18)
	ReskinFont(SystemFont_Shadow_Med1)
	ReskinFont(SystemFont_Shadow_Med1_Outline)
	ReskinFont(SystemFont_Shadow_Med2)
	ReskinFont(SystemFont_Shadow_Med3)
	ReskinFont(SystemFont_Shadow_Huge1)
	ReskinFont(SystemFont_Shadow_Huge2)
	ReskinFont(SystemFont_Shadow_Huge3)
	ReskinFont(SystemFont_Shadow_Small)
	ReskinFont(SystemFont_Shadow_Small2)
	ReskinFont(SystemFont_Small)
	ReskinFont(SystemFont_Small2)
	ReskinFont(SystemFont_Tiny)
	ReskinFont(SystemFont_Tiny2)
	ReskinFont(SystemFont_NamePlate, 10)
	ReskinFont(SystemFont_NamePlateFixed, 10)
	ReskinFont(SystemFont_NamePlateCastBar, 10)
	ReskinFont(SystemFont_LargeNamePlate, 10)
	ReskinFont(SystemFont_LargeNamePlateFixed, 10)
	ReskinFont(SystemFont_World, 64)
	ReskinFont(SystemFont_World_ThickOutline, 64)
	ReskinFont(SystemFont_WTF2, 64)
	ReskinFont(Game11Font)
	ReskinFont(Game12Font)
	ReskinFont(Game13Font)
	ReskinFont(Game13FontShadow)
	ReskinFont(Game15Font)
	ReskinFont(Game15Font_Shadow)
	ReskinFont(Game16Font)
	ReskinFont(Game18Font)
	ReskinFont(Game20Font)
	ReskinFont(Game24Font)
	ReskinFont(Game27Font)
	ReskinFont(Game30Font)
	ReskinFont(Game32Font)
	ReskinFont(Game36Font)
	ReskinFont(Game40Font)
	ReskinFont(Game42Font)
	ReskinFont(Game46Font)
	ReskinFont(Game48Font)
	ReskinFont(Game48FontShadow)
	ReskinFont(Game60Font)
	ReskinFont(Game72Font)
	ReskinFont(Game120Font)
	ReskinFont(System_IME)
	ReskinFont(Fancy12Font)
	ReskinFont(Fancy14Font)
	ReskinFont(Fancy16Font)
	ReskinFont(Fancy18Font)
	ReskinFont(Fancy20Font)
	ReskinFont(Fancy22Font)
	ReskinFont(Fancy24Font)
	ReskinFont(Fancy27Font)
	ReskinFont(Fancy30Font)
	ReskinFont(Fancy32Font)
	ReskinFont(Fancy48Font)
	ReskinFont(SplashHeaderFont)
	ReskinFont(ChatBubbleFont, 13)
	ReskinFont(GameFontNormalHuge2)
	ReskinFont(PriceFont)
	ReskinFont(PriceFontWhite)
	ReskinFont(PriceFontGray)
	ReskinFont(PriceFontGreen)
	ReskinFont(PriceFontRed)
	-- new font family in 11.0.2
	for i = 12, 22 do
		local font = _G["ObjectiveTrackerFont"..i]
		if font then
			ReskinFont(font)
		end
	end

	-- Refont RaidFrame Health
	hooksecurefunc("CompactUnitFrame_UpdateStatusText", Fixed_UpdateStatusText)
end