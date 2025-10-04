local WorldSystem = {}
local WorldData = require(game.ServerStorage.Data.WorldData)
local LoadWorldEvent = game.ReplicatedStorage.RemoteEvents.LoadWorldEvent
local NextLevelEvent = game.ReplicatedStorage.RemoteEvents.NextLevelEvent
local PreviousLevelEvent = game.ReplicatedStorage.RemoteEvents.PreviousLevelEvent
local LevelAmount = 50
local EnemySystem = require(game.ServerScriptService.SystemScripts.EnemySystem)


function WorldSystem.loadWorld(Player)
	local PlayerData = Player:WaitForChild("PlayerData")
	local PlayerWorldRotation = PlayerData.WorldRotation.Value

	local worlds = {"World1", "World2", "World3", "World4", "World5"}
	local index = ((PlayerWorldRotation - 1) % #worlds) + 1
	local PlayerWorld = worlds[index]

	local PlayerLevel = PlayerData.CurrentWorldLevel.Value

	for _,worlds in ipairs(workspace.Worlds:GetChildren()) do

		if worlds.Name == PlayerWorld then
			print("PLAYER WORLD IS: " .. worlds.Name)
			print("PLAYER WORLD LEVEL IS: " .. PlayerLevel)
			for _,objects in ipairs(worlds:GetChildren()) do
				if objects:IsA("Model") then
					objects.Transparency = 0
				end
			end
		else
			for _,objects in ipairs(worlds:GetChildren()) do
				if objects:IsA("Model") then
					objects.Transparency = 1
				end
			end
		end
	end
end

function WorldSystem.NextLevel(Player)
	local PlayerData = Player:WaitForChild("PlayerData")

	--3-5
	--3-1


	if PlayerData.CurrentWorld.Value < PlayerData.HighestWorld.Value then
		-- GARUNTEED ABLE TO GO TO NEXT LEVEL
		if PlayerData.CurrentWorldLevel.Value < LevelAmount then
			PlayerData.CurrentWorldLevel.Value += 1
			if PlayerData.CurrentWorldLevel.Value % PlayerData.BossLevel.Value == 0 then
				PlayerData.CurrentKills.Value = 1
			else
				PlayerData.CurrentKills.Value = 10
			end

			NextLevelEvent:FireClient(Player, true)
			EnemySystem.DespawnEnemy(Player)
			return
		else
			PlayerData.CurrentWorldLevel.Value = 1
			PlayerData.CurrentWorld.Value += 1
			if PlayerData.CurrentWorldLevel.Value % PlayerData.BossLevel.Value == 0 then
				PlayerData.CurrentKills.Value = 1
			else
				PlayerData.CurrentKills.Value = 10
			end
			NextLevelEvent:FireClient(Player, true)
			EnemySystem.DespawnEnemy(Player)
			return
		end
	end




	if PlayerData.CurrentWorld.Value == PlayerData.HighestWorld.Value then
		-- MUST CHECK PLAYER LEVEL

		--If Current PB and moving on
		if PlayerData.CurrentWorldLevel.Value == PlayerData.HighestLevel.Value then
			if PlayerData.CurrentWorldLevel.Value % PlayerData.BossLevel.Value == 0 then
				if PlayerData.CurrentKills.Value == 1 then
					if PlayerData.CurrentWorldLevel.Value < LevelAmount then
						PlayerData.CurrentWorldLevel.Value += 1
						PlayerData.CurrentKills.Value = 0
						PlayerData.HighestKills.Value = 0
						PlayerData.HighestLevel.Value = PlayerData.CurrentWorldLevel.Value
						NextLevelEvent:FireClient(Player, true)
						EnemySystem.DespawnEnemy(Player)
						return
					else
						PlayerData.CurrentWorldLevel.Value = 1
						PlayerData.CurrentWorld.Value += 1
						PlayerData.CurrentKills.Value = 0
						PlayerData.HighestKills.Value = 0
						PlayerData.HighestLevel.Value = PlayerData.CurrentWorldLevel.Value
						PlayerData.HighestWorld.Value = PlayerData.CurrentWorld.Value
						NextLevelEvent:FireClient(Player, true)
						EnemySystem.DespawnEnemy(Player)
						return
					end
				end
			else
				if PlayerData.CurrentKills.Value == 10 then
					if PlayerData.CurrentWorldLevel.Value < LevelAmount then
						PlayerData.CurrentWorldLevel.Value += 1
						PlayerData.CurrentKills.Value = 0
						PlayerData.HighestKills.Value = 0
						PlayerData.HighestLevel.Value = PlayerData.CurrentWorldLevel.Value
						NextLevelEvent:FireClient(Player, true)
						EnemySystem.DespawnEnemy(Player)
						return
					else
						PlayerData.CurrentWorldLevel.Value = 1
						PlayerData.CurrentWorld.Value += 1
						PlayerData.CurrentKills.Value = 0
						PlayerData.HighestKills.Value = 0
						PlayerData.HighestLevel.Value = PlayerData.CurrentWorldLevel.Value
						PlayerData.HighestWorld.Value = PlayerData.CurrentWorld.Value
						NextLevelEvent:FireClient(Player, true)
						EnemySystem.DespawnEnemy(Player)
						return
					end

				end
			end
		end

		--If Level Right before highest
		if PlayerData.CurrentWorldLevel.Value == PlayerData.HighestLevel.Value - 1 then
			PlayerData.CurrentKills.Value = PlayerData.HighestKills.Value
			PlayerData.CurrentWorldLevel.Value += 1
			NextLevelEvent:FireClient(Player, true)
			EnemySystem.DespawnEnemy(Player)
			return
		end



		--If just any random world
		if PlayerData.CurrentWorldLevel.Value < PlayerData.HighestLevel.Value then
			if PlayerData.CurrentWorldLevel.Value < LevelAmount then
				PlayerData.CurrentWorldLevel.Value += 1
				if PlayerData.CurrentWorldLevel.Value % PlayerData.BossLevel.Value == 0 then
					PlayerData.CurrentKills.Value = 1
				else
					PlayerData.CurrentKills.Value = 10
				end
				NextLevelEvent:FireClient(Player, true)
				EnemySystem.DespawnEnemy(Player)
				return
			else
				PlayerData.CurrentWorldLevel.Value = 1
				PlayerData.CurrentWorld.Value += 1
				PlayerData.CurrentKills.Value = 10
				NextLevelEvent:FireClient(Player, true)
				EnemySystem.DespawnEnemy(Player)
				return
			end
		end
	end



	NextLevelEvent:FireClient(Player, false)

end

function WorldSystem.PreviousLevel(Player)
	local PlayerData = Player:WaitForChild("PlayerData")
	if PlayerData.CurrentWorld.Value == 1 and PlayerData.CurrentWorldLevel.Value == 1 then
		print("YOU WORLD 1-1 CANT GO BACK")
		PreviousLevelEvent:FireClient(Player,false)
		return
	end


	if PlayerData.HighestWorld.Value >= PlayerData.CurrentWorld.Value then
		

		if PlayerData.CurrentWorldLevel.Value ~= 1 then
			PlayerData.CurrentWorldLevel.Value -= 1
			if PlayerData.CurrentWorldLevel.Value % PlayerData.BossLevel.Value == 0 then
				print("GOING INTO BOSS WORLD")
				PlayerData.CurrentKills.Value = 1
			else
				PlayerData.CurrentKills.Value = 10
			end
			PreviousLevelEvent:FireClient(Player,true)
			EnemySystem.DespawnEnemy(Player)
			return
		end
		if PlayerData.CurrentWorld.Value ~= 1 then
			PlayerData.CurrentWorld.Value -= 1
			PlayerData.CurrentWorldLevel.Value = LevelAmount
			PlayerStats.HighestKills.Value = 0
			PreviousLevelEvent:FireClient(Player,true)
			EnemySystem.DespawnEnemy(Player)
			return
		end
		PreviousLevelEvent:FireClient(Player,true)
		EnemySystem.DespawnEnemy(Player)
	end
end


return WorldSystem
