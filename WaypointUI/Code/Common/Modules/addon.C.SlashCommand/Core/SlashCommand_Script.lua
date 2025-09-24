---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.SlashCommand; env.C.SlashCommand = NS

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
		do -- UTILITIES
			function Callback:GetTokens(str)
				local wrongseparator = "(%d)" .. (tonumber("1.1") and "," or ".") .. "(%d)"
				local rightseparator = "%1" .. (tonumber("1.1") and "." or ",") .. "%2"
				str = str:gsub("(%d)[%.,] (%d)", "%1 %2"):gsub(wrongseparator, rightseparator)

				local tokens = {}
				for token in str:gmatch("%S+") do table.insert(tokens, token) end

				return tokens
			end
		end

		do -- SLASH COMMAND
			function Callback:GetSlashCommand(name)
				return SlashCmdList[name]
			end

			function Callback:AddSlashCommand(name, command, callback, index)
				_G["SLASH_" .. name .. index] = "/" .. command
				SlashCmdList[name] = function(msg) callback(msg, Callback:GetTokens(msg)) end
			end

			function Callback:HookSlashCommand(name, callback)
				local SLASH = Callback:GetSlashCommand(name)
				SlashCmdList[name] = function(msg)
					SLASH(msg)
					callback(msg, Callback:GetTokens(msg))
				end
			end

			function Callback:RemoveSlashCommand(name)
				local i = 1
				while _G["SLASH_" .. name .. i] ~= nil do
					local slash = _G["SLASH_" .. name .. i]

					_G["SLASH_" .. name .. i] = nil
					hash_SlashCmdList[slash] = nil

					i = i + 1;
				end

				SlashCmdList[name] = nil
				getmetatable(SlashCmdList).__index[name] = nil
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		local slashCommandIndex = {}

		for k, v in ipairs(env.C.AddonInfo.Variables.SlashCommand.REGISTER) do
			if v.hook and Callback:GetSlashCommand(v.hook) then
				Callback:HookSlashCommand(v.hook, v.callback)
			else
				if type(v.command) == "table" then
					for i = 1, #v.command do
						if not slashCommandIndex[v.name] then
							slashCommandIndex[v.name] = 1
						else
							slashCommandIndex[v.name] = slashCommandIndex[v.name] + 1
						end

						--------------------------------

						Callback:AddSlashCommand(v.name, v.command[i], v.callback, slashCommandIndex[v.name])
					end
				else
					if not slashCommandIndex[v.name] then
						slashCommandIndex[v.name] = 1
					else
						slashCommandIndex[v.name] = slashCommandIndex[v.name] + 1
					end

					--------------------------------

					Callback:AddSlashCommand(v.name, v.command, v.callback, slashCommandIndex[v.name])
				end
			end
		end
	end
end
