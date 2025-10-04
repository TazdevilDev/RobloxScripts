local DefaultPlayerData = require(game.ServerStorage.Data.DefaultPlayerData)
local PlayerData

local function LoadData(Player)
	local PlayerUserId = Player.UserId
	local data
	local success, err = pcall(function()
		data = PlayerDataStore:GetAsync(PlayerUserId)
	end)

	if not success then
		warn("Failed to load data for " .. Player.Name .. ": " .. err)
		return
	end

	-- Create player folders
	local PlayerDataFolder = Instance.new("Folder")
	PlayerDataFolder.Name = "PlayerData"
	PlayerDataFolder.Parent = Player

	local UpgradeDataFolder = Instance.new("Folder")
	UpgradeDataFolder.Name = "UpgradeData"
	UpgradeDataFolder.Parent = Player

	-- If first time player
	if not data then
		print("Starting Player")

		-- load defaults for normal stats
		for statName, statValue in pairs(DefaultPlayerData) do
			local val = Instance.new("IntValue")
			val.Name = statName
			val.Value = statValue
			val.Parent = PlayerDataFolder
		end

		-- create upgrade folders based on ServerStorage.Upgrades
		local UpgradeList = game.ServerStorage.Upgrades:GetChildren()
		for _, upgrade in ipairs(UpgradeList) do
			local upgradeFolder = Instance.new("Folder")
			upgradeFolder.Name = upgrade.Name
			upgradeFolder.Parent = UpgradeDataFolder

			for _, val in ipairs(upgrade:GetChildren()) do
				if val:IsA("IntValue") or val:IsA("StringValue") or val:IsA("BoolValue") then
					local cloneVal = Instance.new(val.ClassName)
					cloneVal.Name = val.Name
					cloneVal.Value = val.Value
					cloneVal.Parent = upgradeFolder
				end
			end
		end

	else
		print("Loading Player Data...")



		-- Rebuild normal stats
		for statName, statValue in pairs(data) do
			if typeof(statValue) == "number" or typeof(statValue) == "string" or typeof(statValue) == "boolean" then
				local val = Instance.new(typeof(statValue) == "number" and "IntValue" or "StringValue")
				val.Name = statName
				val.Value = statValue
				val.Parent = PlayerDataFolder
			end
		end

		-- Rebuild upgrades
		for upgradeName, upgradeTable in pairs(data) do
			if type(upgradeTable) == "table" then
				local upgradeFolder = Instance.new("Folder")
				upgradeFolder.Name = upgradeName
				upgradeFolder.Parent = UpgradeDataFolder

				for propName, propValue in pairs(upgradeTable) do
					local val
					if typeof(propValue) == "number" then
						val = Instance.new("IntValue")
					elseif typeof(propValue) == "boolean" then
						val = Instance.new("BoolValue")
					else
						val = Instance.new("StringValue")
					end
					val.Name = propName
					val.Value = propValue
					val.Parent = upgradeFolder
				end
			end
		end

		-- Updating Upgrades If New Ones

		local GameUpgradeList = game.ServerStorage.Upgrades:GetChildren()
		local UpgradeList = {}
		local PlayerUpgradeList = Player:FindFirstChild("UpgradeData"):GetChildren()
		for _,Upgrade in ipairs(GameUpgradeList) do
			table.insert(UpgradeList,Upgrade)
		end


		for _,Upgrades in ipairs(GameUpgradeList) do
			local UpgradeMatch = false
			
			for _,Upgrade in ipairs(PlayerUpgradeList) do
				print(Upgrade.Name)
				print(Upgrades.Name)
				if Upgrade.Name == Upgrades.Name then
					UpgradeMatch = true
				end
			end
			print("DOES IT MATCH?")
			print(UpgradeMatch)
			if not UpgradeMatch then
				print("THERE IS A NEW UPGRADE NEED TO ADD.")
				print(Upgrades)
				local upgradeFolder = Instance.new("Folder")
				upgradeFolder.Name = Upgrades.Name
				upgradeFolder.Parent = UpgradeDataFolder

				for _, UpgradeValues in ipairs(Upgrades:GetChildren()) do
					local val

					if typeof(UpgradeValues.Value) == "number" then
						val = Instance.new("IntValue")
					elseif typeof(UpgradeValues.Value) == "boolean" then
						val = Instance.new("BoolValue")
					else
						val = Instance.new("StringValue")
					end
					val.Name = UpgradeValues.Name
					val.Value = UpgradeValues.Value
					val.Parent = upgradeFolder
				end
			end
		end
	end
end

local function SaveData(Player)
	local PlayerUserId = Player.UserId
	local PlayerNewData = {}
	local PlayerCurrentData = Player.PlayerData:GetChildren()
	local PlayerUpgradeCurrentData = Player.UpgradeData:GetChildren()


	for _,DataValue in pairs(PlayerCurrentData) do
		PlayerNewData[DataValue.Name] = DataValue.Value
	end

	for _,DataValue in pairs(PlayerUpgradeCurrentData) do
		PlayerNewData[DataValue.Name] = {["UpgradeLevel"] = DataValue.UpgradeLevel.Value ,["UpgradeName"] = DataValue.UpgradeName.Value,["UpgradeDescription"] = DataValue.UpgradeDescription.Value,["UpgradeCurrentDamage"] = DataValue.UpgradeCurrentDamage.Value,["InitialPrice"] = DataValue.InitialPrice.Value, ["UpgradeInitialDamage"] = DataValue.UpgradeInitialDamage.Value,["AttackSpeed"] = DataValue.AttackSpeed.Value}
	end


	print(PlayerUpgradeCurrentData)
	print(PlayerNewData)

	PlayerDataStore:SetAsync(PlayerUserId, PlayerNewData)
	print("Player Data Saved!")
end


local function GetDataValue(Player,DataRequest)
	print("Getting Folder...")
	local PlayerDataFolder = Player:FindFirstChild("PlayerData")
	print("Got Folder")
	print(PlayerDataFolder)
	print("Getting Data...")
	local DataValue = PlayerDataFolder:FindFirstChild(DataRequest).Value
	print("Got Data")
	DataTransferEvent:FireClient(Player,DataValue)
end









DataTransferEvent.OnServerEvent:Connect(GetDataValue)
game.Players.PlayerAdded:Connect(LoadData)
game.Players.PlayerRemoving:Connect(SaveData)
