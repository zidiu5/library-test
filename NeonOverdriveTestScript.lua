--================ SETTINGS =================--
_G.showOptionalSettings = true 

--================ LOAD LIBRARY =================--
local url = "https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/NeonOverdriveUI.lua"
local Library = loadstring(game:HttpGet(url .. "?t=" .. tick()))()

-- Variable to store the currently selected player
local SelectedPlayerName = ""

--================ MAIN TAB =================--
local MainTab = Library:CreateTab("Main")

MainTab:Label("Character Settings")

MainTab:Slider("WalkSpeed", 16, 250, 16, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

MainTab:Slider("JumpPower", 50, 500, 50, function(value)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.UseJumpPower = true
        char.Humanoid.JumpPower = value
    end
end)

MainTab:Toggle("Infinite Jump", function(state)
    _G.InfJump = state
end)

-- Connection for Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

--================ TELEPORT TAB =================--
local TPTab = Library:CreateTab("Teleport")

TPTab:Label("Player Teleport")

-- Dropdown to search and select a player
local PlayerDropdown = TPTab:DropdownSearch("Select Player", {}, function(val)
    SelectedPlayerName = val
end)

-- Button to execute the teleport
TPTab:Button("Teleport to Player", function()
    if SelectedPlayerName ~= "" then
        local target = game.Players:FindFirstChild(SelectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = game.Players.LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                Library.Notify("Success", "Teleported to " .. SelectedPlayerName, "Success", 3)
            end
        else
            Library.Notify("Error", "Player character not found", "Error", 3)
        end
    else
        Library.Notify("Warning", "Please select a player first", "Warning", 3)
    end
end)

-- Loop to update the player list automatically
task.spawn(function()
    while task.wait(5) do
        local players = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer then -- Don't show yourself
                table.insert(players, p.Name)
            end
        end
        PlayerDropdown:SetOptions(players)
    end
end)

--================ VISUALS TAB =================--
local VisualsTab = Library:CreateTab("Visuals")

VisualsTab:Label("Environment")

VisualsTab:Button("Enable Fullbright", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    game:GetService("Lighting").GlobalShadows = false
    Library.Notify("Info", "Fullbright enabled", "Info", 2)
end)

VisualsTab:FullRGBPicker("Ambient Color", Color3.fromRGB(255, 255, 255), function(color)
    game:GetService("Lighting").Ambient = color
end)

--================ FINISH =================--
Library.Notify("System", "Neon Overdrive UI Loaded", "Success", 5)
