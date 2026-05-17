--[[
    ███╗   ██╗███████╗ ██████╗ ███╗   ██╗██╗     ██╗██████╗
    ████╗  ██║██╔════╝██╔═══██╗████╗  ██║██║     ██║██╔══██╗
    ██╔██╗ ██║█████╗  ██║   ██║██╔██╗ ██║██║     ██║██████╔╝
    ██║╚██╗██║██╔══╝  ██║   ██║██║╚██╗██║██║     ██║██╔══██╗
    ██║ ╚████║███████╗╚██████╔╝██║ ╚████║███████╗██║██████╔╝
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝╚═════╝

    NeonLib — Professional Mobile UI Library for Roblox
    Version: 2.0.0
    Author:  NeonLib Contributors
    License: MIT

    Usage:
        local Library = loadstring(...)()
        local Window   = Library:CreateWindow({ Title = "My App", Subtitle = "v1.0" })
        local Tab      = Window:CreateTab({ Name = "Main", Icon = "rbxassetid://..." })
        Tab:CreateButton({ Name = "Click Me", Callback = function() end })
]]

-- ──────────────────────────────────────────────────────────────────────────────
-- Services
-- ──────────────────────────────────────────────────────────────────────────────
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ──────────────────────────────────────────────────────────────────────────────
-- Constants & Theme
-- ──────────────────────────────────────────────────────────────────────────────
local THEME = {
    -- Backgrounds
    BG_Primary     = Color3.fromRGB(8,   10,  14),
    BG_Secondary   = Color3.fromRGB(12,  15,  20),
    BG_Card        = Color3.fromRGB(16,  20,  28),
    BG_Element     = Color3.fromRGB(20,  26,  36),
    BG_Hover       = Color3.fromRGB(26,  33,  46),

    -- Accent Neon Green
    Accent         = Color3.fromRGB(0,   255, 140),
    AccentDim      = Color3.fromRGB(0,   180, 100),
    AccentGlow     = Color3.fromRGB(0,   255, 140),

    -- Deep Blue
    Blue           = Color3.fromRGB(30,  100, 255),
    BlueDim        = Color3.fromRGB(20,  70,  180),

    -- Text
    TextPrimary    = Color3.fromRGB(230, 240, 255),
    TextSecondary  = Color3.fromRGB(130, 150, 180),
    TextMuted      = Color3.fromRGB(70,  90,  120),
    TextAccent     = Color3.fromRGB(0,   255, 140),

    -- States
    Success        = Color3.fromRGB(0,   220, 110),
    Warning        = Color3.fromRGB(255, 180, 0),
    Danger         = Color3.fromRGB(255, 60,  80),
    Info           = Color3.fromRGB(30,  140, 255),

    -- Stroke / Border
    Stroke         = Color3.fromRGB(30,  45,  70),
    StrokeAccent   = Color3.fromRGB(0,   255, 140),

    -- Transparency levels
    TransGlass     = 0.85,
    TransCard      = 0.92,
    TransElement   = 0.88,
}

