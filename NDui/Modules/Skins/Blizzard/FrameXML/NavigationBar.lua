local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	local function moveNavButtons(self)
		local width = 0
		local collapsedWidth
		local maxWidth = self:GetWidth() - self.widthBuffer

		local lastShown
		local collapsed = false

		for i = #self.navList, 1, -1 do
			local currentWidth = width
			width = width + self.navList[i]:GetWidth()

			if width > maxWidth then
				collapsed = true
				if not collapsedWidth then
					collapsedWidth = currentWidth
				end
			else
				if lastShown then
					self.navList[lastShown]:SetPoint("LEFT", self.navList[i], "RIGHT", 1, 0)
				end
				lastShown = i
			end
		end

		if collapsed then
			if collapsedWidth + self.overflowButton:GetWidth() > maxWidth then
				lastShown = lastShown + 1
			end

			if lastShown then
				local lastButton = self.navList[lastShown]

				if lastButton then
					lastButton:SetPoint("LEFT", self.overflowButton, "RIGHT", 1, 0)
				end
			end
		end
	end

	hooksecurefunc("NavBar_Initialize", B.ReskinNavBar)

	local function handleNavButton(navButton)
		if navButton.restyled then return end

		B.ReskinButton(navButton)

		navButton.selected:SetDrawLayer("BACKGROUND", 1)
		navButton.selected:SetColorTexture(r, g, b, .25)
		navButton.selected:SetInside(navButton.__bg)

		navButton:HookScript("OnClick", function()
			moveNavButtons(navButton:GetParent())
		end)

		-- arrow button
		local arrowButton = navButton.MenuArrowButton
		arrowButton:SetSize(20, 20)
		B.UpdatePoint(arrowButton, "RIGHT", navButton, "RIGHT", -5, 0)
		B.StripTextures(arrowButton, 99)
		B.SetupTexture(arrowButton, "down")

		navButton.restyled = true
	end

	hooksecurefunc("NavBar_AddButton", function(self)
		B.ReskinNavBar(self)
		handleNavButton(self.navList[#self.navList])
		moveNavButtons(self)
	end)

	-- Update navbar on WorldMap
	B.ReskinNavBar(WorldMapFrame.NavBar)
	local navList = WorldMapFrame.NavBar.navList
	for i = 2, #navList do
		handleNavButton(navList[i])
	end
	moveNavButtons(WorldMapFrame.NavBar)
end)