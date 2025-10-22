local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library

-- Theme
local THEME = {
    Background = Color3.fromRGB(18,18,18),
    Accent = Color3.fromRGB(200,10,10),
    Secondary = Color3.fromRGB(30,30,30),
    Text = Color3.fromRGB(230,230,230),
    Transparency = 0.0,
    CornerRadius = UDim.new(0,8)
}

-- Utility Tween
local function tween(instance, props, time, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local info = TweenInfo.new(time or 0.25, style, dir)
    local t = TweenService:Create(instance, info, props)
    t:Play()
    return t
end

-- Create main GUI container
local function createBaseGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkRedUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    -- Open/Close always visible button
    local ocButton = Instance.new("TextButton")
    ocButton.Name = "OpenCloseButton"
    ocButton.Text = "≡"
    ocButton.Font = Enum.Font.GothamBlack
    ocButton.TextSize = 22
    ocButton.Size = UDim2.new(0,44,0,44)
    ocButton.Position = UDim2.new(0,12,0,12)
    ocButton.AnchorPoint = Vector2.new(0,0)
    ocButton.BackgroundColor3 = THEME.Secondary
    ocButton.TextColor3 = THEME.Text
    ocButton.BorderSizePixel = 0
    ocButton.Parent = screenGui
    local ocCorner = Instance.new("UICorner", ocButton)
    ocCorner.CornerRadius = UDim.new(0,8)

    -- Main Frame (initially hidden offscreen)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0,520,0,360)
    mainFrame.Position = UDim2.new(-1,20,0.05,0) -- off screen to the left
    mainFrame.BackgroundColor3 = THEME.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = THEME.CornerRadius

    -- Shadow/Stroke
    local uiStroke = Instance.new("UIStroke", mainFrame)
    uiStroke.Color = THEME.Secondary
    uiStroke.Transparency = 0.9
    uiStroke.Thickness = 1

    -- Left Tabs panel
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0,150,1,0)
    tabsFrame.Position = UDim2.new(0,0,0,0)
    tabsFrame.BackgroundColor3 = THEME.Secondary
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Parent = mainFrame
    local tabsCorner = Instance.new("UICorner", tabsFrame)
    tabsCorner.CornerRadius = THEME.CornerRadius

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, -150, 0, 48)
    titleBar.Position = UDim2.new(0,150,0,0)
    titleBar.BackgroundColor3 = THEME.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -12, 1, 0)
    titleLabel.Position = UDim2.new(0,12,0,0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "DarkRed UI"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = THEME.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Right area (content)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -150, 1, -48)
    contentFrame.Position = UDim2.new(0,150,0,48)
    contentFrame.BackgroundColor3 = THEME.Background
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    local contentCorner = Instance.new("UICorner", contentFrame)
    contentCorner.CornerRadius = THEME.CornerRadius

    -- Container for tab pages
    local pages = Instance.new("Folder")
    pages.Name = "Pages"
    pages.Parent = contentFrame

    -- Internal storage
    local intern = {
        ScreenGui = screenGui,
        OCButton = ocButton,
        MainFrame = mainFrame,
        TabsFrame = tabsFrame,
        TitleBar = titleBar,
        TitleLabel = titleLabel,
        Content = contentFrame,
        Pages = pages,
        TabButtons = {},
        Elements = {} -- maps id -> object & type & parent page
    }

    return intern
end

-- Create instance of library
function Library.new(config)
    config = config or {}
    local self = setmetatable({}, Library)
    self.title = config.title or "DarkRed UI"
    self.theme = THEME
    self.ui = createBaseGui()
    self.ui.TitleLabel.Text = self.title
    self.open = false

    -- Setup open/close behavior
    local oc = self.ui.OCButton
    local main = self.ui.MainFrame
    oc.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Toggle with ESC or RightCtrl
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Delete then
            self:Toggle()
        end
    end)

    -- Draggable TitleBar
    local dragging = false
    local dragStart, startPos
    self.ui.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    self.ui.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    return self
