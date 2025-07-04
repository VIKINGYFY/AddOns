local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")

local WormholeGossipData = {
	-- 虫洞离心机-德拉诺
	[81205] = {
		[42586] = 542,
		[42587] = 535,
		[42588] = 539,
		[42589] = 550,
		[42590] = 543,
		[42591] = 525,
	},
	-- 龙洞发生器-巨龙群岛
	[195667] = {
		[63907] = 1978,
		[63911] = 2022,
		[63910] = 2023,
		[63909] = 2024,
		[63908] = 2025,
		[108016] = 2151,
		[109715] = 2133,
		[114080] = 2200,
	}
}

local mapIDToName = {}
local function GetMapNameByID(mapID)
	if not mapIDToName[mapID] then
		local mapInfo =  C_Map.GetMapInfo(mapID)
		mapIDToName[mapID] = mapInfo and mapInfo.name
	end

	return mapIDToName[mapID]
end

function M:WormholeHelper()
	if not M.db["WormholeHelper"] then return end

	hooksecurefunc(_G.GossipFrame, "Update", function(self)
		local npcID = B.GetNPCID(UnitGUID("npc"))
		local gossipData = WormholeGossipData[npcID]
		if not gossipData then return end

		for _, button in self.GreetingPanel.ScrollBox:EnumerateFrames() do
			local data = button.GetElementData and button:GetElementData()
			local id = data and data.info and gossipData[data.info.gossipOptionID]
			if id then
				button:SetText(GetMapNameByID(id))
			end
		end
	end)

	if C_AddOns.IsAddOnLoaded("Immersion") then
		local Titles = _G.ImmersionFrame.TitleButtons
		hooksecurefunc(Titles, "UpdateGossipOptions", function(self, data)
			local npcID = B.GetNPCID(UnitGUID("npc"))
			local gossipData = WormholeGossipData[npcID]
			if not gossipData then return end

			for i, info in ipairs(data) do
				local button = self.Buttons[self.idx - #data - 1 + i]
				local id = gossipData[info.gossipOptionID]
				if button and id then
					button:SetText(GetMapNameByID(id))
				end
			end
		end)
	end

	if C_AddOns.IsAddOnLoaded("DialogueUI") then
		local DUIQuestFrame = _G.DUIQuestFrame
		hooksecurefunc(DUIQuestFrame, "HandleGossip", function(self)
			local npcID = B.GetNPCID(UnitGUID("npc"))
			local gossipData = WormholeGossipData[npcID]
			if not gossipData then return end

			for _, button in self.optionButtonPool:EnumerateActive() do
				local id = gossipData[button.gossipOptionID]
				if id then
					button:SetButtonText(GetMapNameByID(id), false)
				end
			end
		end)
	end
end

M:RegisterMisc("WormholeHelper", M.WormholeHelper)