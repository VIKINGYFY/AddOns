---@class env
local env = select(2, ...)

--------------------------------
-- VARIABLES
--------------------------------

env.C.Libraries = {}

--------------------------------
-- LIBRARIES
--------------------------------

do
    env.C.Libraries.AceTimer = LibStub("AceTimer-3.0")
	env.C.Libraries.AdaptiveTimer = LibStub("AdaptiveTimer-1.0")
	env.C.Libraries.LibSerialize = LibStub("LibSerialize")
	env.C.Libraries.LibDeflate = LibStub("LibDeflate")
end

--------------------------------
-- FUNCTIONS (MAIN)
--------------------------------

do

end
