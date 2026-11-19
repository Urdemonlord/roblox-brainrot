-- Steal a Brainrot: world. Builds every static part of the place
-- (ground, conveyor, plots, spawn, sign, trees) from code, so the whole
-- map is versioned in src/ and rebuilds with `rojo build`.
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local World = {}

-- shape is "Ball", "Block", "Cylinder" or "Wedge" (WedgePart is its own
-- class; the others are Part.Shape values).
local function part(name, shape, size, position, color, anchored, parent)
	local p
	if shape == "Wedge" then
		p = Instance.new("WedgePart")
	else
		p = Instance.new("Part")
		p.Shape = Enum.PartType[shape] or Enum.PartType.Block
	end
	p.Name = name
	p.Size = size
	p.Position = position
	p.Color = color
	p.Anchored = anchored ~= false
	p.CanCollide = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- Slot pads for a plot. Returns the list of slot world positions.
function World.buildPlot(plotIndex, plotPos, color, ownerName)
	local plot = Instance.new("Folder")
	plot.Name = "Plot" .. plotIndex
	plot.Parent = workspace

	-- Platform.
	local platform = part("Platform", "Part", Vector3.new(Config.PLOT_SIZE, 2, Config.PLOT_SIZE), plotPos, Color3.fromRGB(120, 200, 120), true, plot)
	platform.Material = Enum.Material.Grass

	-- Coloured border frame.
	local border = part("Border", "Part", Vector3.new(Config.PLOT_SIZE + 2, 0.6, Config.PLOT_SIZE + 2), plotPos + Vector3.new(0, 1.2, 0), color, true, plot)
	border.Material = Enum.Material.Neon
	border.CanCollide = false

	-- Owner sign.
	local sign = part("Sign", "Part", Vector3.new(12, 4, 1), plotPos + Vector3.new(0, 6, -Config.PLOT_SIZE / 2 + 1), Color3.fromRGB(30, 30, 40), true, plot)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = ownerName
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = gui

	-- Slot pads (2 rows x 4 columns) + their world positions.
	local positions = {}
	local pads = {}
	for row = 1, 2 do
		for col = 1, 4 do
			local slotIndex = (row - 1) * 4 + col
			local x = plotPos.X + (col - 2.5) * Config.SLOT_SPACING_X
			local z = plotPos.Z + Config.SLOT_ROW_Z[row]
			local pad = part("Slot" .. slotIndex, "Part", Vector3.new(6, 0.5, 6), Vector3.new(x, 1.3, z), Color3.fromRGB(255, 255, 255), true, plot)
			pad.Material = Enum.Material.Neon
			pad.Transparency = 0.6
			pad.CanCollide = false
			positions[slotIndex] = Vector3.new(x, 1.6, z)
			pads[slotIndex] = pad
		end
	end

	-- Lock indicator: a beacon that turns red while the base is locked.
	local beacon = part("LockBeacon", "Part", Vector3.new(2, 6, 2), plotPos + Vector3.new(Config.PLOT_SIZE / 2 - 2, 4, -Config.PLOT_SIZE / 2 + 2), Color3.fromRGB(90, 220, 120), true, plot)
	beacon.Material = Enum.Material.Neon
	beacon.CanCollide = false

	return { folder = plot, slotPositions = positions, pads = pads, beacon = beacon, signLabel = label }
end

