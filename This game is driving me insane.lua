_G.showOptionalSettings = true -- Settings Tab automatisch erstellen
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/NeonOverdriveUI.lua"))()

local FarmTab = Library:CreateTab("Coin & Orb Farm")

FarmTab:Label("=== AutoFarm Settings ===")

local maxDistance = 100
local distanceSlider = FarmTab:Slider("Max Distance (Studs)", 10, 500, 100, function(val)
    maxDistance = val
end, 0)

local petIds = {} -- Speichert IDs der eigenen Pets
local function updatePets()
    petIds = {}
    for _, pet in pairs(workspace.__THINGS.Pets:GetChildren()) do
        if pet:GetAttribute("Owner") == game.Players.LocalPlayer.Name then
            table.insert(petIds, pet.Name)
        end
    end
end
updatePets()
spawn(function()
    while true do
        updatePets()
        task.wait(5)
    end
end)

local coinMode = "Single"
FarmTab:Dropdown("Coin Mode", {"Single","Multi"}, function(opt)
    coinMode = opt
end)

local farmVariant = "Radius"
local selectedArea = nil
local areaDropdown = nil

FarmTab:Dropdown("Farm Variant", {"Radius","Area"}, function(opt)
    farmVariant = opt
    -- Wenn Area ausgewählt, Area Dropdown erstellen
    if farmVariant == "Area" then
        -- Alle Areas scannen
        local areas = {}
        for _, areaFolder in pairs(workspace.__MAP.Areas:GetChildren()) do
            table.insert(areas, areaFolder.Name)
        end
        if areaDropdown then
            -- Alte Dropdown entfernen, wenn schon existiert
            areaDropdown:SetOptions(areas)
        else
            areaDropdown = FarmTab:Dropdown("Select Area", areas, function(area)
                selectedArea = area
            end)
        end
    else
        if areaDropdown then
            -- Area Dropdown ausblenden, wenn Radius
            areaDropdown:SetOptions({})
            selectedArea = nil
        end
    end
end)

local autofarm = false
FarmTab:Toggle("AutoFarm Coins", false, function(state)
    autofarm = state
end)

local autoOrbs = false
FarmTab:Toggle("Auto Collect Orbs", false, function(state)
    autoOrbs = state
end)

spawn(function()
    while task.wait(0.1) do
        local playerChar = game.Players.LocalPlayer.Character
        local playerPos = playerChar and playerChar:FindFirstChild("HumanoidRootPart") and playerChar.HumanoidRootPart.Position
        if playerPos then
            --================ AUTO COINS ===================
            if autofarm and #petIds > 0 then
                local coinsToFarm = {}
                for _, coinFolder in pairs(workspace.__THINGS.Coins:GetChildren()) do
                    local coinPosPart = coinFolder:FindFirstChild("POS")
                    if coinPosPart then
                        -- Filter nach Variant
                        local includeCoin = false
                        if farmVariant == "Radius" then
                            includeCoin = (coinPosPart.Position - playerPos).Magnitude <= maxDistance
                        elseif farmVariant == "Area" and selectedArea then
                            local coinArea = coinFolder:GetAttribute("Area")
                            includeCoin = coinArea == selectedArea
                        end
                        if includeCoin then
                            coinsToFarm[#coinsToFarm+1] = coinFolder
                        end
                    end
                end

                if #coinsToFarm > 0 then
                    if coinMode == "Single" then
                        local coinFolder = coinsToFarm[1]
                        for _, petId in pairs(petIds) do
                            local joinArgs = {{{coinFolder.Name,{petId}},{false,false}}}
                            workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs))
                            local farmArgs = {{{coinFolder.Name,petId},{false,false}}}
                            workspace.__THINGS.__REMOTES["farm coin"]:FireServer(unpack(farmArgs))
                        end
                        repeat task.wait(0.05) until not coinFolder:FindFirstChild("POS")
                    else
                        -- Multi Mode: Jeder Pet bekommt eigenes Coin
                        local assignedCoins = {}
                        for i, petId in ipairs(petIds) do
                            local coinFolder = coinsToFarm[i] or coinsToFarm[#coinsToFarm]
                            if coinFolder and not assignedCoins[coinFolder] then
                                assignedCoins[coinFolder] = true
                                local joinArgs = {{{coinFolder.Name,{petId}},{false,false}}}
                                workspace.__THINGS.__REMOTES["join coin"]:InvokeServer(unpack(joinArgs))
                                local farmArgs = {{{coinFolder.Name,petId},{false,false}}}
                                workspace.__THINGS.__REMOTES["farm coin"]:FireServer(unpack(farmArgs))
                                spawn(function()
                                    repeat task.wait(0.05) until not coinFolder:FindFirstChild("POS")
                                end)
                            end
                        end
                    end
                end
            end

            --================ AUTO ORBS ===================
            if autoOrbs then
                local orbIds = {}
                for _, orbPart in pairs(workspace.__THINGS.Orbs:GetChildren()) do
                    table.insert(orbIds, orbPart.Name)
                end
                if #orbIds > 0 then
                    local args = {{{orbIds},{false}}}
                    workspace.__THINGS.__REMOTES["claim orbs"]:FireServer(unpack(args))
                end
            end
        end
    end
end)
