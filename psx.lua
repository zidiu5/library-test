-- DarkRed Autofarm (Fast Version + Eggs Tab, Recursive Folder Support)

loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/Amity/main/PetSimulatorXRemotes.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/library.lua"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Things = Workspace:WaitForChild("__THINGS")
local CoinsFolder = Things:WaitForChild("Coins")
local PetsFolder = Things:WaitForChild("Pets")
local OrbsFolder = Things:WaitForChild("Orbs")
local EggsRoot = ReplicatedStorage.__DIRECTORY:WaitForChild("Eggs")

local JoinCoin = ReplicatedStorage:WaitForChild("Join Coin")
local FarmCoin = ReplicatedStorage:WaitForChild("Farm Coin")
local ClaimOrbs = ReplicatedStorage:WaitForChild("Claim Orbs")
local BuyEgg = ReplicatedStorage:WaitForChild("Buy Egg")

local farming = false
local autoCollect = false
local multiple = false
local autoHatch = false
local selectedArea = nil
local selectedVariant = nil
local selectedEgg = nil
local hatchMode = "Single"
local afterJoinDelay = 0.05

local function GetMyPets()
	local pets = {}
	for _, pet in pairs(PetsFolder:GetChildren()) do
		if pet:IsA("BasePart") and pet:GetAttribute("Owner") == Player.Name then
			table.insert(pets, pet.Name)
		end
	end
	return pets
end

local function GetAreas()
	local areas = {"All"}
	for _, coin in pairs(CoinsFolder:GetChildren()) do
		local area = coin:GetAttribute("Area")
		if area and not table.find(areas, area) then
			table.insert(areas, area)
		end
	end
	table.sort(areas)
	return areas
end

local function NormalizeDropdownValue(opt)
	if typeof(opt) == "string" then return opt end
	if typeof(opt) == "table" then
		for k, v in pairs(opt) do
			if v == true then return k end
		end
	end
	return opt
end

local function GetVariants()
	return {"All","Coins","Diamonds","Crate","Safe","Present","Chest","Vault","Candy Cane"}
end

local function GetEggs()
	local eggs = {}
	for _, folder in pairs(EggsRoot:GetChildren()) do
		if folder:IsA("Folder") then
			for _, egg in pairs(folder:GetChildren()) do
				if egg:IsA("Folder") or egg:IsA("Model") or egg:IsA("Part") then
					table.insert(eggs, folder.Name .. " / " .. egg.Name)
				end
			end
		end
	end
	table.sort(eggs)
	return eggs
end

local UI = Library.new({title = "Lucky Sucks"})
local tabFarm = UI:AddTab("Farm")
local tabEggs = UI:AddTab("Eggs")

UI:AddToggle(tabFarm, "Multiple Mode (Each Pet Own Coin)", false, function(state)
	multiple = state
end)

local areaDropdown = UI:AddDropdown(tabFarm, "Select Area", GetAreas(), function(opt)
	local val = NormalizeDropdownValue(opt)
	selectedArea = (val == "All" or not val) and nil or val
end)

UI:AddButton(tabFarm, "Refresh Areas", function()
	UI:UpdateDropdown(areaDropdown, GetAreas(), selectedArea or "All")
end)

UI:AddDropdown(tabFarm, "Select Variant", GetVariants(), function(opt)
	local val = NormalizeDropdownValue(opt)
	selectedVariant = (val == "All" or not val) and nil or val
end)

UI:AddToggle(tabFarm, "Auto Collect Orbs", false, function(state)
	autoCollect = state
	if state then
		task.spawn(function()
			while autoCollect do
				task.wait(0.15)
				local orbIds = {}
				for _, orb in pairs(OrbsFolder:GetChildren()) do
					table.insert(orbIds, orb.Name)
				end
				if #orbIds > 0 then
					pcall(function()
						ClaimOrbs:FireServer(orbIds)
					end)
				end
			end
		end)
	end
end)

UI:AddToggle(tabFarm, "Enable Autofarm", false, function(state)
	farming = state
	if state then
		task.spawn(function()
			while farming do
				task.wait(0.05)
				local pets = GetMyPets()
				if #pets == 0 then
					task.wait(0.3)
					continue
				end
				local coins = {}
				for _, coin in pairs(CoinsFolder:GetChildren()) do
					if not coin or not coin.Parent then continue end
					local area = coin:GetAttribute("Area")
					local name = tostring(coin:GetAttribute("Name") or coin.Name)
					local nameLower = string.lower(name)
					local areaMatch = (not selectedArea or selectedArea == area)
					local variantMatch = (not selectedVariant or selectedVariant == "All") 
						or string.find(nameLower, string.lower(selectedVariant), 1, true)
					if areaMatch and variantMatch then
						table.insert(coins, coin)
					end
				end
				if #coins == 0 then
					task.wait(0.2)
					continue
				end
				if multiple then
					for i, petId in ipairs(pets) do
						if not farming then break end
						local coin = coins[(i - 1) % #coins + 1]
						if not coin or not coin.Parent then continue end
						task.spawn(function()
							pcall(function()
								JoinCoin:InvokeServer(coin.Name, {petId})
								task.wait(afterJoinDelay)
								FarmCoin:FireServer(coin.Name, petId)
							end)
						end)
					end
					task.wait(0.05)
				else
					local coin = coins[1]
					if coin and coin.Parent then
						local coinId = coin.Name
						pcall(function()
							JoinCoin:InvokeServer(coinId, pets)
							task.wait(afterJoinDelay)
							for _, petId in ipairs(pets) do
								FarmCoin:FireServer(coinId, petId)
							end
						end)
						repeat task.wait(0.05) until (not coin.Parent) or (not farming)
					else
						task.wait(0.05)
					end
				end
			end
		end)
	end
end)

UI:AddButton(tabFarm, "Reload Remotes", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/Amity/main/PetSimulatorXRemotes.lua"))()
end)

local eggDropdown = UI:AddDropdown(tabEggs, "Select Egg", GetEggs(), function(opt)
	local val = NormalizeDropdownValue(opt)
	selectedEgg = val
end)

local modeDropdown = UI:AddDropdown(tabEggs, "Select Mode", {"Single","Triple"}, function(opt)
	local val = NormalizeDropdownValue(opt)
	hatchMode = val or "Single"
end)

UI:AddToggle(tabEggs, "Enable Auto Hatch", false, function(state)
	autoHatch = state
	if state then
		task.spawn(function()
			while autoHatch do
				if selectedEgg then
					local split = string.split(selectedEgg, " / ")
					local folder, eggName = split[1], split[2]
					local args = {eggName, hatchMode == "Triple"}
					pcall(function()
						BuyEgg:InvokeServer(unpack(args))
					end)
				end
				task.wait(0.2)
			end
		end)
	end
end)

UI:AddButton(tabEggs, "Refresh Eggs", function()
	UI:UpdateDropdown(eggDropdown, GetEggs(), selectedEgg or "")
end)

print("✅ DarkRed Autofarm (FAST + Eggs Tab, Recursive) loaded successfully!")