function World.build()
	local world = Instance.new("Folder")
	world.Name = "World"
	world.Parent = workspace

	-- Ground.
	part("Ground", "Part", Vector3.new(260, 2, 260), Vector3.new(0, -1, 0), Color3.fromRGB(90, 180, 90), true, world).Material =
		Enum.Material.Grass

	-- Central plaza around the spawn.
	part("Plaza", "Part", Vector3.new(30, 0.6, 20), Vector3.new(0, 0.3, 24), Color3.fromRGB(180, 180, 190), true, world).Material =
		Enum.Material.Concrete

	-- Conveyor belt: a raised dark belt with chevron arrows.
	local belt = part("Belt", "Part", Vector3.new(Config.BELT_HALF_LENGTH * 2, 2, Config.BELT_WIDTH), Vector3.new(0, 0, 0), Color3.fromRGB(40, 40, 50), true, world)
	belt.Material = Enum.Material.Metal
	for x = -80, 80, 20 do
		local arrow = part("Arrow", "Part", Vector3.new(4, 0.3, 6), Vector3.new(x, 1.1, 0), Color3.fromRGB(255, 210, 60), true, world)
		arrow.Material = Enum.Material.Neon
		arrow.CanCollide = false
	end
	-- Belt side rails.
	part("RailNorth", "Part", Vector3.new(Config.BELT_HALF_LENGTH * 2, 1.5, 1), Vector3.new(0, 1.5, -Config.BELT_WIDTH / 2 - 0.5), Color3.fromRGB(255, 210, 60), true, world)
	part("RailSouth", "Part", Vector3.new(Config.BELT_HALF_LENGTH * 2, 1.5, 1), Vector3.new(0, 1.5, Config.BELT_WIDTH / 2 + 0.5), Color3.fromRGB(255, 210, 60), true, world)

	-- Spawn location (players appear on the plaza).
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 1, 24)
	spawn.Color = Color3.fromRGB(90, 220, 120)
	spawn.Anchored = true
	spawn.Duration = 0
	spawn.AllowTeamChangeOnTouch = false
	spawn.Neutral = true
	spawn.Parent = world

	-- Big title sign behind the belt.
	local board = part("TitleBoard", "Part", Vector3.new(46, 10, 1), Vector3.new(0, 8, -32), Color3.fromRGB(25, 25, 35), true, world)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.6, 0)
	title.BackgroundTransparency = 1
	title.Text = "STEAL A BRAINROT"
	title.TextColor3 = Color3.fromRGB(255, 210, 60)
	title.TextScaled = true
	title.Font = Enum.Font.SourceSansBold
	title.Parent = gui
	local sub = Instance.new("TextLabel")
	sub.Position = UDim2.new(0, 0, 0.6, 0)
	sub.Size = UDim2.new(1, 0, 0.4, 0)
	sub.BackgroundTransparency = 1
	sub.Text = "Grab brainrots. Fill your base. Guard it with your life."
	sub.TextColor3 = Color3.fromRGB(255, 255, 255)
	sub.TextScaled = true
	sub.Font = Enum.Font.SourceSans
	sub.Parent = gui

	-- Support posts for the board.
	part("PostL", "Part", Vector3.new(1, 8, 1), Vector3.new(-20, 4, -32), Color3.fromRGB(60, 60, 70), true, world)
	part("PostR", "Part", Vector3.new(1, 8, 1), Vector3.new(20, 4, -32), Color3.fromRGB(60, 60, 70), true, world)

	-- Trees around the edges.
	local treeSpots = {
		Vector3.new(-100, 0, -80), Vector3.new(-40, 0, -90), Vector3.new(40, 0, -85), Vector3.new(100, 0, -75),
		Vector3.new(-105, 0, 40), Vector3.new(105, 0, 30), Vector3.new(-95, 0, 85), Vector3.new(95, 0, 80),
		Vector3.new(-50, 0, 90), Vector3.new(50, 0, 88),
	}
	for i, pos in ipairs(treeSpots) do
		local trunk = part("TreeTrunk" .. i, "Part", Vector3.new(2, 8, 2), pos + Vector3.new(0, 4, 0), Color3.fromRGB(120, 75, 35), true, world)
		trunk.Material = Enum.Material.Wood
		local leaves = part("TreeTop" .. i, "Ball", Vector3.new(9, 9, 9), pos + Vector3.new(0, 11, 0), Color3.fromRGB(40, 160, 70), true, world)
		leaves.Material = Enum.Material.Grass
	end

	return world
end

return World
