-- V 2.0
--================ SETTINGS =================--
_G.showOptionalSettings = true

--================ LOAD LIBRARY =================--
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/NeonOverdriveUI.lua"
))()

--================ SERVICES =================--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local workspaceThings = workspace:WaitForChild("__THINGS")
local RemotesFolder = workspaceThings:WaitForChild("__REMOTES")

--================== MOB TAB ===================
local MobTab = Library:CreateTab("Mob")

-- Kill All Mobs
MobTab:Button("Kill All Mobs", function()
    local Monsters = workspaceThings.Monsters
    local Remote = RemotesFolder.mobdodamage
    for _, mob in ipairs(Monsters:GetChildren()) do
        if mob:IsA("Model") then
            Remote:FireServer({{{mob, 10000}}})
        end
    end
end)

-- Heal All Mobs
MobTab:Button("Heal All Mobs", function()
    local Monsters = workspaceThings.Monsters
    local Remote = RemotesFolder.mobdodamage
    for _, mob in ipairs(Monsters:GetChildren()) do
        if mob:IsA("Model") then
            Remote:FireServer({{{mob, -10000}}})
        end
    end
end)

-- Auto Kill Toggle with Radius Slider
local AutoKillEnabled = false
local KillRadius = 50
MobTab:Slider("Brim Radius Kill", 10, 200, KillRadius, function(value)
    KillRadius = value
end)

MobTab:Toggle("Auto-Kill Mobs", false, function(state)
    AutoKillEnabled = state
    if state then
        task.spawn(function()
            local Monsters = workspaceThings.Monsters
            local Remote = RemotesFolder.mobdodamage

            while AutoKillEnabled do
                local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local HRP = Character:WaitForChild("HumanoidRootPart")

                for _, mob in ipairs(Monsters:GetChildren()) do
                    if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                        if (HRP.Position - mob.HumanoidRootPart.Position).Magnitude <= KillRadius then
                            Remote:FireServer({{{mob, 10000}}})
                        end
                    end
                end

                task.wait(0.5)
            end
        end)
    end
end)

--================ CIRCLE VISUALIZER ===================
local RunService = game:GetService("RunService")
local circleEnabled = false
local SEGMENTS = 60
local CIRCLE_PART_SIZE = 2
local CircleParts = {}

-- Create parts
for i = 1, SEGMENTS do
    local part = Instance.new("Part")
    part.Size = Vector3.new(CIRCLE_PART_SIZE, CIRCLE_PART_SIZE, CIRCLE_PART_SIZE)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 0, 0)
    part.Transparency = 1
    part.Parent = workspace
    table.insert(CircleParts, part)
end

-- Add Circle Toggle to GUI
MobTab:Toggle("Show Kill Radius", false, function(state)
    circleEnabled = state
end)

-- Update loop
RunService.RenderStepped:Connect(function()
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if HRP then
        for i, part in ipairs(CircleParts) do
            if circleEnabled then
                local angle = (i / SEGMENTS) * math.pi * 2
                local x = HRP.Position.X + math.cos(angle) * KillRadius
                local z = HRP.Position.Z + math.sin(angle) * KillRadius
                local y = HRP.Position.Y + 1
                part.Position = Vector3.new(x, y, z)
                part.Transparency = 0.5
            else
                part.Transparency = 1
            end
        end
    end
end)

--================== BUILD TAB ===================
local BuildTab = Library:CreateTab("Build")

-- Dropdown für Materialien (fest definiert)
local Materials = {"Wood", "Brick", "Metal", "Obsidian", "Firebrick"}
local SelectedBlock = Materials[1]

BuildTab:Dropdown("Select Build Block", Materials, function(opt)
    SelectedBlock = opt
end)

-- Hilfsfunktionen
local STEP = 4
local CornerA = Vector3.new(-252, -8, 52)
local CornerB = Vector3.new(112, 72, 368)

local function place(pos, blockName)
    blockName = blockName or SelectedBlock
    local Remote = workspace.__THINGS.__REMOTES.placeblock
    local Part = workspace.__THINGS.__BLOCKS[blockName].Part
    Remote:FireServer({CFrame.new(pos), blockName, Part})
end

local function range(a, b)
    local t = {}
    for v = a, b, (a < b and STEP or -STEP) do
        table.insert(t, v)
    end
    return t
end

--================ BUILD BUTTONS =================--

