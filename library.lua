--// ⚫🔴 DarkRed Library v4 (Mobile Ready + Clean + Persisting Position)
-- Schwarz/Rot Theme | Smooth Animation | Touch-Dragging | Titel + Tabs links | OpenButton Draggable

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library

local THEME = {
    Background = Color3.fromRGB(18,18,18),
    Secondary = Color3.fromRGB(32,32,32),
    Accent = Color3.fromRGB(200,30,30),
    Text = Color3.fromRGB(235,235,235)
}

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function createBaseGui(title)
    local gui = Instance.new("ScreenGui")
    gui.Name = "DarkRedLibrary"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    -- Open/Close Button
    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.new(0,40,0,40)
    openButton.Position = UDim2.new(0,10,0,10)
    openButton.Text = "≡"
    openButton.Font = Enum.Font.GothamBold
    openButton.TextSize = 22
    openButton.TextColor3 = THEME.Text
    openButton.BackgroundColor3 = THEME.Secondary
    openButton.Parent = gui
    Instance.new("UICorner", openButton).CornerRadius = UDim.new(0,8)

    -- Hauptfenster
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,520,0,360)
    main.Position = UDim2.new(-1,0,0.25,0)
    main.BackgroundColor3 = THEME.Background
    main.Active = true
    main.ClipsDescendants = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

    -- Drop Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.ZIndex = 0
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    shadow.Size = UDim2.new(1,20,1,20)
    shadow.Position = UDim2.new(0,-10,0,-10)
    shadow.BackgroundTransparency = 1
    shadow.Parent = main

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1,0,0,40)
    topbar.BackgroundColor3 = THEME.Secondary
    topbar.Parent = main
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0,10)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0,10,0,0)
    titleLabel.Text = title or "DarkRed UI"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = THEME.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = topbar

    -- Tabs-Leiste
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0,140,1,-40)
    tabFrame.Position = UDim2.new(0,0,0,40)
    tabFrame.BackgroundColor3 = THEME.Secondary
    tabFrame.Parent = main

    local tabLayout = Instance.new("UIListLayout", tabFrame)
    tabLayout.Padding = UDim.new(0,6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Content Bereich mit Padding
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-140,1,-40)
    content.Position = UDim2.new(0,140,0,40)
    content.BackgroundColor3 = THEME.Background
    content.Parent = main
    content.Padding = 12 -- Abstand zu Tabs
    content.LayoutOrder = 1

    local folder = Instance.new("Folder")
    folder.Name = "Pages"
    folder.Parent = content

    return {
        Gui = gui,
        OpenButton = openButton,
        Main = main,
        Topbar = topbar,
        Tabs = tabFrame,
        Content = content,
        Pages = folder,
        TitleLabel = titleLabel
    }
end

function Library.new(cfg)
    local self = setmetatable({}, Library)
    self.UI = createBaseGui(cfg and cfg.title or "DarkRed UI")
    self.Tabs = {}
    self.Open = false
    self.LastPosition = UDim2.new(0.5,-260,0.25,0) -- default

    -- Öffnen/Schließen
    self.UI.OpenButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Touch/Mouse Drag für Main Frame
    local dragging, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        self.UI.Main.Position = newPos
        self.LastPosition = newPos
    end

    local function startDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = self.UI.Main.Position
    end

    local function stopDrag()
        dragging = false
    end

    -- Main Frame Drag
    self.UI.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(input)
        end
    end)
    self.UI.Topbar.InputChanged:Connect(function(input)
        if dragging then updateDrag(input) end
    end)
    self.UI.Topbar.InputEnded:Connect(stopDrag)

    -- OpenButton Dragging (getrennt vom Klick)
    local btnDragging, btnStartPos, btnStartOffset
    self.UI.OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            btnDragging = true
            btnStartPos = input.Position
            btnStartOffset = self.UI.OpenButton.Position
        end
    end)
    self.UI.OpenButton.InputChanged:Connect(function(input)
        if btnDragging then
            local delta = input.Position - btnStartPos
            self.UI.OpenButton.Position = UDim2.new(btnStartOffset.X.Scale, btnStartOffset.X.Offset + delta.X, btnStartOffset.Y.Scale, btnStartOffset.Y.Offset + delta.Y)
        end
    end)
    self.UI.OpenButton.InputEnded:Connect(function(input)
        btnDragging = false
    end)

    return self
end

