A modular combat system for Roblox RPG/Clicker-style games. Handles enemy spawning, stat scaling, 
boss fights, and integrates with player data and GUI systems.

Features:

- Randomized enemy and boss spawning.
- Procedural stat scaling for health, rewards, and level progression.
- Boss fight system with timers and GUI updates.
- Supports both player-driven and idle attack mechanics.
- Modular design (EnemySystem module) for reusability and integration with other systems.

How It Works:

- On spawn, the system selects either a random enemy or boss based on player progression.
- Stats (Health, Reward, Level) are calculated dynamically using exponential scaling formulas.
- Bosses are spawned on level milestones and include a countdown timer. If not defeated, they despawn automatically.
- Attacks reduce health and reward players with coins. Once defeated, a new enemy is spawned automatically.

Example:

local EnemySystem = require(game.ServerScriptService.SystemScripts.EnemySystem)

Spawn a new enemy for the player:

EnemySystem.spawnEnemy(player)

Player performs an attack:

EnemySystem.playerAttack(player)

Idle/auto-attack system triggers damage:

EnemySystem.GameAttack(player, upgradeData)
