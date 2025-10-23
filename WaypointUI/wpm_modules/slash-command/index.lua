local env = select(2, ...)

local type = type
local ipairs = ipairs
local tonumber = tonumber
local string_gsub = string.gsub
local string_gmatch = string.gmatch
local SlashCmdList = SlashCmdList
local hash_SlashCmdList = hash_SlashCmdList
local getmetatable = getmetatable

local SlashCommand = env.WPM:New("wpm_modules/slash-command")




local decimalUsesDot = tonumber("1.1") ~= nil
local wrongSeparator = "(%d)" .. (decimalUsesDot and "," or ".") .. "(%d)"
local rightSeparator = "%1" .. (decimalUsesDot and "." or ",") .. "%2"
local decimalSpacingPattern = "(%d)[%.,] (%d)"
local tokenPattern = "%S+"

local function computeTokens(str)
    str = string_gsub(str, decimalSpacingPattern, "%1 %2")
    str = string_gsub(str, wrongSeparator, rightSeparator)

    local tokens = {}
    local count = 0
    for token in string_gmatch(str, tokenPattern) do
        count = count + 1
        tokens[count] = token
    end

    return tokens
end

function SlashCommand:GetTokens(str)
    return computeTokens(str)
end




-- Returns the slash command callback registered in the SlashCmdList
---@param name string
---@return function
function SlashCommand:GetSlashCommand(name)
    return SlashCmdList[name]
end

-- Registers a new slash command to the SlashCmdList. Index must be provided and cannot overlap.
---@param name string
---@param command string | string[]
---@param callback function
---@param index number
function SlashCommand:AddSlashCommand(name, command, callback, index)
    local slashName = "SLASH_" .. name .. index
    _G[slashName] = "/" .. command

    local getTokens = SlashCommand.GetTokens
    SlashCmdList[name] = function(msg)
        callback(msg, getTokens(SlashCommand, msg))
    end
end

-- Hooks a callback onto another slash command in the SlashCmdList. When the hook is called, the callback is called as well.
---@param name string
---@param callback function
function SlashCommand:HookSlashCommand(name, callback)
    local existing = SlashCommand:GetSlashCommand(name)
    if not existing then return end

    local getTokens = SlashCommand.GetTokens
    SlashCmdList[name] = function(msg)
        existing(msg)
        callback(msg, getTokens(SlashCommand, msg))
    end
end

-- Removes a slash command from the SlashCmdList.
---@param name string
function SlashCommand:RemoveSlashCommand(name)
    local i = 1
    local prefix = "SLASH_" .. name
    while true do
        local key = prefix .. i
        local slash = _G[key]
        if not slash then break end

        _G[key] = nil
        if hash_SlashCmdList then
            hash_SlashCmdList[slash] = nil
        end

        i = i + 1
    end

    SlashCmdList[name] = nil
    local slashMeta = getmetatable(SlashCmdList)
    if slashMeta and slashMeta.__index then
        slashMeta.__index[name] = nil
    end
end




local slashCommandIndex = {}

local function AppendToCommandIndex(name)
    local current = slashCommandIndex[name]
    if current == nil then
        slashCommandIndex[name] = 1
    else
        slashCommandIndex[name] = current + 1
    end
end

--[[
    Adds multiple slashcmd commands from a schema.

    Expected schema:
        [1] = {
            name = "EXAMPLE"                                    -- entry name
            hook = "EXAMPLE_02"                                 -- call this slash command when the hook is triggered
            command = "/example" | {"/example1", "/example2"}   -- the slash command to register
            callback = function(msg, tokens)
                ...
            end
        },
        ...
]]
function SlashCommand:AddFromSchema(schema)
    local getSlashCommand = SlashCommand.GetSlashCommand
    local hookSlashCommand = SlashCommand.HookSlashCommand
    local addSlashCommand = SlashCommand.AddSlashCommand

    for index = 1, #schema do
        local v = schema[index]
        assert(v.name, "`AddFromSchema`: `name` is required")
        assert(v.callback, "`AddFromSchema`: `callback` is required")

        -- `hook` specified, attempt to hook to existing slash command
        if v.hook and getSlashCommand(SlashCommand, v.hook) then
            hookSlashCommand(SlashCommand, v.hook, v.callback)
        else
            -- Process multiple command names to assign to the callback. Must be a table.
            local commands = v.command
            if type(commands) == "table" then
                for i = 1, #commands do
                    AppendToCommandIndex(v.name)
                    addSlashCommand(SlashCommand, v.name, commands[i], v.callback, slashCommandIndex[v.name])
                end
            else -- Process single command name and assign to callback
                AppendToCommandIndex(v.name)
                addSlashCommand(SlashCommand, v.name, commands, v.callback, slashCommandIndex[v.name])
            end
        end
    end
end
