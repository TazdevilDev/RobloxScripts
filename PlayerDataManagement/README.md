The Player Data Manager uses and handles saving, loading, and managing persistent 
player data in a Roblox game using the Roblox DataStore API.

Features:
- Saves and restores player progress across sessions.
- Assigns default stats and upgrade values for new players.
- Automatically adds new upgrade entries if the game introduces them after a player’s initial save.
- Stores basic player stats (coins, levels, kills, etc.).
- Supports complex upgrade trees with levels, descriptions, damage scaling, pricing, and attack speed.
- Sends requested data values to clients on demand for UI updates.
- Wraps Roblox’s DataStore calls in pcall for error handling.


How It Works:

- When a Player joins the game, it searches for saved data from DataStore.
- If no data exists, applies default stats and upgrades.
- Builds PlayerData and UpgradeData folders under each player for in-game access.
- Ensures any new upgrades (added to ServerStorage.Upgrades) are injected into older player saves.
- When a Player leaves the game, Collects current player stats and upgrade information.
- Saves the data as a single structured table in DataStore.

