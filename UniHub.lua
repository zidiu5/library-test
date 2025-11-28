-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- RICHTIGER NOCLIP KERN
local Clip = true
local Noclipping = nil
local floatName = "HumanoidRootPart"

local function startNoclip(speaker)
    Clip = false
    task.wait(0.1)

    local function NoclipLoop()
        if Clip == false and speaker.Character then
            for _, child in ipairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                    child.CanCollide = false
                end
            end
        end
    end

    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
    end

    Noclipping = RunService.Stepped:Connect(NoclipLoop)
end

local function stopNoclip()
    Clip = true
    if Noclipping then
        Noclipping:Disconnect()
        Noclipping = nil
    end
end

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- SCREEN GUI
local gui = Instance.new("ScreenGui")
gui.Parent = PlayerGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- OPEN/CLOSE BUTTON
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 38, 0, 38)
OpenBtn.Position = UDim2.new(0, 170, 0.5, -180)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Text = "Z"
OpenBtn.TextScaled = true
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = gui
OpenBtn.Active = true

Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", OpenBtn)
stroke.Color = Color3.fromHex("efbf04")
stroke.Thickness = 2

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 360, 0, 270)
main.Position = UDim2.new(0.5, -180, 1.2, 0)
main.BackgroundColor3 = Color3.fromRGB(0,0,0)
main.Visible = false
main.Active = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local st = Instance.new("UIStroke", main)
st.Thickness = 2
st.Color = Color3.fromHex("efbf04")

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Meine GUI"
Title.TextColor3 = Color3.fromHex("efbf04")
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = main

-- TAB BAR OBEN
local TabHolder = Instance.new("ScrollingFrame")
TabHolder.Size = UDim2.new(1, -20, 0, 40)
TabHolder.Position = UDim2.new(0, 10, 0, 35)
TabHolder.BackgroundTransparency = 1
TabHolder.BorderSizePixel = 0
TabHolder.ScrollBarThickness = 4
TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
TabHolder.AutomaticCanvasSize = Enum.AutomaticSize.X
TabHolder.ScrollingDirection = Enum.ScrollingDirection.X
TabHolder.Parent = main
TabHolder.ScrollBarImageTransparency = 1

local tabLayout = Instance.new("UIListLayout", TabHolder)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0,8)

-- BUTTONS VERTIKAL SCROLL
local BtnHolder = Instance.new("ScrollingFrame")
BtnHolder.Size = UDim2.new(1, -20, 1, -85)
BtnHolder.Position = UDim2.new(0, 10, 0, 80)
BtnHolder.BackgroundTransparency = 1
BtnHolder.BorderSizePixel = 0
BtnHolder.ScrollBarThickness = 6
BtnHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
BtnHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
BtnHolder.ScrollingDirection = Enum.ScrollingDirection.Y
BtnHolder.Parent = main
BtnHolder.ScrollBarImageTransparency = 1

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,8)
layout.Parent = BtnHolder