local TWEEN = {
    Fast    = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Medium  = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow    = TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Bounce  = TweenInfo.new(0.35, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
    Spring  = TweenInfo.new(0.50, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

local SIZES = {
    ButtonHeight   = 48,
    TabHeight      = 44,
    SliderHeight   = 56,
    ToggleHeight   = 48,
    DropdownHeight = 48,
    InputHeight    = 48,
    CornerRadius   = UDim.new(0, 12),
    CornerSmall    = UDim.new(0, 8),
    CornerPill     = UDim.new(1, 0),
    Padding        = 12,
    PaddingLarge   = 16,
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Utility Functions
-- ──────────────────────────────────────────────────────────────────────────────
local Util = {}

function Util.Tween(instance: Instance, info: TweenInfo, properties: {[string]: any}): Tween
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Util.Create(class: string, props: {[string]: any}, children: {Instance}?): Instance
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            (inst :: any)[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Util.AddCorner(parent: Instance, radius: UDim?): UICorner
    return Util.Create("UICorner", {
        CornerRadius = radius or SIZES.CornerRadius,
        Parent       = parent,
    }) :: UICorner
end

function Util.AddStroke(parent: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
    return Util.Create("UIStroke", {
        Color        = color or THEME.Stroke,
        Thickness    = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent       = parent,
    }) :: UIStroke
end

function Util.AddGradient(parent: Instance, colors: ColorSequence?, rotation: number?): UIGradient
    return Util.Create("UIGradient", {
        Color    = colors or ColorSequence.new({
            ColorSequenceKeypoint.new(0, THEME.BG_Secondary),
            ColorSequenceKeypoint.new(1, THEME.BG_Primary),
        }),
        Rotation = rotation or 135,
        Parent   = parent,
    }) :: UIGradient
end

function Util.AddPadding(parent: Instance, horizontal: number?, vertical: number?): UIPadding
    local h = horizontal or SIZES.Padding
    local v = vertical   or SIZES.Padding
    return Util.Create("UIPadding", {
        PaddingLeft   = UDim.new(0, h),
        PaddingRight  = UDim.new(0, h),
        PaddingTop    = UDim.new(0, v),
        PaddingBottom = UDim.new(0, v),
        Parent        = parent,
    }) :: UIPadding
end

function Util.AddListLayout(parent: Instance, spacing: number?, direction: Enum.FillDirection?): UIListLayout
    return Util.Create("UIListLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        FillDirection    = direction or Enum.FillDirection.Vertical,
        Padding          = UDim.new(0, spacing or 8),
        Parent           = parent,
    }) :: UIListLayout
end

function Util.GlowEffect(parent: Instance, color: Color3, size: number?): ImageLabel
    local glow = Util.Create("ImageLabel", {
        Name             = "GlowEffect",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://5028857084",
        ImageColor3      = color,
        ImageTransparency = 0.6,
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(1, size or 30, 1, size or 30),
        ZIndex           = -1,
        Parent           = parent,
    }) :: ImageLabel
    return glow
end

function Util.PulseGlow(glow: ImageLabel)
    local function pulse()
        Util.Tween(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            ImageTransparency = 0.3,
        }):Completed:Connect(function()
            Util.Tween(glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                ImageTransparency = 0.7,
            }):Completed:Connect(pulse)
        end)
    end
    pulse()
end

function Util.RippleEffect(button: Frame | TextButton, x: number, y: number)
    local ripple = Util.Create("Frame", {
        Name                 = "Ripple",
        AnchorPoint          = Vector2.new(0.5, 0.5),
        BackgroundColor3     = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Position             = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y),
        Size                 = UDim2.new(0, 0, 0, 0),
        ClipsDescendants     = false,
        ZIndex               = 10,
        Parent               = button,
    }) :: Frame
    Util.AddCorner(ripple, SIZES.CornerPill)

    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Util.Tween(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
    }):Completed:Connect(function()
        ripple:Destroy()
    end)
end

function Util.GenerateId(): string
    return HttpService:GenerateGUID(false):sub(1, 8)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Notification System
-- ──────────────────────────────────────────────────────────────────────────────
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(gui: ScreenGui)
    local self = setmetatable({}, NotificationSystem)
    self._container = Util.Create("Frame", {
        Name             = "NotificationContainer",
        AnchorPoint      = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position         = UDim2.new(1, -12, 1, -80),
        Size             = UDim2.new(0, 300, 1, -100),
        Parent           = gui,
    }) :: Frame

    Util.Create("UIListLayout", {
        SortOrder     = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding       = UDim.new(0, 8),
        Parent        = self._container,
    })

    self._count = 0
    return self
end

function NotificationSystem:Send(options: {
    Title: string,
    Message: string?,
    Duration: number?,
    Type: string?,
})
    self._count += 1
    local duration = options.Duration or 4
    local notifType = options.Type or "info"

    local accentColor = notifType == "success" and THEME.Success
        or notifType == "warning" and THEME.Warning
        or notifType == "error"   and THEME.Danger
        or THEME.Info

    local frame = Util.Create("Frame", {
        Name             = "Notification_" .. self._count,
        BackgroundColor3 = THEME.BG_Card,
        BackgroundTransparency = 0.1,
        Size             = UDim2.new(1, 0, 0, 72),
        ClipsDescendants = true,
        LayoutOrder      = self._count,
        Parent           = self._container,
    }) :: Frame
    Util.AddCorner(frame)
    Util.AddStroke(frame, accentColor, 1, 0.5)

    -- Left accent bar
    local bar = Util.Create("Frame", {
        BackgroundColor3 = accentColor,
        Size             = UDim2.new(0, 3, 1, 0),
        Parent           = frame,
    }) :: Frame
    Util.AddCorner(bar, UDim.new(0, 3))
    Util.GlowEffect(bar, accentColor, 8)

    -- Content
    local content = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size     = UDim2.new(1, -14, 1, 0),
        Parent   = frame,
    }) :: Frame
    Util.AddPadding(content, 10, 10)

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text       = options.Title,
        TextColor3 = THEME.TextPrimary,
        TextSize   = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size       = UDim2.new(1, 0, 0, 20),
        Parent     = content,
    })

    if options.Message then
        Util.Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text       = options.Message,
            TextColor3 = THEME.TextSecondary,
            TextSize   = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Position   = UDim2.new(0, 0, 0, 24),
            Size       = UDim2.new(1, 0, 0, 30),
            Parent     = content,
        })
    end

    -- Progress bar
    local progressBg = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Element,
        Position = UDim2.new(0, 0, 1, -4),
        Size     = UDim2.new(1, 0, 0, 3),
        Parent   = frame,
    }) :: Frame

    local progressBar = Util.Create("Frame", {
        BackgroundColor3 = accentColor,
        Size             = UDim2.new(1, 0, 1, 0),
        Parent           = progressBg,
    }) :: Frame
    Util.AddCorner(progressBar, UDim.new(1, 0))

    -- Slide in
    frame.Position = UDim2.new(1, 20, 0, 0)
    Util.Tween(frame, TWEEN.Bounce, { Position = UDim2.new(0, 0, 0, 0) })

    -- Progress tween
    Util.Tween(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0),
    })

    task.delay(duration, function()
        Util.Tween(frame, TWEEN.Medium, {
            Position = UDim2.new(1, 20, 0, 0),
            BackgroundTransparency = 1,
        }):Completed:Connect(function()
            frame:Destroy()
        end)
    end)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Element Builders
-- ──────────────────────────────────────────────────────────────────────────────
local Elements = {}

