---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Sound; env.C.Sound = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		function Callback:PlaySoundFile(filePath, bypass)
			if filePath and filePath ~= "" then
				if bypass or env.C.AddonInfo.Variables.Sound.ENABLE_AUDIO() then
					PlaySoundFile(filePath)
				end
			end
		end

		function Callback:PlaySound(soundID, bypass)
			if soundID and soundID ~= "" then
				if bypass or env.C.AddonInfo.Variables.Sound.ENABLE_AUDIO() then
					PlaySound(soundID)
				end
			end
		end
	end
end
