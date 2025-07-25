
-------------------------------------
-- InspectCore Author: M
-------------------------------------

local LibEvent = LibStub:GetLibrary("LibEvent-NDui-MOD")
local LibSchedule = LibStub:GetLibrary("LibSchedule-NDui-MOD")
local LibUnitInfo = LibStub:GetLibrary("LibUnitInfo-NDui-MOD")

local guids, inspecting = {}, false

-- Global API
function GetInspectInfo(unit, timelimit, checkhp)
	local guid = UnitGUID(unit)
	if not guid or not guids[guid] then return end
	if checkhp and UnitHealthMax(unit) ~= guids[guid].hp then return end

	if not timelimit or timelimit == 0 then
		return guids[guid]
	end
	if guids[guid].timer > (time() - timelimit) then
		return guids[guid]
	end
end

-- Global API
function GetInspecting()
	if InspectFrame and InspectFrame.unit then
		local guid = UnitGUID(InspectFrame.unit)
		return guids[guid] or { inuse = true }
	end
	if inspecting and inspecting.expired > time() then
		return inspecting
	end
end

-- Global API @trigger UNIT_REINSPECT_READY
function ReInspect(unit)
	local guid = UnitGUID(unit)
	if not guid then return end

	local data = guids[guid]
	if data then
		LibSchedule:AddTask({
			identity  = guid,
			timer     = 0.5,
			elasped   = 0.5,
			expired   = GetTime() + 3,
			data      = data,
			unit      = unit,
			onExecute = function(self)
				local ilevel = LibUnitInfo:GetUnitItemLevel(self.unit)
				if ilevel <= 0 then
					return true
				else
					self.data.timer = time()
					self.data.ilevel = ilevel
					LibEvent:trigger("UNIT_REINSPECT_READY", self.data)
					return true
				end
			end,
		})
	end
end

-- Global API
function GetInspectSpec(unit)
	local specID, specName
	if unit == "player" then
		specID = GetSpecialization()
		specName = select(2, GetSpecializationInfo(specID))
	else
		specID = GetInspectSpecialization(unit)
		if specID and specID > 0 then
			specName = select(2, GetSpecializationInfoByID(specID))
		end
	end
	return specName or ""
end

-- Clear
hooksecurefunc("ClearInspectPlayer", function()
	inspecting = false
end)

-- @trigger UNIT_INSPECT_STARTED
hooksecurefunc("NotifyInspect", function(unit)
	local guid = UnitGUID(unit)
	if not guid then return end

	local data = guids[guid]
	if data then
		data.unit = unit
		data.name, data.realm = UnitName(unit)
	else
		data = {
			unit   = unit,
			guid   = guid,
			class  = select(2, UnitClass(unit)),
			level  = UnitLevel(unit),
			ilevel = -1,
			spec   = nil,
			hp     = UnitHealthMax(unit),
			timer  = time(),
		}
		data.name, data.realm = UnitName(unit)
		guids[guid] = data
	end
	if not data.realm then
		data.realm = GetRealmName()
	end
	data.expired = time() + 3
	inspecting = data
	LibEvent:trigger("UNIT_INSPECT_STARTED", data)
end)

-- @trigger UNIT_INSPECT_READY
LibEvent:attachEvent("INSPECT_READY", function(this, guid)
	if not guids[guid] then return end
	LibSchedule:AddTask({
		identity  = guid,
		timer     = 0.1,
		elasped   = 0.4,
		expired   = GetTime() + 5,
		repeats   = 2,  --重复次数 10.x里GetInventoryItemLink居然有概率返回nil,所以这里扫两次
		data      = guids[guid],
		onTimeout = function(self) inspecting = false end,
		onExecute = function(self)
			local ilevel = LibUnitInfo:GetUnitItemLevel(self.data.unit)
			if ilevel <= 0 then
				return true
			else
				self.repeats = self.repeats - 1
				if (self.repeats <= 0) then
					self.data.timer = time()
					self.data.name = UnitName(self.data.unit)
					self.data.class = select(2, UnitClass(self.data.unit))
					self.data.ilevel = ilevel
					self.data.spec = GetInspectSpec(self.data.unit)
					self.data.hp = UnitHealthMax(self.data.unit)
					LibEvent:trigger("UNIT_INSPECT_READY", self.data)
					inspecting = false
					return true
				end
			end
		end,
	})
end)
