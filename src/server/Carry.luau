-- Steal a Brainrot: carry. Take from the belt, place in your base,
-- steal from other bases, and the knock-loose rule that makes stealing
-- risky. All of it is server-authoritative: the client never moves a
-- brainrot, it only asks (via prompts) and the server decides.
local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))
local State = require(script.Parent:WaitForChild("State"))
local BrainrotFactory = require(script.Parent:WaitForChild("BrainrotFactory"))

local Carry = {}

-- Set by init.server: { [plotIndex] = { slotPositions, beacon, pads } }
Carry.plots = {}
-- Set by init.server: function(player, message) for steal alerts.
Carry.notify = function() end

function Carry.setPlots(plots)
	Carry.plots = plots
end

function Carry.setNotify(fn)
	Carry.notify = fn
end

local function setModelAnchored(model, anchored)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = anchored
			d.CanCollide = false
			d.Massless = not anchored
		end
	end
end

local function weldToPlayer(record, player)
	local character = player.Character
	if not character then
		return false
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid then
		return false
	end
	setModelAnchored(record.model, false)
	local weld = Instance.new("Weld")
	weld.Name = "CarryWeld"
	weld.Part0 = hrp
	weld.Part1 = record.model.PrimaryPart
	weld.C0 = CFrame.new(0, Config.CARRY_HEIGHT, 0)
	weld.Parent = record.model.PrimaryPart
	humanoid.WalkSpeed = Config.WALK_SPEED_CARRYING
	return true, hrp
end

local function unweld(record)
	if not record.model then
		return
	end
	local weld = record.model.PrimaryPart:FindFirstChild("CarryWeld")
	if weld then
		weld:Destroy()
	end
	setModelAnchored(record.model, true)
end

-- Slot prompts: only the plot owner's own pads, only while carrying.
local function refreshSlotPrompts(playerRecord)
	for plotIndex, plot in pairs(Carry.plots) do
		for slotIndex, pad in pairs(plot.pads) do
			local prompt = pad:FindFirstChild("PlacePrompt")
			if prompt then
				local ownerRecord = State.players[State.usedPlots[plotIndex]]
				prompt.Enabled = ownerRecord == playerRecord
					and playerRecord.carried ~= nil
					and ownerRecord.slots[slotIndex] == nil
			end
		end
	end
end

function Carry.refreshAllSlotPrompts()
	for _, playerRecord in pairs(State.players) do
		refreshSlotPrompts(playerRecord)
	end
	-- Pads on plots whose owner is not carrying stay disabled.
	for plotIndex, plot in pairs(Carry.plots) do
		local ownerRecord = State.players[State.usedPlots[plotIndex]]
		if not ownerRecord or ownerRecord.carried == nil then
			for _, pad in pairs(plot.pads) do
				local prompt = pad:FindFirstChild("PlacePrompt")
				if prompt then
					prompt.Enabled = false
				end
			end
		end
	end
end

-- Take a brainrot off the belt.
function Carry.takeFromBelt(record, player)
	local playerRecord = State.getPlayer(player)
	if not playerRecord or playerRecord.carried then
		return false
	end
	if record.location ~= "belt" then
		return false
	end
	State.removeFromBelt(record)
	BrainrotFactory.removePrompt(record.model)
	record.location = "carried"
	record.ownerUserId = player.UserId
	record.stolenFrom = nil
	playerRecord.carried = record
	local ok = weldToPlayer(record, player)
	if not ok then
		-- Player has no character right now: put it back on the belt.
		playerRecord.carried = nil
		record.location = "belt"
		record.ownerUserId = nil
		record.stolenFrom = nil
		State.addToBelt(record)
		local def = BrainrotData.getById(record.defId)
		local prompt = BrainrotFactory.attachPrompt(record.model, "Take", def.name .. "  $" .. record.rate .. "/s")
		prompt.Triggered:Connect(function(otherPlayer)
			if record.location ~= "belt" then
				return
			end
			Carry.takeFromBelt(record, otherPlayer)
		end)
		return false
	end
	State.syncAttributes(playerRecord)
	Carry.refreshAllSlotPrompts()
	return true
