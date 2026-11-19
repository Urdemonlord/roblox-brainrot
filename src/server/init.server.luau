-- Steal a Brainrot: server entrypoint. Wires every module together:
-- builds the world, hands players a plot on join, loads their
-- character, starts the spawner, income, events, and remotes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local World = require(script.Parent:WaitForChild("World"))
local Spawner = require(script.Parent:WaitForChild("Spawner"))
local Carry = require(script.Parent:WaitForChild("Carry"))
local Income = require(script.Parent:WaitForChild("Income"))
local Events = require(script.Parent:WaitForChild("Events"))
local Remotes = require(script.Parent:WaitForChild("Remotes"))

print("[Brainrot] Server starting...")

World.build()
Remotes.setup()
Carry.setNotify(Remotes.notify)
Events.setNotifyAll(Remotes.notifyAll)
Spawner.setOnTake(Carry.takeFromBelt)

local plots = {} -- [plotIndex] = World.buildPlot result
Carry.setPlots(plots)

local function onCharacterAdded(player, character)
	local record = State.getPlayer(player)
	if not record then
		return
	end
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = Config.WALK_SPEED_NORMAL
	humanoid.Died:Connect(function()
		Carry.dropCarried(record)
	end)
end

local function onPlayerAdded(player)
	local record = State.newPlayer(player)

	-- Leaderboard stats.
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Value = 0
	cashValue.Parent = leaderstats
	local rebirthValue = Instance.new("IntValue")
	rebirthValue.Name = "Rebirths"
	rebirthValue.Value = 0
	rebirthValue.Parent = leaderstats

	-- Plot assignment.
	local plotIndex = State.assignPlot(player.UserId)
	if plotIndex then
		record.plotIndex = plotIndex
		local plotPos = Config.PLOT_POSITIONS[plotIndex]
		local color = Config.PLOT_COLORS[plotIndex]
		plots[plotIndex] = World.buildPlot(plotIndex, plotPos, color, player.DisplayName .. "'s Base")
		for slotIndex, pad in pairs(plots[plotIndex].pads) do
			Carry.attachSlotPrompt(pad, plotIndex, slotIndex)
		end
	else
		-- No free plot (more players than plots): spectate from the plaza.
		Remotes.notify(player, "All base plots are taken! You can still grab brainrots from the belt.")
	end

	State.syncAttributes(record)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		onCharacterAdded(player, player.Character)
	else
		player:LoadCharacter()
	end
end

local function onPlayerRemoving(player)
	local record = State.getPlayer(player)
	if not record then
		return
	end
	if record.carried then
		Carry.dropCarried(record)
	end
	-- Clear the base so the next player gets a clean plot.
	for _, brainrot in pairs(record.slots) do
		if brainrot.model then
			brainrot.model:Destroy()
		end
	end
	if record.plotIndex then
		local plot = plots[record.plotIndex]
		if plot and plot.folder then
			plot.folder:Destroy()
		end
		plots[record.plotIndex] = nil
		State.freePlot(record.plotIndex)
	end
	State.removePlayer(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Per-second housekeeping: leaderstats mirror + lock beacons.
task.spawn(function()
	while true do
		task.wait(1)
		for _, record in pairs(State.players) do
			local leaderstats = record.player:FindFirstChild("leaderstats")
			if leaderstats then
				local cashValue = leaderstats:FindFirstChild("Cash")
				if cashValue then
					cashValue.Value = math.floor(record.cash)
				end
				local rebirthValue = leaderstats:FindFirstChild("Rebirths")
				if rebirthValue then
					rebirthValue.Value = record.rebirths
				end
			end
			if record.plotIndex then
				local plot = plots[record.plotIndex]
				if plot and plot.beacon then
					if State.isLocked(record) then
						plot.beacon.Color = Color3.fromRGB(255, 60, 60)
					else
						plot.beacon.Color = Color3.fromRGB(90, 220, 120)
					end
				end
			end
		end
	end
end)

-- Placed brainrots slowly spin so the base reads as alive.
task.spawn(function()
	while true do
		task.wait(0.1)
		for _, record in pairs(State.players) do
			for _, brainrot in pairs(record.slots) do
				if brainrot.model and brainrot.model.Parent then
					local pivot = brainrot.model:GetPivot()
					brainrot.model:PivotTo(pivot * CFrame.Angles(0, math.rad(2), 0))
				end
			end
		end
	end
end)

Spawner.start()
Income.start()
Events.start()

print("[Brainrot] Server ready.")