-- Button
function Elements.CreateButton(parent: Frame, options: {
    Name: string,
    Description: string?,
    Callback: () -> ()?,
    LayoutOrder: number?,
}): Frame
    local container = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Element,
        Size             = UDim2.new(1, 0, 0, SIZES.ButtonHeight),
        LayoutOrder      = options.LayoutOrder or 0,
        ClipsDescendants = true,
        Parent           = parent,
    }) :: Frame
    Util.AddCorner(container)
    Util.AddStroke(container, THEME.Stroke, 1, 0.3)

    local glow = Util.GlowEffect(container, THEME.Accent, 0)
    glow.ImageTransparency = 1

    -- Icon left
    local iconFrame = Util.Create("Frame", {
        BackgroundColor3 = THEME.AccentDim,
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0, 10, 0.5, -14),
        Size     = UDim2.new(0, 28, 0, 28),
        Parent   = container,
    }) :: Frame
    Util.AddCorner(iconFrame, SIZES.CornerSmall)

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text       = "▶",
        TextColor3 = THEME.Accent,
        TextSize   = 12,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position   = UDim2.new(0.5, 0, 0.5, 0),
        Size       = UDim2.new(1, 0, 1, 0),
        Parent     = iconFrame,
    })

    -- Labels
    local labelFrame = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 0),
        Size     = UDim2.new(1, -70, 1, 0),
        Parent   = container,
    }) :: Frame

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text       = options.Name,
        TextColor3 = THEME.TextPrimary,
        TextSize   = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        AnchorPoint = Vector2.new(0, 0.5),
        Position   = UDim2.new(0, 0, 0.5, options.Description and -10 or 0),
        Size       = UDim2.new(1, 0, 0, 18),
        Parent     = labelFrame,
    })

    if options.Description then
        Util.Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text       = options.Description,
            TextColor3 = THEME.TextMuted,
            TextSize   = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            AnchorPoint = Vector2.new(0, 0.5),
            Position   = UDim2.new(0, 0, 0.5, 8),
            Size       = UDim2.new(1, 0, 0, 14),
            Parent     = labelFrame,
        })
    end

    -- Arrow
    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text       = "›",
        TextColor3 = THEME.TextMuted,
        TextSize   = 20,
        AnchorPoint = Vector2.new(1, 0.5),
        Position   = UDim2.new(1, -12, 0.5, 0),
        Size       = UDim2.new(0, 20, 1, 0),
        Parent     = container,
    })

    -- Clickable overlay
    local btn = Util.Create("TextButton", {
        BackgroundTransparency = 1,
        Size       = UDim2.new(1, 0, 1, 0),
        Text       = "",
        ZIndex     = 5,
        Parent     = container,
    }) :: TextButton

    btn.MouseButton1Down:Connect(function()
        local pos = UserInputService:GetMouseLocation()
        Util.RippleEffect(container :: any, pos.X, pos.Y)
        Util.Tween(container, TWEEN.Fast, { BackgroundColor3 = THEME.BG_Hover })
        Util.Tween(glow, TWEEN.Fast, { ImageTransparency = 0.6 })
        Util.Tween(iconFrame, TWEEN.Fast, { BackgroundTransparency = 0.5 })
    end)

    btn.MouseButton1Up:Connect(function()
        Util.Tween(container, TWEEN.Medium, { BackgroundColor3 = THEME.BG_Element })
        Util.Tween(glow, TWEEN.Medium, { ImageTransparency = 1 })
        Util.Tween(iconFrame, TWEEN.Medium, { BackgroundTransparency = 0.8 })
        if options.Callback then
            task.spawn(options.Callback)
        end
    end)

    return container
end

-- Toggle
function Elements.CreateToggle(parent: Frame, options: {
    Name: string,
    Description: string?,
    Default: boolean?,
    Callback: (boolean) -> ()?,
    LayoutOrder: number?,
}): (Frame, (state: boolean) -> ())
    local state = options.Default or false

    local container = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Element,
        Size             = UDim2.new(1, 0, 0, SIZES.ToggleHeight),
        LayoutOrder      = options.LayoutOrder or 0,
        Parent           = parent,
    }) :: Frame
    Util.AddCorner(container)
    Util.AddStroke(container, THEME.Stroke, 1, 0.3)

    -- Label
    local labelFrame = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size     = UDim2.new(1, -80, 1, 0),
        Parent   = container,
    }) :: Frame

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text       = options.Name,
        TextColor3 = THEME.TextPrimary,
        TextSize   = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        AnchorPoint = Vector2.new(0, 0.5),
        Position   = UDim2.new(0, 0, 0.5, options.Description and -10 or 0),
        Size       = UDim2.new(1, 0, 0, 18),
        Parent     = labelFrame,
    })

    if options.Description then
        Util.Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text       = options.Description,
            TextColor3 = THEME.TextMuted,
            TextSize   = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            AnchorPoint = Vector2.new(0, 0.5),
            Position   = UDim2.new(0, 0, 0.5, 8),
            Size       = UDim2.new(1, 0, 0, 14),
            Parent     = labelFrame,
        })
    end

    -- Toggle track
    local track = Util.Create("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = THEME.BG_Card,
        Position         = UDim2.new(1, -14, 0.5, 0),
        Size             = UDim2.new(0, 50, 0, 26),
        Parent           = container,
    }) :: Frame
    Util.AddCorner(track, SIZES.CornerPill)
    Util.AddStroke(track, state and THEME.Accent or THEME.Stroke, 1.5, 0)

    local trackGrad = Util.Create("UIGradient", {
        Color = state
            and ColorSequence.new({ ColorSequenceKeypoint.new(0, THEME.AccentDim), ColorSequenceKeypoint.new(1, THEME.Accent) })
            or  ColorSequence.new({ ColorSequenceKeypoint.new(0, THEME.BG_Card), ColorSequenceKeypoint.new(1, THEME.BG_Card) }),
        Rotation = 90,
        Parent   = track,
    }) :: UIGradient

    -- Thumb
    local thumb = Util.Create("Frame", {
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or THEME.TextMuted,
        Position         = state and UDim2.new(0, 26, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
        Size             = UDim2.new(0, 20, 0, 20),
        ZIndex           = 2,
        Parent           = track,
    }) :: Frame
    Util.AddCorner(thumb, SIZES.CornerPill)

    if state then Util.GlowEffect(thumb, THEME.Accent, 10) end

    local trackStroke = track:FindFirstChildWhichIsA("UIStroke") :: UIStroke

    local function setState(newState: boolean, silent: boolean?)
        state = newState

        if state then
            Util.Tween(thumb, TWEEN.Bounce, {
                Position         = UDim2.new(0, 26, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            })
            Util.Tween(trackStroke, TWEEN.Medium, { Color = THEME.Accent })
            trackGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, THEME.AccentDim),
                ColorSequenceKeypoint.new(1, THEME.Accent),
            })
        else
            Util.Tween(thumb, TWEEN.Bounce, {
                Position         = UDim2.new(0, 4, 0.5, 0),
                BackgroundColor3 = THEME.TextMuted,
            })
            Util.Tween(trackStroke, TWEEN.Medium, { Color = THEME.Stroke })
            trackGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, THEME.BG_Card),
                ColorSequenceKeypoint.new(1, THEME.BG_Card),
            })
        end

        if not silent and options.Callback then
            task.spawn(options.Callback, state)
        end
    end

    local btn = Util.Create("TextButton", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        Text   = "",
        ZIndex = 5,
        Parent = container,
    }) :: TextButton

    btn.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return container, setState
