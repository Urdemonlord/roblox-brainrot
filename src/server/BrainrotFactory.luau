-- Steal a Brainrot: character factory. Turns a BrainrotData definition
-- into a 3D Model: body, eyes, legs, accessories, and the BillboardGui
-- label (name / rarity / $/sec / mutation) the judge reads.
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))

local BrainrotFactory = {}

local function makePart(shape, size, color, parent)
	local p
	if shape == "Wedge" then
		p = Instance.new("WedgePart")
	else
		p = Instance.new("Part")
		p.Shape = Enum.PartType[shape] or Enum.PartType.Block
	end
	p.Size = size
	p.Color = color
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- Mutation look: Golden / Diamond / Rainbow recolour the body.
local function mutationTint(def, mutation)
	if mutation == "Golden" then
		return Color3.fromRGB(255, 200, 40), Enum.Material.Metal
	elseif mutation == "Diamond" then
		return Color3.fromRGB(150, 230, 255), Enum.Material.Neon
	elseif mutation == "Rainbow" then
		return Color3.fromRGB(255, 90, 200), Enum.Material.Neon
	end
	return def.bodyColor, Enum.Material.SmoothPlastic
end

function BrainrotFactory.build(def, mutation)
	local model = Instance.new("Model")
	model.Name = def.id

	local tint, material = mutationTint(def, mutation)

	-- Body (the PrimaryPart everything else hangs off).
	local body = makePart(def.bodyShape, def.bodySize, tint, model)
	body.Name = "Body"
	body.Material = material
	model.PrimaryPart = body

	-- Eyes on the +Z face.
	local eyeY = def.bodySize.Y * 0.18
	local eyeZ = def.bodySize.Z / 2 + 0.05
	for _, side in ipairs({ -1, 1 }) do
		local eye = makePart("Ball", Vector3.new(0.45, 0.55, 0.3), Color3.fromRGB(255, 255, 255), model)
		eye.Name = "Eye"
		eye.Position = body.Position + Vector3.new(side * 0.55, eyeY, eyeZ)
		local pupil = makePart("Ball", Vector3.new(0.22, 0.28, 0.15), Color3.fromRGB(20, 20, 20), model)
		pupil.Name = "Pupil"
		pupil.Position = body.Position + Vector3.new(side * 0.55, eyeY, eyeZ + 0.15)
	end

	-- Legs.
	local legY = -def.bodySize.Y / 2 - 0.35
	for _, side in ipairs({ -1, 1 }) do
		local leg = makePart("Block", Vector3.new(0.6, 0.8, 0.6), Color3.fromRGB(40, 40, 40), model)
		leg.Name = "Leg"
		leg.Position = body.Position + Vector3.new(side * 0.55, legY, 0)
	end

	-- Accessories from the definition.
	for i, spec in ipairs(def.accessories) do
		local acc = makePart(spec.shape, spec.size, spec.color, model)
		acc.Name = "Accessory" .. i
		acc.Position = body.Position + spec.offset
		acc.Rotation = spec.rotation
	end

	-- Label: name, rarity, $/sec, mutation. Always on top so it reads
	-- in screenshots from any angle.
	local rate = BrainrotData.rateFor(def, mutation)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.new(6, 0, 2.6, 0)
	gui.StudsOffsetWorldSpace = Vector3.new(0, def.bodySize.Y / 2 + 2.2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.34, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = def.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Parent = gui

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Position = UDim2.new(0, 0, 0.34, 0)
	rarityLabel.Size = UDim2.new(1, 0, 0.33, 0)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = def.rarity .. (mutation ~= "Normal" and (" - " .. mutation) or "")
	rarityLabel.TextColor3 = BrainrotData.RARITY_COLORS[def.rarity]
	rarityLabel.TextStrokeTransparency = 0.2
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.SourceSansBold
	rarityLabel.Parent = gui

	local rateLabel = Instance.new("TextLabel")
	rateLabel.Position = UDim2.new(0, 0, 0.67, 0)
	rateLabel.Size = UDim2.new(1, 0, 0.33, 0)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = "$" .. rate .. "/s"
	rateLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	rateLabel.TextStrokeTransparency = 0.2
	rateLabel.TextScaled = true
	rateLabel.Font = Enum.Font.SourceSansBold
	rateLabel.Parent = gui

	return model
end

-- (Re)attach the interaction prompt to a model. The caller owns the
-- Triggered connection; this only creates the prompt itself.
function BrainrotFactory.attachPrompt(model, actionText, objectText)
	local old = model.PrimaryPart:FindFirstChild("Prompt")
	if old then
		old:Destroy()
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Prompt"
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = model.PrimaryPart
	return prompt
end

function BrainrotFactory.removePrompt(model)
	if model.PrimaryPart then
		local old = model.PrimaryPart:FindFirstChild("Prompt")
		if old then
			old:Destroy()
		end
	end
end

return BrainrotFactory
