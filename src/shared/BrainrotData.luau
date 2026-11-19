-- Steal a Brainrot: the cast. Every character is data: name, rarity,
-- $/sec, body look and accessories. BrainrotFactory turns a definition
-- into a 3D model; nothing about a character lives anywhere else.
local BrainrotData = {}

BrainrotData.RARITIES = { "Common", "Rare", "Epic", "Legendary", "Mythic" }

BrainrotData.RARITY_COLORS = {
	Common = Color3.fromRGB(220, 220, 220),
	Rare = Color3.fromRGB(80, 170, 255),
	Epic = Color3.fromRGB(190, 110, 255),
	Legendary = Color3.fromRGB(255, 180, 40),
	Mythic = Color3.fromRGB(255, 70, 120),
}

-- Rarity order for the ladder (higher index = rarer).
BrainrotData.RARITY_RANK = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 }

-- Accessory spec: { shape, size, color, offset, rotation }
-- shape is a Part shape name ("Ball", "Block", "Cylinder", "Wedge").
-- offset/rotation are relative to the body centre, in studs / degrees.
local function acc(shape, size, color, offset, rotation)
	return { shape = shape, size = size, color = color, offset = offset, rotation = rotation or Vector3.new(0, 0, 0) }
end

BrainrotData.CHARACTERS = {
	-- Common
	{
		id = "chimpanzini",
		name = "Chimpanzini Bananini",
		rarity = "Common",
		rate = 5,
		bodyShape = "Ball",
		bodySize = Vector3.new(2.6, 2.6, 2.6),
		bodyColor = Color3.fromRGB(140, 95, 55),
		accessories = {
			acc("Cylinder", Vector3.new(0.7, 2.2, 0.7), Color3.fromRGB(255, 220, 60), Vector3.new(0.9, 1.6, 0), Vector3.new(0, 0, -35)),
		},
		tagline = "Monkey. Banana. Profit.",
	},
	{
		id = "trippi",
		name = "Trippi Troppi",
		rarity = "Common",
		rate = 6,
		bodyShape = "Ball",
		bodySize = Vector3.new(2.4, 2.4, 2.8),
		bodyColor = Color3.fromRGB(255, 140, 60),
		accessories = {
			acc("Wedge", Vector3.new(1.4, 1.2, 0.4), Color3.fromRGB(255, 90, 90), Vector3.new(0, 1.6, 0), Vector3.new(0, 0, 0)),
		},
		tagline = "A fish that learned to walk.",
	},
	{
		id = "tung",
		name = "Tung Tung Tung Sahur",
		rarity = "Common",
		rate = 8,
		bodyShape = "Block",
		bodySize = Vector3.new(1.8, 3.2, 1.8),
		bodyColor = Color3.fromRGB(120, 75, 35),
		accessories = {
			acc("Cylinder", Vector3.new(0.5, 2.4, 0.5), Color3.fromRGB(90, 55, 25), Vector3.new(1.5, 0.4, 0.6), Vector3.new(0, 0, 55)),
		},
		tagline = "He knocks three times. Always.",
	},
	-- Rare
	{
		id = "patapim",
		name = "Brr Brr Patapim",
		rarity = "Rare",
		rate = 15,
		bodyShape = "Ball",
		bodySize = Vector3.new(2.6, 2.8, 2.6),
		bodyColor = Color3.fromRGB(210, 180, 140),
		accessories = {
			acc("Cylinder", Vector3.new(0.6, 1.6, 0.6), Color3.fromRGB(210, 180, 140), Vector3.new(0, 0.4, 1.5), Vector3.new(90, 0, 0)),
			acc("Ball", Vector3.new(1.6, 1.2, 1.6), Color3.fromRGB(70, 180, 80), Vector3.new(0, 1.8, 0), Vector3.new(0, 0, 0)),
		},
		tagline = "A nose that knows things.",
	},
	{
		id = "tralala",
		name = "Tralalero Tralala",
		rarity = "Rare",
		rate = 20,
		bodyShape = "Ball",
		bodySize = Vector3.new(3.0, 2.2, 3.4),
		bodyColor = Color3.fromRGB(60, 140, 255),
		accessories = {
			acc("Wedge", Vector3.new(1.6, 1.4, 0.5), Color3.fromRGB(40, 110, 220), Vector3.new(0, 1.6, -0.4), Vector3.new(0, 0, 0)),
			acc("Wedge", Vector3.new(1.2, 1.0, 0.4), Color3.fromRGB(40, 110, 220), Vector3.new(0, 0.2, -1.9), Vector3.new(0, 0, 180)),
		},
		tagline = "A shark with places to be.",
	},
	{
		id = "lirili",
		name = "Lirili Larila",
		rarity = "Rare",
		rate = 25,
		bodyShape = "Block",
		bodySize = Vector3.new(2.6, 3.0, 2.6),
		bodyColor = Color3.fromRGB(70, 180, 90),
		accessories = {
			acc("Cylinder", Vector3.new(0.8, 2.0, 0.8), Color3.fromRGB(150, 150, 150), Vector3.new(0, 0.2, 1.6), Vector3.new(90, 0, 0)),
			acc("Block", Vector3.new(1.2, 1.4, 0.4), Color3.fromRGB(70, 180, 90), Vector3.new(-1.5, 0.8, 0), Vector3.new(0, 0, 20)),
			acc("Block", Vector3.new(1.2, 1.4, 0.4), Color3.fromRGB(70, 180, 90), Vector3.new(1.5, 0.8, 0), Vector3.new(0, 0, -20)),
		},
		tagline = "Half cactus, half elephant.",
	},
	-- Epic
	{
		id = "cappuccino",
		name = "Cappuccino Assassino",
		rarity = "Epic",
		rate = 50,
		bodyShape = "Cylinder",
		bodySize = Vector3.new(2.4, 2.8, 2.4),
		bodyColor = Color3.fromRGB(245, 240, 225),
		accessories = {
			acc("Block", Vector3.new(2.6, 0.5, 2.6), Color3.fromRGB(60, 40, 25), Vector3.new(0, 1.2, 0), Vector3.new(0, 0, 0)),
			acc("Block", Vector3.new(0.3, 2.6, 0.8), Color3.fromRGB(180, 180, 190), Vector3.new(1.2, 0.6, -0.8), Vector3.new(0, 0, 25)),
		},
		tagline = "Silent. Foamy. Deadly.",
	},
	{
		id = "bombardiro",
		name = "Bombardiro Crocodilo",
		rarity = "Epic",
		rate = 60,
		bodyShape = "Block",
		bodySize = Vector3.new(2.2, 2.2, 4.0),
		bodyColor = Color3.fromRGB(60, 160, 80),
		accessories = {
			acc("Block", Vector3.new(5.0, 0.3, 1.4), Color3.fromRGB(200, 200, 210), Vector3.new(0, 0.6, 0), Vector3.new(0, 0, 0)),
			acc("Block", Vector3.new(1.2, 1.0, 0.5), Color3.fromRGB(60, 160, 80), Vector3.new(0, 0.8, -1.9), Vector3.new(0, 0, 0)),
		},
		tagline = "A bomber plane that bites.",
	},
	{
		id = "ballerina",
		name = "Ballerina Cappuccina",
		rarity = "Epic",
		rate = 80,
		bodyShape = "Ball",
		bodySize = Vector3.new(2.4, 2.8, 2.4),
		bodyColor = Color3.fromRGB(255, 170, 210),
		accessories = {
			acc("Cylinder", Vector3.new(3.4, 0.3, 3.4), Color3.fromRGB(255, 220, 240), Vector3.new(0, -0.4, 0), Vector3.new(0, 0, 0)),
			acc("Ball", Vector3.new(1.0, 1.0, 1.0), Color3.fromRGB(120, 70, 40), Vector3.new(0, 1.8, 0), Vector3.new(0, 0, 0)),
		},
		tagline = "Pirouettes. Then invoices you.",
	},
	-- Legendary
	{
		id = "frigo",
		name = "Frigo Camelo",
		rarity = "Legendary",
		rate = 150,
		bodyShape = "Block",
		bodySize = Vector3.new(2.6, 3.6, 2.2),
		bodyColor = Color3.fromRGB(180, 220, 245),
		accessories = {
			acc("Ball", Vector3.new(1.2, 1.0, 1.2), Color3.fromRGB(210, 170, 110), Vector3.new(-0.6, 2.2, 0), Vector3.new(0, 0, 0)),
			acc("Ball", Vector3.new(1.2, 1.0, 1.2), Color3.fromRGB(210, 170, 110), Vector3.new(0.6, 2.2, 0), Vector3.new(0, 0, 0)),
			acc("Block", Vector3.new(0.3, 1.2, 0.3), Color3.fromRGB(120, 120, 130), Vector3.new(0.9, 0.4, 1.15), Vector3.new(0, 0, 0)),
		},
		tagline = "Keeps your food cold. Judges you.",
	},
	{
		id = "vaca",
		name = "La Vaca Saturno Saturnita",
		rarity = "Legendary",
		rate = 220,
		bodyShape = "Ball",
		bodySize = Vector3.new(3.0, 2.8, 3.0),
		bodyColor = Color3.fromRGB(250, 250, 250),
		accessories = {
			acc("Cylinder", Vector3.new(5.2, 0.25, 5.2), Color3.fromRGB(255, 200, 80), Vector3.new(0, 0.2, 0), Vector3.new(0, 0, 12)),
			acc("Cylinder", Vector3.new(0.4, 1.2, 0.4), Color3.fromRGB(220, 200, 160), Vector3.new(-1.0, 1.7, 0.6), Vector3.new(0, 0, 35)),
			acc("Cylinder", Vector3.new(0.4, 1.2, 0.4), Color3.fromRGB(220, 200, 160), Vector3.new(1.0, 1.7, 0.6), Vector3.new(0, 0, -35)),
		},
		tagline = "A cow with its own orbit.",
	},
	-- Mythic
	{
		id = "tralaleritos",
		name = "Los Tralaleritos",
		rarity = "Mythic",
		rate = 500,
		bodyShape = "Ball",
		bodySize = Vector3.new(3.2, 2.4, 3.6),
		bodyColor = Color3.fromRGB(70, 160, 255),
		accessories = {
			acc("Wedge", Vector3.new(1.8, 1.5, 0.5), Color3.fromRGB(45, 120, 230), Vector3.new(0, 1.7, -0.4), Vector3.new(0, 0, 0)),
			acc("Ball", Vector3.new(1.2, 1.0, 1.2), Color3.fromRGB(120, 200, 255), Vector3.new(-1.1, 1.0, 0.8), Vector3.new(0, 0, 0)),
			acc("Ball", Vector3.new(1.2, 1.0, 1.2), Color3.fromRGB(120, 200, 255), Vector3.new(1.1, 1.0, 0.8), Vector3.new(0, 0, 0)),
			acc("Cylinder", Vector3.new(1.4, 0.5, 1.4), Color3.fromRGB(255, 210, 60), Vector3.new(0, 1.9, 0), Vector3.new(0, 0, 0)),
		},
		tagline = "Three baby sharks. One allowance.",
	},
}

-- Lookups.
local byId = {}
local byRarity = {}
for _, def in ipairs(BrainrotData.CHARACTERS) do
	byId[def.id] = def
	byRarity[def.rarity] = byRarity[def.rarity] or {}
	table.insert(byRarity[def.rarity], def)
end

function BrainrotData.getById(id)
	return byId[id]
end

function BrainrotData.getByRarity(rarity)
	return byRarity[rarity] or {}
end

-- $/sec of a character with a mutation applied.
function BrainrotData.rateFor(def, mutation)
	local mult = 1
	if mutation and mutation ~= "Normal" then
		for _, m in ipairs(BrainrotData.MUTATIONS) do
			if m.name == mutation then
				mult = m.multiplier
				break
			end
		end
	end
	return def.rate * mult
end

BrainrotData.MUTATIONS = {
	{ name = "Golden", chance = 8, multiplier = 2, color = Color3.fromRGB(255, 200, 40) },
	{ name = "Diamond", chance = 2, multiplier = 5, color = Color3.fromRGB(140, 230, 255) },
	{ name = "Rainbow", chance = 0.5, multiplier = 10, color = Color3.fromRGB(255, 90, 200) },
}

return BrainrotData
