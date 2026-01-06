-- V 2.2
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
            Remote:FireServer({{{mob, 100000}}})
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

-- Make All Mobs Invincible
MobTab:Button("Invincible Mobs", function()
    local Monsters = workspaceThings.Monsters
    local Remote = RemotesFolder.mobdodamage
    for _, mob in ipairs(Monsters:GetChildren()) do
        if mob:IsA("Model") then
            Remote:FireServer({{{mob, -10000000000000000000000000000000000000000000000000000000000}}})
        end
    end
end)

--================== SELECTIVE MOB KILL ===================
local MonsterTypes = {"Robot", "RogueBot", "Skeleton", "Tank", "Zombie"}
local SelectedTypes = {} -- Dictionary für Multiselect

-- Multi-Select Dropdown
local MobDropdown = MobTab:Dropdown("Select Mob Types", MonsterTypes, function(opt, state, selection)
    SelectedTypes = selection -- speichert die aktuelle Auswahl
end, true) -- true = Multiselect

MobDropdown.refreshOnUpdate = true

-- Button: Kill Selected Mobs
MobTab:Button("Kill Selected Mobs", function()
    local Monsters = workspaceThings.Monsters
    local Remote = RemotesFolder.mobdodamage
    for _, mob in ipairs(Monsters:GetChildren()) do
        if mob:IsA("Model") and SelectedTypes[mob.Name] then
            Remote:FireServer({{{mob, 100000}}})
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




-- LOW-LAG STAIRS
BuildTab:Button("Low-Lag Stairs", function()
    local Remote = workspace.__THINGS.__REMOTES.placeblock
    local BlockType = SelectedBlock -- benutzt das Dropdown-Material
    local BlockPart = workspace.__THINGS.__BLOCKS[BlockType].Part

    local HEIGHT_STEP = 1   -- jede Stufe hoch
    local LENGTH_STEP = 2   -- jede Stufe vorwärts
    local WIDTH = 3         -- 3 Blöcke breit
    local BLOCK_SPACING = 4 -- Abstand zwischen Blöcken

    local CornerA = Vector3.new(-252, -8, 52) -- Boden
    local CornerB = Vector3.new(112, 72, 368) -- Oben

    local centerX = (CornerA.X + CornerB.X) / 2
    local centerZ = (CornerA.Z + CornerB.Z) / 2

    -- BUILD FUNCTION 
    local function place(pos)
        Remote:FireServer({
            CFrame.new(pos),
            BlockType,
            BlockPart
        })
    end

    -- BUILD STAIR FUNCTION 
    local function buildStair(direction)
        local currentY = CornerA.Y
        local steps = math.floor((CornerB.Y - CornerA.Y) / HEIGHT_STEP)

        for i = 0, steps do
            local offsetX = 0
            local offsetZ = 0
            if direction == "forward" then offsetZ = i * LENGTH_STEP end
            if direction == "backward" then offsetZ = -i * LENGTH_STEP end
            if direction == "right" then offsetX = i * LENGTH_STEP end
            if direction == "left" then offsetX = -i * LENGTH_STEP end

            for w = 0, WIDTH-1 do
                local posX = centerX + offsetX
                local posZ = centerZ + offsetZ
                if direction == "forward" or direction == "backward" then
                    posX = centerX - math.floor(WIDTH/2) * BLOCK_SPACING + w * BLOCK_SPACING
                else
                    posZ = centerZ - math.floor(WIDTH/2) * BLOCK_SPACING + w * BLOCK_SPACING
                end
                place(Vector3.new(posX, currentY, posZ))
            end

            currentY = currentY + HEIGHT_STEP
        end
    end

    -- BUILD ALL 4 DIRECTIONS 
    buildStair("forward")
    buildStair("backward")
    buildStair("right")
    buildStair("left")
end)


--================ THE FLYING CRYSTAL ===================
BuildTab:Button("The Flying Crystal", function()
    local BLOCK_NAME = SelectedBlock
    local STEP = 4
    local PLATFORM_Y = 4
    local TOP_Y = 72

    local PlaceRemote = workspace.__THINGS.__REMOTES.placeblock
    local BlockPart = workspace.__THINGS.__BLOCKS[BLOCK_NAME].Part

    local CornerA = Vector3.new(-252, -8, 52)
    local CornerB = Vector3.new(112, 72, 368)

    local minX,maxX = math.min(CornerA.X,CornerB.X), math.max(CornerA.X,CornerB.X)
    local minY,maxY = math.min(CornerA.Y,CornerB.Y), math.max(CornerA.Y,CornerB.Y)
    local minZ,maxZ = math.min(CornerA.Z,CornerB.Z), math.max(CornerA.Z,CornerB.Z)

    local function place(pos)
        PlaceRemote:FireServer({CFrame.new(pos), BLOCK_NAME, BlockPart})
    end

    local CenterX = (minX + maxX) / 2
    local CenterZ = (minZ + maxZ) / 2

    -- Plattform
    local SIZE = 20
    local OFFSET = math.floor(SIZE / 2)
    local PlatformCorners = {}

    for x=-OFFSET,OFFSET-1 do
        for z=-OFFSET,OFFSET-1 do
            place(Vector3.new(CenterX+x*STEP, PLATFORM_Y, CenterZ+z*STEP))
        end
    end

    PlatformCorners = {
        Vector3.new(CenterX-OFFSET*STEP, PLATFORM_Y, CenterZ-OFFSET*STEP),
        Vector3.new(CenterX+(OFFSET-1)*STEP, PLATFORM_Y, CenterZ-OFFSET*STEP),
        Vector3.new(CenterX+(OFFSET-1)*STEP, PLATFORM_Y, CenterZ+(OFFSET-1)*STEP),
        Vector3.new(CenterX-OFFSET*STEP, PLATFORM_Y, CenterZ+(OFFSET-1)*STEP)
    }

    -- Säulen
    local MapCorners = {
        Vector3.new(minX,minY,minZ),
        Vector3.new(maxX,minY,minZ),
        Vector3.new(maxX,minY,maxZ),
        Vector3.new(minX,minY,maxZ)
    }

    for _,c in ipairs(MapCorners) do
        for y=minY,TOP_Y,STEP do
            place(Vector3.new(c.X,y,c.Z))
        end
    end

    local function connect3D(a,b)
        local steps=math.max(
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

    -- Ketten
    for i=1,4 do
        connect3D(Vector3.new(MapCorners[i].X,TOP_Y,MapCorners[i].Z), PlatformCorners[i])
    end

    local centerTop = Vector3.new(CenterX, TOP_Y, CenterZ)
    for _,c in ipairs(PlatformCorners) do connect3D(c, centerTop) end
    for _,c in ipairs(MapCorners) do
        connect3D(Vector3.new(c.X,TOP_Y,c.Z), centerTop)
    end
end)



--================ THE FLYING HOUSE ===================
BuildTab:Button("The Flying House", function()
    local BLOCK_NAME = SelectedBlock
    local STEP = 4
    local PLATFORM_BOTTOM_Y = 4
    local PLATFORM_MIDDLE_Y = 40
    local TOP_Y = 72

    local PlaceRemote = workspace.__THINGS.__REMOTES.placeblock
    local BlockPart = workspace.__THINGS.__BLOCKS[BLOCK_NAME].Part

    local CornerA = Vector3.new(-252, -8, 52)
    local CornerB = Vector3.new(112, 72, 368)

    local minX,maxX = math.min(CornerA.X,CornerB.X), math.max(CornerA.X,CornerB.X)
    local minY,maxY = math.min(CornerA.Y,CornerB.Y), math.max(CornerA.Y,CornerB.Y)
    local minZ,maxZ = math.min(CornerA.Z,CornerB.Z), math.max(CornerA.Z,CornerB.Z)

    local function place(pos)
        PlaceRemote:FireServer({CFrame.new(pos), BLOCK_NAME, BlockPart})
    end

    local function buildPlatform(cx,cz,y)
        local SIZE=20
        local OFFSET=math.floor(SIZE/2)
        local corners={}
        for x=-OFFSET,OFFSET-1 do
            for z=-OFFSET,OFFSET-1 do
                place(Vector3.new(cx+x*STEP,y,cz+z*STEP))
            end
        end
        corners={
            Vector3.new(cx-OFFSET*STEP,y,cz-OFFSET*STEP),
            Vector3.new(cx+(OFFSET-1)*STEP,y,cz-OFFSET*STEP),
            Vector3.new(cx+(OFFSET-1)*STEP,y,cz+(OFFSET-1)*STEP),
            Vector3.new(cx-OFFSET*STEP,y,cz+(OFFSET-1)*STEP)
        }
        return corners
    end

    local CenterX=(minX+maxX)/2
    local CenterZ=(minZ+maxZ)/2

    local bottomCorners = buildPlatform(CenterX,CenterZ,PLATFORM_BOTTOM_Y)
    local middleCorners = buildPlatform(CenterX,CenterZ,PLATFORM_MIDDLE_Y)

    local MapCorners={
        Vector3.new(minX,minY,minZ),
        Vector3.new(maxX,minY,minZ),
        Vector3.new(maxX,minY,maxZ),
        Vector3.new(minX,minY,maxZ)
    }

    for _,c in ipairs(MapCorners) do
        for y=minY,TOP_Y,STEP do
            place(Vector3.new(c.X,y,c.Z))
        end
    end

    local function connect3D(a,b)
        local steps=math.max(
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

    local topCenter=Vector3.new(CenterX,TOP_Y,CenterZ)

    for i=1,4 do
        connect3D(Vector3.new(MapCorners[i].X,TOP_Y,MapCorners[i].Z), bottomCorners[i])
        connect3D(bottomCorners[i], middleCorners[i])
        connect3D(middleCorners[i], topCenter)
        connect3D(Vector3.new(MapCorners[i].X,TOP_Y,MapCorners[i].Z), topCenter)
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




--================ DRAW TO BUILD TAB ===================
local DrawTab = Library:CreateTab("Draw to Build") -- erstellt einen neuen Tab in deiner GUI

--================ SERVICES ===================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--================ BUILD SETTINGS ===================
local CornerA = Vector3.new(-252, -8, 52)
local CornerB = Vector3.new(112, -8, 368)
local Things = workspace:WaitForChild("__THINGS")
local Remotes = Things:WaitForChild("__REMOTES")
local PlaceRemote = Remotes:WaitForChild("placeblock")
local Blocks = Things:WaitForChild("__BLOCKS")
local BlockName = "Obsidian"
local BlockFolder = Blocks:FindFirstChild(BlockName)

if not BlockFolder then
    warn("Block existiert nicht:", BlockName)
    return
end

local BlockPart = BlockFolder.Part
local GRID_STEP = 4

--================ GUI CALCULATION ===================
local realWidth = math.abs(CornerB.X - CornerA.X)
local realDepth = math.abs(CornerB.Z - CornerA.Z)
local scaleFactor = 4
local canvasW = (realWidth / GRID_STEP) * scaleFactor
local canvasH = (realDepth / GRID_STEP) * scaleFactor

--================ GUI SETUP ===================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, canvasW + 95, 0, canvasH + 20)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Parent = DrawTab.Container

local Canvas = Instance.new("Frame")
Canvas.Size = UDim2.new(0, canvasW, 0, canvasH)
Canvas.Position = UDim2.new(0, 85, 0, 10)
Canvas.BackgroundColor3 = Color3.new(1, 1, 1)
Canvas.ClipsDescendants = true
Canvas.Parent = Main

local function createBtn(text, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 70, 0, 32)
    b.Position = pos
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = Main
    return b
end

local PenBtn = createBtn("✏️ Pen", UDim2.new(0, 7, 0, 10), Color3.fromRGB(80, 80, 80))
local EraserBtn = createBtn("🧽 Eraser", UDim2.new(0, 7, 0, 47))
local ClearBtn = createBtn("❌ Clear", UDim2.new(0, 7, 0, 84), Color3.fromRGB(120, 40, 40))
local BuildBtn = createBtn("🧱 BUILD", UDim2.new(0, 7, 0, 121), Color3.fromRGB(40, 120, 40))
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0, 70, 0, 32)
TextBox.Position = UDim2.new(0, 7, 0, 165)
TextBox.PlaceholderText = "Text..."
Text.Box.Text = ""
TextBox.BackgroundColor3 = Color3.new(0.9,0.9,0.9)
TextBox.Parent = Main
local DrawBtn = createBtn("Draw", UDim2.new(0, 7, 0, 202), Color3.fromRGB(40, 60, 120))

--================ FONT (Kompakt) ===================
local FONT = {
    -- GROSSBUCHSTABEN
    ["A"]={"0001000","0010100","0100010","0100010","0111110","0100010","0100010","0100010","0100010"},
    ["B"]={"1111100","1000010","1000010","1000010","1111100","1000010","1000010","1000010","1111100"},
    ["C"]={"0111110","1000001","1000000","1000000","1000000","1000000","1000000","1000001","0111110"},
    ["D"]={"1111100","1000010","1000010","1000010","1000010","1000010","1000010","1000010","1111100"},
    ["E"]={"1111111","1000000","1000000","1000000","1111110","1000000","1000000","1000000","1111111"},
    ["F"]={"1111111","1000000","1000000","1000000","1111110","1000000","1000000","1000000","1000000"},
    ["G"]={"0111110","1000001","1000000","1000000","1001111","1000001","1000001","1000001","0111110"},
    ["H"]={"1000001","1000001","1000001","1000001","1111111","1000001","1000001","1000001","1000001"},
    ["I"]={"0111110","0001000","0001000","0001000","0001000","0001000","0001000","0001000","0111110"},
    ["J"]={"0000011","0000001","0000001","0000001","0000001","0000001","1000001","1000001","0111110"},
    ["K"]={"1000010","1000100","1001000","1010000","1100000","1010000","1001000","1000100","1000010"},
    ["L"]={"1000000","1000000","1000000","1000000","1000000","1000000","1000000","1000000","1111111"},
    ["M"]={"1000001","1100011","1010101","1001001","1000001","1000001","1000001","1000001","1000001"},
    ["N"]={"1000001","1100001","1010001","1001001","1000101","1000011","1000001","1000001","1000001"},
    ["O"]={"0111110","1000001","1000001","1000001","1000001","1000001","1000001","1000001","0111110"},
    ["P"]={"1111110","1000001","1000001","1000001","1111110","1000000","1000000","1000000","1000000"},
    ["Q"]={"0111110","1000001","1000001","1000001","1000001","1000001","1010001","1001001","0111111"},
    ["R"]={"1111100","1000010","1000010","1000010","1111100","1001000","1000100","1000010","1000001"},
    ["S"]={"0111111","1000000","1000000","0111110","0000001","0000001","0000001","0000001","1111110"},
    ["T"]={"1111111","0001000","0001000","0001000","0001000","0001000","0001000","0001000","0001000"},
    ["U"]={"1000001","1000001","1000001","1000001","1000001","1000001","1000001","1000001","0111110"},
    ["V"]={"1000001","1000001","1000001","1000001","1000001","0100010","0100010","0010100","0001000"},
    ["W"]={"1000001","1000001","1000001","1000001","1001001","1010101","1010101","1100011","1000001"},
    ["X"]={"1000001","0100010","0100010","0010100","0001000","0010100","0100010","0100010","1000001"},
    ["Y"]={"1000001","0100010","0100010","0010100","0001000","0001000","0001000","0001000","0001000"},
    ["Z"]={"1111111","0000001","0000010","0000100","0001000","0010000","0100000","1000000","1111111"},

    -- KLEINBUCHSTABEN
    ["a"]={"0000000","0000000","0000000","0111110","0000001","0111111","1000001","1000001","0111111"},
    ["b"]={"1000000","1000000","1000000","1011100","1100010","1000010","1000010","1100010","1011100"},
    ["c"]={"0000000","0000000","0000000","0011110","0100000","0100000","0100000","0100001","0011110"},
    ["d"]={"0000001","0000001","0000001","0011101","0100011","1000001","1000001","0100011","0011101"},
    ["e"]={"0000000","0000000","0000000","0111110","1000001","1111111","1000000","1000001","0111110"},
    ["f"]={"0001100","0010010","0010000","1111000","0010000","0010000","0010000","0010000","0010000"},
    ["g"]={"0000000","0011101","0100011","1000001","1000001","0100011","0011101","0000001","0111110"},
    ["h"]={"1000000","1000000","1000000","1011110","1100001","1000001","1000001","1000001","1000001"},
    ["i"]={"0001000","0000000","0000000","0011000","0001000","0001000","0001000","0001000","0011100"},
    ["j"]={"0000100","0000000","0000000","0001100","0000100","0000100","0000100","1000100","0111000"},
    ["k"]={"1000000","1000000","1000000","1000010","1000100","1011000","1001000","1000100","1000010"},
    ["l"]={"0110000","0010000","0010000","0010000","0010000","0010000","0010000","0010000","0001110"},
    ["m"]={"0000000","0000000","0000000","1010110","1101001","1010001","1010001","1010001","1010001"},
    ["n"]={"0000000","0000000","0000000","1011110","1100001","1000001","1000001","1000001","1000001"},
    ["o"]={"0000000","0000000","0000000","0111110","1000001","1000001","1000001","1000001","0111110"},
    ["p"]={"0000000","1011110","1100001","1000001","1000001","1100001","1011110","1000000","1000000"},
    ["q"]={"0000000","0011101","0100011","1000001","1000001","0100011","0011101","0000001","0000001"},
    ["r"]={"0000000","0000000","0000000","1011110","1100001","1000000","1000000","1000000","1000000"},
    ["s"]={"0000000","0000000","0000000","0111111","1000000","0111110","0000001","1000001","1111110"},
    ["t"]={"0010000","0010000","1111110","0010000","0010000","0010000","0010000","0010010","0001100"},
    ["u"]={"0000000","0000000","0000000","1000001","1000001","1000001","1000001","1000011","0111101"},
    ["v"]={"0000000","0000000","0000000","1000001","1000001","1000001","0100010","0100010","0001000"},
    ["w"]={"0000000","0000000","0000000","1000001","1000001","1010101","1010101","1011101","0101010"},
    ["x"]={"0000000","0000000","0000000","1000001","0100010","0011100","0100010","1000001","1000001"},
    ["y"]={"0000000","1000001","1000001","1000001","0100011","0011101","0000001","1000010","0111100"},
    ["z"]={"0000000","0000000","0000000","1111111","0000010","0001100","0010000","0100000","1111111"},

    -- SPEZIALSYMBOLE & ZAHLEN
    ["0"]={"0111110","1000001","1000011","1000101","1001001","1010001","1100001","1000001","0111110"},
    ["1"]={"0001000","0011000","0101000","0001000","0001000","0001000","0001000","0001000","0111110"},
    ["2"]={"0111110","1000001","0000001","0000010","0001100","0010000","0100000","1000000","1111111"},
    ["3"]={"1111111","0000010","0000100","0001100","0000010","0000001","0000001","1000001","0111110"},
    ["4"]={"0000100","0001100","0010100","0100100","1000100","1111111","0000100","0000100","0000100"},
    ["5"]={"1111111","1000000","1000000","1111110","0000001","0000001","0000001","1000001","0111110"},
    ["6"]={"0111110","1000000","1000000","1111110","1000001","1000001","1000001","1000001","0111110"},
    ["7"]={"1111111","0000001","0000010","0000100","0001000","0010000","0100000","0100000","0100000"},
    ["8"]={"0111110","1000001","1000001","0111110","1000001","1000001","1000001","1000001","0111110"},
    ["9"]={"0111110","1000001","1000001","1000001","0111111","0000001","0000001","0000001","0111110"},
    ["€"]={"0011110","0100001","1111000","0100000","1111000","0100000","0100001","0011110","0000000"},
    ["#"]={"0010010","0010010","1111111","0010010","1111111","0010010","0010010","0000000","0000000"},
    ["*"]={"0001000","1011101","0111110","0011100","0111110","1011101","0001000","0000000","0000000"},
    ["π"]={"0000000","0000000","1111111","0010010","0010010","0010010","0010010","0010010","1010011"},
    ["!"]={"0001000","0001000","0001000","0001000","0001000","0001000","0000000","0001000","0000000"},
    ["?"]={"0111110","1000001","0000001","0000010","0001100","0001000","0000000","0001000","0000000"},
    ["."]={"0000000","0000000","0000000","0000000","0000000","0000000","0000000","0110000","0110000"},
    [","]={"0000000","0000000","0000000","0000000","0000000","0000000","0000000","0011000","0001000"},
    [" "]={"0000000","0000000","0000000","0000000","0000000","0000000","0000000","0000000","0000000"},
}

--================ CORE VARIABLES ===================
local mode = "Pen"
local isDrawing = false
local lastPos = nil
local currentInput = nil
local GRID_X, GRID_Y = 7, 9

--================ DRAW FUNCTIONS ===================
local function drawDot(pos)
    local snX = math.floor(pos.X / scaleFactor) * scaleFactor
    local snY = math.floor(pos.Y / scaleFactor) * scaleFactor
    for _, v in ipairs(Canvas:GetChildren()) do
        if v.Position.X.Offset == snX and v.Position.Y.Offset == snY then return end
    end
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, scaleFactor, 0, scaleFactor)
    dot.Position = UDim2.new(0, snX, 0, snY)
    dot.BackgroundColor3 = Color3.new(0, 0, 0)
    dot.BorderSizePixel = 0
    dot.Name = "Dot"
    dot.Parent = Canvas
end

local function erase(pos)
    for _, v in ipairs(Canvas:GetChildren()) do
        if v.Name == "Dot" then
            local vP = Vector2.new(v.Position.X.Offset, v.Position.Y.Offset)
            if (vP - pos).Magnitude < (scaleFactor * 2.2) then v:Destroy() end
        end
    end
end

local function processInput()
    if not currentInput then return end
    local absPos = currentInput.Position
    local canvasPos = Canvas.AbsolutePosition
    local relX = absPos.X - canvasPos.X
    local relY = absPos.Y - canvasPos.Y
    if relX < 0 or relY < 0 or relX > Canvas.AbsoluteSize.X or relY > Canvas.AbsoluteSize.Y then lastPos = nil return end
    local relPos = Vector2.new(relX, relY)
    if lastPos then
        local dist = (relPos - lastPos).Magnitude
        local steps = math.max(1, math.floor(dist / (scaleFactor / 2)))
        for i=0,steps do
            local p = lastPos:Lerp(relPos, i/steps)
            if mode == "Pen" then drawDot(p) else erase(p) end
        end
    else
        if mode == "Pen" then drawDot(relPos) else erase(relPos) end
    end
    lastPos = relPos
end

--================ INPUT EVENTS ===================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDrawing = true
        currentInput = input
        lastPos = nil
        processInput()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == currentInput then isDrawing = false currentInput = nil lastPos = nil end
end)

