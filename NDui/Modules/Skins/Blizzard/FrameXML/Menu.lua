local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["Menu"] = function()

	if not Menu then return end

	local menuManagerProxy = Menu.GetManager()

	local backdrops = {}

	local function skinMenu(menuFrame)
		B.StripTextures(menuFrame)

		if backdrops[menuFrame] then
			menuFrame.bg = backdrops[menuFrame]
		else
			menuFrame.bg = B.SetBD(menuFrame)
			backdrops[menuFrame] = menuFrame.bg
		end

		if not menuFrame.ScrollBar.styled then
			B.ReskinScroll(menuFrame.ScrollBar)
			menuFrame.ScrollBar.styled = true
		end

		for i = 1, menuFrame:GetNumChildren() do
			local child = select(i, menuFrame:GetChildren())

			local minLevel = child.MinLevel
			if minLevel and not minLevel.styled then
				B.ReskinInput(minLevel)
				minLevel.styled = true
			end

			local maxLevel = child.MaxLevel
			if maxLevel and not maxLevel.styled then
				B.ReskinInput(maxLevel)
				maxLevel.styled = true
			end
		end
	end

	local function setupMenu(manager, _, menuDescription)
		local menuFrame = manager:GetOpenMenu()
		if menuFrame then
			skinMenu(menuFrame)
			menuDescription:AddMenuAcquiredCallback(skinMenu)
		end
	end

	hooksecurefunc(menuManagerProxy, "OpenMenu", setupMenu)
	hooksecurefunc(menuManagerProxy, "OpenContextMenu", setupMenu)
end