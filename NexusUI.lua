--[[
	╔═══════════════════════════════════════════════════╗
	║           NexusUI  —  Mobile UI Library           ║
	║        Dark · Green · Blue · Modern               ║
	║                  v1.0.0                           ║
	╚═══════════════════════════════════════════════════╝

	USAGE EXAMPLE:
	
	local NexusUI = require(game.ReplicatedStorage.NexusUI)
	
	local window = NexusUI:CreateWindow({
		Title = "My App",
		Subtitle = "Dashboard",
	})
	
	local section = window:AddSection("Settings")
	
	section:AddToggle("Dark Mode", false, function(value)
		print("Toggle:", value)
	end)
	
	section:AddSlider("Volume", 0, 100, 75, function(value)
		print("Slider:", value)
	end)
	
	section:AddButton("Save", function()
		print("Saved!")
	end)
	
	section:AddDropdown("Quality", {"Low", "Medium", "High"}, "Medium", function(choice)
		print("Dropdown:", choice)
	end)
	
	section:AddTextbox("Username", "Enter name...", function(text)
		print("Input:", text)
	end)

	section:AddColorPicker("Accent Color", Color3.fromRGB(0, 200, 120), function(color)
		print("Color:", color)
	end)

	window:AddNotification("Welcome to NexusUI!", 3)
]]

-- ╔══════════════════════════╗
-- ║        SERVICES          ║
-- ╚══════════════════════════╝

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- ╔══════════════════════════╗
-- ║         THEME            ║
-- ╚══════════════════════════╝

local Theme = {
	-- Backgrounds
	BG_Primary   = Color3.fromRGB(8,  10,  12),   -- near-black base
	BG_Secondary = Color3.fromRGB(12, 16,  20),   -- panel
	BG_Tertiary  = Color3.fromRGB(16, 22,  28),   -- card
	BG_Elevated  = Color3.fromRGB(20, 28,  36),   -- elevated card / hover

	-- Accent
	Accent_Green      = Color3.fromRGB(0,   220, 120),
	Accent_GreenDim   = Color3.fromRGB(0,   160, 88),
	Accent_Blue       = Color3.fromRGB(30,  140, 255),
	Accent_BlueDim    = Color3.fromRGB(20,  100, 200),
	Accent_Glow       = Color3.fromRGB(0,   255, 140),

	-- Text
	Text_Primary   = Color3.fromRGB(230, 240, 248),
	Text_Secondary = Color3.fromRGB(130, 155, 175),
	Text_Muted     = Color3.fromRGB(60,  80,  100),
	Text_Accent    = Color3.fromRGB(0,   220, 120),

	-- Borders
	Border_Subtle  = Color3.fromRGB(20,  35,  50),
	Border_Default = Color3.fromRGB(30,  60,  90),
	Border_Accent  = Color3.fromRGB(0,   180, 100),

	-- Semantic
	Success  = Color3.fromRGB(0,   220, 120),
	Warning  = Color3.fromRGB(255, 185, 30),
	Danger   = Color3.fromRGB(255, 70,  80),
	Info     = Color3.fromRGB(30,  140, 255),

	-- Fonts
	Font_Title  = Enum.Font.GothamBold,
	Font_Body   = Enum.Font.Gotham,
	Font_Mono   = Enum.Font.RobotoMono,

	-- Sizing (mobile-first)
	CornerRadius  = 10,
	SmallRadius   = 6,
	LargeRadius   = 16,
	Padding       = 14,
	ItemHeight    = 48,
	HeaderHeight  = 56,
	WindowWidth   = 340,

	-- Animation
	TweenInfo_Fast   = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	TweenInfo_Medium = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	TweenInfo_Spring = TweenInfo.new(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

-- ╔══════════════════════════╗
-- ║       UTILITIES          ║
-- ╚══════════════════════════╝

local function Tween(obj, props, info)
	local t = TweenService:Create(obj, info or Theme.TweenInfo_Fast, props)
	t:Play()
	return t
end

local function MakeCorner(radius, parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or Theme.CornerRadius)
	c.Parent = parent
	return c
end

local function MakePadding(x, y, parent)
	local p = Instance.new("UIPadding")
	p.PaddingLeft   = UDim.new(0, x or Theme.Padding)
	p.PaddingRight  = UDim.new(0, x or Theme.Padding)
	p.PaddingTop    = UDim.new(0, y or Theme.Padding)
	p.PaddingBottom = UDim.new(0, y or Theme.Padding)
	p.Parent = parent
	return p
end

local function MakeStroke(color, thickness, transparency, parent)
	local s = Instance.new("UIStroke")
	s.Color        = color or Theme.Border_Default
	s.Thickness    = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function MakeLabel(text, size, color, font, parent)
	local l = Instance.new("TextLabel")
	l.Text          = text or ""
	l.TextSize      = size or 14
	l.TextColor3    = color or Theme.Text_Primary
	l.Font          = font or Theme.Font_Body
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate   = Enum.TextTruncate.AtEnd
	l.Size           = UDim2.new(1, 0, 0, size and size + 6 or 20)
	l.Parent         = parent
	return l
end

local function MakeFrame(size, pos, color, parent)
	local f = Instance.new("Frame")
	f.Size = size or UDim2.new(1, 0, 0, 40)
	f.Position = pos or UDim2.new(0, 0, 0, 0)
	f.BackgroundColor3 = color or Theme.BG_Secondary
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

local function MakeGradient(color1, color2, rotation, parent)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2),
	})
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end