function Library:Toggle()
    local target = self.Open and UDim2.new(-1,0,0.25,0) or self.LastPosition
    tween(self.UI.Main, {Position = target}, 0.3)
    self.Open = not self.Open
end

-- Tabs
function Library:AddTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1,-20,0,36)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextColor3 = THEME.Text
    tabBtn.BackgroundColor3 = THEME.Background
    tabBtn.Parent = self.UI.Tabs
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0,6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.CanvasSize = UDim2.new(0,0,0,600)
    page.ScrollBarThickness = 5
    page.Visible = false
    page.BackgroundTransparency = 1
    page.Parent = self.UI.Pages

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    table.insert(self.Tabs, {Button = tabBtn, Page = page})

    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do
            t.Page.Visible = false
            tween(t.Button, {BackgroundColor3 = THEME.Background}, 0.2)
        end
        page.Visible = true
        tween(tabBtn, {BackgroundColor3 = THEME.Accent}, 0.2)
    end)

    if #self.Tabs == 1 then
        page.Visible = true
        tabBtn.BackgroundColor3 = THEME.Accent
    end

    return page
end

-- UI Elemente
function Library:AddLabel(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,24)
    lbl.Text = text
    lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.Parent = tab
    return lbl
end

function Library:AddButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,34)
    btn.Position = UDim2.new(0,12,0,0)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = THEME.Text
    btn.BackgroundColor3 = THEME.Secondary
    btn.Parent = tab
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

function Library:AddToggle(tab, text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-20,0,34)
    container.Position = UDim2.new(0,12,0,0)
    container.BackgroundTransparency = 1
    container.Parent = tab

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0)
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = THEME.Text
    lbl.BackgroundTransparency = 1
    lbl.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,50,0,24)
    btn.Position = UDim2.new(1,-50,0.5,-12)
    btn.BackgroundColor3 = default and THEME.Accent or THEME.Secondary
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local val = default
    btn.MouseButton1Click:Connect(function()
        val = not val
        btn.Text = val and "ON" or "OFF"
        tween(btn, {BackgroundColor3 = val and THEME.Accent or THEME.Secondary}, 0.2)
        pcall(callback, val)
    end)
end

function Library:AddTextbox(tab, placeholder, callback)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0,180,0,30)
    tb.Position = UDim2.new(0,12,0,0)
    tb.PlaceholderText = placeholder
    tb.TextColor3 = THEME.Text
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    tb.BackgroundColor3 = THEME.Secondary
    tb.Parent = tab
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0,6)
    tb.FocusLost:Connect(function(enter)
        if enter then pcall(callback, tb.Text) end
    end)
end

function Library:AddDropdown(tab, text, options, callback)
    local dd = Instance.new("Frame")
    dd.Size = UDim2.new(0,180,0,34)
    dd.Position = UDim2.new(0,12,0,0)
    dd.BackgroundColor3 = THEME.Secondary
    dd.Parent = tab
    Instance.new("UICorner", dd).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", dd)
    lbl.Size = UDim2.new(1,-28,1,0)
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = THEME.Text
    lbl.TextSize = 14
    lbl.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", dd)
    btn.Size = UDim2.new(0,26,0,26)
    btn.Position = UDim2.new(1,-26,0.5,-13)
    btn.Text = "▾"
    btn.BackgroundTransparency = 1
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16

    local list = Instance.new("Frame", dd)
    list.Position = UDim2.new(0,0,1,4)
    list.Size = UDim2.new(1,0,0,0)
    list.BackgroundColor3 = THEME.Secondary
    list.Visible = false
    Instance.new("UICorner", list).CornerRadius = UDim.new(0,6)
    local layout = Instance.new("UIListLayout", list)
    layout.Padding = UDim.new(0,4)

    for _,opt in ipairs(options) do
        local o = Instance.new("TextButton", list)
        o.Size = UDim2.new(1,-8,0,26)
        o.Text = opt
        o.Font = Enum.Font.Gotham
        o.TextSize = 14
        o.TextColor3 = THEME.Text
        o.BackgroundColor3 = THEME.Background
        Instance.new("UICorner", o).CornerRadius = UDim.new(0,6)
        o.MouseButton1Click:Connect(function()
            lbl.Text = opt
            list.Visible = false
            pcall(callback, opt)
        end)
    end

    btn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        list.Size = list.Visible and UDim2.new(1,0,0,#options*30) or UDim2.new(1,0,0,0)
    end)
end

return Library
