-- DarkRed Autofarm (Fast Version)

loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/Amity/main/PetSimulatorXRemotes.lua"))()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/library.lua"))()

--// Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Things = Workspace:WaitForChild("__THINGS")
local CoinsFolder = Things:WaitForChild("Coins")
local PetsFolder = Things:WaitForChild("Pets")
local OrbsFolder = Things:WaitForChild("Orbs")

--// Remotes
local JoinCoin = ReplicatedStorage:WaitForChild("Join Coin")
local FarmCoin = ReplicatedStorage:WaitForChild("Farm Coin")
local ClaimOrbs = ReplicatedStorage:WaitForChild("Claim Orbs")

--// Variables
local farming = false
local autoCollect = false
local multiple = false
local selectedArea = nil
local selectedVariant = nil
local afterJoinDelay = 0.05

--// 🧠 Find Your Own Pets
local function GetMyPets()
	local pets = {}
	for _, pet in pairs(PetsFolder:GetChildren()) do
		if pet:IsA("BasePart") and pet:GetAttribute("Owner") == Player.Name then
			table.insert(pets, pet.Name)
		end
	end
	return pets
end

--// 🗺️ Find Areas
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

-- Normalize Dropdown Value
local function NormalizeDropdownValue(opt)
	if typeof(opt) == "string" then return opt end
	if typeof(opt) == "table" then
		for k, v in pairs(opt) do
			if v == true then return k end
		end
	end
	return opt
end

-- Variants
local function GetVariants()
	return {"All","Coins","Diamonds","Crate","Safe","Present","Chest","Vault","Candy Cane"}
end

-- GUI
local UI = Library.new({title = "Lucky Sucks)"})
local tab = UI:AddTab("Main")

-- Multiple Mode Toggle
UI:AddToggle(tab, "Multiple Mode", false, function(state)
	multiple = state
	print("🐾 Multiple Mode:", state)
end)

-- Area Dropdown
local areaDropdown = UI:AddDropdown(tab, "Select Area", GetAreas(), function(opt)
	local val = NormalizeDropdownValue(opt)
	selectedArea = (val == "All" or not val) and nil or val
	print("📍 Area:", selectedArea or "All")
end)

UI:AddButton(tab, "🔁 Refresh Areas", function()
	UI:UpdateDropdown(areaDropdown, GetAreas(), selectedArea or "All")
end)

-- Variant Dropdown
UI:AddDropdown(tab, "Select Variant", GetVariants(), function(opt)
	local val = NormalizeDropdownValue(opt)
	selectedVariant = (val == "All" or not val) and nil or val
	print("💠 Variant:", selectedVariant or "All")
end)

-- AutoCollect
UI:AddToggle(tab, "Enable Auto Collect", false, function(state)
	autoCollect = state
	print("💎 AutoCollect:", state)
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

-- Autofarm
UI:AddToggle(tab, "Enable Autofarm (FAST)", false, function(state)
	farming = state
	print("🟢 Autofarm:", state)

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

UI:AddButton(tab, "⚠️ Reload Remotes", function()
	print("🔁 Reloading remotes...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/Amity/main/PetSimulatorXRemotes.lua"))()
end)

print("✅ DarkRed Autofarm (FAST) loaded successfully!")
