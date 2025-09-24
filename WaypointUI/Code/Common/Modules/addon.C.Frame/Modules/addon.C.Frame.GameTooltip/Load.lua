---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales

--------------------------------

env.C.Frame.GameTooltip = {}
local NS = env.C.Frame.GameTooltip; env.C.Frame.GameTooltip = NS

--------------------------------

function NS:Load()
	local function Variables()
		NS.Variables:Load()
	end

	local function Modules()
		NS.Elements:Load()
		NS.Script:Load()
	end

	--------------------------------

	Variables()
	Modules()
end