end

-- Place the carried brainrot into one of your own slots.
function Carry.placeInSlot(player, slotIndex)
	local playerRecord = State.getPlayer(player)
	if not playerRecord or not playerRecord.carried then
		return false
	end
	local record = playerRecord.carried
	if slotIndex < 1 or slotIndex > State.slotCount(playerRecord) then
		return false
	end
	if playerRecord.slots[slotIndex] then
		return false
	end
	local plot = Carry.plots[playerRecord.plotIndex]
	if not plot then
		return false
	end
	unweld(record)
	local pos = plot.slotPositions[slotIndex]
	record.model:PivotTo(CFrame.new(pos))
	record.location = "slot"
	record.ownerUserId = player.UserId
	record.slotIndex = slotIndex
	record.plotIndex = playerRecord.plotIndex
	record.stolenFrom = nil
	record.stolenFromSlot = nil
	if record.knockConn then
		record.knockConn:Disconnect()
		record.knockConn = nil
	end
	playerRecord.slots[slotIndex] = record
	playerRecord.carried = nil
	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = Config.WALK_SPEED_NORMAL
		end
	end
	-- Steal prompt: other players may grab it when the base is unlocked.
	local def = BrainrotData.getById(record.defId)
	local prompt = BrainrotFactory.attachPrompt(record.model, "Steal", def.name .. "  $" .. record.rate .. "/s")
	prompt.HoldDuration = 0.5
	prompt.Triggered:Connect(function(thief)
		Carry.stealFromSlot(record, thief)
	end)
	State.syncAttributes(playerRecord)
	Carry.refreshAllSlotPrompts()
	return true
end

-- Steal a placed brainrot out of someone else's base.
function Carry.stealFromSlot(record, thief)
	if record.location ~= "slot" then
		return false
	end
	local thiefRecord = State.getPlayer(thief)
	if not thiefRecord or thiefRecord.carried then
		return false
	end
	local ownerRecord = State.players[record.ownerUserId]
	if not ownerRecord then
		return false
	end
	if record.ownerUserId == thief.UserId then
		return false -- your own brainrot: the prompt is not for you
	end
	if State.isLocked(ownerRecord) then
		return false -- locked base: hands off
	end
	-- Take it out of the owner's slot.
	ownerRecord.slots[record.slotIndex] = nil
	record.stolenFromSlot = record.slotIndex
	BrainrotFactory.removePrompt(record.model)
	record.location = "carried"
	record.stolenFrom = record.ownerUserId
	record.stolenAt = os.clock()
	record.slotIndex = nil
	record.plotIndex = nil
	thiefRecord.carried = record
	local ok, hrp = weldToPlayer(record, thief)
	if not ok then
		thiefRecord.carried = nil
		Carry.returnStolen(record)
		return false
	end
	-- Knock-loose: the owner touching the thief inside the grace window
	-- wins the brainrot back.
	local conn
	conn = hrp.Touched:Connect(function(hit)
		if record.location ~= "carried" then
			conn:Disconnect()
			return
		end
		if os.clock() - record.stolenAt > Config.STEAL_GRACE_SECONDS then
			conn:Disconnect()
			return
		end
		local other = Players:GetPlayerFromCharacter(hit.Parent)
		if other and other.UserId == record.stolenFrom then
			conn:Disconnect()
			Carry.returnStolen(record)
		end
	end)
	record.knockConn = conn
	State.syncAttributes(ownerRecord)
	State.syncAttributes(thiefRecord)
	Carry.refreshAllSlotPrompts()
	local def = BrainrotData.getById(record.defId)
	local owner = Players:GetPlayerByUserId(record.stolenFrom)
	if owner then
		Carry.notify(owner, "ALERT: " .. thief.DisplayName .. " stole your " .. def.name .. "! Touch them to win it back!")
	end
	Carry.notify(thief, "You stole " .. def.name .. "! Run it home before " .. (owner and owner.DisplayName or "the owner") .. " touches you!")
	return true
