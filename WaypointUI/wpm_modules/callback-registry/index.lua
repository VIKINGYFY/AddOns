local env              = select(2, ...)

local table_insert     = table.insert
local math_floor       = math.floor

local CallbackRegistry = env.WPM:New("wpm_modules/callback-registry")
local db               = {}





local function insertCallback(callbacks, entry)
    local low, high = 1, #callbacks

    while low <= high do
        local mid = math_floor((low + high) * 0.5)
        if entry.priority < callbacks[mid].priority then
            high = mid - 1
        else
            low = mid + 1
        end
    end

    table_insert(callbacks, low, entry)
end




function CallbackRegistry:Add(id, func, priority)
    local callbacks = db[id]
    if not callbacks then
        callbacks = {}
        db[id] = callbacks
    end

    insertCallback(callbacks, {
        func     = func,
        priority = priority or 0
    })
end

function CallbackRegistry:Trigger(id, ...)
    local callbacks = db[id]
    if not callbacks then return end

    for i = 1, #callbacks do
        callbacks[i].func(...)
    end
end
