-- Steal a Brainrot: rebirth. Spend a growing pile of cash to reset your
-- base and your wallet in exchange for a permanent income multiplier
-- and more base slots. The reset is the progression: each rebirth makes
-- the next rarity ladder climb faster.
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("State"))
local Carry = require(script.Parent:WaitForChild("Carry"))

local Rebirth = {}

function Rebirth.tryRebirth(player)
	local record = State.getPlayer(player)
	if not record then
		return false, "no player record"
	end
	local cost = State.rebirthCost(record)
	if record.cash < cost then
		return false, "need $" .. cost
	end
	-- Hand back anything carried first, then clear the base.
	if record.carried then
		Carry.dropCarried(record)
	end
	for slotIndex, brainrot in pairs(record.slots) do
		if brainrot.model then
			brainrot.model:Destroy()
			brainrot.model = nil
		end
		record.slots[slotIndex] = nil
	end
	record.cash = 0
	record.rebirths += 1
	record.multiplier = 1 + record.rebirths * Config.REBIRTH_MULTIPLIER
	record.lockUntil = 0
	record.lockCooldownUntil = 0
	State.syncAttributes(record)
	Carry.refreshAllSlotPrompts()
	return true, "Rebirth " .. record.rebirths .. "! Income x" .. record.multiplier
end

return Rebirth
