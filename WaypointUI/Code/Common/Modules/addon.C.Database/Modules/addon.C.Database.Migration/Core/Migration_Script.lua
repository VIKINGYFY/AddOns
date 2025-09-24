---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Database.Migration; env.C.Database.Migration = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	local MIGRATION_GLOBAL = env.C.AddonInfo.Variables.Database.MIGRATION_GLOBAL
	local MIGRATION_LOCAL = env.C.AddonInfo.Variables.Database.MIGRATION_LOCAL
	local MIGRATION_GLOBAL_PERSISTENT = env.C.AddonInfo.Variables.Database.MIGRATION_GLOBAL_PERSISTENT
	local MIGRATION_LOCAL_PERSISTENT = env.C.AddonInfo.Variables.Database.MIGRATION_LOCAL_PERSISTENT

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		local function MigrateDatabase(migrationTable, database)
			if #migrationTable > 0 then
				for _, v in ipairs(migrationTable) do
					if database.profile[v.from] then
						database.profile[v.to] = database.profile[v.from]
					end
				end
			end
		end

		function Callback:Migrate()
			MigrateDatabase(MIGRATION_GLOBAL, env.C.Database.Variables.DB_GLOBAL)
			MigrateDatabase(MIGRATION_LOCAL, env.C.Database.Variables.DB_LOCAL)
			MigrateDatabase(MIGRATION_GLOBAL_PERSISTENT, env.C.Database.Variables.DB_GLOBAL_PERSISTENT)
			MigrateDatabase(MIGRATION_LOCAL_PERSISTENT, env.C.Database.Variables.DB_LOCAL_PERSISTENT)
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Callback:Migrate()
	end
end
