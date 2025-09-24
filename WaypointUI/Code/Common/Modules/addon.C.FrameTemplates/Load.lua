---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales

--------------------------------

env.C.FrameTemplates = {}
env.C.FrameTemplates.Styles = {}
local NS = env.C.FrameTemplates; env.C.FrameTemplates = NS

--------------------------------

function NS:Load()
	local function Modules()

	end

	local function Prefabs()
		NS.Prefabs:Load()
	end

	--------------------------------

	Prefabs()
	Modules()
end
