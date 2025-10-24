-- DarkRed Library V6.3.4 (Dropdown pushes content down; dropdown list is a ScrollingFrame inside an auto-sizing container)
-- Adds Update functions for label, textbox, button, toggle, dropdown
-- Mobile-ready, draggable open button, position persisting, padded tab pages
-- Features: Auto-fullwidth elements, auto-scroll only when needed, dropdown expands and pushes content

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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

    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.new(0,40,0,40)
    openButton.Position = UDim2.new(0,10,0,10)
    openButton.Text = "≡"
    openButton.Font = Enum.Font.GothamBold
    openButton.TextSize = 22
    openButton.TextColor3 = THEME.Text
    openButton.BackgroundColor3 = THEME.Secondary
    openButton.Active = true
    openButton.Draggable = true
    openButton.Parent = gui
    Instance.new("UICorner", openButton).CornerRadius = UDim.new(0,8)

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,520,0,360)
    main.Position = UDim2.new(0.25,0,0.25,0)
    main.BackgroundColor3 = THEME.Background
    main.Active = true
    main.ClipsDescendants = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1,0,0,40)
    topbar.BackgroundColor3 = THEME.Secondary
    topbar.Parent = main
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0,10)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1,-20,1,0)
    titleLabel.Position = UDim2.new(0,10,0,0)
    titleLabel.Text = title or "DarkRed UI"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = THEME.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = topbar

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0,140,1,-40)
    tabFrame.Position = UDim2.new(0,0,0,40)
    tabFrame.BackgroundColor3 = THEME.Secondary
    tabFrame.Parent = main
    local tabLayout = Instance.new("UIListLayout", tabFrame)
    tabLayout.Padding = UDim.new(0,6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-140,1,-40)
    content.Position = UDim2.new(0,140,0,40)
    content.BackgroundColor3 = THEME.Background
    content.Parent = main

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

local function genId(prefix)
    return prefix .. "_" .. tostring(math.random(1,1e9))
end

function Library.new(cfg)
    local self = setmetatable({}, Library)
    self.UI = createBaseGui(cfg and cfg.title or "DarkRed UI")
    self.Tabs = {}
    self.Elements = {}
    self.Open = false
    self.LastPosition = self.UI.Main.Position

    local dragging, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        self.UI.Main.Position = newPos
        self.LastPosition = newPos
    end

    self.UI.Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.UI.Main.Position
        end
    end)
    self.UI.Main.InputChanged:Connect(function(input)
        if dragging then updateDrag(input) end
    end)
    self.UI.Main.InputEnded:Connect(function()
        dragging = false
    end)

    self.UI.OpenButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    return self
end

function Library:Toggle()
    local target = self.Open and UDim2.new(-1,0,0.25,0) or self.LastPosition
    tween(self.UI.Main,{Position=target},0.28)
    self.Open = not self.Open
end

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
    page.Position = UDim2.new(0,0,0,0)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    page.BackgroundTransparency = 1
    page.Parent = self.UI.Pages

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local padding = Instance.new("UIPadding", page)
    padding.PaddingLeft = UDim.new(0,12)
    padding.PaddingRight = UDim.new(0,12)
    padding.PaddingTop = UDim.new(0,10)
    padding.PaddingBottom = UDim.new(0,10)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
    end)

    table.insert(self.Tabs,{Button=tabBtn, Page=page})

    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = THEME.Background
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = THEME.Accent
    end)

    if #self.Tabs == 1 then
        page.Visible = true
        tabBtn.BackgroundColor3 = THEME.Accent
    end

    return page
end

function Library:AddLabel(tab,text)
    local id = genId("label")
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-24,0,24)
    lbl.Text = text or ""
    lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.BackgroundTransparency = 1
    lbl.Parent = tab
    self.Elements[id]={type="label", instance=lbl}
    return id,lbl
end

function Library:AddButton(tab,text,callback)
    local id = genId("button")
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-24,0,34)
    btn.Text = text or "Button"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = THEME.Text
    btn.BackgroundColor3 = THEME.Secondary
    btn.Parent = tab
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    self.Elements[id]={type="button", instance=btn, callback=callback}
    return id,btn
end

function Library:AddToggle(tab,text,default,callback)
    local id = genId("toggle")
    local container = Instance.new("Frame")
    container.Size=UDim2.new(1,-24,0,34)
    container.BackgroundTransparency=1
    container.Parent=tab

    local lbl = Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-60,1,0)
    lbl.Text=text or ""
    lbl.Font=Enum.Font.Gotham
    lbl.TextSize=14
    lbl.TextColor3=THEME.Text
    lbl.BackgroundTransparency=1
    lbl.Parent=container

    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(0,50,0,24)
    btn.Position=UDim2.new(1,-50,0.5,-12)
    btn.BackgroundColor3=default and THEME.Accent or THEME.Secondary
    btn.Text=default and "ON" or "OFF"
    btn.TextColor3=THEME.Text
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=12
    btn.Parent=container
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)

    local val=default and true or false
    btn.MouseButton1Click:Connect(function()
        val=not val
        btn.Text=val and "ON" or "OFF"
        tween(btn,{BackgroundColor3=val and THEME.Accent or THEME.Secondary},0.16)
        pcall(callback,val)
    end)

    self.Elements[id]={type="toggle", instance=btn, container=container, label=lbl, value=val, callback=callback}
    return id,btn
end

function Library:AddTextbox(tab,placeholder,callback)
    local id=genId("textbox")
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(1,-24,0,30)
    tb.PlaceholderText=placeholder or ""
    tb.Text = ""
    tb.TextColor3=THEME.Text
    tb.Font=Enum.Font.Gotham
    tb.TextSize=14
    tb.BackgroundColor3=THEME.Secondary
    tb.Parent=tab
    Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
    tb.FocusLost:Connect(function(enter)
        if enter then pcall(callback,tb.Text) end
    end)
    self.Elements[id]={type="textbox", instance=tb, callback=callback}
    return id,tb
