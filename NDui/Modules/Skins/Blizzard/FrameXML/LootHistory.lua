local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b

	local frame = GroupLootHistoryFrame
	if not frame then return end

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.ClosePanelButton)
	B.ReskinScroll(frame.ScrollBar)
	B.ReskinDropDown(frame.EncounterDropdown)

	local bar = frame.Timer
	if bar then
		B.StripTextures(bar)
		B.CreateBDFrame(bar, .25, nil, -C.mult)
		bar.Fill:SetTexture(DB.normTex)
		bar.Fill:SetVertexColor(cr, cg, cb)
	end

	-- Resize button
	B.StripTextures(frame.ResizeButton)
	frame.ResizeButton:SetHeight(8)

	local line1 = frame.ResizeButton:CreateTexture()
	line1:SetTexture(DB.bdTex)
	line1:SetVertexColor(.7, .7, .7)
	line1:SetSize(30, C.mult)
	line1:SetPoint("TOP", 0, -2)
	local line2 = frame.ResizeButton:CreateTexture()
	line2:SetTexture(DB.bdTex)
	line2:SetVertexColor(.7, .7, .7)
	line2:SetSize(30, C.mult)
	line2:SetPoint("TOP", 0, -5)

	frame.ResizeButton:HookScript("OnEnter", function()
		line1:SetVertexColor(cr, cg, cb)
		line2:SetVertexColor(cr, cg, cb)
	end)
	frame.ResizeButton:HookScript("OnLeave", function()
		line1:SetVertexColor(.7, .7, .7)
		line2:SetVertexColor(.7, .7, .7)
	end)

	-- Item frame
	local function ReskinLootButton(button)
		if not button.styled then
			if button.BackgroundArtFrame then
				button.BackgroundArtFrame.NameFrame:SetAlpha(0)
				button.BackgroundArtFrame.BorderFrame:SetAlpha(0)
				B.CreateBDFrame(button.BackgroundArtFrame.BorderFrame, .25)
			end
			local item = button.Item
			if item then
				B.StripTextures(item, 1)
				item.bg = B.ReskinIcon(item.icon)
				item.bg:SetFrameLevel(item.bg:GetFrameLevel() + 1)
				B.ReskinBorder(item.IconBorder, true)
			end

			button.styled = true
		end
	end

	hooksecurefunc(frame.ScrollBox, "Update", function(self)
		self:ForEachFrame(ReskinLootButton)
	end)
end)