end

-- Internal helper: create a tab
function Library:AddTab(name)
    local ui = self.ui
    local tabsFrame = ui.TabsFrame
    local pages = ui.Pages

    -- Tab Button
    local btn = Instance.new("TextButton")
    btn.Name = "TabButton_" .. name
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.Position = UDim2.new(0,6,0,6 + (#ui.TabButtons * 46))
    btn.BackgroundColor3 = THEME.Background
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Parent = tabsFrame
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0,6)

    -- Page
    local page = Instance.new("Frame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1,0,1,0)
    page.Position = UDim2.new(0,0,0,0)
    page.BackgroundTransparency = 1
    page.Parent = pages
    page.Visible = false

    -- Click behavior to show page
    btn.MouseButton1Click:Connect(function()
        -- hide all pages
        for _,p in pairs(pages:GetChildren()) do
            if p:IsA("Frame") then p.Visible = false end
        end
        page.Visible = true
        -- animate selection
        for _,b in pairs(ui.TabButtons) do
            tween(b, {BackgroundColor3 = THEME.Background}, 0.18)
        end
        tween(btn, {BackgroundColor3 = THEME.Accent}, 0.18)
    end)

    table.insert(ui.TabButtons, btn)

    -- If first tab, auto-select
    if #ui.TabButtons == 1 then
        btn:Activate()
        btn:MouseButton1Click()
    end

    return page
end

-- Create UI element helpers
local function makeLabel(parent, text, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 0, 28)
    lbl.Position = UDim2.new(0,12,0,posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or ""
    lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function makeButton(parent, text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,160,0,34)
    btn.Position = UDim2.new(0,12,0,posY)
    btn.BackgroundColor3 = THEME.Secondary
    btn.Text = text or "Button"
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    return btn
end

local function makeToggle(parent, text, posY, default)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -24, 0, 34)
    container.Position = UDim2.new(0,12,0,posY)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -66, 1, 0)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = THEME.Text
    label.TextXAlignment = Enum.TextXAlignment.Left

    local tbtn = Instance.new("TextButton", container)
    tbtn.Size = UDim2.new(0,48,0,26)
    tbtn.Position = UDim2.new(1,-48,0,4)
    tbtn.BackgroundColor3 = THEME.Secondary
    tbtn.BorderSizePixel = 0
    tbtn.Text = default and "ON" or "OFF"
    tbtn.Font = Enum.Font.GothamBold
    tbtn.TextSize = 12
    tbtn.TextColor3 = THEME.Text
    Instance.new("UICorner", tbtn).CornerRadius = UDim.new(0,6)

    return container, tbtn, label
end

local function makeTextbox(parent, placeholder, posY)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -24, 0, 28)
    tb.Position = UDim2.new(0,12,0,posY)
    tb.BackgroundColor3 = THEME.Secondary
    tb.Text = ""
    tb.PlaceholderText = placeholder or ""
    tb.TextColor3 = THEME.Text
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    tb.BorderSizePixel = 0
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0,6)
    tb.Parent = parent
    return tb
end

