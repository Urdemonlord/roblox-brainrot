-- Steal a Brainrot: client HUD. Shows cash, income, rebirths, the
-- event banner, the lock and rebirth buttons, and server notifications.
-- The client never owns game state: every number comes from player
-- attributes the server syncs, every action is a RemoteEvent.
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local UI = {}

local function label(name, parent, position, size, textSize, color, anchor)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.AnchorPoint = anchor or Vector2.new(0, 0)
	l.Position = position
	l.Size = size
	l.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	l.BackgroundTransparency = 0.3
	l.BorderSizePixel = 0
	l.Text = ""
	l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	l.TextSize = textSize
	l.Font = Enum.Font.SourceSansBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function button(name, parent, position, size, text, color)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = position
	b.Size = size
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 20
	b.Font = Enum.Font.SourceSansBold
	b.Parent = parent
	return b
end

function UI.build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true

	-- Top-left: cash + income.
	local cash = label("Cash", gui, UDim2.new(0, 12, 0, 12), UDim2.fromOffset(280, 44), 26, Color3.fromRGB(120, 255, 120))
	local income = label("Income", gui, UDim2.new(0, 12, 0, 60), UDim2.fromOffset(280, 30), 18, Color3.fromRGB(200, 255, 200))

	-- Top-right: rebirths + rebirth button.
	local rebirths = label("Rebirths", gui, UDim2.new(1, -292, 0, 12), UDim2.fromOffset(280, 30), 18, Color3.fromRGB(255, 255, 255))
	rebirths.TextXAlignment = Enum.TextXAlignment.Right
	local rebirthButton = button("RebirthButton", gui, UDim2.new(1, -292, 0, 46), UDim2.fromOffset(280, 40), "REBIRTH", Color3.fromRGB(150, 80, 220))
	rebirthButton.TextXAlignment = Enum.TextXAlignment.Right

	-- Top-centre: event banner (hidden when no event).
	local banner = label("EventBanner", gui, UDim2.new(0.5, -220, 0, 12), UDim2.fromOffset(440, 44), 24, Color3.fromRGB(255, 210, 60))
	banner.TextXAlignment = Enum.TextXAlignment.Center
	banner.Visible = false

	-- Alert line under the banner.
	local alert = label("Alert", gui, UDim2.new(0.5, -300, 0, 62), UDim2.fromOffset(600, 30), 18, Color3.fromRGB(255, 220, 220))
	alert.TextXAlignment = Enum.TextXAlignment.Center
	alert.Visible = false

	-- Bottom-centre: lock button + carrying line.
	local lockButton = button("LockButton", gui, UDim2.new(0.5, -110, 1, -64), UDim2.fromOffset(220, 44), "LOCK BASE", Color3.fromRGB(60, 160, 80))
	local carrying = label("Carrying", gui, UDim2.new(0.5, -220, 1, -108), UDim2.fromOffset(440, 30), 18, Color3.fromRGB(255, 255, 255))
	carrying.TextXAlignment = Enum.TextXAlignment.Center
	carrying.Visible = false

	-- Bottom-left: how to play.
	local help = label("Help", gui, UDim2.new(0, 12, 1, -92), UDim2.fromOffset(340, 80), 15, Color3.fromRGB(230, 230, 230))
	help.Text = "E: take / place / steal\nWalk to your base to place.\nLock your base to stop thieves."
	help.TextYAlignment = Enum.TextYAlignment.Top

	gui.Parent = player:WaitForChild("PlayerGui")
	return {
		gui = gui,
		cash = cash,
		income = income,
		rebirths = rebirths,
		rebirthButton = rebirthButton,
		banner = banner,
		alert = alert,
		lockButton = lockButton,
		carrying = carrying,
	}
end

return UI
