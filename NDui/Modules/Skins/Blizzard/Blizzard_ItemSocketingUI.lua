local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_ItemSocketingUI"] = function()
	local GemTypeInfo = {
		Yellow = {r=0.97, g=0.82, b=0.29},
		Red = {r=1, g=0.47, b=0.47},
		Blue = {r=0.47, g=0.67, b=1},
		Hydraulic = {r=1, g=1, b=1},
		Cogwheel = {r=1, g=1, b=1},
		Meta = {r=1, g=1, b=1},
		Prismatic = {r=1, g=1, b=1},
		PunchcardRed = {r=1, g=0.47, b=0.47},
		PunchcardYellow = {r=0.97, g=0.82, b=0.29},
		PunchcardBlue = {r=0.47, g=0.67, b=1},
		Domination = {r=.24, g=.5, b=.7},
		Cypher = {r=1, g=.8, b=0},
		Tinker = {r=1, g=.47, b=.47},
		Primordial = {r=1, g=0, b=1},
		Fragrance = {r=1, g=1, b=1},
		SingingThunder = {r=0.97, g=0.82, b=0.29},
		SingingSea = {r=0.47, g=0.67, b=1},
		SingingWind = {r=1, g=0.47, b=0.47},
	}

	for i = 1, MAX_NUM_SOCKETS do
		local socket = _G["ItemSocketingSocket"..i]
		local shine = _G["ItemSocketingSocket"..i.."Shine"]

		B.StripTextures(socket)
		socket:SetPushedTexture(0)
		socket:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		socket.icon:SetTexCoord(unpack(DB.TexCoord))
		socket.bg = B.ReskinIcon(socket.icon)

		shine:ClearAllPoints()
		shine:SetOutside()
		socket.BracketFrame:Hide()
		socket.Background:SetAlpha(0)
	end

	hooksecurefunc("ItemSocketingFrame_Update", function()
		for i, socket in ipairs(ItemSocketingFrame.Sockets) do
			if not socket:IsShown() then break end

			local color = GemTypeInfo[GetSocketTypes(i)] or GemTypeInfo.Cogwheel
			socket.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		end

		ItemSocketingDescription:HideBackdrop()
	end)

	B.ReskinFrame(ItemSocketingFrame)
	ItemSocketingFrame.BackgroundColor:SetAlpha(0)
	B.CreateBDFrame(ItemSocketingScrollFrame, .25)
	B.ReskinButton(ItemSocketingSocketButton)
	B.ReskinScroll(ItemSocketingScrollFrame.ScrollBar)
end