end

function Library:AddDropdown(tab,labelText,options,callback,multiSelect)
    local id=genId("dropdown")
    options = options or {}
    multiSelect = multiSelect or false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-24,0,34)
    container.BackgroundTransparency = 1
    container.Parent = tab
    container.AutomaticSize = Enum.AutomaticSize.Y

    local dd = Instance.new("Frame")
    dd.Size = UDim2.new(1,0,0,34)
    dd.BackgroundColor3 = THEME.Secondary
    dd.Parent = container
    Instance.new("UICorner", dd).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", dd)
    lbl.Size = UDim2.new(1,-28,1,0)
    lbl.Position = UDim2.new(0,8,0,0)
    lbl.Text = labelText or (options[1] or "Choose")
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = THEME.Text
    lbl.TextSize = 14
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", dd)
    btn.Size = UDim2.new(0,26,0,26)
    btn.Position = UDim2.new(1,-26,0.5,-13)
    btn.Text = "▾"
    btn.BackgroundTransparency = 1
    btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16

    local list = Instance.new("ScrollingFrame", container)
    list.Position = UDim2.new(0,0,0,34 + 6)
    list.Size = UDim2.new(1,0,0,0)
    list.BackgroundColor3 = THEME.Secondary
    list.Visible = false
    list.ScrollBarThickness = 6
    Instance.new("UICorner", list).CornerRadius = UDim.new(0,6)

    local layout = Instance.new("UIListLayout", list)
    layout.Padding = UDim.new(0,6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    local padding = Instance.new("UIPadding", list)
    padding.PaddingTop = UDim.new(0,6)
    padding.PaddingBottom = UDim.new(0,6)
    padding.PaddingLeft = UDim.new(0,8)
    padding.PaddingRight = UDim.new(0,8)

    local selectedOptions = {}

    local function rebuild(opts)
    -- alte Optionen entfernen
    for _,c in pairs(list:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local totalHeight = 6 -- Padding oben
    for _,opt in ipairs(opts) do
        local o = Instance.new("TextButton", list)
        o.Size = UDim2.new(1,0,0,26)
        o.Text = opt
        o.Font = Enum.Font.Gotham
        o.TextSize = 14
        o.TextColor3 = THEME.Text
        o.BackgroundColor3 = selectedOptions[opt] and THEME.Accent or THEME.Background
        Instance.new("UICorner", o).CornerRadius = UDim.new(0,6)

        o.MouseButton1Click:Connect(function()
            if multiSelect then
                selectedOptions[opt] = not selectedOptions[opt]
            else
                for k,_ in pairs(selectedOptions) do selectedOptions[k]=false end
                selectedOptions[opt]=true
            end

            -- Farben aktualisieren
            for _,btn in pairs(list:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = selectedOptions[btn.Text] and THEME.Accent or THEME.Background
                end
            end

            -- Label aktualisieren
            local display = {}
            for k,v in pairs(selectedOptions) do
                if v then table.insert(display,k) end
            end
            lbl.Text = #display>0 and table.concat(display,", ") or "Choose"

            pcall(callback, selectedOptions)

            if not multiSelect then
                list.Visible = false
            end
        end)

        totalHeight = totalHeight + 26 + 6 -- Button Höhe + Padding
    end

    list.CanvasSize = UDim2.new(0,0,totalHeight)
    list.Size = UDim2.new(1,0,0, math.min(totalHeight, 150)) -- max. 150px Höhe
end

    rebuild(options)

    btn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        if list.Visible then
            list.Size = UDim2.new(1,0,0, math.min(#options*32+12,150))
        end
    end)

    self.Elements[id] = {
        type = "dropdown",
        container = container,
        header = dd,
        label = lbl,
        list = list,
        rebuild = rebuild,
        options = options,
        selectedOptions = selectedOptions,
        callback = callback,
        multiSelect = multiSelect
    }

    return id, dd
end


-- UPDATE FUNCTIONS
function Library:UpdateLabel(id,newText)
    local el=self.Elements[id]
    if not el or el.type~="label" then return false end
    el.instance.Text=newText or el.instance.Text
    return true
end

function Library:UpdateButton(id,newText)
    local el=self.Elements[id]
    if not el or el.type~="button" then return false end
    el.instance.Text=newText or el.instance.Text
    return true
end

function Library:UpdateToggle(id,newValue)
    local el=self.Elements[id]
    if not el or el.type~="toggle" then return false end
    el.value=newValue and true or false
    el.instance.Text=el.value and "ON" or "OFF"
    tween(el.instance,{BackgroundColor3=el.value and THEME.Accent or THEME.Secondary},0.14)
    if el.callback then pcall(el.callback,el.value) end
    return true
end

function Library:UpdateTextbox(id,newText,setPlaceholder)
    local el=self.Elements[id]
    if not el or el.type~="textbox" then return false end
    if setPlaceholder then
        el.instance.PlaceholderText=newText or el.instance.PlaceholderText
    else
        el.instance.Text=newText or el.instance.Text
    end
    return true
end

function Library:UpdateDropdown(id,newOptions,setSelected)
    local el=self.Elements[id]
    if not el or el.type~="dropdown" then return false end
    el.options=newOptions or {}
    el.rebuild(el.options)
    if setSelected then
        el.label.Text=setSelected
    end
    return true
end

function Library:GetDropdownSelected(id)
    local el=self.Elements[id]
    if not el or el.type~="dropdown" then return nil end
    return el.label.Text
end

return Library
