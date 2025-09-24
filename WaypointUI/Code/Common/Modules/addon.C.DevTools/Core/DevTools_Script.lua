---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.DevTools; env.C.DevTools = NS

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
		function Callback:Print(text)
			if text then
				if env.C.AddonInfo.Variables.General.IS_DEVELOPER_MODE then
					print(text)
				end
			end
		end
	end

	--------------------------------
	-- FUNCTIONS (UNIT TEST)
	--------------------------------

	do
		Callback.UnitTest = {}

		--------------------------------

		function Callback.UnitTest:New(data)
			-- Format
			-- 	{
			-- 		{
			--			name = "Stage 1"
			-- 			run = function(env) ... end
			--			test = function(env) criteria = {...} return Callback.UnitTest:Check(crteria) end
			-- 		},
			-- 		{
			--			name = "Stage 2"
			-- 			test = function(env) criteria = {...} return Callback.UnitTest:Check(criteria) end
			-- 		}
			-- 	}

			local unitTest = {}
			unitTest.data = data

			function unitTest:Run()
				local data = unitTest.data
				for i = 1, #data do
					local scenario = data[i]
					local name = scenario.name

					if scenario.run then
						scenario.run(unitTest, name)
					end
					if scenario.test then
						local success = scenario.test(unitTest, name)
						if success then
							print(env.CS:GetSharedColor().RGB_GREEN_HEXCODE .. "UNIT_TEST_PASSED: ", name .. "|r")
						else
							print(env.CS:GetSharedColor().RGB_RED_HEXCODE .. "UNIT_TEST_FAILED: ", name .. "|r")
							print("UNIT_TEST_STOPPED: " .. (i - 1) .. "/" .. (#data))
							return
						end
					end
				end
			end

			return unitTest
		end

		function Callback.UnitTest:Check(sucessCriteria)
			local success

			--------------------------------

			if sucessCriteria then success = true else success = false end

			--------------------------------

			return success
		end
	end
end