-- Corner Version 1
BuildTab:Button("Corner Version 1", function()
    local minX,maxX = math.min(CornerA.X,CornerB.X), math.max(CornerA.X,CornerB.X)
    local minY,maxY = math.min(CornerA.Y,CornerB.Y), math.max(CornerA.Y,CornerB.Y)
    local minZ,maxZ = math.min(CornerA.Z,CornerB.Z), math.max(CornerA.Z,CornerB.Z)

    local C = {
        Vector3.new(minX,minY,minZ),Vector3.new(maxX,minY,minZ),
        Vector3.new(maxX,minY,maxZ),Vector3.new(minX,minY,maxZ)
    }

    for _,c in ipairs(C) do
        for _,y in ipairs(range(minY,maxY)) do
            place(Vector3.new(c.X,y,c.Z))
        end
    end

    local T = {
        Vector3.new(minX,maxY,minZ),Vector3.new(maxX,maxY,minZ),
        Vector3.new(maxX,maxY,maxZ),Vector3.new(minX,maxY,maxZ)
    }

    local function connect(a,b)
        if a.X~=b.X then
            for _,x in ipairs(range(a.X,b.X)) do place(Vector3.new(x,a.Y,a.Z)) end
        else
            for _,z in ipairs(range(a.Z,b.Z)) do place(Vector3.new(a.X,a.Y,z)) end
        end
    end

    connect(T[1],T[2]); connect(T[2],T[3])
    connect(T[3],T[4]); connect(T[4],T[1])

    local function diag(a,b)
        local steps = math.abs((b.X-a.X)/STEP)
        for i=0,steps do
            local t = i/steps
            place(Vector3.new(a.X+(b.X-a.X)*t,a.Y,a.Z+(b.Z-a.Z)*t))
        end
    end

    diag(T[1],T[3]); diag(T[2],T[4])
end)

-- Corner Version 2
BuildTab:Button("Corner Version 2", function()
    local minX,maxX = math.min(CornerA.X,CornerB.X), math.max(CornerA.X,CornerB.X)
    local minY,maxY = math.min(CornerA.Y,CornerB.Y), math.max(CornerA.Y,CornerB.Y)
    local minZ,maxZ = math.min(CornerA.Z,CornerB.Z), math.max(CornerA.Z,CornerB.Z)

    local C = {}
    for _,x in ipairs({minX,maxX}) do
        for _,y in ipairs({minY,maxY}) do
            for _,z in ipairs({minZ,maxZ}) do
                table.insert(C, Vector3.new(x,y,z))
            end
        end
    end

    local function connect3D(a,b)
        local steps = math.max(
            math.abs((b.X-a.X)/STEP),
            math.abs((b.Y-a.Y)/STEP),
            math.abs((b.Z-a.Z)/STEP)
        )
        for i=0,steps do
            local t=i/steps
            place(Vector3.new(
                a.X+(b.X-a.X)*t,
                a.Y+(b.Y-a.Y)*t,
                a.Z+(b.Z-a.Z)*t
            ))
        end
    end

    for i=1,#C do
        for j=i+1,#C do
            connect3D(C[i],C[j])
        end
    end
end)

-- 4 Row Stairs
BuildTab:Button("4-Row Stairs", function()
    local HEIGHT=1
    local LENGTH=2
    local WIDTH=5
    local centerX=(CornerA.X+CornerB.X)/2
    local centerZ=(CornerA.Z+CornerB.Z)/2
    local steps=math.floor((CornerB.Y-CornerA.Y)/HEIGHT)

    local function stair(dir)
        local y=CornerA.Y
        for i=0,steps do
            for w=0,WIDTH-1 do
                local x,z=centerX,centerZ
                if dir=="f" or dir=="b" then
                    x=centerX-math.floor(WIDTH/2)+w
                    z=centerZ+(dir=="f" and i or -i)*LENGTH
                else
                    z=centerZ-math.floor(WIDTH/2)+w
                    x=centerX+(dir=="r" and i or -i)*LENGTH
                end
                place(Vector3.new(x,y,z))
            end
            y+=HEIGHT
        end
    end

    stair("f"); stair("b"); stair("r"); stair("l")
end)