end

-- A stolen brainrot goes home: its old slot if free, else any free slot,
-- else it is sold off as insurance for its owner.
function Carry.returnStolen(record)
	local ownerRecord = record.stolenFrom and State.players[record.stolenFrom] or nil
	local thiefRecord = nil
	for _, pr in pairs(State.players) do
		if pr.carried == record then
			thiefRecord = pr
			break
		end
	end
	if record.knockConn then
		record.knockConn:Disconnect()
		record.knockConn = nil
	end
	if thiefRecord then
		thiefRecord.carried = nil
		if thiefRecord.player.Character then
			local humanoid = thiefRecord.player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = Config.WALK_SPEED_NORMAL
			end
		end
		State.syncAttributes(thiefRecord)
	end
	if not ownerRecord then
		if record.model then
			record.model:Destroy()
			record.model = nil
		end
		Carry.refreshAllSlotPrompts()
		return
	end
	unweld(record)
	local slotIndex = nil
	if record.stolenFromSlot and ownerRecord.slots[record.stolenFromSlot] == nil then
		slotIndex = record.stolenFromSlot
	else
		slotIndex = State.freeSlot(ownerRecord)
	end
	if slotIndex then
		local plot = Carry.plots[ownerRecord.plotIndex]
		record.model:PivotTo(CFrame.new(plot.slotPositions[slotIndex]))
		record.location = "slot"
		record.ownerUserId = ownerRecord.player.UserId
		record.slotIndex = slotIndex
		record.plotIndex = ownerRecord.plotIndex
		record.stolenFrom = nil
		record.stolenFromSlot = nil
		ownerRecord.slots[slotIndex] = record
		local def = BrainrotData.getById(record.defId)
		local prompt = BrainrotFactory.attachPrompt(record.model, "Steal", def.name .. "  $" .. record.rate .. "/s")
		prompt.HoldDuration = 0.5
		prompt.Triggered:Connect(function(thief)
			Carry.stealFromSlot(record, thief)
		end)
	else
		-- No room at home: sell it, owner gets insurance.
		local payout = record.rate * 30
		ownerRecord.cash += payout
		record.model:Destroy()
		record.model = nil
		Carry.notify(ownerRecord.player, "Your stolen brainrot was sold for $" .. payout .. " (no free slot).")
	end
	State.syncAttributes(ownerRecord)
	Carry.refreshAllSlotPrompts()
end

-- Drop what you are carrying when you die or leave: stolen goods go
-- home, belt grabs run away (despawn).
function Carry.dropCarried(playerRecord)
	local record = playerRecord.carried
	if not record then
		return
	end
	if record.knockConn then
		record.knockConn:Disconnect()
		record.knockConn = nil
	end
	playerRecord.carried = nil
	if playerRecord.player.Character then
		local humanoid = playerRecord.player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = Config.WALK_SPEED_NORMAL
		end
	end
	if record.stolenFrom then
		Carry.returnStolen(record)
	else
		unweld(record)
		if record.model then
			record.model:Destroy()
			record.model = nil
		end
	end
	State.syncAttributes(playerRecord)
	Carry.refreshAllSlotPrompts()
end

-- Attach the "Place brainrot" prompt to one slot pad.
function Carry.attachSlotPrompt(pad, plotIndex, slotIndex)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PlacePrompt"
	prompt.ActionText = "Place brainrot"
	prompt.ObjectText = "Slot " .. slotIndex
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false
	prompt.Parent = pad
	prompt.Triggered:Connect(function(player)
		local playerRecord = State.getPlayer(player)
		if not playerRecord or playerRecord.plotIndex ~= plotIndex then
			return
		end
		Carry.placeInSlot(player, slotIndex)
	end)
end

return Carry
