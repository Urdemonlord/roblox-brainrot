-- Steal a Brainrot: client entrypoint. Builds the HUD, mirrors server
-- attributes into it, and fires the two RemoteEvents (lock, rebirth).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(script.Parent:WaitForChild("UI"))

local player = Players.LocalPlayer
local handles = UI.build()

local requestLock = ReplicatedStorage:WaitForChild("RequestLock")
local requestRebirth = ReplicatedStorage:WaitForChild("RequestRebirth")
local notifyEvent = ReplicatedStorage:WaitForChild("Notify")

local function money(n)
	local s = tostring(math.floor(n))
	local out = ""
	while #s > 3 do
		out = "," .. string.sub(s, -3) .. out
		s = string.sub(s, 1, -4)
	end
	return "$" .. s .. out
end

local function refresh()
	handles.cash.Text = "  " .. money(player:GetAttribute("Cash") or 0)
	handles.income.Text = "  $" .. (player:GetAttribute("IncomePerSec") or 0) .. "/s"
	local rebirths = player:GetAttribute("Rebirths") or 0
	local mult = player:GetAttribute("Multiplier") or 1
	handles.rebirths.Text = "Rebirths: " .. rebirths .. "  (x" .. mult .. ")  "
	handles.rebirthButton.Text = "REBIRTH  " .. money(player:GetAttribute("RebirthCost") or 0) .. "  "
	local lockRemaining = player:GetAttribute("LockRemaining") or 0
	local lockCooldown = player:GetAttribute("LockCooldown") or 0
	if lockRemaining > 0 then
		handles.lockButton.Text = "LOCKED  " .. lockRemaining .. "s"
	elseif lockCooldown > 0 then
		handles.lockButton.Text = "LOCK  (" .. lockCooldown .. "s)"
	else
		handles.lockButton.Text = "LOCK BASE"
	end
	local carrying = player:GetAttribute("Carrying") or ""
	if carrying ~= "" then
		handles.carrying.Text = "Carrying: " .. carrying .. "  — take it to your base!"
		handles.carrying.Visible = true
	else
		handles.carrying.Visible = false
	end
end

for _, attr in ipairs({ "Cash", "IncomePerSec", "Rebirths", "Multiplier", "LockRemaining", "LockCooldown", "RebirthCost", "Carrying" }) do
	player:GetAttributeChangedSignal(attr):Connect(refresh)
end
refresh()

-- Event banner + countdown (server sends the wall-clock end time).
local function refreshEvent()
	local name = ReplicatedStorage:GetAttribute("EventName") or ""
	if name == "" then
		handles.banner.Visible = false
		return
	end
	handles.banner.Visible = true
	local endsAt = ReplicatedStorage:GetAttribute("EventEndsAt") or 0
	local remaining = math.max(0, endsAt - os.time())
	handles.banner.Text = name .. "  —  " .. remaining .. "s"
	local r = ReplicatedStorage:GetAttribute("EventColorR") or 1
	local g = ReplicatedStorage:GetAttribute("EventColorG") or 1
	local b = ReplicatedStorage:GetAttribute("EventColorB") or 1
	handles.banner.TextColor3 = Color3.new(r, g, b)
end

for _, attr in ipairs({ "EventName", "EventEndsAt", "EventColorR", "EventColorG", "EventColorB" }) do
	ReplicatedStorage:GetAttributeChangedSignal(attr):Connect(refreshEvent)
end
refreshEvent()
task.spawn(function()
	while true do
		task.wait(0.5)
		refreshEvent()
		refresh()
	end
end)

handles.lockButton.Activated:Connect(function()
	requestLock:FireServer()
end)

handles.rebirthButton.Activated:Connect(function()
	requestRebirth:FireServer()
end)

local alertUntil = 0
notifyEvent.OnClientEvent:Connect(function(message)
	handles.alert.Text = message
	handles.alert.Visible = true
	alertUntil = os.clock() + 5
end)
task.spawn(function()
	while true do
		task.wait(0.5)
		if handles.alert.Visible and os.clock() > alertUntil then
			handles.alert.Visible = false
		end
	end
end)
