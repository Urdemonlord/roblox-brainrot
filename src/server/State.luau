-- Steal a Brainrot: state. THE single source of truth for everything
-- that changes at runtime. No other module keeps its own copy of player
-- data: Spawner, Carry, Income, Events and Rebirth all read and write
-- through this module, and the client only ever sees it via attributes
-- and RemoteEvents.
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))

local State = {}

State.players = {} -- [userId] = player record
State.belt = {} -- list of brainrot records currently walking the belt
State.nextBrainrotId = 1
State.currentEvent = nil -- { name, endsAt, incomeMultiplier } or nil
State.eventIndex = 0
State.usedPlots = {} -- [plotIndex] = userId

-- A brainrot record: one row per character instance in the world.
--   id, defId, mutation ("Normal"|"Golden"|"Diamond"|"Rainbow"), rate ($/sec)
--   model (the 3D Model), location ("belt"|"slot"|"carried")
--   ownerUserId (who owns it; nil while on the belt), slotIndex, plotIndex
--   stolenFrom (userId it was stolen from, while carried), stolenAt (clock)
local function newBrainrotRecord(def, mutation)
	local id = State.nextBrainrotId
	State.nextBrainrotId += 1
	return {
		id = id,
		defId = def.id,
		mutation = mutation,
		rate = BrainrotData.rateFor(def, mutation),
		model = nil,
		location = "belt",
		ownerUserId = nil,
		slotIndex = nil,
		plotIndex = nil,
		stolenFrom = nil,
		stolenAt = 0,
	}
end

function State.newBrainrot(def, mutation)
	return newBrainrotRecord(def, mutation)
end

function State.newPlayer(player)
	local record = {
		player = player,
		plotIndex = nil,
		cash = Config.START_CASH,
		rebirths = 0,
		multiplier = 1,
		lockUntil = 0,
		lockCooldownUntil = 0,
		slots = {}, -- [slotIndex] = brainrot record
		carried = nil, -- brainrot record or nil
	}
	State.players[player.UserId] = record
	return record
end

function State.getPlayer(player)
	return State.players[player.UserId]
end

function State.removePlayer(player)
	State.players[player.UserId] = nil
end

function State.slotCount(record)
	return math.min(Config.BASE_SLOTS + record.rebirths * Config.SLOTS_PER_REBIRTH, Config.MAX_SLOTS)
end

function State.freeSlot(record)
	for i = 1, State.slotCount(record) do
		if record.slots[i] == nil then
			return i
		end
	end
	return nil
end

function State.incomePerSecond(record)
	local total = 0
	for _, brainrot in pairs(record.slots) do
		total += brainrot.rate
	end
	total *= record.multiplier
	if State.currentEvent and State.currentEvent.incomeMultiplier then
		total *= State.currentEvent.incomeMultiplier
	end
	return total
end

function State.isLocked(record)
	return os.clock() < record.lockUntil
end

function State.lockRemaining(record)
	return math.max(0, record.lockUntil - os.clock())
end

function State.lockCooldownRemaining(record)
	return math.max(0, record.lockCooldownUntil - os.clock())
end

function State.rebirthCost(record)
	return Config.REBIRTH_BASE_COST * (Config.REBIRTH_COST_GROWTH ^ record.rebirths)
end

-- Push the numbers the client HUD reads. Attributes replicate for free.
function State.syncAttributes(record)
	local player = record.player
	player:SetAttribute("Cash", math.floor(record.cash))
	player:SetAttribute("IncomePerSec", math.floor(State.incomePerSecond(record)))
	player:SetAttribute("Rebirths", record.rebirths)
	player:SetAttribute("Multiplier", record.multiplier)
	player:SetAttribute("LockRemaining", math.floor(State.lockRemaining(record)))
	player:SetAttribute("LockCooldown", math.floor(State.lockCooldownRemaining(record)))
	player:SetAttribute("RebirthCost", State.rebirthCost(record))
	player:SetAttribute("SlotsUsed", State.slotsUsed(record))
	player:SetAttribute("SlotsTotal", State.slotCount(record))
	if record.carried then
		local def = BrainrotData.getById(record.carried.defId)
		player:SetAttribute("Carrying", def and def.name or "")
	else
		player:SetAttribute("Carrying", "")
	end
end

function State.slotsUsed(record)
	local n = 0
	for _ in pairs(record.slots) do
		n += 1
	end
	return n
end

-- Assign the first free plot to a player. Returns the plot index or nil.
function State.assignPlot(userId)
	for i = 1, #Config.PLOT_POSITIONS do
		if State.usedPlots[i] == nil then
			State.usedPlots[i] = userId
			return i
		end
	end
	return nil
end

function State.freePlot(plotIndex)
	State.usedPlots[plotIndex] = nil
end

-- Belt bookkeeping.
function State.addToBelt(record)
	table.insert(State.belt, record)
end

function State.removeFromBelt(record)
	for i, b in ipairs(State.belt) do
		if b.id == record.id then
			table.remove(State.belt, i)
			return true
		end
	end
	return false
end

return State
