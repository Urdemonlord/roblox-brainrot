# Steal a Brainrot

A 3D Roblox game in the Steal a Brainrot genre, built for make.fun's
`roblox-brainrot-01` bounty. A Rojo project: `rojo build` compiles
`src/` into `game.rbxl`, and `main.ts` (Node 22, standard library only)
hands the game in.

## The game

Brainrot characters walk along a central conveyor belt. Grab one (E),
carry it to your base, and place it in a slot: it earns $/sec forever.
Climb the rarity ladder, chase Golden / Diamond / Rainbow mutations,
rebirth for a permanent income multiplier and more slots, and lock your
base before someone steals your best brainrot out from under you.

- **12 named characters across 5 rarities**: Common (Chimpanzini
  Bananini, Trippi Troppi, Tung Tung Tung Sahur), Rare (Brr Brr
  Patapim, Tralalero Tralala, Lirili Larila), Epic (Cappuccino
  Assassino, Bombardiro Crocodilo, Ballerina Cappuccina), Legendary
  (Frigo Camelo, La Vaca Saturno Saturnita), Mythic (Los Tralaleritos).
- **Stealing**: hold E on a brainrot in an unlocked base to steal it.
  The owner has 10 seconds to touch you and win it back. Lock your
  base for 30 seconds (60 second recharge) to stop thieves cold.
- **Timed events** (rotating every 150s): Golden Hour (income x2),
  Brainrot Rush (faster, rarer spawns), Thief Raid (all locks break,
  guard your base yourself).
- **Rebirth**: spend a growing pile of cash to reset your base for +25%
  income per rebirth and +2 slots.

## Layout

- `src/shared/` — `BrainrotData.luau` (the cast) and `Config.luau`
  (every tuning number). Replicated to client and server.
- `src/server/` — one module per job: `State` (the single source of
  truth), `World` (the map), `BrainrotFactory` (character models +
  labels), `Spawner` (the belt), `Carry` (take / place / steal),
  `Income` (the $/sec tick), `Events` (timed events), `Rebirth`,
  `Remotes` (lock + rebirth requests, notifications).
- `src/client/` — `UI.luau` (HUD) and `Game.client.luau` (wiring).
  The client never owns game state.
- `screenshots/` — 3-4 captures of the game running in Roblox Studio;
  the first by name is the cover. One of them is the thumbnail uploaded
  for the game on Roblox.
- `PLAY.json` — the published place (url, place_id, universe_id).
- `TOUR.json` — the optional tour: keys that bring the game to each
  screenshot.

## Build and hand in

```sh
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

`main.ts` copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json`
to `/output` and writes `/output/dossier.json` with
`vendor/makefun-roblox.ts`, the kit's copy, unchanged.