end

-- Slider
function Elements.CreateSlider(parent: Frame, options: {
    Name: string,
    Description: string?,
    Min: number,
    Max: number,
    Default: number?,
    Step: number?,
    Suffix: string?,
    Callback: (number) -> ()?,
    LayoutOrder: number?,
}): (Frame, (value: number) -> ())
    local min  = options.Min or 0
    local max  = options.Max or 100
    local step = options.Step or 1
    local currentValue = math.clamp(options.Default or min, min, max)

    local container = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Element,
        Size             = UDim2.new(1, 0, 0, SIZES.SliderHeight),
        LayoutOrder      = options.LayoutOrder or 0,
        Parent           = parent,
    }) :: Frame
    Util.AddCorner(container)
    Util.AddStroke(container, THEME.Stroke, 1, 0.3)
    Util.AddPadding(container, 14, 0)

    -- Header row
    local header = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size     = UDim2.new(1, 0, 0, 18),
        Parent   = container,
    }) :: Frame

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text       = options.Name,
        TextColor3 = THEME.TextPrimary,
        TextSize   = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size       = UDim2.new(0.6, 0, 1, 0),
        Parent     = header,
    })

    local valueLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text       = tostring(currentValue) .. (options.Suffix or ""),
        TextColor3 = THEME.Accent,
        TextSize   = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        AnchorPoint = Vector2.new(1, 0),
        Position   = UDim2.new(1, 0, 0, 0),
        Size       = UDim2.new(0.4, 0, 1, 0),
        Parent     = header,
    }) :: TextLabel

    -- Track
    local track = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Card,
        Position = UDim2.new(0, 0, 0, 36),
        Size     = UDim2.new(1, 0, 0, 6),
        Parent   = container,
    }) :: Frame
    Util.AddCorner(track, SIZES.CornerPill)

    local fill = Util.Create("Frame", {
        BackgroundColor3 = THEME.AccentDim,
        Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0),
        Parent = track,
    }) :: Frame
    Util.AddCorner(fill, SIZES.CornerPill)
    Util.AddGradient(fill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.AccentDim),
        ColorSequenceKeypoint.new(1, THEME.Accent),
    }), 0)

    -- Thumb
    local thumb = Util.Create("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position         = UDim2.new((currentValue - min) / (max - min), 0, 0.5, 0),
        Size             = UDim2.new(0, 18, 0, 18),
        ZIndex           = 3,
        Parent           = track,
    }) :: Frame
    Util.AddCorner(thumb, SIZES.CornerPill)
    Util.AddStroke(thumb, THEME.Accent, 2, 0)
    Util.GlowEffect(thumb, THEME.Accent, 12)

    local function setValue(val: number, silent: boolean?)
        val = math.clamp(math.round(val / step) * step, min, max)
        currentValue = val
        local pct = (val - min) / (max - min)
        Util.Tween(fill, TWEEN.Fast, { Size = UDim2.new(pct, 0, 1, 0) })
        Util.Tween(thumb, TWEEN.Fast, { Position = UDim2.new(pct, 0, 0.5, 0) })
        valueLabel.Text = tostring(val) .. (options.Suffix or "")
        if not silent and options.Callback then
            task.spawn(options.Callback, val)
        end
    end

    local dragging = false

    local inputFrame = Util.Create("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -14, 0, 28),
        Size     = UDim2.new(1, 28, 0, 22),
        Text     = "",
        ZIndex   = 5,
        Parent   = container,
    }) :: TextButton

    inputFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Util.Tween(thumb, TWEEN.Fast, { Size = UDim2.new(0, 22, 0, 22) })
        end
    end)

    inputFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Util.Tween(thumb, TWEEN.Fast, { Size = UDim2.new(0, 18, 0, 18) })
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos  = track.AbsolutePosition
            local absSize = track.AbsoluteSize
            local relX    = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
            setValue(min + relX * (max - min))
        end
    end)

    return container, setValue
end

