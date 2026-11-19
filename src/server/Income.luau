-- Steal a Brainrot: income. One tick per second pays every player for
-- the brainrots standing in their base slots. Nothing else mints cash.
local State = require(script.Parent:WaitForChild("State"))

local Income = {}

function Income.start()
	task.spawn(function()
		while true do
			task.wait(1)
			for _, record in pairs(State.players) do
				local earned = State.incomePerSecond(record)
				if earned > 0 then
					record.cash += earned
				end
				State.syncAttributes(record)
			end
		end
	end)
end

return Income
