-- Steal a Brainrot: remotes. The only two things the client may ask
-- the server to do (lock the base, rebirth) and the one channel the
-- server uses to talk back (notifications). Everything else the player
-- does goes through ProximityPrompts, which fire on the server directly.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local Rebirth = require(script.Parent:WaitForChild("Rebirth"))

local Remotes = {}

local requestLock
local requestRebirth
local notifyEvent

function Remotes.setup()
	requestLock = Instance.new("RemoteEvent")
	requestLock.Name = "RequestLock"
	requestLock.Parent = ReplicatedStorage

	requestRebirth = Instance.new("RemoteEvent")
	requestRebirth.Name = "RequestRebirth"
	requestRebirth.Parent = ReplicatedStorage

	notifyEvent = Instance.new("RemoteEvent")
	notifyEvent.Name = "Notify"
	notifyEvent.Parent = ReplicatedStorage

	requestLock.OnServerEvent:Connect(function(player)
		local record = State.getPlayer(player)
		if not record then
			return
		end
		if State.currentEvent and State.currentEvent.name == "THIEF RAID" then
			Remotes.notify(player, "THIEF RAID: locks are broken! Guard your base yourself!")
			return
		end
		if State.isLocked(record) then
			return
		end
		if State.lockCooldownRemaining(record) > 0 then
			Remotes.notify(player, "Lock recharging: " .. math.floor(State.lockCooldownRemaining(record)) .. "s left.")
			return
		end
		record.lockUntil = os.clock() + Config.LOCK_DURATION
		record.lockCooldownUntil = record.lockUntil + Config.LOCK_COOLDOWN
		State.syncAttributes(record)
		Remotes.notify(player, "Base locked for " .. Config.LOCK_DURATION .. "s. Nobody can steal from you.")
	end)

	requestRebirth.OnServerEvent:Connect(function(player)
		local ok, msg = Rebirth.tryRebirth(player)
		Remotes.notify(player, msg)
	end)
end

function Remotes.notify(player, message)
	if notifyEvent then
		notifyEvent:FireClient(player, message)
	end
end

function Remotes.notifyAll(message)
	if notifyEvent then
		notifyEvent:FireAllClients(message)
	end
end

return Remotes
