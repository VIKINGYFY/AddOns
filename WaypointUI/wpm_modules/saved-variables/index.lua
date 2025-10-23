local env = select(2, ...)

local type = type
local pairs = pairs

local CallbackRegistry = env.WPM:Import("wpm_modules/callback-registry")
local SavedVariables = env.WPM:New("wpm_modules/saved-variables")
local databases = {}

SavedVariables.Enum = {}
SavedVariables.Enum.Root = "@Root"





local function initTable(databaseName)
    if not _G[databaseName] then _G[databaseName] = {} end
end

local function setVariable(self, key, value)
    local database = _G[self.databaseName]
    if not type(value) == "table" and database[key] == value then return end

    database[key] = value

    -- Triggers Callback under name 'SavedVariables.<databaseName>.<key>'
    CallbackRegistry:Trigger(self.callbackPrefix .. tostring(key), value)
end

local function getVariable(self, key)
    local database = _G[self.databaseName]
    local value = database[key]
    if value == nil then
        value = self.defaultValues[key]
    end
    return value
end

local function resetVariable(self, key)
    local defaults = self.defaultValues
    local defaultValue = defaults[key]
    _G[self.databaseName][key] = defaultValue

    -- Triggers Callback under name 'SavedVariables.<databaseName>.<key>'
    CallbackRegistry:Trigger(self.callbackPrefix .. tostring(key), defaultValue)
end

local function wipeDatabase(self)
    _G[self.databaseName] = {}
end

local function setDefaults(self, tbl)
    self.defaultValues = tbl
    return self
end

local function nestedIndex(root, indexList)
    for i = 1, #indexList do
        if root == nil then return nil end
        root = root[indexList[i]]
    end
    return root
end

local function migrate(self, schema)
    --[[
        Expected Schema:
            {
                migrationType = "variable" | "directory",
                from = "variable" | { "profile", "variable" },
                to = "newKey" | { "profile", "newKey" }
            },
            {
                migrationType = "delete",
                target = "variable" | { "profile", "variable" }
            }
    ]]

    local db = _G[self.databaseName]
    if not db or type(schema) ~= "table" then return self end

    for i = 1, #schema do
        local v = schema[i]
        local fromIsPath = type(v.from) == "table"
        local toIsPath = type(v.to) == "table"

        local from = fromIsPath and nestedIndex(db, v.from) or db[v.from]
        local to = toIsPath and nestedIndex(db, v.to) or v.to

        if v.migrationType == "directory" then
            if not from or not to then return end

            local target
            if not toIsPath and v.to == SavedVariables.Enum.Root then
                target = db
            elseif toIsPath then
                target = to
            else
                target = db[v.to]
            end

            if not target then return end
            for key, value in pairs(from) do
                if not target[key] then
                    target[key] = value
                    from[key] = nil
                end
            end
        elseif v.migrationType == "variable" and from and not db[to] then
            if not from or not to then return end

            db[to] = from
            db[v.from] = nil
        elseif v.migrationType == "delete" then
            if not to then return end

            db[to] = nil
        end
    end
    return self
end





local meta = {
    __index = function(t, k)
        if k == "defaults" then
            return function(tbl)
                return setDefaults(t, tbl)
            end
        elseif k == "migrationPlan" then
            return function(schema)
                return migrate(t, schema)
            end
        end
        return nil
    end
}





--- Creates and registers a new database instance from the .toc saved variable reference. It's recommended to call after the `ADDON_LOADED` event has fired to ensure saved variables are available
function SavedVariables.RegisterDatabase(databaseName)
    initTable(databaseName)

    local callbackPrefix = "SavedVariables." .. databaseName .. "."
    local entry = {
        SetVariable    = setVariable,
        GetVariable    = getVariable,
        ResetVariable  = resetVariable,
        Wipe           = wipeDatabase,
        databaseName   = databaseName,
        defaultValues  = {},
        callbackPrefix = callbackPrefix
    }
    setmetatable(entry, meta)

    databases[databaseName] = entry
    return entry
end

-- Removes a registered database
function SavedVariables.RemoveDatabase(databaseName)
    databases[databaseName] = nil
end

-- Returns a registered database
function SavedVariables.GetDatabase(databaseName)
    return databases[databaseName]
end

-- Hooks a function for when a setting variable has changed
function SavedVariables.OnChange(db, var, func)
    CallbackRegistry:Add("SavedVariables." .. db .. "." .. var, func)
end