-- Dropdown
function Elements.CreateDropdown(parent: Frame, options: {
    Name: string,
    Items: {string},
    Default: string?,
    Placeholder: string?,
    Callback: (string) -> ()?,
    LayoutOrder: number?,
}): (Frame, (item: string) -> ())
    local selectedItem = options.Default or options.Placeholder or "Select..."
    local isOpen       = false

    local wrapper = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(1, 0, 0, SIZES.DropdownHeight),
        LayoutOrder = options.LayoutOrder or 0,
        ClipsDescendants = false,
        Parent      = parent,
    }) :: Frame

    local container = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Element,
        Size             = UDim2.new(1, 0, 0, SIZES.DropdownHeight),
        ClipsDescendants = false,
        Parent           = wrapper,
    }) :: Frame
    Util.AddCorner(container)
    Util.AddStroke(container, THEME.Stroke, 1, 0.3)

    -- Selected label
    local labelPad = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, -50, 1, 0),
        Parent = container,
    }) :: Frame
    Util.AddPadding(labelPad, 14, 0)

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text       = options.Name,
        TextColor3 = THEME.TextMuted,
        TextSize   = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position   = UDim2.new(0, 14, 0, 6),
        Size       = UDim2.new(1, -60, 0, 14),
        Parent     = container,
    })

    local selectedLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text       = selectedItem,
        TextColor3 = selectedItem == (options.Placeholder or "Select...") and THEME.TextMuted or THEME.TextPrimary,
        TextSize   = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position   = UDim2.new(0, 14, 0, 22),
        Size       = UDim2.new(1, -60, 0, 18),
        Parent     = container,
    }) :: TextLabel

    -- Arrow icon
    local arrow = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text       = "⌄",
        TextColor3 = THEME.TextSecondary,
        TextSize   = 18,
        AnchorPoint = Vector2.new(1, 0.5),
        Position   = UDim2.new(1, -14, 0.5, 0),
        Size       = UDim2.new(0, 20, 0, 20),
        Parent     = container,
    }) :: TextLabel

    -- Dropdown list
    local listFrame = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Card,
        Position         = UDim2.new(0, 0, 1, 4),
        Size             = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        ZIndex           = 20,
        Parent           = container,
    }) :: Frame
    Util.AddCorner(listFrame)
    Util.AddStroke(listFrame, THEME.Stroke, 1, 0.2)

    local listLayout = Util.AddListLayout(listFrame, 0)

    local listHeight = #options.Items * 40

    local function setSelected(item: string, silent: boolean?)
        selectedItem = item
        selectedLabel.Text      = item
        selectedLabel.TextColor3 = THEME.TextPrimary
        if not silent and options.Callback then
            task.spawn(options.Callback, item)
        end
    end

    for i, item in ipairs(options.Items) do
        local row = Util.Create("TextButton", {
            BackgroundColor3 = THEME.BG_Card,
            BackgroundTransparency = item == selectedItem and 0.7 or 1,
            Size             = UDim2.new(1, 0, 0, 40),
            Text             = "",
            LayoutOrder      = i,
            ZIndex           = 21,
            Parent           = listFrame,
        }) :: TextButton

        local dot = Util.Create("Frame", {
            BackgroundColor3 = THEME.Accent,
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 14, 0.5, 0),
            Size             = UDim2.new(0, 6, 0, 6),
            Visible          = item == selectedItem,
            ZIndex           = 22,
            Parent           = row,
        }) :: Frame
        Util.AddCorner(dot, SIZES.CornerPill)

        Util.Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json",
                item == selectedItem and Enum.FontWeight.SemiBold or Enum.FontWeight.Regular),
            Text       = item,
            TextColor3 = item == selectedItem and THEME.TextAccent or THEME.TextPrimary,
            TextSize   = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position   = UDim2.new(0, 30, 0, 0),
            Size       = UDim2.new(1, -30, 1, 0),
            ZIndex     = 22,
            Parent     = row,
        })

        if i < #options.Items then
            Util.Create("Frame", {
                BackgroundColor3 = THEME.Stroke,
                BackgroundTransparency = 0.5,
                Position = UDim2.new(0, 14, 1, 0),
                Size     = UDim2.new(1, -28, 0, 1),
                ZIndex   = 21,
                Parent   = row,
            })
        end

        row.MouseButton1Click:Connect(function()
            setSelected(item)
            -- close
            isOpen = false
            Util.Tween(arrow, TWEEN.Fast, { Rotation = 0 })
            Util.Tween(listFrame, TWEEN.Medium, { Size = UDim2.new(1, 0, 0, 0) })
            task.delay(0.25, function() wrapper.Size = UDim2.new(1, 0, 0, SIZES.DropdownHeight) end)
        end)
    end

    -- Open button
    local openBtn = Util.Create("TextButton", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0, SIZES.DropdownHeight),
        Text   = "",
        ZIndex = 10,
        Parent = container,
    }) :: TextButton

    openBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            wrapper.Size = UDim2.new(1, 0, 0, SIZES.DropdownHeight + listHeight + 4)
            Util.Tween(arrow, TWEEN.Fast, { Rotation = 180 })
            Util.Tween(listFrame, TWEEN.Medium, { Size = UDim2.new(1, 0, 0, listHeight) })
        else
            Util.Tween(arrow, TWEEN.Fast, { Rotation = 0 })
            Util.Tween(listFrame, TWEEN.Medium, { Size = UDim2.new(1, 0, 0, 0) })
            task.delay(0.25, function() wrapper.Size = UDim2.new(1, 0, 0, SIZES.DropdownHeight) end)
        end
    end)

    return wrapper, setSelected
end

-- TextInput
function Elements.CreateInput(parent: Frame, options: {
    Name: string,
    Placeholder: string?,
    Default: string?,
    ClearOnFocus: boolean?,
    Callback: (string) -> ()?,
    LayoutOrder: number?,
}): (Frame, (value: string) -> ())
    local container = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Element,
        Size             = UDim2.new(1, 0, 0, SIZES.InputHeight),
        LayoutOrder      = options.LayoutOrder or 0,
        Parent           = parent,
    }) :: Frame
    Util.AddCorner(container)

    local stroke = Util.AddStroke(container, THEME.Stroke, 1, 0.3)

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        Text       = options.Name,
        TextColor3 = THEME.TextMuted,
        TextSize   = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position   = UDim2.new(0, 14, 0, 6),
        Size       = UDim2.new(1, -28, 0, 14),
        Parent     = container,
    })

    local input = Util.Create("TextBox", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
        PlaceholderText  = options.Placeholder or "",
        PlaceholderColor3 = THEME.TextMuted,
        Text       = options.Default or "",
        TextColor3 = THEME.TextPrimary,
        TextSize   = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = options.ClearOnFocus or false,
        Position   = UDim2.new(0, 14, 0, 22),
        Size       = UDim2.new(1, -28, 0, 20),
        Parent     = container,
    }) :: TextBox

    input.Focused:Connect(function()
        Util.Tween(stroke, TWEEN.Fast, { Color = THEME.Accent, Transparency = 0 })
    end)

    input.FocusLost:Connect(function(enterPressed)
        Util.Tween(stroke, TWEEN.Fast, { Color = THEME.Stroke, Transparency = 0.3 })
        if options.Callback then
            task.spawn(options.Callback, input.Text)
        end
    end)

    local function setValue(val: string)
        input.Text = val
    end

    return container, setValue
end

