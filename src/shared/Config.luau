-- Steal a Brainrot: tuning constants. One place for every number the
-- other modules use, so balance changes never touch game logic.
local Config = {}

-- Conveyor belt (runs along X at Z = 0, top at Y = 1).
Config.BELT_HALF_LENGTH = 90
Config.BELT_WIDTH = 10
Config.BELT_TOP_Y = 1
Config.BELT_WALK_SPEED = 4 -- studs per second
Config.SPAWN_INTERVAL = 4 -- seconds between spawns (halved during Rush)
Config.MAX_ON_BELT = 10
Config.BELT_START_X = -88

-- Player plots: 6 plots, 3 per side of the belt.
Config.PLOT_POSITIONS = {
	Vector3.new(-60, 0, -45),
	Vector3.new(0, 0, -45),
	Vector3.new(60, 0, -45),
	Vector3.new(-60, 0, 45),
	Vector3.new(0, 0, 45),
	Vector3.new(60, 0, 45),
}
Config.PLOT_SIZE = 40
Config.PLOT_COLORS = {
	Color3.fromRGB(45, 140, 255),
	Color3.fromRGB(255, 90, 90),
	Color3.fromRGB(90, 220, 120),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(190, 110, 255),
	Color3.fromRGB(255, 130, 200),
}

-- Base slots: 2 rows x 4 columns, laid out on the plot.
Config.BASE_SLOTS = 8
Config.SLOTS_PER_REBIRTH = 2
Config.MAX_SLOTS = 16
Config.SLOT_SPACING_X = 8
Config.SLOT_SPACING_Z = 9
Config.SLOT_ROW_Z = { -8, 8 } -- relative to plot centre

-- Carrying.
Config.WALK_SPEED_NORMAL = 16
Config.WALK_SPEED_CARRYING = 12
Config.STEAL_GRACE_SECONDS = 10 -- owner can touch the thief to win it back
Config.CARRY_HEIGHT = 4.2 -- studs above the head while carried

-- Base lock.
Config.LOCK_DURATION = 30
Config.LOCK_COOLDOWN = 60 -- after the lock ends

-- Rebirth.
Config.REBIRTH_BASE_COST = 10000
Config.REBIRTH_COST_GROWTH = 2 -- cost doubles per rebirth
Config.REBIRTH_MULTIPLIER = 0.25 -- +25% income per rebirth

-- Timed events: first event 60s after the server starts, then every 150s.
Config.FIRST_EVENT_DELAY = 60
Config.EVENT_CYCLE_SECONDS = 150
Config.EVENTS = {
	{ name = "GOLDEN HOUR", duration = 60, incomeMultiplier = 2, color = Color3.fromRGB(255, 210, 60) },
	{ name = "BRAINROT RUSH", duration = 45, incomeMultiplier = 1, color = Color3.fromRGB(90, 220, 120) },
	{ name = "THIEF RAID", duration = 30, incomeMultiplier = 1, color = Color3.fromRGB(255, 60, 60) },
}

-- Rarity roll weights (out of 100). Rush shifts these toward rare.
Config.RARITY_WEIGHTS = { Common = 55, Rare = 25, Epic = 12, Legendary = 6, Mythic = 2 }
Config.RARITY_WEIGHTS_RUSH = { Common = 40, Rare = 30, Epic = 18, Legendary = 9, Mythic = 3 }

-- Cash.
Config.START_CASH = 0

return Config
