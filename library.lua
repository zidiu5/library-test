--// 🔧 FIXED DarkRed UI Library (2025 Edition)
-- Verbesserungen:
-- ✅ Tabs funktionieren
-- ✅ Inhalte sichtbar
-- ✅ Dragging funktioniert
-- ✅ Modernes schwarz/rotes Design mit Animation

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library

-- Farben
local THEME = {
    Background = Color3.fromRGB(20,20,20),
    Secondary = Color3.fromRGB(35,35,35),
    Accent = Color3.fromRGB(200,30,30),
    Text = Color3.fromRGB(235,235,235)
}

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Haupt-UI erstellen
local function createBaseGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DarkRedLibrary"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    -- Open/Close-Button
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
    main.Size = UDim2.new(0,520,0,340)
    main.Position = UDim2.new(-1,0,0.1,0)
    main.BackgroundColor3 = THEME.Background
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)

    -- Tab-Leiste
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0,140,1,0)
    tabFrame.BackgroundColor3 = THEME.Secondary
    tabFrame.Parent = main
    Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0,8)

    -- Content-Bereich
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-140,1,0)
    content.Position = UDim2.new(0,140,0,0)
    content.BackgroundColor3 = THEME.Background
    content.Parent = main

    local folder = Instance.new("Folder")
    folder.Name = "Pages"
    folder.Parent = content

    return {
        Gui = gui,
        OpenButton = openButton,
        Main = main,
        Tabs = tabFrame,
        Content = content,
        Pages = folder
    }
end

-- Library erstellen
function Library.new(config)
    local self = setmetatable({}, Library)
    self.UI = createBaseGui()
    self.Open = false
    self.Tabs = {}
    self.Elements = {}

    -- Öffnen/Schließen
    self.UI.OpenButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Dragging
    local dragging = false
    local dragStart, startPos
    self.UI.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.UI.Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.UI.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return self
end

-- Öffnen/Schließen
function Library:Toggle()
    if self.Open then
        tween(self.UI.Main, {Position = UDim2.new(-1,0,0.1,0)}, 0.3)
    else
        tween(self.UI.Main, {Position = UDim2.new(0,10,0.1,0)}, 0.3)
    end
    self.Open = not self.Open
end

-- Tab hinzufügen
function Library:AddTab(name)
    local y = (#self.Tabs * 46) + 10
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1,-20,0,40)
    tabBtn.Position = UDim2.new(0,10,0,y)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextColor3 = THEME.Text
    tabBtn.BackgroundColor3 = THEME.Background
    tabBtn.Parent = self.UI.Tabs
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0,6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.CanvasSize = UDim2.new(0,0,0,600)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.BackgroundTransparency = 1
    page.Parent = self.UI.Pages

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    table.insert(self.Tabs, {Button = tabBtn, Page = page})

    -- Klick um Tab zu zeigen
    tabBtn.MouseButton1Click:Connect(function()
        for _,t in ipairs(self.Tabs) do
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

-- UI Elemente hinzufügen
function Library:AddLabel(tab, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,24)
    lbl.Text = text
    lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.BackgroundTransparency = 1
    lbl.Parent = tab
    return lbl
end

function Library:AddButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,34)
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

    return btn
end

function Library:AddTextbox(tab, placeholder, callback)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0,180,0,30)
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
    return tb
end

function Library:AddDropdown(tab, text, options, callback)
    local dd = Instance.new("Frame")
    dd.Size = UDim2.new(0,180,0,34)
    dd.BackgroundColor3 = THEME.Secondary
    dd.Parent = tab
    Instance.new("UICorner", dd).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", dd)
    lbl.Size = UDim2.new(1,-28,1,0)
    lbl.Text = options[1] or text
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
        o.Position = UDim2.new(0,4,0,0)
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

    return dd
end

return Library