-- Separator / Label
function Elements.CreateLabel(parent: Frame, options: {
    Text: string,
    LayoutOrder: number?,
}): Frame
    local container = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(1, 0, 0, 28),
        LayoutOrder = options.LayoutOrder or 0,
        Parent      = parent,
    }) :: Frame

    local line = Util.Create("Frame", {
        BackgroundColor3 = THEME.Stroke,
        AnchorPoint      = Vector2.new(0, 0.5),
        Position         = UDim2.new(0, 0, 0.5, 0),
        Size             = UDim2.new(1, 0, 0, 1),
        Parent           = container,
    }) :: Frame

    local label = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Secondary,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 0, 0, 20),
        AutomaticSize    = Enum.AutomaticSize.X,
        Parent           = container,
    }) :: Frame
    Util.AddCorner(label, UDim.new(0, 4))
    Util.AddPadding(label, 8, 0)

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        Text       = options.Text:upper(),
        TextColor3 = THEME.TextMuted,
        TextSize   = 10,
        AutomaticSize = Enum.AutomaticSize.X,
        Size       = UDim2.new(0, 0, 1, 0),
        Parent     = label,
    })

    return container
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Section
-- ──────────────────────────────────────────────────────────────────────────────
local Section = {}
Section.__index = Section

function Section.new(parent: Frame, options: {
    Name: string?,
    LayoutOrder: number?,
}): table
    local self      = setmetatable({}, Section)
    self._order     = 0

    local wrapper   = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Card,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        LayoutOrder      = options.LayoutOrder or 0,
        Parent           = parent,
    }) :: Frame
    Util.AddCorner(wrapper)
    Util.AddStroke(wrapper, THEME.Stroke, 1, 0.5)

    if options.Name and options.Name ~= "" then
        local header = Util.Create("Frame", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, 0, 0, 34),
            LayoutOrder = 0,
            Parent      = wrapper,
        }) :: Frame
        Util.AddPadding(header, 14, 0)

        Util.Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
            Text       = options.Name:upper(),
            TextColor3 = THEME.Accent,
            TextSize   = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size       = UDim2.new(1, 0, 1, 0),
            Parent     = header,
        })

        local sep = Util.Create("Frame", {
            BackgroundColor3 = THEME.Stroke,
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 1,
            Parent = wrapper,
        }) :: Frame
    end

    local innerPad = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        Parent      = wrapper,
    }) :: Frame
    Util.AddPadding(innerPad, 10, 10)
    Util.AddListLayout(innerPad, 8)
    Util.AddListLayout(wrapper, 0)

    self._container = innerPad
    return self
end