local function MakeListLayout(padding, fillDir, parent)
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, padding or 6)
	l.FillDirection = fillDir or Enum.FillDirection.Vertical
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local function AutoSize(frame, layout, extraHeight)
	local function update()
		frame.Size = UDim2.new(
			frame.Size.X.Scale, frame.Size.X.Offset,
			0, layout.AbsoluteContentSize.Y + (extraHeight or 0)
		)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end

-- ╔══════════════════════════╗
-- ║       COMPONENTS         ║
-- ╚══════════════════════════╝

-- ── Ripple Effect ──────────────────────────────────────────────────
local function AddRipple(button, color)
	button.ClipsDescendants = true
	button.MouseButton1Down:Connect(function(x, y)
		local ripple = Instance.new("Frame")
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		ripple.BackgroundColor3 = color or Theme.Accent_Green
		ripple.BackgroundTransparency = 0.75
		ripple.BorderSizePixel = 0
		MakeCorner(999, ripple)
		ripple.Parent = button
		local size = button.AbsoluteSize.X * 2.5
		Tween(ripple, {
			Size = UDim2.new(0, size, 0, size),
			BackgroundTransparency = 1,
		}, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		task.delay(0.55, function() ripple:Destroy() end)
	end)
end

-- ── Separator ──────────────────────────────────────────────────────
local function MakeSeparator(parent)
	local sep = MakeFrame(UDim2.new(1, -28, 0, 1), nil, Theme.Border_Subtle, parent)
	sep.Position = UDim2.new(0, 14, 0, 0)
	sep.BackgroundTransparency = 0.4
	return sep
end

-- ╔══════════════════════════╗
-- ║        LIBRARY           ║
-- ╚══════════════════════════╝

local NexusUI = {}
NexusUI.__index = NexusUI

-- ── Screen setup ───────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Notification layer (always on top)
local NotifLayer = Instance.new("Frame")
NotifLayer.Name = "Notifications"
NotifLayer.Size = UDim2.new(1, 0, 1, 0)
NotifLayer.BackgroundTransparency = 1
NotifLayer.ZIndex = 999
NotifLayer.Parent = ScreenGui

local NotifList = MakeListLayout(8, nil, NotifLayer)
NotifList.HorizontalAlignment = Enum.HorizontalAlignment.Center
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
local notifPad = Instance.new("UIPadding")
notifPad.PaddingBottom = UDim.new(0, 28)
notifPad.Parent = NotifLayer

-- ══════════════════════════════════════════════════════════════════
--  CreateWindow
-- ══════════════════════════════════════════════════════════════════
function NexusUI:CreateWindow(config)
	config = config or {}
	local Window = {}

	-- ── Root Frame ─────────────────────────────────────────
	local Root = MakeFrame(
		UDim2.new(0, Theme.WindowWidth, 0, 0),
		UDim2.new(0.5, -Theme.WindowWidth/2, 0.5, -300),
		Theme.BG_Primary,
		ScreenGui
	)
	Root.Name = "NexusWindow"
	Root.AnchorPoint = Vector2.new(0, 0)
	MakeCorner(Theme.LargeRadius, Root)
	MakeStroke(Theme.Border_Default, 1, 0, Root)

	-- subtle inner shadow overlay
	local innerGlow = MakeFrame(UDim2.new(1, 0, 0, 2), nil, Theme.Accent_Green, Root)
	innerGlow.BackgroundTransparency = 0.85
	MakeCorner(Theme.LargeRadius, innerGlow)

	-- drag support
	local dragging, dragStart, startPos = false, nil, nil
	local TitleBar -- defined below

	-- ── Header ─────────────────────────────────────────────
	local Header = MakeFrame(
		UDim2.new(1, 0, 0, Theme.HeaderHeight + 12),
		nil,
		Theme.BG_Secondary,
		Root
	)
	Header.ZIndex = 2
	MakeCorner(Theme.LargeRadius, Header)

	-- header accent gradient strip
	local accentStrip = MakeFrame(UDim2.new(1, 0, 0, 2), UDim2.new(0,0,1,-2), Color3.new(1,1,1), Header)
	MakeGradient(Theme.Accent_Green, Theme.Accent_Blue, 0, accentStrip)
	accentStrip.BackgroundTransparency = 0
	accentStrip.ZIndex = 3

	-- drag handle (top pill)
	local Handle = MakeFrame(UDim2.new(0, 36, 0, 4), UDim2.new(0.5,-18, 0, 8), Theme.Text_Muted, Header)
	Handle.BackgroundTransparency = 0.5
	MakeCorner(99, Handle)

	-- icon circle
	local IconBG = MakeFrame(UDim2.new(0,36,0,36), UDim2.new(0, Theme.Padding, 0, 18), Theme.BG_Elevated, Header)
	MakeCorner(10, IconBG)
	MakeStroke(Theme.Border_Accent, 1, 0.5, IconBG)
	local IconLabel = MakeLabel(config.Icon or "✦", 16, Theme.Accent_Green, Theme.Font_Body, IconBG)
	IconLabel.Size = UDim2.new(1,0,1,0)
	IconLabel.TextXAlignment = Enum.TextXAlignment.Center
	IconLabel.TextYAlignment = Enum.TextYAlignment.Center

	-- title
	local TitleLabel = MakeLabel(
		config.Title or "NexusUI",
		18,
		Theme.Text_Primary,
		Theme.Font_Title,
		Header
	)
	TitleLabel.Position = UDim2.new(0, Theme.Padding + 44, 0, 16)
	TitleLabel.Size = UDim2.new(1, -(Theme.Padding*2 + 44 + 32), 0, 22)

	-- subtitle
	if config.Subtitle then
		local SubLabel = MakeLabel(config.Subtitle, 12, Theme.Text_Secondary, Theme.Font_Body, Header)
		SubLabel.Position = UDim2.new(0, Theme.Padding + 44, 0, 38)
		SubLabel.Size = UDim2.new(1, -(Theme.Padding*2 + 44), 0, 14)
	end

	-- close button
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 28, 0, 28)
	CloseBtn.Position = UDim2.new(1, -(Theme.Padding + 28), 0, 14)
	CloseBtn.BackgroundColor3 = Theme.BG_Elevated
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Theme.Text_Secondary
	CloseBtn.TextSize = 18
	CloseBtn.Font = Theme.Font_Title
	CloseBtn.BorderSizePixel = 0
	CloseBtn.Parent = Header
	MakeCorner(8, CloseBtn)

	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseBtn, {BackgroundColor3 = Theme.Danger, TextColor3 = Theme.Text_Primary})
	end)
	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseBtn, {BackgroundColor3 = Theme.BG_Elevated, TextColor3 = Theme.Text_Secondary})
	end)
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(Root, {BackgroundTransparency = 1}, Theme.TweenInfo_Medium)
		task.delay(0.32, function() Root:Destroy() end)
	end)

	-- drag logic
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Root.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			Root.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- ── Content Scroll ─────────────────────────────────────
	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Size = UDim2.new(1, 0, 0, 420)
	ScrollFrame.Position = UDim2.new(0, 0, 0, Theme.HeaderHeight + 12)
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.ScrollBarThickness = 2
	ScrollFrame.ScrollBarImageColor3 = Theme.Accent_Blue
	ScrollFrame.ScrollBarImageTransparency = 0.4
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
	ScrollFrame.Parent = Root

	local ContentList = MakeListLayout(0, nil, ScrollFrame)
	MakePadding(10, 10, ScrollFrame)

	-- auto-resize canvas
	ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
	end)

	-- auto-resize window height
	ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local targetH = math.min(ContentList.AbsoluteContentSize.Y + Theme.HeaderHeight + 32, 560)
		Tween(ScrollFrame, {Size = UDim2.new(1, 0, 0, targetH - Theme.HeaderHeight - 12)}, Theme.TweenInfo_Medium)
		Tween(Root, {Size = UDim2.new(0, Theme.WindowWidth, 0, targetH)}, Theme.TweenInfo_Medium)
	end)

	-- entrance animation
	Root.Size = UDim2.new(0, Theme.WindowWidth, 0, 0)
	Root.BackgroundTransparency = 1
	task.defer(function()
		Tween(Root, {BackgroundTransparency = 0}, Theme.TweenInfo_Medium)
		Tween(Root, {Size = UDim2.new(0, Theme.WindowWidth, 0, 80)}, Theme.TweenInfo_Spring)
	end)

	-- ══════════════════════════════════════════════════════
	--  AddSection
	-- ══════════════════════════════════════════════════════
	function Window:AddSection(title)
		local Section = {}

		-- section wrapper
		local SectionFrame = MakeFrame(UDim2.new(1, 0, 0, 40), nil, Color3.new(0,0,0), ScrollFrame)
		SectionFrame.BackgroundTransparency = 1

		-- section header
		local SectionHeader = MakeFrame(UDim2.new(1, 0, 0, 30), nil, Theme.BG_Tertiary, SectionFrame)
		MakeCorner(Theme.SmallRadius, SectionHeader)
		MakePadding(10, 0, SectionHeader)
		MakeStroke(Theme.Border_Subtle, 1, 0, SectionHeader)

		-- accent dot
		local Dot = MakeFrame(UDim2.new(0,4,0,14), UDim2.new(0, 10, 0.5, -7), Theme.Accent_Green, SectionHeader)
		MakeCorner(99, Dot)
		MakeGradient(Theme.Accent_Green, Theme.Accent_Blue, 90, Dot)

		local SectionTitle = MakeLabel(title or "Section", 12, Theme.Text_Secondary, Theme.Font_Title, SectionHeader)
		SectionTitle.Position = UDim2.new(0, 20, 0, 0)
		SectionTitle.Size = UDim2.new(1, -20, 1, 0)
		SectionTitle.TextYAlignment = Enum.TextYAlignment.Center
		SectionTitle.Text = string.upper(title or "SECTION")

		-- items container
		local ItemsFrame = MakeFrame(UDim2.new(1, 0, 0, 0), UDim2.new(0,0,0,32), Theme.BG_Tertiary, SectionFrame)
		MakeCorner(Theme.CornerRadius, SectionFrame)
		MakeStroke(Theme.Border_Subtle, 1, 0, ItemsFrame)
		local ItemsList = MakeListLayout(0, nil, ItemsFrame)
		MakePadding(0, 0, ItemsFrame)
		AutoSize(ItemsFrame, ItemsList)

		local SectionList = MakeListLayout(4, nil, SectionFrame)
		AutoSize(SectionFrame, SectionList, 4)

		-- helper to make an item row base
		local function MakeItem(h)
			local item = MakeFrame(UDim2.new(1, 0, 0, h or Theme.ItemHeight), nil, Color3.new(0,0,0), ItemsFrame)
			item.BackgroundTransparency = 1
			MakePadding(Theme.Padding, 0, item)
			return item
		end

		-- ── separator between items
		local itemCount = 0
		local function AddSep()
			itemCount += 1
			if itemCount > 1 then
				MakeSeparator(ItemsFrame)
			end
		end

		-- ─────────────────────────────────────────────────
		-- AddButton
		-- ─────────────────────────────────────────────────
		function Section:AddButton(label, callback, style)
			AddSep()
			local item = MakeItem()
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 36)
			btn.Position = UDim2.new(0, 0, 0.5, -18)
			btn.BackgroundColor3 = (style == "primary") and Theme.Accent_Green
				or (style == "danger") and Theme.Danger
				or Theme.BG_Elevated
			btn.Text = label or "Button"
			btn.TextColor3 = (style == "primary") and Theme.BG_Primary or Theme.Text_Primary
			btn.TextSize = 14
			btn.Font = Theme.Font_Body
			btn.BorderSizePixel = 0
			btn.Parent = item
			MakeCorner(Theme.SmallRadius, btn)
			if style ~= "primary" then
				MakeStroke(Theme.Border_Default, 1, 0, btn)
			end
			AddRipple(btn, (style == "primary") and Theme.Accent_GreenDim or Theme.Accent_Blue)

			btn.MouseEnter:Connect(function()
				local c = (style == "primary") and Theme.Accent_GreenDim
					or (style == "danger") and Color3.fromRGB(200, 50, 60)
					or Theme.BG_Elevated
				Tween(btn, {BackgroundColor3 = c})
			end)
			btn.MouseLeave:Connect(function()
				local c = (style == "primary") and Theme.Accent_Green
					or (style == "danger") and Theme.Danger
					or Theme.BG_Elevated
				Tween(btn, {BackgroundColor3 = c})
			end)
			btn.MouseButton1Click:Connect(function()
				if callback then task.spawn(callback) end
			end)

			return btn
		end

		-- ─────────────────────────────────────────────────
		-- AddToggle
		-- ─────────────────────────────────────────────────
		function Section:AddToggle(label, default, callback)
			AddSep()
			local item = MakeItem()
			local state = default or false

			local lbl = MakeLabel(label or "Toggle", 14, Theme.Text_Primary, Theme.Font_Body, item)
			lbl.Position = UDim2.new(0, 0, 0, 0)
			lbl.Size = UDim2.new(1, -56, 1, 0)
			lbl.TextYAlignment = Enum.TextYAlignment.Center

			-- track bg
			local Track = MakeFrame(UDim2.new(0, 44, 0, 24), UDim2.new(1, -44, 0.5, -12), Theme.BG_Elevated, item)
			MakeCorner(99, Track)
			MakeStroke(Theme.Border_Default, 1, 0, Track)

			-- thumb
			local Thumb = MakeFrame(UDim2.new(0, 18, 0, 18), UDim2.new(0, 3, 0.5, -9), Theme.Text_Muted, Track)
			MakeCorner(99, Thumb)

			local function SetState(val, silent)
				state = val
				if state then
					Tween(Track, {BackgroundColor3 = Theme.Accent_Green})
					Tween(Thumb, {Position = UDim2.new(0, 23, 0.5, -9), BackgroundColor3 = Theme.BG_Primary})
				else
					Tween(Track, {BackgroundColor3 = Theme.BG_Elevated})
					Tween(Thumb, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Theme.Text_Muted})
				end
				if not silent and callback then task.spawn(callback, state) end
			end

			SetState(state, true)

			local ClickArea = Instance.new("TextButton")
			ClickArea.Size = UDim2.new(1, 0, 1, 0)
			ClickArea.BackgroundTransparency = 1
			ClickArea.Text = ""
			ClickArea.Parent = item
			ClickArea.MouseButton1Click:Connect(function() SetState(not state) end)

			local API = {}
			function API:Set(val) SetState(val, true) end
			function API:Get() return state end
			return API
		end

		-- ─────────────────────────────────────────────────
		-- AddSlider
		-- ─────────────────────────────────────────────────
		function Section:AddSlider(label, min, max, default, callback)
			AddSep()
			local item = MakeItem(64)
			local value = default or min or 0
			min = min or 0; max = max or 100

			-- label row
			local TopRow = MakeFrame(UDim2.new(1, 0, 0, 20), nil, Color3.new(0,0,0), item)
			TopRow.BackgroundTransparency = 1
			local lbl = MakeLabel(label or "Slider", 14, Theme.Text_Primary, Theme.Font_Body, TopRow)
			lbl.Size = UDim2.new(1, -50, 1, 0)
			local ValLabel = MakeLabel(tostring(value), 13, Theme.Accent_Green, Theme.Font_Mono, TopRow)
			ValLabel.Size = UDim2.new(0, 46, 1, 0)
			ValLabel.Position = UDim2.new(1, -46, 0, 0)
			ValLabel.TextXAlignment = Enum.TextXAlignment.Right

			-- track
			local TrackBG = MakeFrame(UDim2.new(1, 0, 0, 4), UDim2.new(0, 0, 0, 28), Theme.BG_Elevated, item)
			MakeCorner(99, TrackBG)

			local TrackFill = MakeFrame(UDim2.new(0, 0, 1, 0), nil, Theme.Accent_Green, TrackBG)
			MakeCorner(99, TrackFill)
			MakeGradient(Theme.Accent_Green, Theme.Accent_Blue, 0, TrackFill)

			local Thumb = MakeFrame(UDim2.new(0,16,0,16), UDim2.new(0,-8,0.5,-8), Theme.Text_Primary, TrackBG)
			MakeCorner(99, Thumb)
			MakeStroke(Theme.Accent_Green, 2, 0, Thumb)

			local function SetValue(v, silent)
				v = math.clamp(v, min, max)
				value = v
				local pct = (v - min) / (max - min)
				Tween(TrackFill, {Size = UDim2.new(pct, 0, 1, 0)})
				Tween(Thumb, {Position = UDim2.new(pct, -8, 0.5, -8)})
				ValLabel.Text = tostring(math.floor(v))
				if not silent and callback then task.spawn(callback, v) end
			end

			SetValue(value, true)

			local sliding = false
			TrackBG.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = true
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if sliding and (input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseMovement) then
					local rel = (input.Position.X - TrackBG.AbsolutePosition.X) / TrackBG.AbsoluteSize.X
					SetValue(min + (max - min) * math.clamp(rel, 0, 1))
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = false
				end
			end)

			local API = {}
			function API:Set(v) SetValue(v, true) end
			function API:Get() return value end
			return API
		end

		-- ─────────────────────────────────────────────────
		-- AddDropdown
		-- ─────────────────────────────────────────────────
		function Section:AddDropdown(label, options, default, callback)
			AddSep()
			local item = MakeItem()
			local selected = default or (options and options[1]) or ""
			local open = false

			local lbl = MakeLabel(label or "Dropdown", 14, Theme.Text_Primary, Theme.Font_Body, item)
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.TextYAlignment = Enum.TextYAlignment.Center

			local SelBtn = Instance.new("TextButton")
			SelBtn.Size = UDim2.new(0.5, -4, 0, 30)
			SelBtn.Position = UDim2.new(0.5, 4, 0.5, -15)
			SelBtn.BackgroundColor3 = Theme.BG_Elevated
			SelBtn.Text = selected .. "  ▾"
			SelBtn.TextColor3 = Theme.Accent_Green
			SelBtn.TextSize = 13
			SelBtn.Font = Theme.Font_Body
			SelBtn.BorderSizePixel = 0
			SelBtn.Parent = item
			MakeCorner(Theme.SmallRadius, SelBtn)
			MakeStroke(Theme.Border_Default, 1, 0, SelBtn)

			-- dropdown panel
			local Panel = MakeFrame(UDim2.new(0, Theme.WindowWidth - 28, 0, 0), UDim2.new(0,0,0,0), Theme.BG_Elevated, ScreenGui)
			Panel.Visible = false
			MakeCorner(Theme.CornerRadius, Panel)
			MakeStroke(Theme.Accent_Blue, 1, 0.3, Panel)
			Panel.ZIndex = 50

			local PanelList = MakeListLayout(0, nil, Panel)
			MakePadding(0, 4, Panel)
			AutoSize(Panel, PanelList, 8)

			for _, opt in ipairs(options or {}) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, 0, 0, 36)
				optBtn.BackgroundColor3 = (opt == selected) and Theme.BG_Primary or Color3.new(0,0,0)
				optBtn.BackgroundTransparency = (opt == selected) and 0 or 1
				optBtn.Text = opt
				optBtn.TextColor3 = (opt == selected) and Theme.Accent_Green or Theme.Text_Primary
				optBtn.TextSize = 13
				optBtn.Font = Theme.Font_Body
				optBtn.BorderSizePixel = 0
				optBtn.ZIndex = 51
				optBtn.Parent = Panel
				MakePadding(Theme.Padding, 0, optBtn)
				AddRipple(optBtn, Theme.Accent_Blue)

				optBtn.MouseButton1Click:Connect(function()
					selected = opt
					SelBtn.Text = selected .. "  ▾"
					open = false
					Panel.Visible = false
					if callback then task.spawn(callback, selected) end
				end)
			end

			SelBtn.MouseButton1Click:Connect(function()
				open = not open
				if open then
					local abs = SelBtn.AbsolutePosition
					Panel.Position = UDim2.new(0, abs.X - 14, 0, abs.Y + 34)
					Panel.Visible = true
					Tween(Panel, {BackgroundTransparency = 0}, Theme.TweenInfo_Fast)
				else
					Panel.Visible = false
				end
			end)

			local API = {}
			function API:Set(v) selected = v; SelBtn.Text = v .. "  ▾" end
			function API:Get() return selected end
			return API
		end

		-- ─────────────────────────────────────────────────
		-- AddTextbox
		-- ─────────────────────────────────────────────────
		function Section:AddTextbox(label, placeholder, callback)
			AddSep()
			local item = MakeItem(60)

			local lbl = MakeLabel(label or "Input", 12, Theme.Text_Secondary, Theme.Font_Body, item)
			lbl.Size = UDim2.new(1, 0, 0, 16)

			local InputBG = MakeFrame(UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 18), Theme.BG_Elevated, item)
			MakeCorner(Theme.SmallRadius, InputBG)
			MakeStroke(Theme.Border_Default, 1, 0, InputBG)

			local Input = Instance.new("TextBox")
			Input.Size = UDim2.new(1, -24, 1, 0)
			Input.Position = UDim2.new(0, 10, 0, 0)
			Input.BackgroundTransparency = 1
			Input.Text = ""
			Input.PlaceholderText = placeholder or ""
			Input.PlaceholderColor3 = Theme.Text_Muted
			Input.TextColor3 = Theme.Text_Primary
			Input.TextSize = 13
			Input.Font = Theme.Font_Body
			Input.ClearTextOnFocus = false
			Input.TextXAlignment = Enum.TextXAlignment.Left
			Input.Parent = InputBG

			Input.Focused:Connect(function()
				Tween(InputBG, {BackgroundColor3 = Theme.BG_Primary})
				Tween(InputBG, {}, Theme.TweenInfo_Fast)
				MakeStroke(Theme.Accent_Blue, 1, 0, InputBG)
			end)
			Input.FocusLost:Connect(function(enter)
				Tween(InputBG, {BackgroundColor3 = Theme.BG_Elevated})
				MakeStroke(Theme.Border_Default, 1, 0, InputBG)
				if callback then task.spawn(callback, Input.Text, enter) end
			end)

			local API = {}
			function API:Set(v) Input.Text = v end
			function API:Get() return Input.Text end
			return API
		end

		-- ─────────────────────────────────────────────────
		-- AddColorPicker (simplified HSV wheel-less version)
		-- ─────────────────────────────────────────────────
		function Section:AddColorPicker(label, default, callback)
			AddSep()
			local item = MakeItem(80)
			local color = default or Color3.fromRGB(0, 220, 120)

			local lbl = MakeLabel(label or "Color", 14, Theme.Text_Primary, Theme.Font_Body, item)
			lbl.Size = UDim2.new(1, -80, 0, 20)

			local Preview = MakeFrame(UDim2.new(0, 32, 0, 32), UDim2.new(1, -36, 0, 24), color, item)
			MakeCorner(Theme.SmallRadius, Preview)
			MakeStroke(Theme.Border_Default, 1, 0, Preview)

			-- R/G/B sliders stacked
			local channels = {
				{name="R", key="r", color=Theme.Danger},
				{name="G", key="g", color=Theme.Accent_Green},
				{name="B", key="b", color=Theme.Accent_Blue},
			}

			local subItem = MakeItem(64)
			subItem.Parent = ItemsFrame
			MakePadding(Theme.Padding, 6, subItem)
			itemCount += 1

			local subList = MakeListLayout(4, nil, subItem)
			AutoSize(subItem, subList, 12)

			local vals = {r = color.R * 255, g = color.G * 255, b = color.B * 255}

			local function UpdateColor()
				color = Color3.fromRGB(vals.r, vals.g, vals.b)
				Preview.BackgroundColor3 = color
				if callback then task.spawn(callback, color) end
			end

			for _, ch in ipairs(channels) do
				local row = MakeFrame(UDim2.new(1, 0, 0, 16), nil, Color3.new(0,0,0), subItem)
				row.BackgroundTransparency = 1
				local chLbl = MakeLabel(ch.name, 11, Theme.Text_Muted, Theme.Font_Mono, row)
				chLbl.Size = UDim2.new(0, 12, 1, 0)

				local trackBG = MakeFrame(UDim2.new(1, -20, 0, 4), UDim2.new(0, 16, 0.5, -2), Theme.BG_Primary, row)
				MakeCorner(99, trackBG)
				local trackFill = MakeFrame(UDim2.new(vals[ch.key]/255, 0, 1, 0), nil, ch.color, trackBG)
				MakeCorner(99, trackFill)

				local sliding2 = false
				trackBG.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.Touch
					or inp.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding2 = true
					end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if sliding2 and (inp.UserInputType == Enum.UserInputType.Touch
					or inp.UserInputType == Enum.UserInputType.MouseMovement) then
						local rel = math.clamp((inp.Position.X - trackBG.AbsolutePosition.X)/trackBG.AbsoluteSize.X, 0, 1)
						vals[ch.key] = rel * 255
						Tween(trackFill, {Size = UDim2.new(rel, 0, 1, 0)})
						UpdateColor()
					end
				end)
				UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.Touch
					or inp.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding2 = false
					end
				end)
			end

			local API = {}
			function API:Set(c)
				color = c
				Preview.BackgroundColor3 = c
				vals = {r = c.R*255, g = c.G*255, b = c.B*255}
			end
			function API:Get() return color end
			return API
		end

		-- ─────────────────────────────────────────────────
		-- AddLabel
		-- ─────────────────────────────────────────────────
		function Section:AddLabel(text, style)
			AddSep()
			local item = MakeItem(40)
			local color = (style == "success") and Theme.Success
				or (style == "warning") and Theme.Warning
				or (style == "danger")  and Theme.Danger
				or (style == "info")    and Theme.Info
				or Theme.Text_Secondary

			local lbl = MakeLabel(text or "", 13, color, Theme.Font_Body, item)
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.TextYAlignment = Enum.TextYAlignment.Center
			lbl.TextWrapped = true

			local API = {}
			function API:Set(t) lbl.Text = t end
			return API
		end

		-- ─────────────────────────────────────────────────
		-- AddKeybind
		-- ─────────────────────────────────────────────────
		function Section:AddKeybind(label, default, callback)
			AddSep()
			local item = MakeItem()
			local key = default or Enum.KeyCode.Unknown
			local listening = false

			local lbl = MakeLabel(label or "Keybind", 14, Theme.Text_Primary, Theme.Font_Body, item)
			lbl.Size = UDim2.new(1, -90, 1, 0)
			lbl.TextYAlignment = Enum.TextYAlignment.Center

			local KeyBtn = Instance.new("TextButton")
			KeyBtn.Size = UDim2.new(0, 78, 0, 28)
			KeyBtn.Position = UDim2.new(1, -78, 0.5, -14)
			KeyBtn.BackgroundColor3 = Theme.BG_Elevated
			KeyBtn.Text = key.Name
			KeyBtn.TextColor3 = Theme.Accent_Blue
			KeyBtn.TextSize = 12
			KeyBtn.Font = Theme.Font_Mono
			KeyBtn.BorderSizePixel = 0
			KeyBtn.Parent = item
			MakeCorner(Theme.SmallRadius, KeyBtn)
			MakeStroke(Theme.Border_Default, 1, 0, KeyBtn)

			KeyBtn.MouseButton1Click:Connect(function()
				listening = not listening
				if listening then
					KeyBtn.Text = "..."
					KeyBtn.TextColor3 = Theme.Warning
				else
					KeyBtn.Text = key.Name
					KeyBtn.TextColor3 = Theme.Accent_Blue
				end
			end)

			UserInputService.InputBegan:Connect(function(input, gp)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					key = input.KeyCode
					listening = false
					KeyBtn.Text = key.Name
					KeyBtn.TextColor3 = Theme.Accent_Blue
					if callback then task.spawn(callback, key) end
				end
			end)

			local API = {}
			function API:Get() return key end
			return API
		end

		return Section
	end -- AddSection

	-- ══════════════════════════════════════════════════════
	--  AddNotification (global, top-level)
	-- ══════════════════════════════════════════════════════
	function Window:AddNotification(message, duration, style)
		duration = duration or 3
		local bgColor = (style == "success") and Theme.Success
			or (style == "warning") and Theme.Warning
			or (style == "danger")  and Theme.Danger
			or Theme.Accent_Blue

		local Notif = MakeFrame(UDim2.new(0, Theme.WindowWidth - 32, 0, 44), nil, Theme.BG_Elevated, NotifLayer)
		Notif.BackgroundTransparency = 1
		MakeCorner(Theme.CornerRadius, Notif)
		MakeStroke(bgColor, 1, 0.3, Notif)

		local accent = MakeFrame(UDim2.new(0, 3, 0, 28), UDim2.new(0, 8, 0.5, -14), bgColor, Notif)
		MakeCorner(99, accent)

		local msg = MakeLabel(message, 13, Theme.Text_Primary, Theme.Font_Body, Notif)
		msg.Size = UDim2.new(1, -28, 1, 0)
		msg.Position = UDim2.new(0, 20, 0, 0)
		msg.TextYAlignment = Enum.TextYAlignment.Center
		msg.TextWrapped = true

		Tween(Notif, {BackgroundTransparency = 0}, Theme.TweenInfo_Spring)
		task.delay(duration, function()
			Tween(Notif, {BackgroundTransparency = 1}, Theme.TweenInfo_Medium)
			task.delay(0.35, function() Notif:Destroy() end)
		end)
	end

	-- ══════════════════════════════════════════════════════
	--  Toggle visibility
	-- ══════════════════════════════════════════════════════
	function Window:SetVisible(visible)
		if visible then
			Root.Visible = true
			Tween(Root, {BackgroundTransparency = 0}, Theme.TweenInfo_Medium)
		else
			Tween(Root, {BackgroundTransparency = 1}, Theme.TweenInfo_Medium)
			task.delay(0.35, function() Root.Visible = false end)
		end
	end

	function Window:Destroy()
		Root:Destroy()
	end

	return Window
