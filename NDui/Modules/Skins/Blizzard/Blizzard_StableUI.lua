local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_StableUI"] = function()
	B.ReskinFrame(StableFrame)
	B.ReskinButton(StableFrame.StableTogglePetButton)
	B.ReskinButton(StableFrame.ReleasePetButton)

	local stabledPetList = StableFrame.StabledPetList
	B.StripTextures(stabledPetList)
	B.StripTextures(stabledPetList.ListCounter)
	B.CreateBDFrame(stabledPetList.ListCounter, .25)
	B.ReskinInput(stabledPetList.FilterBar.SearchBox)
	B.ReskinFilterButton(stabledPetList.FilterBar.FilterDropdown)
	B.ReskinScroll(stabledPetList.ScrollBar)

	local modelScene = StableFrame.PetModelScene
	if modelScene then
		local petInfo = modelScene.PetInfo
		if petInfo then
			hooksecurefunc(petInfo.Type, "SetText", B.ReplaceIconString)
		end

		local list = modelScene.AbilitiesList
		if list then
			hooksecurefunc(list, "Layout", function(self)
				for frame in self.abilityPool:EnumerateActive() do
					if not frame.styled then
						B.ReskinIcon(frame.Icon)
						frame.styled = true
					end
				end
			end)
		end

		B.ReskinModelControl(modelScene)

		if DB.isNewPatch and petInfo.Specialization then
			B.ReskinDropDown(petInfo.Specialization)
		end
	end
end