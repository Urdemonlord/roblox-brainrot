-- Steal a Brainrot: timed events. One event runs at a time, on a fixed
-- rotation: Golden Hour (income x2), Brainrot Rush (faster, rarer
-- spawns), Thief Raid (base locks break and stealing is free, so you
-- have to dash home and guard your base). The current event is exposed
-- on ReplicatedStorage attributes for the client banner.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local Spawner = require(script.Parent:WaitForChild("Spawner"))

local Events = {}

local notifyAll = function() end

function Events.setNotifyAll(fn)
	notifyAll = fn
end

local function applyEvent(eventDef)
	local event = {
		name = eventDef.name,
		-- Wall clock: the client reads this attribute for its countdown.
		endsAt = os.time() + eventDef.duration,
		incomeMultiplier = eventDef.incomeMultiplier,
		color = eventDef.color,
	}
	State.currentEvent = event
	ReplicatedStorage:SetAttribute("EventName", event.name)
	ReplicatedStorage:SetAttribute("EventEndsAt", event.endsAt)
	ReplicatedStorage:SetAttribute("EventColorR", event.color.R)
	ReplicatedStorage:SetAttribute("EventColorG", event.color.G)
	ReplicatedStorage:SetAttribute("EventColorB", event.color.B)

	if event.name == "BRAINROT RUSH" then
		Spawner.setRush(true)
	elseif event.name == "THIEF RAID" then
		-- Locks break: every base is open for the whole raid.
		for _, record in pairs(State.players) do
			record.lockUntil = 0
		end
		-- A guaranteed rare walks the belt so there is something to fight over.
		task.spawn(function()
			task.wait(2)
			Spawner.spawnOne()
		end)
	end
	notifyAll("EVENT: " .. event.name .. "!")
	return event
end

local function clearEvent()
	State.currentEvent = nil
	Spawner.setRush(false)
	ReplicatedStorage:SetAttribute("EventName", "")
	ReplicatedStorage:SetAttribute("EventEndsAt", 0)
end

function Events.start()
	task.spawn(function()
		task.wait(Config.FIRST_EVENT_DELAY)
		while true do
			State.eventIndex += 1
			local def = Config.EVENTS[((State.eventIndex - 1) % #Config.EVENTS) + 1]
			applyEvent(def)
			task.wait(def.duration)
			clearEvent()
			task.wait(Config.EVENT_CYCLE_SECONDS - def.duration)
		end
	end)
end

return Events