end -- CreateWindow

-- ══════════════════════════════════════════════════════════════════
--  Standalone Notification (no window needed)
-- ══════════════════════════════════════════════════════════════════
function NexusUI:Notify(message, duration, style)
	local w = {AddNotification = function(self, ...) end}
	-- reuse window notify logic
	local tmp = {AddNotification = NexusUI.CreateWindow(NexusUI, {Title=""}).AddNotification}
	-- simpler direct impl
	local bgColor = (style == "success") and Theme.Success
		or (style == "warning") and Theme.Warning
		or (style == "danger")  and Theme.Danger
		or Theme.Accent_Blue
	duration = duration or 3

	local Notif = MakeFrame(UDim2.new(0, Theme.WindowWidth - 32, 0, 44), nil, Theme.BG_Elevated, NotifLayer)
	Notif.BackgroundTransparency = 1
	MakeCorner(Theme.CornerRadius, Notif)
	MakeStroke(bgColor, 1, 0.3, Notif)

	local accent = MakeFrame(UDim2.new(0, 3, 0, 28), UDim2.new(0, 8, 0.5, -14), bgColor, Notif)
	MakeCorner(99, accent)

	local msg = MakeLabel(message, 13, Theme.Text_Primary, Theme.Font_Body, Notif)
	msg.Size = UDim2.new(1, -28, 1, 0)
	msg.Position = UDim2.new(0, 20, 0, 0)
	msg.TextYAlignment = Enum.TextYAlignment.Center
	msg.TextWrapped = true

	Tween(Notif, {BackgroundTransparency = 0}, Theme.TweenInfo_Spring)
	task.delay(duration, function()
		Tween(Notif, {BackgroundTransparency = 1}, Theme.TweenInfo_Medium)
		task.delay(0.35, function() Notif:Destroy() end)
	end)
end

-- ══════════════════════════════════════════════════════════════════
--  Theme accessor
-- ══════════════════════════════════════════════════════════════════
function NexusUI:GetTheme()
	return Theme
end

function NexusUI:SetAccent(green, blue)
	if green then Theme.Accent_Green = green; Theme.Text_Accent = green end
	if blue  then Theme.Accent_Blue  = blue  end
end

return NexusUI
