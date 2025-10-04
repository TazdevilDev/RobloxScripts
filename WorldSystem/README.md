A player progression manager for Roblox RPGs. Handles navigation through levels and worlds, 
integrates with enemy spawning, and ensures progression checks for bosses and milestones.

Features:

- Multi-world support with configurable level caps (default: 50 levels per world).
- Dynamic environment loading: makes only the active world visible.
- Progression checks for highest world, highest level, and boss kills.
- Integrates with EnemySystem to spawn/despawn enemies on world transitions.
- Remote events for client-side updates (NextLevelEvent, PreviousLevelEvent).


How It Works:

- Tracks player’s current world, level, and highest achievements.
- Controls whether the player can move forward/backward in progression.
- On progression, updates stats and triggers enemy despawning/respawning.
- Ensures boss fights act as gatekeepers for moving forward.


Example:

local WorldSystem = require(game.ServerScriptService.SystemScripts.WorldSystem)

Load current world environment for the player:
WorldSystem.loadWorld(player)

Advance to the next level:
WorldSystem.NextLevel(player)

Go back to a previous level:
WorldSystem.PreviousLevel(player)