local function makeDropdown(parent, labelText, posY, options)
    options = options or {}
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -24, 0, 34)
    container.Position = UDim2.new(0,12,0,posY)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(1, -140, 1, 0)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText or "Dropdown"
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = THEME.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local selected = Instance.new("TextLabel", container)
    selected.Size = UDim2.new(0,110,1,0)
    selected.Position = UDim2.new(1,-110,0,0)
    selected.BackgroundColor3 = THEME.Secondary
    selected.Text = options[1] or "Choose"
    selected.Font = Enum.Font.Gotham
    selected.TextSize = 14
    selected.TextColor3 = THEME.Text
    selected.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", selected).CornerRadius = UDim.new(0,6)

    local arrow = Instance.new("TextButton", container)
    arrow.Size = UDim2.new(0,28,0,26)
    arrow.Position = UDim2.new(1, -136,0,4)
    arrow.Text = "▾"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.BackgroundColor3 = THEME.Secondary
    arrow.TextColor3 = THEME.Text
    arrow.BorderSizePixel = 0
    Instance.new("UICorner", arrow).CornerRadius = UDim.new(0,6)

    -- Dropdown list (hidden)
    local list = Instance.new("Frame")
    list.Name = "Options"
    list.Size = UDim2.new(0, 230, 0, 0)
    list.Position = UDim2.new(1, -230, 1, 6)
    list.BackgroundColor3 = THEME.Secondary
    list.BorderSizePixel = 0
    list.Parent = container
    Instance.new("UICorner", list).CornerRadius = UDim.new(0,6)
    list.Visible = false
    local uiList = Instance.new("UIListLayout", list)
    uiList.Padding = UDim.new(0,4)

    local function rebuildOptions(opts)
        for _,v in pairs(list:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        local height = 6
        for i,opt in ipairs(opts) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,-10,0,28)
            b.Position = UDim2.new(0,5,0, height)
            b.BackgroundColor3 = THEME.Background
            b.BorderSizePixel = 0
            b.Text = opt
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.TextColor3 = THEME.Text
            b.Parent = list
            local c = Instance.new("UICorner", b)
            c.CornerRadius = UDim.new(0,6)
            b.MouseButton1Click:Connect(function()
                selected.Text = opt
                list.Visible = false
                -- event: we'll handle externally by connecting to arrow or storing callbacks
            end)
            height = height + 34
        end
        list.Size = UDim2.new(0,230,0, height)
    end

    rebuildOptions(options)

    arrow.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
    end)

    return {
        Container = container,
        SelectedLabel = selected,
        OptionsFrame = list,
        Rebuild = rebuildOptions,
        GetSelected = function() return selected.Text end,
        SetSelected = function(text) selected.Text = text end
    }
end

function Library:AddButton(tabFrame, text, callback)
    local page = tabFrame
    local children = #page:GetChildren()
    local posY = 8 + children * 44
    local btn = makeButton(page, text, posY)
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    local id = "button_" .. tostring(math.random(1,999999))
    self.ui.Elements[id] = {Type="Button", Instance=btn, Parent=page}
    return id, btn
end

function Library:AddToggle(tabFrame, text, default, callback)
    local page = tabFrame
    local children = #page:GetChildren()
    local posY = 8 + children * 44
    local container, tbtn, label = makeToggle(page, text, posY, default)
    local value = default or false
    tbtn.MouseButton1Click:Connect(function()
        value = not value
        tbtn.Text = value and "ON" or "OFF"
        tween(tbtn, {BackgroundColor3 = value and THEME.Accent or THEME.Secondary}, 0.18)
        pcall(callback, value)
    end)
    tween(tbtn, {BackgroundColor3 = value and THEME.Accent or THEME.Secondary}, 0.01)
    local id = "toggle_" .. tostring(math.random(1,999999))
    self.ui.Elements[id] = {Type="Toggle", Instance=tbtn, Container=container, Label=label, Value=value, Parent=page, Callback=callback}
    return id, tbtn
end

function Library:AddLabel(tabFrame, text)
    local page = tabFrame
    local children = #page:GetChildren()
    local posY = 8 + children * 44
    local lbl = makeLabel(page, text, posY)
    local id = "label_" .. tostring(math.random(1,999999))
    self.ui.Elements[id] = {Type="Label", Instance=lbl, Parent=page}
    return id, lbl
end

function Library:AddTextbox(tabFrame, placeholder, callback)
    local page = tabFrame
    local children = #page:GetChildren()
    local posY = 8 + children * 44
    local tb = makeTextbox(page, placeholder, posY)
    tb.FocusLost:Connect(function(enter)
        if enter then pcall(callback, tb.Text) end
    end)
    local id = "textbox_" .. tostring(math.random(1,999999))
    self.ui.Elements[id] = {Type="Textbox", Instance=tb, Parent=page}
    return id, tb
