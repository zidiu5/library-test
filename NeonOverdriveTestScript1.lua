--================ SERVICES ===================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

--================ BUILD SETTINGS ===============
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

--================ GUI CALCULATION =================
local realWidth = math.abs(CornerB.X - CornerA.X)
local realDepth = math.abs(CornerB.Z - CornerA.Z)

local scaleFactor = 4 
local canvasW = (realWidth / GRID_STEP) * scaleFactor
local canvasH = (realDepth / GRID_STEP) * scaleFactor

--================ GUI SETUP =======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, canvasW + 95, 0, canvasH + 20)
Main.Position = UDim2.new(0.5, -(canvasW+95)/2, 0.5, -(canvasH+20)/2)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Parent = ScreenGui
Main.Visible = false

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
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.new(0.9,0.9,0.9)
TextBox.Parent = Main
local DrawBtn = createBtn("Draw", UDim2.new(0, 7, 0, 202), Color3.fromRGB(40, 60, 120))

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 80, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "GUI"
ToggleButton.Parent = ScreenGui

--================ FONT (Kompakt) =================
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

--================ CORE FUNCTIONS =================
local mode = "Pen"
local isDrawing = false
local GRID_Y = 9
local GRID_X = 7
local lastPos = nil
local currentInput = nil


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
            if (vP - pos).Magnitude < (scaleFactor * 2.2) then 
                v:Destroy() 
            end
        end
    end
end

--================ INPUT ===================
local function processInput()
    if not Main.Visible then return end
    if not currentInput then return end
    
    local absPos = currentInput.Position
    local canvasPos = Canvas.AbsolutePosition
    local canvasSize = Canvas.AbsoluteSize

    local relX = absPos.X - canvasPos.X
    local relY = absPos.Y - canvasPos.Y

    if relX < 0 or relY < 0
    or relX > canvasSize.X
    or relY > canvasSize.Y then
        lastPos = nil
        return
    end

    local relPos = Vector2.new(relX, relY)

    if lastPos then
        local dist = (relPos - lastPos).Magnitude
        local steps = math.max(1, math.floor(dist / (scaleFactor / 2)))

        for i = 0, steps do
            local p = lastPos:Lerp(relPos, i / steps)
            if mode == "Pen" then
                drawDot(p)
            else
                erase(p)
            end
        end
    else
        if mode == "Pen" then
            drawDot(relPos)
        else
            erase(relPos)
        end
    end

    lastPos = relPos
end



UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        isDrawing = true
        currentInput = input
        lastPos = nil
        processInput()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == currentInput then
        isDrawing = false
        currentInput = nil
        lastPos = nil
    end
end)


UserInputService.InputChanged:Connect(function(input)
    if not isDrawing then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        currentInput = input
        processInput()
    end
end)


--================ BUTTONS =================
PenBtn.MouseButton1Click:Connect(function() mode = "Pen" PenBtn.BackgroundColor3 = Color3.fromRGB(80,80,80) EraserBtn.BackgroundColor3 = Color3.fromRGB(60,60,60) end)
EraserBtn.MouseButton1Click:Connect(function() mode = "Eraser" EraserBtn.BackgroundColor3 = Color3.fromRGB(80,80,80) PenBtn.BackgroundColor3 = Color3.fromRGB(60,60,60) end)
ClearBtn.MouseButton1Click:Connect(function() Canvas:ClearAllChildren() end)
ToggleButton.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

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

--================ DRAW TEXT =================
DrawBtn.MouseButton1Click:Connect(function()
    Canvas:ClearAllChildren()
    local text = TextBox.Text:upper()
    local startX = scaleFactor
    local startY = scaleFactor
    local curX = startX
    local curY = startY
    
    local charW = (GRID_X + 1) * scaleFactor 
    local charH = (GRID_Y + 1) * scaleFactor 

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
