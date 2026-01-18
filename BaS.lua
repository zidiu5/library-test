-- V 2.3
--================ SETTINGS =================--
_G.showOptionalSettings = true

--================ LOAD LIBRARY =================--
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/zidiu5/library-test/refs/heads/main/Framework.lua"
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
            Remote:FireServer({{{mob, 10000000}}})
        end
    end
end, "Kills all monsters currently on the map.")

-- Heal All Mobs
MobTab:Button("Heal All Mobs", function()
    local Monsters = workspaceThings.Monsters
    local Remote = RemotesFolder.mobdodamage
    for _, mob in ipairs(Monsters:GetChildren()) do
        if mob:IsA("Model") then
            Remote:FireServer({{{mob, -10000}}})
        end
    end
end, "Gives monsters 10.000 extra Health.")

-- Make All Mobs Invincible
MobTab:Button("Invincible Mobs", function()
    local Monsters = workspaceThings.Monsters
    local Remote = RemotesFolder.mobdodamage
    for _, mob in ipairs(Monsters:GetChildren()) do
        if mob:IsA("Model") then
            Remote:FireServer({{{mob, -10000000000000000000000000000000000000000000000000000000}}})
        end
    end
end, "Makes monsters UNKILLABLE.")

--================== SELECTIVE MOB KILL ===================
local MonsterTypes = {"Robot", "RogueBot", "Skeleton", "Tank", "Zombie"}
local SelectedTypes = {}

-- Multi-Select Dropdown
local MobDropdown = MobTab:Dropdown(
    "Select Mob Types",
    MonsterTypes,
    function(opt, state, selection)
        SelectedTypes = selection
    end,
    true,
)

MobDropdown.refreshOnUpdate = true

-- Kill Selected Mobs
MobTab:Button("Kill Selected Mobs", function()
    local Monsters = workspaceThings.Monsters
    local Remote = RemotesFolder.mobdodamage
    for _, mob in ipairs(Monsters:GetChildren()) do
        if mob:IsA("Model") and SelectedTypes[mob.Name] then
            Remote:FireServer({{{mob, 1000000}}})
        end
    end
end, "Instantly kills the selected monster types.")

--================ AUTO KILL ===================
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
                            Remote:FireServer({{{mob, 1000000}}})
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end, "Kills monsters within the selected radius.")

--================ CIRCLE VISUALIZER ===================
local RunService = game:GetService("RunService")
local circleEnabled = false
local SEGMENTS = 60
local CIRCLE_PART_SIZE = 2
local CircleParts = {}

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

MobTab:Toggle("Show Kill Radius", false, function(state)
    circleEnabled = state
end, "Displays a visual circle around your character showing the auto-kill range.")

RunService.RenderStepped:Connect(function()
    local Character = LocalPlayer.Character
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    if HRP then
        for i, part in ipairs(CircleParts) do
            if circleEnabled then
                local angle = (i / SEGMENTS) * math.pi * 2
                part.Position = Vector3.new(
                    HRP.Position.X + math.cos(angle) * KillRadius,
                    HRP.Position.Y + 1,
                    HRP.Position.Z + math.sin(angle) * KillRadius
                )
                part.Transparency = 0.5
            else
                part.Transparency = 1
            end
        end
    end
end)

--================== BUILD TAB ===================
local BuildTab = Library:CreateTab("Build")

local Materials = {"Wood", "Brick", "Metal", "Obsidian", "Firebrick"}
local SelectedBlock = Materials[1]

BuildTab:Dropdown(
    "Select Build Block",
    Materials,
    function(opt)
        SelectedBlock = opt
    end,
    false,
    "Choose which material is used for all building structures."
)

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
end, "Builds a basic frame structure at the corners.")

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
end, "Builds a more complex 3D wireframe connecting all corners.")

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
end, "Builds four; 5-block wide staircases facing all directions.")

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
end, "Builds a central 3x3 tower with a large platform and supports.")




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
end, "Same as 4-Row Stairs just less lag.")


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
end, "Builds a floating platform connected with geometric lines.")



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
end, "Builds a multi-layered structure with various connection levels.")




-- The Wall
BuildTab:Button("The Wall", function()
    local minY = math.min(CornerA.Y, CornerB.Y)
    local maxY = 72
    for y = minY, maxY, STEP do
        for x = CornerA.X, CornerB.X, STEP do
            place(Vector3.new(x, y, CornerA.Z))
        end
    end
end, "Ugly Fat Wall at the front.")

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
end, "Ugly Fat Wall at the front Jr.")









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
end, true, "Do you really need infos for this?")

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
                task.wait(0.1)
            end
        end)
    end
end, "Heals all Players(Lags after Time)")

-- Collect All Drops Button
MiscTab:Button("Collect All Drops", function()
    local Drops = workspace:WaitForChild("__DEBRIS"):WaitForChild("MonsterDrops")
    local Remote = RemotesFolder:WaitForChild("redeemdrop")
    for _, drop in ipairs(Drops:GetChildren()) do
        if drop:FindFirstChild("UID") then
            Remote:FireServer({{drop.UID.Value}})
        end
    end
end, "Collects all Drops. (Lvl 100 the Blue things lag)")
