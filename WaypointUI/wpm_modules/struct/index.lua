local env = select(2, ...)
local Utils_Standard = env.WPM:Import("wpm_modules/utils/standard")

local struct = env.WPM:New("wpm_modules/struct")



-- Logic
--------------------------------

local instance_mt_cache = setmetatable({}, { __mode = "k" })

local function equals(a, b)
    return a and b and a.id == b.id
end

local function getInstanceMT(definition)
    local mt = instance_mt_cache[definition]
    if mt then return mt end

    mt = {
        __index = function(t, k)
            local value = rawget(t, k)
            if value ~= nil then return value end

            local def = rawget(t, "definition")
            if def then
                local defVal = rawget(def, k)
                if type(defVal) == "table" and rawget(defVal, "isStruct") then
                    local substruct = defVal({})
                    rawset(t, k, substruct)
                    return substruct
                end
                return defVal
            end
        end,
        __newindex = function(t, k, v)
            local def = rawget(t, "definition")
            if def then
                local defVal = rawget(def, k)
                if type(defVal) == "table" and rawget(defVal, "isStruct") and type(v) == "table" and not rawget(v, "isStruct") then
                    local substruct = rawget(t, k)
                    if substruct then
                        for kk, vv in pairs(v) do
                            substruct[kk] = vv
                        end
                    else
                        rawset(t, k, defVal(v))
                    end
                    return
                end
            end
            rawset(t, k, v)
        end,
        __call = function(t, updates)
            if type(updates) ~= "table" then return t end

            local def = rawget(t, "definition")
            local newInstance = setmetatable({
                id = rawget(t, "id"),
                definition = def,
                isStruct = true
            }, mt)

            for k, v in pairs(def) do
                if type(v) ~= "function" and k ~= "isStruct" then
                    local existing = rawget(t, k)
                    if existing ~= nil then
                        rawset(newInstance, k, existing)
                    elseif type(v) ~= "table" or not rawget(v, "isStruct") then
                        rawset(newInstance, k, v)
                    end
                end
            end

            for k, v in pairs(t) do
                if k ~= "id" and k ~= "definition" and k ~= "isStruct" and rawget(newInstance, k) == nil then
                    rawset(newInstance, k, v)
                end
            end

            for k, v in pairs(updates) do
                newInstance[k] = v
            end

            return newInstance
        end,
        __eq = equals
    }
    instance_mt_cache[definition] = mt
    return mt
end

local definition_mt = {
    __index = function(t, k)
        return rawget(t.definition, k)
    end,
    __eq = equals,
    __call = function(t, initialValues)
        local instance = initialValues or {}
        instance.id = rawget(t, "id")
        instance.definition = rawget(t, "definition")
        instance.isStruct = true

        setmetatable(instance, getInstanceMT(instance.definition))

        local def = instance.definition
        for k, v in pairs(def) do
            if rawget(instance, k) == nil and type(v) ~= "function" and k ~= "isStruct" then
                if type(v) == "table" and rawget(v, "isStruct") then
                    instance[k] = v({})
                else
                    instance[k] = v
                end
            end
        end

        return instance
    end
}



-- API
--------------------------------

function struct.New(definition)
    local new = {
        id = Utils_Standard.GenerateRandomID(),
        definition = definition,
        isStruct = true
    }
    return setmetatable(new, definition_mt)
end