function Section:CreateButton(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateButton(self._container, options) end
function Section:CreateToggle(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateToggle(self._container, options) end
function Section:CreateSlider(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateSlider(self._container, options) end
function Section:CreateDropdown(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateDropdown(self._container, options) end
function Section:CreateInput(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateInput(self._container, options) end
function Section:CreateLabel(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateLabel(self._container, options) end

-- ──────────────────────────────────────────────────────────────────────────────
-- Tab
-- ──────────────────────────────────────────────────────────────────────────────
local Tab = {}
Tab.__index = Tab

function Tab.new(contentArea: Frame, tabBar: Frame, options: {
    Name: string,
    Icon: string?,
    LayoutOrder: number?,
}): table
    local self      = setmetatable({}, Tab)
    self._order     = 0
    self._isActive  = false

    -- Tab button in tab bar
    local tabBtn = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Element,
        BackgroundTransparency = 0.5,
        Size             = UDim2.new(0, 0, 1, -8),
        AutomaticSize    = Enum.AutomaticSize.X,
        AnchorPoint      = Vector2.new(0, 0.5),
        Position         = UDim2.new(0, 0, 0.5, 0),
        LayoutOrder      = options.LayoutOrder or 0,
        Parent           = tabBar,
    }) :: Frame
    Util.AddCorner(tabBtn)
    Util.AddPadding(tabBtn, 14, 0)

    local tabLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
        Text       = options.Name,
        TextColor3 = THEME.TextMuted,
        TextSize   = 13,
        Size       = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Parent     = tabBtn,
    }) :: TextLabel

    -- Indicator underline
    local indicator = Util.Create("Frame", {
        AnchorPoint      = Vector2.new(0.5, 1),
        BackgroundColor3 = THEME.Accent,
        Position         = UDim2.new(0.5, 0, 1, 4),
        Size             = UDim2.new(0, 0, 0, 2),
        Parent           = tabBtn,
    }) :: Frame
    Util.AddCorner(indicator, SIZES.CornerPill)

    -- Content page
    local page = Util.Create("ScrollingFrame", {
        BackgroundTransparency   = 1,
        ScrollBarThickness       = 0,
        CanvasSize               = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize      = Enum.AutomaticSize.Y,
        ScrollingDirection       = Enum.ScrollingDirection.Y,
        Size                     = UDim2.new(1, 0, 1, 0),
        Visible                  = false,
        Parent                   = contentArea,
    }) :: ScrollingFrame
    Util.AddPadding(page, 12, 10)
    Util.AddListLayout(page, 10)

    self._tabBtn   = tabBtn
    self._tabLabel = tabLabel
    self._indicator = indicator
    self._page     = page

    -- Click
    local clickBtn = Util.Create("TextButton", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        Text   = "",
        ZIndex = 5,
        Parent = tabBtn,
    }) :: TextButton

    self._clickBtn = clickBtn

    function self:Activate()
        self._isActive = true
        self._page.Visible = true
        Util.Tween(self._tabBtn, TWEEN.Fast, { BackgroundTransparency = 0.1, BackgroundColor3 = THEME.BG_Hover })
        Util.Tween(self._tabLabel, TWEEN.Fast, { TextColor3 = THEME.TextAccent })
        Util.Tween(self._indicator, TWEEN.Bounce, { Size = UDim2.new(0.8, 0, 0, 2) })
    end

    function self:Deactivate()
        self._isActive = false
        self._page.Visible = false
        Util.Tween(self._tabBtn, TWEEN.Fast, { BackgroundTransparency = 0.5, BackgroundColor3 = THEME.BG_Element })
        Util.Tween(self._tabLabel, TWEEN.Fast, { TextColor3 = THEME.TextMuted })
        Util.Tween(self._indicator, TWEEN.Fast, { Size = UDim2.new(0, 0, 0, 2) })
    end

    return self
end

function Tab:CreateSection(options)
    self._order += 1
    options = options or {}
    options.LayoutOrder = self._order
    return Section.new(self._page, options)
end

function Tab:CreateButton(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateButton(self._page, options) end
function Tab:CreateToggle(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateToggle(self._page, options) end
function Tab:CreateSlider(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateSlider(self._page, options) end
function Tab:CreateDropdown(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateDropdown(self._page, options) end
function Tab:CreateInput(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateInput(self._page, options) end
function Tab:CreateLabel(options) self._order += 1; options.LayoutOrder = self._order; return Elements.CreateLabel(self._page, options) end

-- ──────────────────────────────────────────────────────────────────────────────
-- Window
-- ──────────────────────────────────────────────────────────────────────────────
local Window = {}
Window.__index = Window

function Window.new(gui: ScreenGui, notifications: table, options: {
    Title: string,
    Subtitle: string?,
    Size: UDim2?,
    Position: UDim2?,
    MinimizeKey: Enum.KeyCode?,
}): table
    local self      = setmetatable({}, Window)
    self._tabs      = {}
    self._activeTab = nil
    self._visible   = true
    self._notifications = notifications
    self._tabOrder  = 0

    -- Main frame
    local window = Util.Create("Frame", {
        Name             = "NeonLib_Window",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = THEME.BG_Primary,
        Position         = options.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size             = options.Size or UDim2.new(0, 360, 0, 580),
        ClipsDescendants = false,
        Parent           = gui,
    }) :: Frame
    Util.AddCorner(window, UDim.new(0, 18))
    Util.AddStroke(window, THEME.Stroke, 1, 0)

    -- Background gradient
    Util.AddGradient(window, ColorSequence.new({
        ColorSequenceKeypoint.new(0,   THEME.BG_Secondary),
        ColorSequenceKeypoint.new(0.5, THEME.BG_Primary),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(6, 8, 12)),
    }), 145)

    -- Ambient top glow
    local topGlow = Util.Create("ImageLabel", {
        BackgroundTransparency = 1,
        Image            = "rbxassetid://5028857084",
        ImageColor3      = THEME.Accent,
        ImageTransparency = 0.85,
        AnchorPoint      = Vector2.new(0.5, 0),
        Position         = UDim2.new(0.5, 0, -0.05, 0),
        Size             = UDim2.new(1.2, 0, 0.4, 0),
        ZIndex           = -1,
        Parent           = window,
    }) :: ImageLabel
    Util.PulseGlow(topGlow)

    -- Title bar
    local titleBar = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 60),
        Parent           = window,
    }) :: Frame
    Util.AddPadding(titleBar, 16, 0)

    -- Accent dot cluster
    local dots = Util.Create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint  = Vector2.new(0, 0.5),
        Position     = UDim2.new(0, 16, 0.5, 0),
        Size         = UDim2.new(0, 42, 0, 12),
        Parent       = titleBar,
    }) :: Frame
    Util.AddListLayout(dots, 6, Enum.FillDirection.Horizontal)

    local dotColors = { THEME.Accent, THEME.Blue, THEME.Warning }
    for _, col in ipairs(dotColors) do
        local d = Util.Create("Frame", {
            BackgroundColor3 = col,
            Size = UDim2.new(0, 8, 0, 8),
            Parent = dots,
        }) :: Frame
        Util.AddCorner(d, SIZES.CornerPill)
        Util.GlowEffect(d, col, 6)
    end

    -- Title
    local titleFrame = Util.Create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint  = Vector2.new(0.5, 0.5),
        Position     = UDim2.new(0.5, 0, 0.5, 0),
        Size         = UDim2.new(0.6, 0, 1, 0),
        Parent       = titleBar,
    }) :: Frame

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
        Text       = options.Title,
        TextColor3 = THEME.TextPrimary,
        TextSize   = 16,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position   = UDim2.new(0.5, 0, 0.5, options.Subtitle and -8 or 0),
        Size       = UDim2.new(1, 0, 0, 20),
        Parent     = titleFrame,
    })

    if options.Subtitle then
        Util.Create("TextLabel", {
            BackgroundTransparency = 1,
            FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text       = options.Subtitle,
            TextColor3 = THEME.TextMuted,
            TextSize   = 11,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position   = UDim2.new(0.5, 0, 0.5, 8),
            Size       = UDim2.new(1, 0, 0, 14),
            Parent     = titleFrame,
        })
    end

    -- Close / minimize button
    local closeBtn = Util.Create("TextButton", {
        BackgroundColor3 = Color3.fromRGB(40, 18, 22),
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -16, 0.5, 0),
        Size             = UDim2.new(0, 32, 0, 32),
        Text             = "✕",
        FontFace         = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
        TextColor3       = THEME.Danger,
        TextSize         = 12,
        Parent           = titleBar,
    }) :: TextButton
    Util.AddCorner(closeBtn)

    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    -- Divider
    local divider = Util.Create("Frame", {
        BackgroundColor3 = THEME.Stroke,
        Position = UDim2.new(0, 0, 0, 60),
        Size     = UDim2.new(1, 0, 0, 1),
        Parent   = window,
    }) :: Frame

    -- Tab bar
    local tabBarWrapper = Util.Create("Frame", {
        BackgroundColor3 = THEME.BG_Secondary,
        Position = UDim2.new(0, 0, 0, 61),
        Size     = UDim2.new(1, 0, 0, SIZES.TabHeight),
        Parent   = window,
    }) :: Frame

    local tabBar = Util.Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        ScrollBarThickness     = 0,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.X,
        ScrollingDirection     = Enum.ScrollingDirection.X,
        Size                   = UDim2.new(1, 0, 1, 0),
        Parent                 = tabBarWrapper,
    }) :: ScrollingFrame
    Util.AddPadding(tabBar, 8, 4)
    Util.AddListLayout(tabBar, 4, Enum.FillDirection.Horizontal)

    local tabDivider = Util.Create("Frame", {
        BackgroundColor3 = THEME.Stroke,
        Position = UDim2.new(0, 0, 0, 61 + SIZES.TabHeight),
        Size     = UDim2.new(1, 0, 0, 1),
        Parent   = window,
    }) :: Frame

    -- Content area
    local contentArea = Util.Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 61 + SIZES.TabHeight + 1),
        Size     = UDim2.new(1, 0, 1, -(61 + SIZES.TabHeight + 1)),
        ClipsDescendants = true,
        Parent   = window,
    }) :: Frame

    self._window      = window
    self._tabBar      = tabBar
    self._contentArea = contentArea

    -- Drag support (mobile & desktop)
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = window.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Keybind
    if options.MinimizeKey then
        UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == options.MinimizeKey then
                self:Toggle()
            end
        end)
    end

    -- Entrance animation
    window.Size     = UDim2.new(0, 0, 0, 0)
    window.BackgroundTransparency = 1
    task.delay(0.05, function()
        local targetSize = options.Size or UDim2.new(0, 360, 0, 580)
        Util.Tween(window, TWEEN.Spring, { Size = targetSize, BackgroundTransparency = 0 })
    end)

    return self