UserInputService.InputChanged:Connect(function(input)
    if not isDrawing then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        currentInput = input
        processInput()
    end
end)

--================ BUTTON CALLBACKS ===================
PenBtn.MouseButton1Click:Connect(function()
    mode = "Pen"
    PenBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    EraserBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
end)

EraserBtn.MouseButton1Click:Connect(function()
    mode = "Eraser"
    EraserBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    PenBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
end)

ClearBtn.MouseButton1Click:Connect(function()
    Canvas:ClearAllChildren()
end)

--================ BUILD ===================
BuildBtn.MouseButton1Click:Connect(function()
    local placed = {}
    for _, dot in ipairs(Canvas:GetChildren()) do
        if dot.Name == "Dot" then
            local gridX = dot.Position.X.Offset / scaleFactor
            local gridZ = dot.Position.Y.Offset / scaleFactor
            local worldX = CornerA.X + (gridX * GRID_STEP)
            local worldZ = CornerA.Z + (gridZ * GRID_STEP)
            local key = worldX.."_"..worldZ
            if not placed[key] then
                placed[key] = true
                PlaceRemote:FireServer({CFrame.new(worldX, CornerA.Y, worldZ), BlockName, BlockPart})
                task.wait(0.01)
            end
        end
    end
end)

--================ DRAW TEXT ===================
DrawBtn.MouseButton1Click:Connect(function()
    Canvas:ClearAllChildren()
    local text = TextBox.Text:upper()
    local startX, startY = scaleFactor, scaleFactor
    local curX, curY = startX, startY
    local charW, charH = (GRID_X + 1) * scaleFactor, (GRID_Y + 1) * scaleFactor
    for i = 1, #text do
        local char = text:sub(i,i)
        if curX + (GRID_X * scaleFactor) > Canvas.AbsoluteSize.X then
            curX = startX
            curY = curY + charH
        end
        if curY + (GRID_Y * scaleFactor) > Canvas.AbsoluteSize.Y then break end
        local grid = FONT[char] or FONT[" "]
        for y = 1, GRID_Y do
            local row = grid[y]
            if row then
                for x = 1, GRID_X do
                    if row:sub(x,x) == "1" then
                        drawDot(Vector2.new(curX + (x-1)*scaleFactor, curY + (y-1)*scaleFactor))
                    end
                end
            end
        end
        curX = curX + charW
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