end

function Library:AddDropdown(tabFrame, labelText, options, callback)
    local page = tabFrame
    local children = #page:GetChildren()
    local posY = 8 + children * 44
    local dd = makeDropdown(page, labelText, posY, options)
    dd.OptionsFrame.ChildAdded:Connect(function(child)
        if child:IsA("TextButton") then
            child.MouseButton1Click:Connect(function()
                pcall(callback, child.Text)
            end)
        end
    end)
    for _,c in pairs(dd.OptionsFrame:GetChildren()) do
        if c:IsA("TextButton") then
            c.MouseButton1Click:Connect(function()
                pcall(callback, c.Text)
            end)
        end
    end
    local id = "dropdown_" .. tostring(math.random(1,999999))
    self.ui.Elements[id] = {Type="Dropdown", Instance=dd.Container, Dropdown=dd, Parent=page}
    return id, dd
end

-- Update functions
function Library:UpdateButton(id, newText)
    local el = self.ui.Elements[id]
    if not el or el.Type ~= "Button" then return false end
    el.Instance.Text = newText or el.Instance.Text
    return true
end

function Library:UpdateLabel(id, newText)
    local el = self.ui.Elements[id]
    if not el or el.Type ~= "Label" then return false end
    el.Instance.Text = newText or el.Instance.Text
    return true
end

function Library:UpdateToggle(id, newValue)
    local el = self.ui.Elements[id]
    if not el or el.Type ~= "Toggle" then return false end
    el.Value = newValue and true or false
    el.Instance.Text = el.Value and "ON" or "OFF"
    tween(el.Instance, {BackgroundColor3 = el.Value and THEME.Accent or THEME.Secondary}, 0.12)
    if el.Callback then pcall(el.Callback, el.Value) end
    return true
end

function Library:UpdateTextbox(id, newText)
    local el = self.ui.Elements[id]
    if not el or el.Type ~= "Textbox" then return false end
    el.Instance.Text = newText or el.Instance.Text
    return true
end

function Library:UpdateDropdown(id, newOptions, setSelected)
    local el = self.ui.Elements[id]
    if not el or el.Type ~= "Dropdown" then return false end
    el.Dropdown.Rebuild(newOptions or {})
    if setSelected then
        el.Dropdown.SetSelected(setSelected)
    end
    return true
end

function Library:GetDropdownSelected(id)
    local el = self.ui.Elements[id]
    if not el or el.Type ~= "Dropdown" then return nil end
    return el.Dropdown.GetSelected()
end

function Library:Toggle()
    local main = self.ui.MainFrame
    if not self.open then
        tween(main, {Position = UDim2.new(0,20,0.05,0)}, 0.28)
        self.open = true
    else
        tween(main, {Position = UDim2.new(-1,20,0.05,0)}, 0.28)
        self.open = false
    end
end

function Library:GetTab(name)
    local pages = self.ui.Pages
    for _,p in pairs(pages:GetChildren()) do
        if p.Name == "Page_" .. name then
            return p
        end
    end
    return nil
end

function Library:CreateExample()
    local tab = self:AddTab("Main")
    local btnId = self:AddButton(tab, "Test Button", function() print("Button clicked!") end)
    local togId = self:AddToggle(tab, "Auto Farm", false, function(v) print("Toggle:", v) end)
    local lblId = self:AddLabel(tab, "Status: Ready")
    local tbId = self:AddTextbox(tab, "Enter value...", function(t) print("TextBox value:", t) end)
    local ddId, dd = self:AddDropdown(tab, "Mode", {"Fast","Normal","Safe"}, function(sel) print("Dropdown:", sel) end)
    return {
        Button = btnId,
        Toggle = togId,
        Label = lblId,
        Textbox = tbId,
        Dropdown = ddId
    }
end

return Library