end

function Window:CreateTab(options: { Name: string, Icon: string? }): table
    self._tabOrder += 1
    options.LayoutOrder = self._tabOrder

    local tab = Tab.new(self._contentArea, self._tabBar, options)

    tab._clickBtn.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)

    table.insert(self._tabs, tab)

    if #self._tabs == 1 then
        self:SwitchTab(tab)
    end

    return tab
end

function Window:SwitchTab(targetTab: table)
    for _, tab in ipairs(self._tabs) do
        tab:Deactivate()
    end
    targetTab:Activate()
    self._activeTab = targetTab
end

function Window:Toggle()
    self._visible = not self._visible
    if self._visible then
        self._window.Visible = true
        Util.Tween(self._window, TWEEN.Bounce, {
            Size = UDim2.new(0, 360, 0, 580),
            BackgroundTransparency = 0,
        })
    else
        Util.Tween(self._window, TWEEN.Medium, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        }):Completed:Connect(function()
            if not self._visible then
                self._window.Visible = false
            end
        end)
    end
end

function Window:Notify(options)
    self._notifications:Send(options)
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Library Entry Point
-- ──────────────────────────────────────────────────────────────────────────────
local Library = {}
Library.__index = Library

function Library.new(): table
    local self = setmetatable({}, Library)

    -- Root ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name              = "NeonLib"
    gui.ResetOnSpawn      = false
    gui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder      = 999
    gui.IgnoreGuiInset    = true

    local success = pcall(function()
        gui.Parent = CoreGui
    end)
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self._gui           = gui
    self._notifications = NotificationSystem.new(gui)
    self._windows       = {}

    -- Floating toggle button (mobile-friendly)
    local toggleBtn = Util.Create("ImageButton", {
        Name             = "NeonLib_Toggle",
        AnchorPoint      = Vector2.new(0, 1),
        BackgroundColor3 = THEME.BG_Card,
        Position         = UDim2.new(0, 14, 1, -90),
        Size             = UDim2.new(0, 44, 0, 44),
        Image            = "",
        Parent           = gui,
    }) :: ImageButton
    Util.AddCorner(toggleBtn)
    Util.AddStroke(toggleBtn, THEME.Accent, 1.5, 0)
    Util.GlowEffect(toggleBtn :: any, THEME.Accent, 16)
    Util.PulseGlow((toggleBtn:FindFirstChild("GlowEffect") :: any))

    Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        FontFace   = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Black),
        Text       = "N",
        TextColor3 = THEME.Accent,
        TextSize   = 22,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position   = UDim2.new(0.5, 0, 0.5, 0),
        Size       = UDim2.new(1, 0, 1, 0),
        Parent     = toggleBtn,
    })

    toggleBtn.MouseButton1Click:Connect(function()
        for _, win in ipairs(self._windows) do
            win:Toggle()
        end
    end)

    self._toggleBtn = toggleBtn
    return self
end

function Library:CreateWindow(options: {
    Title: string,
    Subtitle: string?,
    Size: UDim2?,
    Position: UDim2?,
    MinimizeKey: Enum.KeyCode?,
}): table
    local win = Window.new(self._gui, self._notifications, options)
    table.insert(self._windows, win)
    return win
end

function Library:Notify(options)
    self._notifications:Send(options)
end

function Library:Destroy()
    self._gui:Destroy()
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Return
-- ──────────────────────────────────────────────────────────────────────────────
return Library.new()

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 USAGE EXAMPLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = Library:CreateWindow({
    Title       = "NeonLib",
    Subtitle    = "v2.0 — Mobile Edition",
    MinimizeKey = Enum.KeyCode.RightShift,
})

-- Tab 1 — Main
local MainTab = Window:CreateTab({ Name = "Main" })

local Section1 = MainTab:CreateSection({ Name = "Actions" })

Section1:CreateButton({
    Name        = "Say Hello",
    Description = "Prints a greeting",
    Callback    = function()
        print("Hello from NeonLib!")
        Library:Notify({ Title = "Hello!", Message = "Button was pressed.", Type = "success" })
    end,
})

local _, setToggle = Section1:CreateToggle({
    Name     = "God Mode",
    Default  = false,
    Callback = function(state)
        print("God Mode:", state)
    end,
})

local _, setSpeed = Section1:CreateSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 250,
    Default  = 16,
    Step     = 1,
    Suffix   = " sps",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})

-- Tab 2 — Settings
local SettingsTab = Window:CreateTab({ Name = "Settings" })

local Section2 = SettingsTab:CreateSection({ Name = "Appearance" })

Section2:CreateDropdown({
    Name    = "Theme",
    Items   = { "Neon Green", "Ocean Blue", "Crimson Red" },
    Default = "Neon Green",
    Callback = function(item)
        print("Selected theme:", item)
    end,
})

Section2:CreateInput({
    Name        = "Custom Title",
    Placeholder = "Enter window title...",
    Callback    = function(text)
        print("Title set to:", text)
    end,
})
]]