-- BUTTON + BESCHREIBUNG CREATOR
local function makeButtonWithDescription(text, description)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,35)
    container.BackgroundTransparency = 1
    container.Parent = BtnHolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, -5, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = description or ""
    label.TextColor3 = Color3.fromHex("efbf04")
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.35, 0, 1, 0)
    b.Position = UDim2.new(0.65, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.TextColor3 = Color3.fromHex("efbf04")
    b.Text = text or ""
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = container
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    local borderFrame = Instance.new("Frame")
    borderFrame.Size = UDim2.new(1, -4, 1, -4)
    borderFrame.Position = UDim2.new(0, 2, 0, 2)
    borderFrame.BackgroundTransparency = 1
    borderFrame.Parent = b
    local strokeInner = Instance.new("UIStroke")
    strokeInner.Parent = borderFrame
    strokeInner.Color = Color3.fromHex("efbf04")
    strokeInner.Thickness = 1
    strokeInner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    return b
end

local function setupToggleVisual(button, state)
    if state then
        button.BackgroundColor3 = Color3.fromHex("efbf04")
        button.TextColor3 = Color3.fromRGB(0,0,0)
    else
        button.BackgroundColor3 = Color3.fromRGB(0,0,0)
        button.TextColor3 = Color3.fromHex("efbf04")
    end
end

-- TABS
local tabs = {}
local function makeTab(name)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0,80,1,0)
    tab.BackgroundColor3 = Color3.fromRGB(0,0,0)
    tab.TextColor3 = Color3.fromHex("efbf04")
    tab.Text = name
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 14
    tab.Parent = TabHolder
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0,6)

    tab.MouseButton1Click:Connect(function()
        for _, child in ipairs(BtnHolder:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextBox") then
                child:Destroy()
            end
        end

        if name == "GUIs" then
            local success, Scripts = pcall(function()
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/links.lua"))()
            end)
            if success and type(Scripts) == "table" then
                for _, entry in pairs(Scripts) do
                    local btn = makeButtonWithDescription(entry.name, entry.desc or "No description")
                    btn.MouseButton1Click:Connect(function()
                        loadstring(game:HttpGet(entry.url))()
                    end)
                end
            else
                makeButtonWithDescription("Error", "Could not load GitHub links")
            end

        elseif name == "Game Detect" then
            local detectBtn = makeButtonWithDescription("Detect Game", "Detects the current game")
            detectBtn.MouseButton1Click:Connect(function()
                local currentId = game.PlaceId
                local success, Scripts = pcall(function()
                    return loadstring(game:HttpGet("https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/links.lua"))()
                end)
                if success and type(Scripts) == "table" then
                    local found = false
                    for _, entry in pairs(Scripts) do
                        local gameIds = entry.gameId
                        if type(gameIds) ~= "table" then
                            gameIds = {gameIds}
                        end
                        for _, id in ipairs(gameIds) do
                            if id == currentId then
                                found = true
                                local btn = makeButtonWithDescription(entry.name, entry.desc or "No description")
                                btn.MouseButton1Click:Connect(function()
                                    loadstring(game:HttpGet(entry.url))()
                                end)
                                break
                            end
                        end
                    end
                    if not found then
                        makeButtonWithDescription("No scripts found", "No GitHub scripts for this game")
                    end
                else
                    makeButtonWithDescription("Error", "Could not load GitHub links")
                end
            end)

        elseif name == "Misc" then
            -- Setup Misc Tab (WalkSpeed, JumpPower, Gravity, Noclip, ESP, ESPv2)
            local function setupMiscTab()
                -- WalkSpeed
                local walkSpeedBox = Instance.new("TextBox")
                walkSpeedBox.Size = UDim2.new(0.9,0,0,30)
                walkSpeedBox.Text = ""
                walkSpeedBox.PlaceholderText = "WalkSpeed (default 16)"
                walkSpeedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
                walkSpeedBox.TextColor3 = Color3.fromHex("efbf04")
                walkSpeedBox.Font = Enum.Font.Gotham
                walkSpeedBox.TextSize = 14
                walkSpeedBox.Parent = BtnHolder
                Instance.new("UICorner", walkSpeedBox).CornerRadius = UDim.new(0,5)
                walkSpeedBox.FocusLost:Connect(function(enter)
                    if enter and tonumber(walkSpeedBox.Text) then
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid.WalkSpeed = tonumber(walkSpeedBox.Text)
                        end
                    end
                end)

                -- JumpPower
                local jumpPowerBox = Instance.new("TextBox")
                jumpPowerBox.Size = UDim2.new(0.9,0,0,30)
                jumpPowerBox.Text = ""
                jumpPowerBox.PlaceholderText = "JumpPower (default 50)"
                jumpPowerBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
                jumpPowerBox.TextColor3 = Color3.fromHex("efbf04")
                jumpPowerBox.Font = Enum.Font.Gotham
                jumpPowerBox.TextSize = 14
                jumpPowerBox.Parent = BtnHolder
                Instance.new("UICorner", jumpPowerBox).CornerRadius = UDim.new(0,5)
                jumpPowerBox.FocusLost:Connect(function(enter)
                    if enter and tonumber(jumpPowerBox.Text) then
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid.JumpPower = tonumber(jumpPowerBox.Text)
                        end
                    end
                end)

                -- Gravity
                local gravityBox = Instance.new("TextBox")
                gravityBox.Size = UDim2.new(0.9,0,0,30)
                gravityBox.Text = ""
                gravityBox.PlaceholderText = "Gravity (default 196.2)"
                gravityBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
                gravityBox.TextColor3 = Color3.fromHex("efbf04")
                gravityBox.Font = Enum.Font.Gotham
                gravityBox.TextSize = 14
                gravityBox.Parent = BtnHolder
                Instance.new("UICorner", gravityBox).CornerRadius = UDim.new(0,5)
                gravityBox.FocusLost:Connect(function(enter)
                    if enter and tonumber(gravityBox.Text) then
                        game.Workspace.Gravity = tonumber(gravityBox.Text)
                    end
                end)

                -- Noclip Toggle
                local noclipToggle = makeButtonWithDescription("Noclip", "Toggle Noclip")
                local noclipActive = false
                noclipToggle.MouseButton1Click:Connect(function()
                    noclipActive = not noclipActive
                    setupToggleVisual(noclipToggle, noclipActive)
                    if noclipActive then
                        startNoclip(player)
                    else
                        stopNoclip()
                    end
                end)
                player.CharacterAdded:Connect(function(char)
                    if noclipActive then
                        task.wait(0.1)
                        startNoclip(player)
                    end
                end)


                ---------------------------------------------------------------------
                -- LIVE-UPDATING ESP SYSTEM (V1, V2, V3 Name ESP)
                ---------------------------------------------------------------------
                
                local espActive = false
                local espV2Active = false
                local espV3Active = false
                
                local espBoxes = {}      -- v1
                local espHitboxes = {}   -- v2
                local espNames = {}      -- v3
                
                local function clearESP(tbl)
                    for _, obj in pairs(tbl) do
                        if obj then obj:Destroy() end
                    end
                    table.clear(tbl)
                end
                
                ---------------------------------------------------------------------
                -- ESP V1  (every bodypart box)
                ---------------------------------------------------------------------
                local function applyESP_V1(char, plr)
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Adornee = part
                            box.Size = part.Size
                            box.AlwaysOnTop = true
                            box.ZIndex = 10
                            box.Transparency = 0
                            box.Color3 = plr.TeamColor.Color
                            box.Parent = part
                            table.insert(espBoxes, box)
                        end
                    end
                end
                
                ---------------------------------------------------------------------
                -- ESP V2  (Big hitbox around HumanoidRootPart)
                ---------------------------------------------------------------------
                local function applyESP_V2(char, plr)
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = root
                    box.Size = root.Size * Vector3.new(2.2, 3, 2.2)
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Transparency = 0.5
                    box.Color3 = plr.TeamColor.Color
                    box.Parent = root
                
                    table.insert(espHitboxes, box)
                end
                
                ---------------------------------------------------------------------
                -- ESP V3  (Name above head, visible everywhere)
                ---------------------------------------------------------------------
                local function applyESP_V3(char, plr)
                    local head = char:FindFirstChild("Head")
                    if not head then return end
                
                    local billboard = Instance.new("BillboardGui")
                    billboard.Adornee = head
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.MaxDistance = math.huge
                    billboard.Parent = head
                
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.Name
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    label.TextColor3 = plr.TeamColor.Color
                    label.Parent = billboard
                
                    table.insert(espNames, billboard)
                end
                
                ---------------------------------------------------------------------
                -- Apply ESP to one player
                ---------------------------------------------------------------------
                local function applyESP(plr)
                    if plr == player then return end
                    if not plr.Character then return end
                
                    if espActive then applyESP_V1(plr.Character, plr) end
                    if espV2Active then applyESP_V2(plr.Character, plr) end
                    if espV3Active then applyESP_V3(plr.Character, plr) end
                end
                
                ---------------------------------------------------------------------
                -- AUTO-UPDATE: when someone spawns/dies
                ---------------------------------------------------------------------
                Players.PlayerAdded:Connect(function(plr)
                    plr.CharacterAdded:Connect(function()
                        task.wait(0.5)
                        applyESP(plr)
                    end)
                end)
                
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then
                        if plr.Character then applyESP(plr) end
                        plr.CharacterAdded:Connect(function()
                            task.wait(0.5)
                            applyESP(plr)
                        end)
                    end
                end
                
                ---------------------------------------------------------------------
                -- TOGGLE BUTTONS (connect these to your existing buttons)
                ---------------------------------------------------------------------
                
                -- ESP v1 Toggle
                espToggle.MouseButton1Click:Connect(function()
                    espActive = not espActive
                    setupToggleVisual(espToggle, espActive)
                    clearESP(espBoxes)
                    if espActive then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            applyESP(plr)
                        end
                    end
                end)
                
                -- ESP v2 Toggle
                espV2Toggle.MouseButton1Click:Connect(function()
                    espV2Active = not espV2Active
                    setupToggleVisual(espV2Toggle, espV2Active)
                    clearESP(espHitboxes)
                    if espV2Active then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            applyESP(plr)
                        end
                    end
                end)
                
                -- ESP v3 (Name ESP)
                local espV3Toggle = makeButtonWithDescription("ESP v3", "Name above head")
                espV3Toggle.MouseButton1Click:Connect(function()
                    espV3Active = not espV3Active
                    setupToggleVisual(espV3Toggle, espV3Active)
                    clearESP(espNames)
                    if espV3Active then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            applyESP(plr)
                        end
                    end
                end)
            setupMiscTab()
        end
    end)

    tabs[name] = tab
end

makeTab("Game Detect")
makeTab("GUIs")
makeTab("Misc")

-- MAIN GUI TOGGLE
local isOpen = false
local function toggle()
    isOpen = not isOpen
    if isOpen then
        main.Visible = true
        main.Position = UDim2.new(0.5,-180,1.2,0)
        TweenService:Create(main,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{Position = UDim2.new(0.5,-180,0.5,-135)}):Play()
    else
        TweenService:Create(main,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{Position = UDim2.new(0.5,-180,1.2,0)}):Play()
        task.wait(0.35)
        main.Visible = false
    end
end

-- OPEN BUTTON DRAG
local dragging=false
local dragStart
local startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragStart=input.Position
        startPos=OpenBtn.Position
        dragging=true
    end
end)
OpenBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position - dragStart
        OpenBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        dragging=false
        if (input.Position - dragStart).Magnitude<8 then toggle() end
    end
end)

-- MAIN FRAME DRAG
local dragMain=false
local mStart
local mPos
main.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragMain=true
        mStart=input.Position
        mPos=main.Position
    end
end)
main.InputChanged:Connect(function(input)
    if dragMain and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position - mStart
        main.Position=UDim2.new(mPos.X.Scale,mPos.X.Offset+delta.X,mPos.Y.Scale,mPos.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragMain=false
    end
end)

-- Standard-Tab beim Start
tabs["Game Detect"]:MouseButton1Click()
