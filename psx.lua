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

--// Dropdown Normalizer
local function NormalizeDropdownValue(opt)
	if typeof(opt) == "string" then return opt end
	if typeof(opt) == "table" then
		for k, v in pairs(opt) do
			if v == true then return k end
		end
	end
	return opt
end

--// Variants
local function GetVariants()
	return {"All","Coins","Diamonds","Crate","Safe","Present","Chest","Vault","Candy Cane"}
end

--// 🪟 GUI
local UI = Library.new({title = "🪙 DarkRed Autofarm"})
local tab = UI:AddTab("Main")

--// 🔘 Autofarm Toggle
UI:AddToggle(tab, "Enable Autofarm", false, function(state)
	farming = state
	print("🟢 Autofarm:", state)
	if state then
		task.spawn(function()
			while farming do
				task.wait(0.25)

				local pets = GetMyPets()
				if #pets == 0 then
					warn("⚠️ No pets found.")
					continue
				end

				--// Filter Coins
				local coins = {}
				for _, coin in pairs(CoinsFolder:GetChildren()) do
					if not coin or not coin.Parent then continue end

					-- read attribute "Name" (fallback to object.Name)
					local attrName = coin:GetAttribute("Name") or coin.Name
					if attrName == "Candy Canes" then continue end -- ignore completely

					local area = coin:GetAttribute("Area")
					local nameLower = string.lower(tostring(attrName))

					local areaMatch = (not selectedArea or selectedArea == area)

					-- Variant: match against attribute "Name" partial
					local variantMatch = false
					if not selectedVariant or selectedVariant == "All" then
						variantMatch = true
					else
						-- search for the word anywhere in the attrName (case-insensitive)
						if string.find(nameLower, string.lower(selectedVariant), 1, true) then
							variantMatch = true
						end
					end

					if areaMatch and variantMatch then
						table.insert(coins, coin)
					end
				end

				if #coins == 0 then
					task.wait(0.5)
					continue
				end

				--// Smart Multiple Mode: Only if enough coins exist
				local useMultiple = multiple and (#coins >= #pets)
				print(("🪙 %d Coins | Area: %s | Type: %s | Mode: %s"):format(
					#coins, selectedArea or "All", selectedVariant or "All", useMultiple and "MULTI" or "NORMAL"
				))

				if useMultiple then
					-- Each pet gets its own coin
					for i, petId in ipairs(pets) do
						local coin = coins[i]
						if not coin then break end
						local coinId = coin.Name
						task.spawn(function()
							pcall(function()
								JoinCoin:InvokeServer(coinId, {petId})
								FarmCoin:FireServer(coinId, petId)
							end)
						end)
						task.wait(0.03)
					end
				else
					-- All pets farm the same coins (sequentially)
					for _, coin in ipairs(coins) do
						if not farming then break end
						if not coin or not coin.Parent then continue end
						local coinId = coin.Name
						pcall(function()
							JoinCoin:InvokeServer(coinId, pets)
						end)
						for _, petId in ipairs(pets) do
							task.spawn(function()
								pcall(function()
									FarmCoin:FireServer(coinId, petId)
								end)
							end)
						end
						-- wait until coin disappears (serial)
						repeat task.wait(0.08) until (not coin.Parent) or (not farming)
					end
				end
			end
		end)
	end
end)

--// 🔄 AutoCollect Toggle
UI:AddToggle(tab, "Enable Auto Collect", false, function(state)
	autoCollect = state
	print("💎 AutoCollect:", state)
	if state then
		task.spawn(function()
			while autoCollect do
				task.wait(0.25)
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

--// ⚙️ Multiple Mode Toggle
UI:AddToggle(tab, "Multiple Mode (Each Pet Own Coin)", false, function(state)
	multiple = state
	print("🐾 Multiple Mode:", state)
end)

--// 📂 Area Dropdown
local areaDropdown = UI:AddDropdown(tab, "Select Area", GetAreas(), function(opt)
	local val = NormalizeDropdownValue(opt)
	selectedArea = (val == "All" or not val) and nil or val
	print("📍 Area:", selectedArea or "All")
end)

UI:AddButton(tab, "🔁 Refresh Areas", function()
	UI:UpdateDropdown(areaDropdown, GetAreas(), selectedArea or "All")
end)

--// 💎 Variants Dropdown (matching against attribute "Name")
UI:AddDropdown(tab, "Select Variant", GetVariants(), function(opt)
	local val = NormalizeDropdownValue(opt)
	selectedVariant = (val == "All" or not val) and nil or val
	print("💠 Variant:", selectedVariant or "All")
end)

--// ⚠️ Not Working Button
UI:AddButton(tab, "⚠️ Not Working (Reload Remotes)", function()
	print("🔁 Reloading remote data...")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/Amity/main/PetSimulatorXRemotes.lua"))()
end)

print("✅ DarkRed Autofarm (Fast) + AutoCollect + Variants (Attribute-Name Match) + Smart Multiple Mode loaded!")
