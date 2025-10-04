local EnemySystem = {}
local enemyBox = workspace.EnemyBox
local clickDetector = enemyBox.ClickDetector
local EnemyList = game.ReplicatedStorage.Enemies:GetChildren()
local BossList = game.ReplicatedStorage.Bosses:GetChildren()
local playerDmg = 1
local currentEnemyDropReward = enemyBox.DropReward.Value
local currentEnemyLevel = enemyBox.EnemyLevel.Value
local BossActive = false
local BossTimer
local function randomEnemyNumber()
	return math.random(1,#EnemyList)
end
local function randomBossNumber()
	return math.random(1,#BossList)
end

local function SetEnemyStats(Player)

	local CurrentEnemy = enemyBox.CurrentEnemy:GetChildren()
	local EnemyHealth = enemyBox.MaxHealth.Value
	local EnemyReward = enemyBox.DropReward.Value
	local EnemyLevel = enemyBox.EnemyLevel.Value
	local BaseHealth = 10
	local BaseReward = 1
	local BaseLevel = 1
	local PlayerData = Player:WaitForChild("PlayerData")
	local CurrentPlayerWorld = PlayerData.CurrentWorld.Value
	local CurrentPlayerLevel = PlayerData.CurrentWorldLevel.Value


	EnemyHealth = math.floor(BaseHealth * (1.05 ^ ((CurrentPlayerWorld * 50 + CurrentPlayerLevel) - 1)))


	EnemyReward = math.floor(BaseReward * (1.05 ^ ((CurrentPlayerWorld * 50 + CurrentPlayerLevel) - 1)))

	EnemyLevel = (((CurrentPlayerWorld - 1) * 50) + 1) * CurrentPlayerLevel

	-- 1-1: (((1 - 1) * 50) + 1) * 1 = 1
	-- 1-50: (((1 - 1) * 50) + 1) * 50 = 50
	-- 2-1: (((2 - 1) * 50) + 1) * 1 = = 51
	-- 3-1: (((3 - 1) * 50) + 1) * 1 = 101


	return EnemyHealth, EnemyReward, EnemyLevel
end

function EnemySystem.DespawnEnemy(Player)
	local CurrentEnemy = enemyBox.CurrentEnemy:GetChildren()
	CurrentEnemy[1]:Destroy()
	EnemySystem.spawnEnemy(Player)
end
function EnemySystem.spawnEnemy(Player)
	print("SPAWNING DA ENEMY")
	print(Player)


	local PlayerStats = Player:WaitForChild("PlayerData")
	local PlayerCurrentWorld = PlayerStats.CurrentWorld.Value
	local PlayerCurrentLevel = PlayerStats.CurrentWorldLevel.Value
	print(PlayerStats.CurrentWorldLevel.Value % PlayerStats.BossLevel.Value)
	if PlayerStats.CurrentWorldLevel.Value % PlayerStats.BossLevel.Value == 0 then
		local randomBoss = BossList[randomBossNumber()]
		local cloneBoss = randomBoss:Clone()
		local EnemyHealth, EnemyReward, EnemyLevel = SetEnemyStats(Player)
		cloneBoss.Parent = enemyBox.CurrentEnemy
		cloneBoss.CFrame = enemyBox.CFrame + Vector3.new(3,-4,0)
		enemyBox.MaxHealth.Value = EnemyHealth * 2.5
		enemyBox.CurrentHealth.Value = enemyBox.MaxHealth.Value
		enemyBox.DropReward.Value = EnemyReward * 2.5
		enemyBox.EnemyLevel.Value = EnemyLevel

		
		if not BossActive then
			BossActive = true
			
			BossTimer = task.spawn(function()
				local Timer = os.clock()
				local TimerDuration = Timer + 15
				Player.PlayerGui.MainGui.Frame.BossTimerFrame.Visible = true
				while os.clock() < TimerDuration and BossActive do
					local TimeLeft = TimerDuration - os.clock()
					Player.PlayerGui.MainGui.Frame.BossTimerFrame.Timer.Text = math.max(math.floor(TimeLeft * 10) / 10, 0)
					task.wait(0.1)
				end
				
				enemyBox.CurrentHealth.Value = 0
				BossActive = false
				EnemySystem.DespawnEnemy(Player)
				
			end)
			
			
		end
		


	else
		BossActive = false
		Player.PlayerGui.MainGui.Frame.BossTimerFrame.Visible = false
		local randomEnemy = EnemyList[randomEnemyNumber()]
		local cloneEnemy = randomEnemy:Clone()
		local EnemyHealth, EnemyReward, EnemyLevel = SetEnemyStats(Player)
		cloneEnemy.Parent = enemyBox.CurrentEnemy
		cloneEnemy.CFrame = enemyBox.CFrame + Vector3.new(3,-4,0)
		enemyBox.MaxHealth.Value = EnemyHealth
		enemyBox.CurrentHealth.Value = enemyBox.MaxHealth.Value
		enemyBox.DropReward.Value = EnemyReward
		enemyBox.EnemyLevel.Value = EnemyLevel
	end


end

function EnemySystem.playerAttack(Player)

	print("Player Attack!")
	print(Player)
	local PlayerStats = Player:WaitForChild("PlayerData")
	local PlayerUpgradeStats = Player:WaitForChild("UpgradeData")
	print("DamageDealing: " .. PlayerUpgradeStats.Sword.UpgradeCurrentDamage.Value)
	enemyBox.CurrentHealth.Value -= PlayerUpgradeStats.Sword.UpgradeCurrentDamage.Value
	print("Current Enemy Health: " .. enemyBox.CurrentHealth.Value)

	local currentEnemy = enemyBox.CurrentEnemy:GetChildren()

	if enemyBox.CurrentHealth.Value <= 0 then
		print("Enemy Died")
		if BossActive then
			task.cancel(BossTimer)
		end
		
		enemyBox.CurrentHealth.Value = 0
		BossActive = false
		currentEnemy[1]:Destroy()
		PlayerStats.Coins.Value += enemyBox.DropReward.Value
		
		if PlayerStats.CurrentWorldLevel.Value % PlayerStats.BossLevel.Value == 0 then
			PlayerStats.CurrentKills.Value += 1
			if PlayerStats.CurrentKills.Value >= 1 then
				PlayerStats.CurrentKills.Value = 1
			end
		else
			if PlayerStats.CurrentKills.Value >= 10 then
				PlayerStats.CurrentKills.Value = 10
			else
				PlayerStats.CurrentKills.Value += 1
			end
		end
		
		if PlayerStats.CurrentWorld.Value == PlayerStats.HighestWorld.Value then
			if PlayerStats.CurrentWorldLevel.Value == PlayerStats.HighestLevel.Value then
				if PlayerStats.CurrentKills.Value >= PlayerStats.HighestKills.Value then
					PlayerStats.HighestKills.Value = PlayerStats.CurrentKills.Value
				elseif PlayerStats.HighestKills.Value == 10 then
					PlayerStats.HighestKills.Value = 0
				end
			end
		end


		EnemySystem.spawnEnemy(Player)
		return
	end
end

function EnemySystem.GameAttack(Player, IdleUpgrade)
	print("Idle Attack!")
	print(IdleUpgrade)
	local PlayerStats = Player:WaitForChild("PlayerData")
	local currentEnemy = enemyBox.CurrentEnemy:GetChildren()


	print("Damage Dealing..." .. IdleUpgrade.UpgradeCurrentDamage.Value)
	enemyBox.CurrentHealth.Value -= IdleUpgrade.UpgradeCurrentDamage.Value
	print("Current Enemy Health: " .. enemyBox.CurrentHealth.Value)
	if enemyBox.CurrentHealth.Value <= 0 then
		print("Enemy Died")

		enemyBox.CurrentHealth.Value = 0
		currentEnemy[1]:Destroy()
		PlayerStats.Coins.Value += enemyBox.DropReward.Value
		if PlayerStats.CurrentWorldLevel.Value % PlayerStats.BossLevel.Value == 0 then
			if PlayerStats.CurrentKills.Value >= 1 then
				PlayerStats.CurrentKills.Value = 1				
			end
		end
		if PlayerStats.CurrentKills.Value >= 10 then
			PlayerStats.CurrentKills.Value = 10
		else
			PlayerStats.CurrentKills.Value += 1
		end
		if PlayerStats.CurrentWorld.Value == PlayerStats.HighestWorld.Value then
			if PlayerStats.CurrentWorldLevel.Value == PlayerStats.HighestLevel.Value then
				if PlayerStats.CurrentKills.Value >= PlayerStats.HighestKills.Value then
					PlayerStats.HighestKills.Value = PlayerStats.CurrentKills.Value
				elseif PlayerStats.HighestKills.Value == 10 then
					PlayerStats.HighestKills.Value = 0
				end
			end
		end


		EnemySystem.spawnEnemy(Player)
		return
	end
end

return EnemySystem
