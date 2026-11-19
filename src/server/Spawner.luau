-- Steal a Brainrot: spawner. Rolls brainrots onto the conveyor belt and
-- walks them along it. Rarity and mutation rolls live here and nowhere
-- else; Events.lua only tells the spawner when a Rush is running.
local RunService = game:GetService("RunService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))
local State = require(script.Parent:WaitForChild("State"))
local BrainrotFactory = require(script.Parent:WaitForChild("BrainrotFactory"))

local Spawner = {}

local rushActive = false
local onTake -- set by init: function(record) called when a belt brainrot is taken

function Spawner.setRush(active)
	rushActive = active
end

function Spawner.isRush()
	return rushActive
end

function Spawner.setOnTake(fn)
	onTake = fn
end

local function rollRarity()
	local weights = rushActive and Config.RARITY_WEIGHTS_RUSH or Config.RARITY_WEIGHTS
	local total = 0
	for _, w in pairs(weights) do
		total += w
	end
	local roll = math.random() * total
	local acc = 0
	for _, rarity in ipairs(BrainrotData.RARITIES) do
		acc += weights[rarity]
		if roll <= acc then
			return rarity
		end
	end
	return "Common"
end

local function rollMutation()
	local chances = BrainrotData.MUTATIONS
	local factor = rushActive and 2 or 1
	for _, m in ipairs(chances) do
		if math.random() * 100 < m.chance * factor then
			return m.name
		end
	end
	return "Normal"
end

function Spawner.spawnOne()
	if #State.belt >= Config.MAX_ON_BELT then
		return nil
	end
	local rarity = rollRarity()
	local defs = BrainrotData.getByRarity(rarity)
	local def = defs[math.random(1, #defs)]
	local mutation = rollMutation()
	local record = State.newBrainrot(def, mutation)

	local model = BrainrotFactory.build(def, mutation)
	model.Parent = workspace
	local startY = Config.BELT_TOP_Y + def.bodySize.Y / 2 + 0.8
	model:PivotTo(CFrame.new(Config.BELT_START_X, startY, 0))
	record.model = model
	State.addToBelt(record)

	-- Take prompt (on the belt, anyone may grab it).
	local prompt = BrainrotFactory.attachPrompt(model, "Take", def.name .. "  $" .. record.rate .. "/s")
	prompt.Triggered:Connect(function(player)
		if record.location ~= "belt" then
			return
		end
		if onTake then
			onTake(record, player)
		end
	end)

	return record
end

function Spawner.despawn(record)
	State.removeFromBelt(record)
	if record.model then
		record.model:Destroy()
		record.model = nil
	end
end

-- Walk every belt brainrot forward; despawn at the end of the belt.
function Spawner.start()
	task.spawn(function()
		while true do
			local interval = rushActive and (Config.SPAWN_INTERVAL / 2) or Config.SPAWN_INTERVAL
			task.wait(interval)
			Spawner.spawnOne()
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		for i = #State.belt, 1, -1 do
			local record = State.belt[i]
			local model = record.model
			if not model or not model.Parent then
				table.remove(State.belt, i)
			else
				local pivot = model:GetPivot()
				local x = pivot.Position.X + Config.BELT_WALK_SPEED * dt
				if x >= Config.BELT_HALF_LENGTH - 2 then
					Spawner.despawn(record)
				else
					model:PivotTo(CFrame.new(x, pivot.Position.Y, 0) * CFrame.Angles(0, 0, 0))
				end
			end
		end
	end)
end

return Spawner
