local env = select(2, ...)

local package = {}

function package:New(name)
	env["wpm/" .. name] = {}
	return env["wpm/" .. name]
end

function package:Import(name)
	return env["wpm/" .. name]
end

local awaitMetatable = {
    __index = function(self, key)
        return env["wpm/" .. rawget(self, "name")][key]
    end
}

function package:Await(name)
    return setmetatable({ name = name }, awaitMetatable)
end

env.WPM = package