-- The Chain Tower
BuildTab:Button("The Chain Tower", function()
    local PLATFORM_Y = 72
    local minX, maxX = math.min(CornerA.X, CornerB.X), math.max(CornerA.X, CornerB.X)
    local minY, maxY = math.min(CornerA.Y, CornerB.Y), math.max(CornerA.Y, CornerB.Y)
    local minZ, maxZ = math.min(CornerA.Z, CornerB.Z), math.max(CornerA.Z, CornerB.Z)
    local CenterX = (minX + maxX) / 2
    local CenterZ = (minZ + maxZ) / 2

    -- 3x3 Tower
    for y = minY, maxY, STEP do
        for x = -1, 1 do
            for z = -1, 1 do
                place(Vector3.new(CenterX + (x*STEP), y, CenterZ + (z*STEP)))
            end
        end
    end

    -- 20x20 Platform
    local SIZE = 20
    local OFFSET = math.floor(SIZE / 2)
    local PlatformCorners = {}
    for x = -OFFSET, OFFSET-1 do
        for z = -OFFSET, OFFSET-1 do
            place(Vector3.new(CenterX + (x*STEP), PLATFORM_Y, CenterZ + (z*STEP)))
        end
    end

    table.insert(PlatformCorners, Vector3.new(CenterX - OFFSET*STEP, PLATFORM_Y, CenterZ - OFFSET*STEP))
    table.insert(PlatformCorners, Vector3.new(CenterX + (OFFSET-1)*STEP, PLATFORM_Y, CenterZ - OFFSET*STEP))
    table.insert(PlatformCorners, Vector3.new(CenterX + (OFFSET-1)*STEP, PLATFORM_Y, CenterZ + (OFFSET-1)*STEP))
    table.insert(PlatformCorners, Vector3.new(CenterX - OFFSET*STEP, PLATFORM_Y, CenterZ + (OFFSET-1)*STEP))

    local GroundCorners = {
        Vector3.new(minX, minY, minZ),
        Vector3.new(maxX, minY, minZ),
        Vector3.new(maxX, minY, maxZ),
        Vector3.new(minX, minY, maxZ)
    }

    local function connect3D(a,b)
        local steps = math.max(
            math.abs((b.X-a.X)/STEP),
            math.abs((b.Y-a.Y)/STEP),
            math.abs((b.Z-a.Z)/STEP)
        )
        for i=0,steps do
            local t=i/steps
            place(Vector3.new(
                a.X+(b.X-a.X)*t,
                a.Y+(b.Y-a.Y)*t,
                a.Z+(b.Z-a.Z)*t
            ))
        end
    end

    for _, pCorner in ipairs(PlatformCorners) do
        for _, gCorner in ipairs(GroundCorners) do
            connect3D(pCorner, gCorner)
        end
    end
end)

-- The Wall
BuildTab:Button("The Wall", function()
    local minY = math.min(CornerA.Y, CornerB.Y)
    local maxY = 72
    for y = minY, maxY, STEP do
        for x = CornerA.X, CornerB.X, STEP do
            place(Vector3.new(x, y, CornerA.Z))
        end
    end
end)

-- The Fly Screen
BuildTab:Button("The Fly Screen", function()
    local minY = math.min(CornerA.Y, CornerB.Y)
    local maxY = 72
    local rowToggle = false
    for y = minY, maxY, STEP do
        rowToggle = not rowToggle
        for x = CornerA.X, CornerB.X, STEP do
            if not rowToggle or (rowToggle and (math.floor((x-CornerA.X)/STEP)%2==0)) then
                place(Vector3.new(x, y, CornerA.Z))
            end
        end
    end
end)




--================== POWERS TAB ==================
local PowersTab = Library:CreateTab("Powers")

local UpgradesFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Upgrades")
local EquipRemote = RemotesFolder:WaitForChild("equippower")
local UnequipRemote = RemotesFolder:WaitForChild("unequippower")

-- Scan Powers
local PowerList = {}
for _, module in ipairs(UpgradesFolder:GetChildren()) do
    if module:IsA("ModuleScript") then
        table.insert(PowerList, module.Name)
    end
end
table.sort(PowerList)

-- State
local LastSelection = {}

local function equip(power)
    EquipRemote:FireServer({power})
end

local function unequip(power)
    UnequipRemote:FireServer({power})
end

-- Dropdown (Multiselect!)
PowersTab:Dropdown("Powers", PowerList, function(opt, state, all)
    if state then
        equip(opt)
    else
        unequip(opt)
    end
    LastSelection[opt] = state
end, true)

--================== MISC TAB ===================
local MiscTab = Library:CreateTab("Misc")

-- Heal All Players Toggle
local HealAllEnabled = false
MiscTab:Toggle("Heal All Players", false, function(state)
    HealAllEnabled = state
    if state then
        task.spawn(function()
            while HealAllEnabled do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local args = {
                            {
                                "Heal",
                                player.Character
                            }
                        }
                        RemotesFolder.upgradefxserver:FireServer(unpack(args))
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- Collect All Drops Button
MiscTab:Button("Collect All Drops", function()
    local Drops = workspace:WaitForChild("__DEBRIS"):WaitForChild("MonsterDrops")
    local Remote = RemotesFolder:WaitForChild("redeemdrop")
    for _, drop in ipairs(Drops:GetChildren()) do
        if drop:FindFirstChild("UID") then
            Remote:FireServer({{drop.UID.Value}})
        end
    end
end)
