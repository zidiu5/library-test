--// CYBERPUNK ULTIMATE UI LIBRARY
--// VERSION 3 

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local SavedWindowSize = nil


--================ CONFIG SYSTEM =================--
local HttpService = game:GetService("HttpService")
local Config = {}
Config.FileName = "CyberpunkUI_Config.json"
Config.Data = {}

local function SaveConfig(data)
	if writefile then
		writefile(Config.FileName, HttpService:JSONEncode(data))
		return
	end

	local folder = Player:FindFirstChild("UI_CONFIG")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "UI_CONFIG"
		folder.Parent = Player
	end

	local value = folder:FindFirstChild("DATA")
	if not value then
		value = Instance.new("StringValue")
		value.Name = "DATA"
		value.Parent = folder
	end

	value.Value = HttpService:JSONEncode(data)
end

local function LoadConfig()
	if isfile and readfile and isfile(Config.FileName) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(Config.FileName))
		end)
		if ok then return data end
	end

	local folder = Player:FindFirstChild("UI_CONFIG")
	if folder then
		local value = folder:FindFirstChild("DATA")
		if value and value.Value ~= "" then
			local ok, data = pcall(function()
				return HttpService:JSONDecode(value.Value)
			end)
			if ok then return data end
		end
	end

	return {}
end

function Config:Get(key, default)
	return Config.Data[key] ~= nil and Config.Data[key] or default
end

function Config:Set(key, value)
	Config.Data[key] = value
	SaveConfig(Config.Data)
end

-- 💡 HELPER FÜR Color3
function Config:ColorToTable(color)
	return {r = color.R, g = color.G, b = color.B}
end

function Config:TableToColor(tbl, default)
	if not tbl then return default end
	return Color3.new(tbl.r, tbl.g, tbl.b)
end

Config.Data = LoadConfig()



local PLACE_KEY = "Place_" .. game.PlaceId
Config.Data[PLACE_KEY] = Config.Data[PLACE_KEY] or {}
local GameConfig = Config.Data[PLACE_KEY]

-- Keybind
guiKey = GameConfig.GuiKey or "RightShift"

-- Drag Toggle
DragEnabled = GameConfig.DragEnabled or false

-- Farbe merken
SavedMainColor = Config:TableToColor(GameConfig.MainColor, Color3.fromRGB(40, 40, 40))

-- GUI Size / Position merken
SavedGuiSize = GameConfig.GuiSize or {X=1, Y=1, OffsetX=0, OffsetY=0}
SavedGuiPosition = GameConfig.GuiPosition or {X=0, Y=0, OffsetX=20, OffsetY=200}






--================ THEME =================--
local Theme = {
	Main = Color3.fromRGB(10,10,18),
	Accent = Color3.fromRGB(0,255,255),
	Secondary = Color3.fromRGB(255,0,255),
	Text = Color3.fromRGB(240,240,240),
	DarkText = Color3.fromRGB(150,150,150),
	Button = Color3.fromRGB(25,25,40),
	Success = Color3.fromRGB(0,255,150),
	Font = Enum.Font.GothamBold,
	FontSecondary = Enum.Font.Gotham
}
local currentTransparency = 0 -- Defaultwert

local function Tween(obj, info, goal)
	local t = TweenService:Create(obj, TweenInfo.new(unpack(info)), goal)
	t:Play()
	return t
end

--================ SCREEN GUI =================--
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "CyberpunkUI"
ScreenGui.ResetOnSpawn = false


--================ UI STATE =================--
local isOpen = false

local OpenUI
local CloseUI

--================ OPEN BUTTON =================--
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.fromOffset(40,40)
OpenButton.Position = UDim2.fromOffset(20,200)
OpenButton.Text = "Z"
OpenButton.Font = Enum.Font.Merriweather
OpenButton.TextSize = 25
OpenButton.BackgroundColor3 = Theme.Main
OpenButton.TextColor3 = Theme.Accent
OpenButton.BorderSizePixel = 0
OpenButton.AutoButtonColor = false
OpenButton.ZIndex = 10
OpenButton.Active = true 

local Corner = Instance.new("UICorner", OpenButton)
Corner.CornerRadius = UDim.new(0,6)

local Stroke = Instance.new("UIStroke", OpenButton)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,0,255)

--================ UNSICHTBARE SWIPE ZONE =================--
local SwipeZone = Instance.new("Frame", ScreenGui)
SwipeZone.Name = "SwipeZone"
SwipeZone.Size = UDim2.new(0, 40, 0.6, 0) 
SwipeZone.Position = UDim2.new(0, 0, 0.2, 0) 
SwipeZone.BackgroundTransparency = 1 
SwipeZone.Active = true
SwipeZone.Visible = false
SwipeZone.ZIndex = 1000

-- Visual Feedback (Optional: Kleiner Streifen der aufleuchtet)
local SwipeIndicator = Instance.new("Frame", SwipeZone)
SwipeIndicator.Size = UDim2.new(0, 2, 1, 0)
SwipeIndicator.BackgroundColor3 = Theme.Accent
SwipeIndicator.BackgroundTransparency = 1 -- Standard unsichtbar
Instance.new("UICorner", SwipeIndicator)

local swipeStart = nil
local SWIPE_THRESHOLD = 100 

SwipeZone.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		swipeStart = input.Position
		Tween(SwipeIndicator, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundTransparency = 0.5})
	end
end)

UIS.InputChanged:Connect(function(input)
	if swipeStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position.X - swipeStart.X
		-- Wenn wir ziehen, leuchtet der Balken stärker
		local glow = math.clamp(1 - (delta / SWIPE_THRESHOLD), 0.2, 1)
		SwipeIndicator.BackgroundTransparency = glow

		local glow = math.clamp(delta / SWIPE_THRESHOLD, 0, 1)
		SwipeIndicator.BackgroundTransparency = 1 - glow
		SwipeIndicator.Size = UDim2.new(0, 2 + (glow * 4), 1, 0) -- Wird dicker beim Ziehen

		if delta > SWIPE_THRESHOLD then
			swipeStart = nil
			if not isOpen then OpenUI() end
			Tween(SwipeIndicator, {0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundTransparency = 1})
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	swipeStart = nil
	Tween(SwipeIndicator, {0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundTransparency = 1})
end)


--================ DRAG SETTINGS =================--
local dragEnabled = false 
local dragging = false
local dragStartPos = nil
local buttonStartPos = nil
local potentialClick = false
local DRAG_THRESHOLD = 8

--================ INPUT BEGAN =================--
OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		potentialClick = true

		if dragEnabled then
			dragStartPos = input.Position
			buttonStartPos = OpenButton.Position
			dragging = false
		end
	end
end)

--================ INPUT CHANGED =================--
UIS.InputChanged:Connect(function(input)
	if not dragEnabled or not dragStartPos then return end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStartPos

		-- Magnitude ist sauberer für Diagonalen
		if delta.Magnitude > DRAG_THRESHOLD then
			dragging = true
			potentialClick = false
		end

		if dragging then
			OpenButton.Position = buttonStartPos + UDim2.fromOffset(delta.X, delta.Y)
		end
	end
end)

--================ INPUT ENDED =================--
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		if potentialClick then
			isOpen = not isOpen
			if isOpen then OpenUI() else CloseUI() end
		end

		-- Reset für den nächsten Klick/Drag
		dragging = false
		potentialClick = false
		dragStartPos = nil
	end
end)

--================ NEON GLOW LAYER =================--
local Glow = Instance.new("Frame", OpenButton)
Glow.Name = "NeonGlow"
Glow.AnchorPoint = Vector2.new(0.5,0.5)
Glow.Position = UDim2.fromScale(0.5,0.5)
Glow.Size = UDim2.fromOffset(45,45)
Glow.BackgroundColor3 = Color3.fromRGB(0,0,255)
Glow.BackgroundTransparency = 0.85
Glow.ZIndex = OpenButton.ZIndex - 1

local GlowCorner = Instance.new("UICorner", Glow)
GlowCorner.CornerRadius = UDim.new(0,8)

local GlowStroke = Instance.new("UIStroke", Glow)
GlowStroke.Thickness = 3
GlowStroke.Transparency = 0.65

-- Idle Glow Pulse
task.spawn(function()
	while true do
		Tween(Glow,{1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			BackgroundTransparency = 0.9
		})
		Tween(GlowStroke,{1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			Transparency = 0.85
		})
		task.wait(1.4)

		Tween(Glow,{1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			BackgroundTransparency = 0.85
		})
		Tween(GlowStroke,{1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			Transparency = 0.75
		})
		task.wait(1.4)
	end
end)


-- Korrigierter Hover für Designs
OpenButton.MouseEnter:Connect(function()
	if OpenButton.Text == "O" then -- Minimalist Check
		Tween(OpenButton, {0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
			BackgroundTransparency = 0.2
		})
	else
		Tween(OpenButton, {0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
			BackgroundColor3 = Color3.fromRGB(20,20,35)
		})
		Tween(Stroke,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
			Color = Theme.Secondary
		})
		Tween(Glow,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
			BackgroundColor3 = Theme.Secondary
		})
		Tween(GlowStroke,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
			Color = Theme.Secondary
		})
	end
end)


OpenButton.MouseLeave:Connect(function()
	if OpenButton.Text == "O" then
		Tween(OpenButton, {0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
			BackgroundTransparency = 1
		})
	else
		Tween(OpenButton, {0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {
			BackgroundColor3 = Theme.Main
		})
		Tween(Stroke,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
			Color = Color3.fromRGB(0,0,255)
		})
		Tween(Glow,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
			BackgroundColor3 = Color3.fromRGB(0,0,255)
		})
		Tween(GlowStroke,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
			Color = Color3.fromRGB(0,0,255)
		})
	end
end)



--================ MAIN FRAME =================--
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromScale(0.5,0.8)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Theme.Main
Main.Active = true
Main.Visible = false
Main.ClipsDescendants = true

if SavedWindowSize then
	Main.Size = SavedWindowSize
end

--================ CLOSE X BUTTON (NUR EINMAL HIER!) =================--
local CloseX = Instance.new("TextButton", Main)
CloseX.Name = "CloseX"
CloseX.Size = UDim2.fromOffset(30, 30)
CloseX.Position = UDim2.new(1, -35, 0, 12)
CloseX.BackgroundTransparency = 1
CloseX.Text = "✕"
CloseX.Font = Theme.Font
CloseX.TextSize = 22
CloseX.TextColor3 = Theme.Accent
CloseX.ZIndex = 100
CloseX.Visible = false -- Standardmäßig aus

CloseX.MouseButton1Click:Connect(function()
	CloseUI()
end)

-- Hover Effekt für das X
CloseX.MouseEnter:Connect(function()
	Tween(CloseX, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {TextColor3 = Theme.Secondary})
end)
CloseX.MouseLeave:Connect(function()
	Tween(CloseX, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {TextColor3 = Theme.Accent})
end)

--================ APPLY DESIGN FUNKTION (JETZT MIT FORCE FIX) =================--
local function ApplyButtonDesign(style)
	-- Reset alles
	OpenButton.Visible = true
	SwipeZone.Visible = false
	Glow.Visible = false
	Stroke.Enabled = true
	OpenButton.BackgroundTransparency = 0

	-- Styles anwenden
	if style == "Standard Neon" then
		OpenButton.Text = "Z"
		OpenButton.BackgroundColor3 = Theme.Main
		Glow.Visible = true
		Corner.CornerRadius = UDim.new(0, 6)
		OpenButton.Size = UDim2.fromOffset(40, 40)
	elseif style == "Minimalist O" then
		OpenButton.Text = "O"
		OpenButton.BackgroundTransparency = 1 
		OpenButton.BackgroundColor3 = Color3.fromRGB(0,0,0) 
		Corner.CornerRadius = UDim.new(1, 0)
		OpenButton.Size = UDim2.fromOffset(30, 30)
	elseif style == "Swipe Mode" then
		OpenButton.Visible = false 
		SwipeZone.Visible = true
	end

	-- DER FIX: Sofortiges Umschalten der Sichtbarkeit des X
	if CloseX then
		if style == "Swipe Mode" and isOpen then
			CloseX.Visible = true
		else
			CloseX.Visible = false
		end
	end
end



--================ RESIZE HANDLE =================--
local ResizeHandle = Instance.new("Frame", Main)
ResizeHandle.Size = UDim2.fromOffset(18,18)
ResizeHandle.Position = UDim2.new(1,-18,1,-18)
ResizeHandle.AnchorPoint = Vector2.new(0,0)
ResizeHandle.BackgroundColor3 = Theme.Accent
ResizeHandle.BackgroundTransparency = 0.2
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 50
ResizeHandle.Visible = false -- standardmäßig aus

local ResizeCorner = Instance.new("UICorner", ResizeHandle)
ResizeCorner.CornerRadius = UDim.new(0,6)

local resizing = false
local startMouse
local startSize

local MIN_SIZE = Vector2.new(350,300)
local MAX_SIZE = Vector2.new(900,700)

ResizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		resizing = true
		startMouse = input.Position
		startSize = Main.AbsoluteSize
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		resizing = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if not resizing then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then return end

	local delta = input.Position - startMouse

	local newX = math.clamp(
		startSize.X + delta.X,
		MIN_SIZE.X,
		MAX_SIZE.X
	)

	local newY = math.clamp(
		startSize.Y + delta.Y,
		MIN_SIZE.Y,
		MAX_SIZE.Y
	)

	Main.Size = UDim2.fromOffset(newX, newY)
	SavedWindowSize = Main.Size
end)






--================ SETTINGS FUNCTIONS & 12 DESIGNS =================--

local function SetMainBackgroundColor(color)
	if Main then
		Tween(Main, {0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundColor3 = color})
	end
end

-- Die 12 Designs mit ihren Grundfarben
local BgColors = {
	["Neon Circuit"] = Color3.fromRGB(0, 242, 255),
	--	["Vaporwave Flow"] = Color3.fromRGB(74, 25, 66),
	--	["Pulsing Aura"] = Color3.fromRGB(183, 0, 255),
	["Digital Rain"] = Color3.fromRGB(0, 255, 0),
	--	["Liquid Glass"] = Color3.fromRGB(200, 200, 255),
	["Heavy Energy Bars"] = Color3.fromRGB(0, 255, 255),
	["Glitch Flare"] = Color3.fromRGB(255, 0, 255),
	["Particle Drift"] = Color3.fromRGB(255, 255, 255),
	["Galactic Warp"] = Color3.fromRGB(10, 10, 25),
	--	["Retro Wave Sun"] = Color3.fromRGB(255, 0, 128),
	--	["Bio-Organic Pulse"] = Color3.fromRGB(100, 0, 255),
	["Cyber Grid 2.0"] = Color3.fromRGB(0, 242, 255)
}

local function ApplySpecialEffect(name)
	-- 1. Alles Alte löschen
	for _, v in pairs(Main:GetChildren()) do
		if v.Name == "SpecialEffect" then v:Destroy() end
	end

	-- 2. Container erstellen (ZIndex 1 = Über Background, unter Buttons)
	local EffectLayer = Instance.new("Frame", Main)
	EffectLayer.Name = "SpecialEffect"
	EffectLayer.Size = UDim2.fromScale(1, 1)
	EffectLayer.BackgroundTransparency = 1
	EffectLayer.ZIndex = 1
	EffectLayer.Active = false
	Main.ClipsDescendants = true

	-- 3. Die 12 Animationen
	if name == "Neon Circuit" then
		local line = Instance.new("Frame", EffectLayer)
		line.Size = UDim2.new(1, 0, 0, 2); line.BackgroundColor3 = Color3.fromRGB(0, 242, 255); line.BorderSizePixel = 0
		task.spawn(function()
			while line.Parent do
				line.Position = UDim2.fromScale(0, -0.1)
				local t = Tween(line, {4, Enum.EasingStyle.Linear}, {Position = UDim2.fromScale(0, 1.1)})
				if t then t.Completed:Wait() end
			end
		end)

	elseif name == "Vaporwave Flow" then
		local grad = Instance.new("ImageLabel", EffectLayer)
		grad.Size = UDim2.fromScale(2, 2); grad.Position = UDim2.fromScale(-0.5, -0.5); grad.BackgroundTransparency = 1
		grad.Image = "rbxassetid://13110452331"; grad.ImageColor3 = Color3.fromRGB(26, 28, 44); grad.ImageTransparency = 0.5
		task.spawn(function()
			while grad.Parent do
				Tween(grad, {10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {Rotation = 360}).Completed:Wait()
			end
		end)

	elseif name == "Pulsing Aura" then
		local aura = Instance.new("ImageLabel", EffectLayer)
		aura.Size = UDim2.fromOffset(400, 400); aura.AnchorPoint = Vector2.new(0.5, 0.5); aura.Position = UDim2.fromScale(0.5, 0.5)
		aura.Image = "rbxassetid://6283307527"; aura.ImageColor3 = Color3.fromRGB(183, 0, 255); aura.BackgroundTransparency = 1
		task.spawn(function()
			while aura.Parent do
				Tween(aura, {2, Enum.EasingStyle.Sine}, {ImageTransparency = 0.8, Size = UDim2.fromOffset(300, 300)}).Completed:Wait()
				Tween(aura, {2, Enum.EasingStyle.Sine}, {ImageTransparency = 0.3, Size = UDim2.fromOffset(500, 500)}).Completed:Wait()
			end
		end)

	elseif name == "Digital Rain" then
		for i = 1, 12 do
			task.spawn(function()
				local r = Instance.new("Frame", EffectLayer)
				r.Size = UDim2.new(0, 2, 0, 120); r.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
				local g = Instance.new("UIGradient", r); g.Rotation = 90; g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
				while r.Parent do
					r.Position = UDim2.fromScale(math.random(), -0.3)
					Tween(r, {math.random(10, 20)/10, Enum.EasingStyle.Linear}, {Position = UDim2.fromScale(r.Position.X.Scale, 1.3)}).Completed:Wait()
				end
			end)
		end

	elseif name == "Liquid Glass" then
		local g = Instance.new("Frame", EffectLayer)
		g.Size = UDim2.fromScale(2, 0.2); g.BackgroundColor3 = Color3.new(1,1,1); g.BackgroundTransparency = 0.9; g.Rotation = 45
		task.spawn(function()
			while g.Parent do
				g.Position = UDim2.fromScale(-1, -1)
				Tween(g, {5, Enum.EasingStyle.Linear}, {Position = UDim2.fromScale(1, 1)}).Completed:Wait()
			end
		end)

	elseif name == "Heavy Energy Bars" then
		local b = Instance.new("Frame", EffectLayer)
		b.Size = UDim2.new(1, 0, 0, 60); b.BackgroundColor3 = Color3.fromRGB(0, 255, 255); b.BackgroundTransparency = 0.8
		task.spawn(function()
			while b.Parent do
				b.Position = UDim2.fromScale(0, -0.2)
				Tween(b, {3, Enum.EasingStyle.Linear}, {Position = UDim2.fromScale(0, 1.2)}).Completed:Wait()
			end
		end)

	elseif name == "Glitch Flare" then
		task.spawn(function()
			while EffectLayer.Parent do
				local f = Instance.new("Frame", EffectLayer)
				f.Size = UDim2.new(1, 0, 0, math.random(1, 5)); f.BackgroundColor3 = Color3.fromRGB(255, 0, 255); f.Position = UDim2.fromScale(0, math.random())
				task.wait(0.1) f:Destroy()
				task.wait(math.random(1, 4))
			end
		end)

	elseif name == "Particle Drift" then
		for i = 1, 15 do
			task.spawn(function()
				local p = Instance.new("Frame", EffectLayer)
				p.Size = UDim2.fromOffset(3, 3); p.BackgroundColor3 = Color3.new(1,1,1)
				Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
				while p.Parent do
					p.Position = UDim2.fromScale(math.random(), math.random()); p.BackgroundTransparency = 1
					Tween(p, {2, Enum.EasingStyle.Sine}, {BackgroundTransparency = 0.4, Position = UDim2.fromScale(p.Position.X.Scale+0.05, p.Position.Y.Scale-0.05)}).Completed:Wait()
				end
			end)
		end

	elseif name == "Galactic Warp" then
		task.spawn(function()
			while EffectLayer.Parent do
				local s = Instance.new("Frame", EffectLayer)
				s.Size = UDim2.fromOffset(1, 1); s.Position = UDim2.fromScale(0.5, 0.5)
				Tween(s, {1, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {Position = UDim2.fromScale(math.random(), math.random()), Size = UDim2.fromOffset(15, 15), BackgroundTransparency = 1})
				game.Debris:AddItem(s, 1)
				task.wait(0.2)
			end
		end)

	elseif name == "Retro Wave Sun" then
		local sun = Instance.new("Frame", EffectLayer)
		sun.Size = UDim2.fromOffset(160, 160); sun.Position = UDim2.new(0.5, -80, 0.5, -80); sun.BackgroundColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", sun).CornerRadius = UDim.new(1, 0)
		local g = Instance.new("UIGradient", sun); g.Rotation = 90
		g.Color = ColorSequence.new(Color3.fromRGB(255, 0, 128), Color3.fromRGB(255, 140, 0))

	elseif name == "Bio-Organic Pulse" then
		local bio = Instance.new("ImageLabel", EffectLayer)
		bio.Size = UDim2.fromScale(0.6, 0.6); bio.Position = UDim2.fromScale(0.5, 0.5); bio.AnchorPoint = Vector2.new(0.5, 0.5)
		bio.Image = "rbxassetid://13110452331"; bio.ImageColor3 = Color3.fromRGB(100, 0, 255); bio.BackgroundTransparency = 1
		task.spawn(function()
			while bio.Parent do
				Tween(bio, {4, Enum.EasingStyle.Sine}, {Size = UDim2.fromScale(1.1, 1.1), ImageTransparency = 0.8}).Completed:Wait()
				Tween(bio, {4, Enum.EasingStyle.Sine}, {Size = UDim2.fromScale(0.6, 0.6), ImageTransparency = 0.4}).Completed:Wait()
			end
		end)

	elseif name == "Cyber Grid 2.0" then
		local grid = Instance.new("ImageLabel", EffectLayer)
		grid.Size = UDim2.fromScale(1, 1); grid.Image = "rbxassetid://6071575925"
		grid.ImageColor3 = Color3.fromRGB(0, 242, 255); grid.ImageTransparency = 0.8; grid.BackgroundTransparency = 1
	end
end







-- Change transparency
local function SetMainTransparency(value)
	Tween(Main, {0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {BackgroundTransparency = value})
end

-- Blur effect
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game.Lighting

local function SetBlur(enabled, intensity)
	if enabled then
		Tween(blur, {0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {Size = intensity or 20})
	else
		Tween(blur, {0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {Size = 0})
	end
end


local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0,18)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 3
MainStroke.Color = Theme.Accent

task.spawn(function()
	while true do
		Tween(MainStroke,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{Color = Theme.Secondary})
		task.wait(2)
		Tween(MainStroke,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{Color = Theme.Accent})
		task.wait(2)
	end
end)

--================ TITLE BAR =================--
local TitleBar = Instance.new("Frame", Main) 
TitleBar.Size = UDim2.new(1,0,0,55) 
TitleBar.BackgroundTransparency = 1 
TitleBar.BorderSizePixel = 0 

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,0,1,0)
Title.Position = UDim2.fromScale(0.5,0.5)
Title.AnchorPoint = Vector2.new(0.5,0.5)
Title.BackgroundTransparency = 1
Title.Text = "NEON OVERDRIVE UI"
Title.Font = Enum.Font.Merriweather
Title.TextSize = 28 -- BIG
Title.TextColor3 = Theme.Accent
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.RichText = true
Title.TextWrapped = true
Title.TextStrokeTransparency = 1
Title.Text = "<i>NEON OVERDRIVE UI</i>"

--================ TITLE NEON ANIMATION =================--
task.spawn(function()
	while true do
		Tween(Title,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			TextColor3 = Theme.Secondary
		})
		task.wait(2)
		Tween(Title,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			TextColor3 = Theme.Accent
		})
		task.wait(2)
	end
end)


local TitleStroke = Instance.new("UIStroke", Title)
TitleStroke.Thickness = 1.5
TitleStroke.Color = Theme.Accent
TitleStroke.Transparency = 0.6

task.spawn(function()
	while true do
		Tween(TitleStroke,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			Color = Theme.Secondary
		})
		task.wait(2)
		Tween(TitleStroke,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{
			Color = Theme.Accent
		})
		task.wait(2)
	end
end)



-- Hover Effekt für das X
CloseX.MouseEnter:Connect(function()
	Tween(CloseX, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {TextColor3 = Theme.Secondary})
end)
CloseX.MouseLeave:Connect(function()
	Tween(CloseX, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {TextColor3 = Theme.Accent})
end)


--================ SUBTITLE "By Zidiu1" =================--
local SubTitle = Instance.new("TextLabel", TitleBar)
SubTitle.Size = UDim2.new(1,0,0,20) 
SubTitle.Position = UDim2.fromOffset(0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "<i>By Zidiu1</i>"
SubTitle.Font = Title.Font 
SubTitle.TextSize = 15
SubTitle.TextColor3 = Theme.Accent
SubTitle.RichText = true
SubTitle.TextStrokeTransparency = 1
SubTitle.TextXAlignment = Enum.TextXAlignment.Center
SubTitle.TextYAlignment = Enum.TextYAlignment.Center

-- Neon-Effekt wie Titel
local SubTitleStroke = Instance.new("UIStroke", SubTitle)
SubTitleStroke.Thickness = 1.5
SubTitleStroke.Color = Theme.Accent
SubTitleStroke.Transparency = 0.6

task.spawn(function()
	while true do
		-- TextColor tween
		Tween(SubTitle,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{TextColor3 = Theme.Secondary})
		-- Stroke tween
		Tween(SubTitleStroke,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{Color = Theme.Secondary})
		task.wait(2)
		Tween(SubTitle,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{TextColor3 = Theme.Accent})
		Tween(SubTitleStroke,{2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut},{Color = Theme.Accent})
		task.wait(2)
	end
end)




--================ DRAG =================--
do
	local dragging, dragStart, startPos
	TitleBar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = Main.Position
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - dragStart
			Main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
		end
	end)
end

--================ TAB BAR =================--
local TabBar = Instance.new("ScrollingFrame", Main)
TabBar.Position = UDim2.fromOffset(10,65)
TabBar.Size = UDim2.new(0,150,1,-75)
TabBar.BackgroundTransparency = 1
TabBar.ScrollBarThickness = 4
TabBar.BorderSizePixel = 0
TabBar.ScrollBarImageColor3 = Theme.Accent
local DEFAULT_SIZE = UDim2.fromScale(0.5, 0.8)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.Padding = UDim.new(0,8)

TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	TabBar.CanvasSize = UDim2.new(0,0,0,TabLayout.AbsoluteContentSize.Y + 10)
end)

--================ PAGES =================--
local Pages = Instance.new("Frame", Main)
Pages.Position = UDim2.fromOffset(170,65)
Pages.Size = UDim2.new(1,-180,1,-75)
Pages.BackgroundTransparency = 1

--================ OPEN / CLOSE ANIMATION =================--
Main.Size = UDim2.fromScale(0.5,0.8)

--================ OPEN / CLOSE ANIMATION (FIXED) =================--
OpenUI = function()
	isOpen = true 
	Main.Visible = true
	local targetSize = SavedWindowSize or DEFAULT_SIZE

	-- X-Logik beim Öffnen
	if CloseX then
		CloseX.Visible = (SwipeZone.Visible == true)
	end

	-- Falls wir im Swipe-Modus sind, Button immer verstecken
	if SwipeZone.Visible then
		OpenButton.Visible = false
	end

	-- Startpunkt für Animation
	Main.Size = UDim2.new(targetSize.X.Scale * 0.9, targetSize.X.Offset, targetSize.Y.Scale * 0.9, targetSize.Y.Offset)
	Main.BackgroundTransparency = 1

	Tween(Main, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
		Size = targetSize,
		BackgroundTransparency = currentTransparency
	})
end

CloseUI = function()
	isOpen = false
	local targetSize = SavedWindowSize or DEFAULT_SIZE

	Tween(Main, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {
		Size = UDim2.new(targetSize.X.Scale * 0.9, targetSize.X.Offset, targetSize.Y.Scale * 0.9, targetSize.Y.Offset),
		BackgroundTransparency = 1
	})

	task.delay(0.25, function()
		if not isOpen then
			Main.Visible = false
			if CloseX then CloseX.Visible = false end

			if SwipeZone.Visible == false then
				OpenButton.Visible = true
			end
		end
	end)
end


--================ LIBRARY =================--
local Library = {}
local CurrentPage, CurrentTab

function Library:CreateTab(name)
	local Elements = {} -- nur einmal definieren
	local orderCounter = 0

	-- TAB BUTTON
	local TabBtn = Instance.new("TextButton", TabBar)
	TabBtn.Size = UDim2.new(0.95,0,0,45)
	TabBtn.Text = "  "..name:upper()
	TabBtn.Font = Theme.Font
	TabBtn.TextSize = 14
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left
	TabBtn.BackgroundColor3 = Theme.Button
	TabBtn.TextColor3 = Theme.DarkText
	Instance.new("UICorner", TabBtn)

	local Indicator = Instance.new("Frame", TabBtn)
	Indicator.Name = "Indicator"
	Indicator.Size = UDim2.new(0,4,0.6,0)
	Indicator.Position = UDim2.new(0,0,0.2,0)
	Indicator.BackgroundColor3 = Theme.Accent
	Indicator.Visible = false

	-- PAGE
	local Page = Instance.new("ScrollingFrame", Pages)
	Page.Size = UDim2.new(1,0,1,0)
	Page.BackgroundTransparency = 1
	Page.ScrollBarThickness = 4
	Page.BorderSizePixel = 0
	Page.ScrollBarImageColor3 = Theme.Accent
	Page.Visible = false

	local Padding = Instance.new("UIPadding", Page)
	Padding.PaddingLeft = UDim.new(0,6)
	Padding.PaddingRight = UDim.new(0,6)
	Padding.PaddingTop = UDim.new(0,6)

	local Layout = Instance.new("UIListLayout", Page)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0,10)

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
	end)

	-- TAB CLICK
	TabBtn.MouseButton1Click:Connect(function()
		if CurrentPage then CurrentPage.Visible = false end
		if CurrentTab then
			CurrentTab.TextColor3 = Theme.DarkText
			CurrentTab.BackgroundColor3 = Theme.Button
			local old = CurrentTab:FindFirstChild("Indicator")
			if old then old.Visible = false end
		end
		Page.Visible = true
		Indicator.Visible = true
		TabBtn.TextColor3 = Theme.Accent
		TabBtn.BackgroundColor3 = Color3.fromRGB(35,35,55)
		CurrentPage = Page
		CurrentTab = TabBtn
	end)

	if not CurrentPage then
		Page.Visible = true
		Indicator.Visible = true
		TabBtn.TextColor3 = Theme.Accent
		CurrentPage = Page
		CurrentTab = TabBtn
	end

	--================ ELEMENT FUNCTIONS =================--

	-- BUTTON
	function Elements:Button(text, callback, tooltip, duration)
		orderCounter += 1

		-- Button UI
		local b = Instance.new("TextButton", Page)
		b.LayoutOrder = orderCounter
		b.Size = UDim2.new(1,0,0,45)
		b.Text = text
		b.Font = Theme.Font
		b.TextSize = 16
		b.BackgroundColor3 = Theme.Button
		b.TextColor3 = Theme.Text
		b.AutoButtonColor = false
		Instance.new("UICorner", b)

		-- Button Objekt
		local Button = {
			_destroyed = false,
			_events = {Clicked = {}},
			_connections = {}
		}

		-- Farben für Hover / Click
		local baseColor = Theme.Button
		local hoverColor = Color3.new(
			math.clamp(baseColor.R + 0.06, 0, 1),
			math.clamp(baseColor.G + 0.06, 0, 1),
			math.clamp(baseColor.B + 0.06, 0, 1)
		)
		local clickColor = Color3.new(
			math.clamp(baseColor.R - 0.06, 0, 1),
			math.clamp(baseColor.G - 0.06, 0, 1),
			math.clamp(baseColor.B - 0.06, 0, 1)
		)

		local hovering = false

		-- Mouse Enter / Leave
		local enterConn = b.MouseEnter:Connect(function()
			if Button._destroyed then return end
			hovering = true
			b.BackgroundColor3 = hoverColor
		end)
		local leaveConn = b.MouseLeave:Connect(function()
			if Button._destroyed then return end
			hovering = false
			b.BackgroundColor3 = baseColor
		end)
		table.insert(Button._connections, enterConn)
		table.insert(Button._connections, leaveConn)

		-- Click Connection mit Effekt und sicherem Callback
		local clickConn = b.MouseButton1Click:Connect(function()
			if Button._destroyed then return end

			-- Sofort Click-Farbe setzen
			b.BackgroundColor3 = clickColor

			-- kurze Verzögerung, dann zurück auf Hover/Base
			task.spawn(function()
				task.wait(0.1)
				if Button._destroyed then return end
				b.BackgroundColor3 = hovering and hoverColor or baseColor
			end)

			-- Hauptcallback
			if callback then pcall(callback) end
			-- alle registrierten Events feuern
			for _, fn in ipairs(Button._events.Clicked) do
				pcall(fn)
			end
		end)
		table.insert(Button._connections, clickConn)

		-- Event API
		function Button:OnClick(fn)
			table.insert(self._events.Clicked, fn)
			local disconnected = false
			return {
				Disconnect = function()
					if disconnected then return end
					disconnected = true
					for i,v in ipairs(self._events.Clicked) do
						if v == fn then
							table.remove(self._events.Clicked, i)
							break
						end
					end
				end
			}
		end

		-- Destroy / Cleanup
		function Button:Destroy()
			if self._destroyed then return end
			self._destroyed = true
			for _,c in ipairs(self._connections) do
				c:Disconnect()
			end
			for _,list in pairs(self._events) do
				table.clear(list)
			end
			b:Destroy()
		end

		Library:AddTooltip(b, tooltip, duration)
		return Button
	end

	-- TOGGLE
	function Elements:Toggle(text, default, callback, tooltip, duration)
		orderCounter += 1

		-- UI
		local button = Instance.new("TextButton", Page)
		button.LayoutOrder = orderCounter
		button.Size = UDim2.new(1,0,0,45)
		button.Font = Theme.Font
		button.TextSize = 16
		button.AutoButtonColor = false
		Instance.new("UICorner", button)

		-- Toggle Object
		local Toggle = {}
		Toggle.state = default == true
		Toggle._destroyed = false

		Toggle._events = {
			Changed = {},
			Enabled = {},
			Disabled = {}
		}
		Toggle._connections = {}

		-- UI Update
		local function refresh()
			if Toggle.state then
				button.Text = text .. " : ON"
				button.BackgroundColor3 = Theme.Accent
				button.TextColor3 = Color3.new(1,1,1)
			else
				button.Text = text .. " : OFF"
				button.BackgroundColor3 = Theme.Button
				button.TextColor3 = Theme.Text
			end
		end

		-- Fire Events
		local function fire(event)
			for _,fn in ipairs(Toggle._events[event]) do
				task.spawn(fn, Toggle.state)
			end
		end

		-- Core Set
		function Toggle:Set(value)
			if Toggle._destroyed then return end
			if Toggle.state == value then return end

			Toggle.state = value
			refresh()
			fire("Changed")

			if value then
				fire("Enabled")
			else
				fire("Disabled")
			end

			-- Initial Callback für Library-Kompatibilität
			if callback then
				pcall(callback, Toggle.state)
			end
		end

		function Toggle:Get()
			return Toggle.state
		end

		-- Event API (mit Disconnect)
		local function register(event, fn)
			local list = Toggle._events[event]
			table.insert(list, fn)

			local disconnected = false
			return {
				Disconnect = function()
					if disconnected then return end
					disconnected = true
					for i,v in ipairs(list) do
						if v == fn then
							table.remove(list, i)
							break
						end
					end
				end
			}
		end

		function Toggle:OnChanged(fn) return register("Changed", fn) end
		function Toggle:OnEnabled(fn) return register("Enabled", fn) end
		function Toggle:OnDisabled(fn) return register("Disabled", fn) end

		-- Button Connection
		table.insert(Toggle._connections,
			button.MouseButton1Click:Connect(function()
				Toggle:Set(not Toggle.state)
			end)
		)

		-- Destroy / Cleanup
		function Toggle:Destroy()
			if Toggle._destroyed then return end
			Toggle._destroyed = true

			for _,c in ipairs(Toggle._connections) do
				c:Disconnect()
			end

			for _,list in pairs(Toggle._events) do
				table.clear(list)
			end

			button:Destroy()
		end

		-- UI initialisieren
		refresh()

		-- 🔹 Callback direkt feuern, damit Default-Wert berücksichtigt wird
		if callback then
			pcall(callback, Toggle.state)
		end

		Library:AddTooltip(button, tooltip, duration)
		return Toggle
	end

	-- TEXT BOX
	function Elements:TextBox(placeholder, callback)
		orderCounter += 1

		-- TextBox UI
		local box = Instance.new("TextBox", Page)
		box.LayoutOrder = orderCounter
		box.Size = UDim2.new(1,0,0,45)
		box.PlaceholderText = placeholder
		box.Font = Theme.Font
		box.TextSize = 16
		box.BackgroundColor3 = Theme.Button
		box.TextColor3 = Theme.Accent
		box.PlaceholderColor3 = Theme.DarkText
		box.ClearTextOnFocus = false
		box.Text = ""
		Instance.new("UICorner", box)

		-- TextBox Objekt
		local TextBox = {
			_destroyed = false,
			_events = {Changed = {}},
			_connections = {}
		}

		-- Haupt-Callback Connection (FocusLost)
		local conn = box.FocusLost:Connect(function(enter)
			if TextBox._destroyed then return end
			if enter and callback then
				pcall(callback, box.Text)
			end
			for _, fn in ipairs(TextBox._events.Changed) do
				pcall(fn, box.Text)
			end
		end)
		table.insert(TextBox._connections, conn)

		-- Live-Update beim Tippen
		local liveConn = box:GetPropertyChangedSignal("Text"):Connect(function()
			if TextBox._destroyed then return end
			for _, fn in ipairs(TextBox._events.Changed) do
				pcall(fn, box.Text)
			end
		end)
		table.insert(TextBox._connections, liveConn)

		-- Event API
		function TextBox:OnChanged(fn)
			table.insert(self._events.Changed, fn)
			local disconnected = false
			return {
				Disconnect = function()
					if disconnected then return end
					disconnected = true
					for i,v in ipairs(self._events.Changed) do
						if v == fn then
							table.remove(self._events.Changed, i)
							break
						end
					end
				end
			}
		end

		-- Get / Set API
		function TextBox:Get()
			return box.Text
		end

		function TextBox:Set(value)
			if self._destroyed then return end
			box.Text = tostring(value)
		end

		-- Destroy / Cleanup
		function TextBox:Destroy()
			if self._destroyed then return end
			self._destroyed = true
			for _, c in ipairs(self._connections) do
				c:Disconnect()
			end
			for _, list in pairs(self._events) do
				table.clear(list)
			end
			box:Destroy()
		end

		return TextBox
	end

	-- DROPDOWN
	function Elements:Dropdown(label, options, callback, multiselect)
		options = options or {}
		multiselect = multiselect or false

		orderCounter += 1
		local container = Instance.new("Frame", Page)
		container.LayoutOrder = orderCounter
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true
		container.Size = UDim2.new(1,0,0,40)

		local title = Instance.new("TextButton", container)
		title.Size = UDim2.new(1,0,0,40)
		title.BackgroundColor3 = Theme.Button
		title.Text = label.." ▼"
		title.Font = Theme.Font
		title.TextSize = 16
		title.TextColor3 = Theme.Text
		title.AutoButtonColor = false
		Instance.new("UICorner", title)

		local optionContainer = Instance.new("Frame", container)
		optionContainer.BackgroundTransparency = 1
		optionContainer.ClipsDescendants = true
		optionContainer.Size = UDim2.new(1,0,0,0)
		optionContainer.Position = UDim2.new(0,0,0,title.Size.Y.Offset + 5)

		local optionLayout = Instance.new("UIListLayout", optionContainer)
		optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		optionLayout.Padding = UDim.new(0,5)

		local optionButtons = {}
		local DropdownObject = {
			opened = false,
			multiselect = multiselect,
			selection = {},
			refreshOnUpdate = false
		}

		-- Build Options
		local function buildOptions()
			for _, btn in ipairs(optionButtons) do btn:Destroy() end
			table.clear(optionButtons)

			for i, opt in ipairs(options) do
				local btnContainer = Instance.new("Frame", optionContainer)
				btnContainer.Size = UDim2.new(1,0,0,30)
				btnContainer.BackgroundTransparency = 1
				btnContainer.LayoutOrder = i

				local btn = Instance.new("TextButton", btnContainer)
				btn.Size = UDim2.new(1,0,1,0)
				btn.BackgroundColor3 = Theme.Button
				btn.TextColor3 = Theme.Text
				btn.Text = tostring(opt)
				btn.Font = Theme.Font
				btn.TextSize = 14
				btn.AutoButtonColor = false
				Instance.new("UICorner", btn)

				local checkbox
				if multiselect then
					DropdownObject.selection[opt] = DropdownObject.selection[opt] or false
					checkbox = Instance.new("Frame", btn)
					checkbox.Size = UDim2.new(0,20,0,20)
					checkbox.Position = UDim2.new(0,5,0.5,-10)
					checkbox.BackgroundColor3 = DropdownObject.selection[opt] and Theme.Accent or Color3.fromRGB(0,0,0)
					checkbox.BorderSizePixel = 1
					Instance.new("UICorner", checkbox)
				end

				btn.MouseButton1Click:Connect(function()
					if multiselect then
						-- Toggle Auswahl
						DropdownObject.selection[opt] = not DropdownObject.selection[opt]
						if checkbox then
							checkbox.BackgroundColor3 = DropdownObject.selection[opt] and Theme.Accent or Color3.fromRGB(0,0,0)
						end
						-- Callback liefert: OptionName, neuer Zustand, aktuelle Auswahl
						if callback then pcall(callback, opt, DropdownObject.selection[opt], DropdownObject.selection) end
					else
						-- Single-Select
						title.Text = label.." ▼ "..tostring(opt)
						DropdownObject.selection = {}  -- vorherige Auswahl löschen
						DropdownObject.selection[opt] = true
						if callback then pcall(callback, opt, true, DropdownObject.selection) end
						DropdownObject.opened = false
						Tween(optionContainer,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size = UDim2.new(1,0,0,0)})
					end
				end)

				table.insert(optionButtons, btnContainer)
			end
		end

		buildOptions()


		-- Open/Close
		title.MouseButton1Click:Connect(function()
			DropdownObject.opened = not DropdownObject.opened
			local totalHeight = 0
			for _, btn in ipairs(optionButtons) do
				totalHeight += btn.Size.Y.Offset
			end

			local padding = (#optionButtons > 1) and (#optionButtons - 1) * 5 or 0
			if DropdownObject.opened then
				-- Extra 5px am unteren Rand für sauberes Design
				totalHeight += padding + 5
			else
				totalHeight = 0
			end

			Tween(optionContainer,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size = UDim2.new(1,0,0,totalHeight)})
			title.Text = label..(DropdownObject.opened and " ▲" or " ▼")
		end)



		-- Auto container height (nur AbsoluteSize)
		optionContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			container.Size = UDim2.new(1,0,0, title.Size.Y.Offset + optionContainer.AbsoluteSize.Y)
		end)


		-- API
		function DropdownObject:SetOptions(newOptions)
			options = newOptions or {}
			if multiselect then
				for k,_ in pairs(DropdownObject.selection) do DropdownObject.selection[k] = false end
			end
			if self.refreshOnUpdate then buildOptions() end
		end

		function DropdownObject:GetOptions()
			return options
		end

		function DropdownObject:Refresh()
			buildOptions()
		end

		return DropdownObject
	end

	-- DROPDOWN SEARCH
	function Elements:DropdownSearch(label, options, callback, multiselect)
		options = options or {}
		multiselect = multiselect or false

		local RunService = game:GetService("RunService")
		orderCounter += 1

		local container = Instance.new("Frame", Page)
		container.LayoutOrder = orderCounter
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true
		container.Size = UDim2.new(1,0,0,40)

		-- TITLE BUTTON
		local title = Instance.new("TextButton", container)
		title.Size = UDim2.new(1,0,0,40)
		title.BackgroundColor3 = Theme.Button
		title.Text = label.." ▼"
		title.Font = Theme.Font
		title.TextSize = 16
		title.TextColor3 = Theme.Text
		title.AutoButtonColor = false
		Instance.new("UICorner", title)

		-- DROPDOWN BODY
		local body = Instance.new("Frame", container)
		body.BackgroundTransparency = 1
		body.ClipsDescendants = true
		body.Size = UDim2.new(1,0,0,0)
		body.Position = UDim2.new(0,0,0,45)

		-- SEARCH BOX
		local search = Instance.new("TextBox", body)
		search.Size = UDim2.new(1,0,0,32)
		search.PlaceholderText = "Search..."
		search.Text = ""
		search.Font = Theme.FontSecondary
		search.TextSize = 14
		search.BackgroundColor3 = Theme.Button
		search.TextColor3 = Theme.Accent
		search.PlaceholderColor3 = Theme.DarkText
		search.ClearTextOnFocus = false
		Instance.new("UICorner", search)

		-- OPTIONS HOLDER
		local optionHolder = Instance.new("Frame", body)
		optionHolder.BackgroundTransparency = 1
		optionHolder.Position = UDim2.new(0,0,0,38)
		optionHolder.Size = UDim2.new(1,0,0,0)

		local layout = Instance.new("UIListLayout", optionHolder)
		layout.Padding = UDim.new(0,5)

		local Dropdown = {
			opened = false,
			multiselect = multiselect,
			options = options,
			selection = {}
		}

		local optionButtons = {}
		local animating = false -- Nur für Height Tween

		-- FUNCTION: update heights (spam-sicher nur Animation)
		local function updateBodyHeight()
			-- Warte, bis Layoutsize korrekt ist
			RunService.Heartbeat:Wait()
			local waitTime = 0
			repeat
				waitTime += RunService.Heartbeat:Wait()
			until layout.AbsoluteContentSize.Y > 0 or waitTime > 0.1 -- max 0.1 Sek warten

			local contentHeight = layout.AbsoluteContentSize.Y
			local totalHeight = 38 + contentHeight + 5

			optionHolder.Size = UDim2.new(1,0,0,contentHeight)
			Tween(body, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {Size = UDim2.new(1,0,0,totalHeight)})
		end


		-- BUILD OPTIONS
		local function build(filter)
			for _,v in ipairs(optionButtons) do v:Destroy() end
			table.clear(optionButtons)

			filter = filter and filter:lower() or ""

			for i,opt in ipairs(options) do
				if filter == "" or tostring(opt):lower():find(filter) then
					local row = Instance.new("Frame", optionHolder)
					row.Size = UDim2.new(1,0,0,30)
					row.BackgroundTransparency = 1

					local btn = Instance.new("TextButton", row)
					btn.Size = UDim2.new(1,0,1,0)
					btn.BackgroundColor3 = Theme.Button
					btn.TextColor3 = Theme.Text
					btn.Text = tostring(opt)
					btn.Font = Theme.Font
					btn.TextSize = 14
					btn.AutoButtonColor = false
					Instance.new("UICorner", btn)

					local checkbox
					if multiselect then
						Dropdown.selection[opt] = Dropdown.selection[opt] or false
						checkbox = Instance.new("Frame", btn)
						checkbox.Size = UDim2.new(0,18,0,18)
						checkbox.Position = UDim2.new(0,6,0.5,-9)
						checkbox.BackgroundColor3 = Dropdown.selection[opt] and Theme.Accent or Color3.fromRGB(0,0,0)
						checkbox.BorderSizePixel = 1
						Instance.new("UICorner", checkbox)
					end

					btn.MouseButton1Click:Connect(function()
						if multiselect then
							Dropdown.selection[opt] = not Dropdown.selection[opt]
							if checkbox then
								checkbox.BackgroundColor3 = Dropdown.selection[opt] and Theme.Accent or Color3.fromRGB(0,0,0)
							end
							if callback then pcall(callback, opt, Dropdown.selection[opt], Dropdown.selection) end
						else
							title.Text = label.." ▼ "..tostring(opt)
							if callback then pcall(callback, opt, true, { [opt]=true }) end
							Dropdown.opened = false
							Tween(body,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size=UDim2.new(1,0,0,0)})
						end
					end)

					table.insert(optionButtons, row)
				end
			end

			-- Update nur wenn Dropdown geöffnet
			if Dropdown.opened then
				updateBodyHeight()
			else
				body.Size = UDim2.new(1,0,0,0)
				optionHolder.Size = UDim2.new(1,0,0,0)
			end
		end

		build()

		-- SEARCH FILTER
		search:GetPropertyChangedSignal("Text"):Connect(function()
			build(search.Text)
		end)

		-- OPEN / CLOSE
		title.MouseButton1Click:Connect(function()
			Dropdown.opened = not Dropdown.opened
			title.Text = label..(Dropdown.opened and " ▲" or " ▼")
			build(search.Text)
		end)

		-- AUTO HEIGHT
		body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			container.Size = UDim2.new(1,0,0,40 + body.AbsoluteSize.Y)
		end)

		-- API
		function Dropdown:SetOptions(new)
			options = new or {}
			self.options = options
			build(search.Text)
		end

		function Dropdown:GetOptions()
			return options
		end

		function Dropdown:Refresh()
			build(search.Text)
		end

		return Dropdown
	end

	-- FULL RGB PICKER
	function Elements:FullRGBPicker(label, defaultColor, callback)
		orderCounter += 1
		local container = Instance.new("Frame", Page)
		container.Size = UDim2.new(1, 0, 0, 40) -- nur Button-Höhe
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true
		container.LayoutOrder = orderCounter

		-- Button
		local title = Instance.new("TextButton", container)
		title.Size = UDim2.new(1, 0, 0, 40)
		title.BackgroundColor3 = Theme.Button
		title.Text = label.." ▼"
		title.Font = Theme.Font
		title.TextSize = 16
		title.TextColor3 = Theme.Text
		title.AutoButtonColor = false
		Instance.new("UICorner", title)

		-- Farbvorschau
		local colorPreview = Instance.new("Frame", title)
		colorPreview.Size = UDim2.new(0, 25, 0, 25)
		colorPreview.Position = UDim2.new(1, -30, 0.5, -12.5)
		colorPreview.BackgroundColor3 = defaultColor
		colorPreview.BorderSizePixel = 0
		Instance.new("UICorner", colorPreview)

		-- Picker Container
		local pickerContainer = Instance.new("Frame", container)
		pickerContainer.Size = UDim2.new(1, 0, 0, 160)
		pickerContainer.Position = UDim2.new(0, 0, 0, 40)
		pickerContainer.BackgroundColor3 = Theme.Button
		pickerContainer.ClipsDescendants = true
		Instance.new("UICorner", pickerContainer)
		pickerContainer.Visible = false

		-- Color Circle
		local pickerCircle = Instance.new("ImageLabel", pickerContainer)
		pickerCircle.Size = UDim2.new(0, 145, 0, 145)
		pickerCircle.Position = UDim2.new(0, 3, 0.03, 0)
		pickerCircle.BackgroundTransparency = 1
		pickerCircle.Image = "rbxassetid://99441834088327"
		pickerCircle.ScaleType = Enum.ScaleType.Fit

		-- Slider
		local sliderContainer = Instance.new("Frame", pickerContainer)
		sliderContainer.Size = UDim2.new(0, 30, 0, 145)
		sliderContainer.Position = UDim2.new(0, 180, 0.03, 0)
		sliderContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		Instance.new("UICorner", sliderContainer)

		local sliderFill = Instance.new("Frame", sliderContainer)
		sliderFill.Size = UDim2.new(1, 0, 1, 0)
		sliderFill.BackgroundColor3 = Color3.new(1, 1, 1)
		Instance.new("UICorner", sliderFill)

		-- Cursor
		local cursor = Instance.new("Frame", pickerCircle)
		cursor.Size = UDim2.new(0, 10, 0, 10)
		cursor.AnchorPoint = Vector2.new(0.5, 0.5)
		cursor.BackgroundColor3 = Color3.new(1, 1, 1)
		cursor.BorderSizePixel = 0
		Instance.new("UICorner", cursor)
		cursor.Position = UDim2.new(0.5, 0, 0.5, 0)

		local opened = false
		local draggingCircle, draggingSlider = false, false
		local hue, sat, val = 0, 1, 1

		local function HSVtoRGB(h, s, v)
			local i = math.floor(h * 6)
			local f = h * 6 - i
			local p = v * (1 - s)
			local q = v * (1 - f * s)
			local t = v * (1 - (1 - f) * s)
			i = i % 6
			if i == 0 then return Color3.new(v, t, p) end
			if i == 1 then return Color3.new(q, v, p) end
			if i == 2 then return Color3.new(p, v, t) end
			if i == 3 then return Color3.new(p, q, v) end
			if i == 4 then return Color3.new(t, p, v) end
			return Color3.new(v, p, q)
		end

		local function updateColor()
			local color = HSVtoRGB(hue, sat, val)
			colorPreview.BackgroundColor3 = color
			pcall(callback, color)
		end

		-- Toggle Picker
		title.MouseButton1Click:Connect(function()
			opened = not opened
			pickerContainer.Visible = opened
			title.Text = label..(opened and " ▲" or " ▼")
			container.Size = UDim2.new(1, 0, 0, 40 + (opened and 160 or 0))
		end)

		local UIS = game:GetService("UserInputService")
		local currentInput = nil

		local function startDrag(input, isCircle)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				currentInput = input
				if isCircle then draggingCircle = true else draggingSlider = true end
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						draggingCircle = false
						draggingSlider = false
						currentInput = nil
					end
				end)
			end
		end

		local function dragUpdate(input)
			if not currentInput then return end
			local mx, my = input.Position.X, input.Position.Y

			if draggingCircle then
				local localPos = Vector2.new(mx - pickerCircle.AbsolutePosition.X, my - pickerCircle.AbsolutePosition.Y)
				local nx = (localPos.X / pickerCircle.AbsoluteSize.X - 0.5) * 2
				local ny = (localPos.Y / pickerCircle.AbsoluteSize.Y - 0.5) * 2
				local r = math.sqrt(nx * nx + ny * ny)
				if r <= 1 then
					local angle = math.atan2(ny, nx)
					if angle < 0 then angle += math.pi * 2 end
					hue = angle / (math.pi * 2)
					sat = math.clamp(r, 0, 1)
					cursor.Position = UDim2.fromScale(localPos.X / pickerCircle.AbsoluteSize.X, localPos.Y / pickerCircle.AbsoluteSize.Y)
					updateColor()
				end
			end

			if draggingSlider then
				local y = math.clamp(my - sliderContainer.AbsolutePosition.Y, 0, sliderContainer.AbsoluteSize.Y)
				val = 1 - y / sliderContainer.AbsoluteSize.Y
				sliderFill.Size = UDim2.new(1, 0, y / sliderContainer.AbsoluteSize.Y, 0)
				updateColor()
			end
		end

		pickerCircle.InputBegan:Connect(function(input) startDrag(input, true) end)
		sliderContainer.InputBegan:Connect(function(input) startDrag(input, false) end)
		UIS.InputChanged:Connect(dragUpdate)
	end

	-- SLIDER
	function Elements:Slider(label, min, max, default, callback, precision, tooltip, duration)
		precision = precision or 0
		orderCounter += 1

		-- Container
		local Container = Instance.new("Frame", Page)
		Container.LayoutOrder = orderCounter
		Container.Size = UDim2.new(1,0,0,60)
		Container.BackgroundTransparency = 1

		-- Label
		local TextLabel = Instance.new("TextLabel", Container)
		TextLabel.Size = UDim2.new(1, -50, 0, 20)
		TextLabel.Position = UDim2.new(0,0,0,0)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Font = Theme.Font
		TextLabel.TextSize = 16
		TextLabel.TextColor3 = Theme.Text
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Slider Frame
		local SliderFrame = Instance.new("Frame", Container)
		SliderFrame.Size = UDim2.new(1, -50, 0, 10)
		SliderFrame.Position = UDim2.new(0,0,0,30)
		SliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,70)
		SliderFrame.BorderSizePixel = 0
		Instance.new("UICorner", SliderFrame)

		-- Slider Fill
		local SliderFill = Instance.new("Frame", SliderFrame)
		SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
		SliderFill.BackgroundColor3 = Theme.Accent
		SliderFill.BorderSizePixel = 0
		Instance.new("UICorner", SliderFill)

		-- Toggle Button
		local ToggleBtn = Instance.new("TextButton", Container)
		ToggleBtn.Size = UDim2.new(0,40,0,30)
		ToggleBtn.Position = UDim2.new(1,-45,0,15)
		ToggleBtn.Text = "ON"
		ToggleBtn.Font = Theme.Font
		ToggleBtn.TextSize = 14
		ToggleBtn.BackgroundColor3 = Theme.Button
		ToggleBtn.TextColor3 = Theme.Text
		Instance.new("UICorner", ToggleBtn)

		local Slider = {
			_value = default,
			_enabled = true,
			_destroyed = false,
			_connections = {}
		}

		-- Präzisions-Funktion
		local function round(val)
			local mult = 10 ^ precision
			return math.floor(val * mult + 0.5) / mult
		end

		-- UI Update
		local function refreshUI()
			local displayVal = round(Slider._value)
			TextLabel.Text = label.." : "..tostring(displayVal)
			SliderFill.Size = UDim2.new((Slider._value - min)/(max - min), 0, 1, 0)
		end

		-- Dragging
		local dragging = false
		local function updateSlider(inputX)
			if not Slider._enabled then return end -- Slider kann nur gezogen werden, wenn aktiv
			local x = math.clamp(inputX - SliderFrame.AbsolutePosition.X, 0, SliderFrame.AbsoluteSize.X)
			local val = min + (x / SliderFrame.AbsoluteSize.X) * (max - min)
			Slider._value = val
			refreshUI()
			if callback then
				pcall(callback, Slider._value)
			end
		end

		-- Input Connections
		table.insert(Slider._connections, SliderFrame.InputBegan:Connect(function(input)
			if not Slider._enabled then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				updateSlider(input.Position.X)
				local conn
				conn = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						conn:Disconnect()
					end
				end)
			end
		end))

		table.insert(Slider._connections, game:GetService("UserInputService").InputChanged:Connect(function(input)
			if dragging and Slider._enabled and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input.Position.X)
			end
		end))

		-- Toggle Button
		ToggleBtn.MouseButton1Click:Connect(function()
			Slider._enabled = not Slider._enabled
			if Slider._enabled then
				ToggleBtn.Text = "ON"
				ToggleBtn.BackgroundColor3 = Theme.Button
				ToggleBtn.TextColor3 = Theme.Text
			else
				ToggleBtn.Text = "OFF"
				ToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
				ToggleBtn.TextColor3 = Color3.fromRGB(120,120,120)
			end

			-- 🔹 Callback immer mit aktuellem Wert, nie nil
			if callback then
				pcall(callback, Slider._value)
			end
		end)

		-- API
		function Slider:Set(value)
			if Slider._destroyed then return end
			Slider._value = math.clamp(value, min, max)
			refreshUI()
			if callback then
				pcall(callback, Slider._value)
			end
		end

		function Slider:Get()
			return Slider._value
		end

		function Slider:Enable()
			if Slider._destroyed then return end
			Slider._enabled = true
			ToggleBtn.Text = "ON"
			ToggleBtn.BackgroundColor3 = Theme.Button
			ToggleBtn.TextColor3 = Theme.Text
			if callback then pcall(callback, Slider._value) end
		end

		function Slider:Disable()
			if Slider._destroyed then return end
			Slider._enabled = false
			ToggleBtn.Text = "OFF"
			ToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
			ToggleBtn.TextColor3 = Color3.fromRGB(120,120,120)
			if callback then pcall(callback, Slider._value) end
		end

		function Slider:Destroy()
			if Slider._destroyed then return end
			Slider._destroyed = true
			for _,c in ipairs(Slider._connections) do
				c:Disconnect()
			end
			Container:Destroy()
			ToggleBtn:Destroy()
		end

		refreshUI()

		-- 🔹 Default Callback direkt feuern
		if callback then
			pcall(callback, default)
		end

		Library:AddTooltip(Container, tooltip, duration)
		return Slider
	end

	-- DUAL SLIDER (MIN & MAX) + TEXT-INPUT
	function Elements:DualSlider(label, min, max, defaultMin, defaultMax, callback, tooltip, duration)
		orderCounter += 1

		-- Container
		local Container = Instance.new("Frame", Page)
		Container.LayoutOrder = orderCounter
		Container.Size = UDim2.new(1, 0, 0, 70)
		Container.BackgroundTransparency = 1

		-- Label (Titel)
		local TextLabel = Instance.new("TextLabel", Container)
		TextLabel.Size = UDim2.new(1, -110, 0, 20)
		TextLabel.Position = UDim2.new(0, 0, 0, 5)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Font = Theme.Font
		TextLabel.TextSize = 15
		TextLabel.TextColor3 = Theme.Text
		TextLabel.Text = label:upper()
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Hilfsfunktion für Input-Felder
		local function createInput(pos, val)
			local box = Instance.new("TextBox", Container)
			box.Size = UDim2.new(0, 45, 0, 22)
			box.Position = pos
			box.BackgroundColor3 = Theme.Button
			box.TextColor3 = Theme.Accent
			box.Font = Theme.Font
			box.TextSize = 13
			box.Text = tostring(val)
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
			local s = Instance.new("UIStroke", box)
			s.Color = Theme.Accent
			s.Thickness = 1
			s.Transparency = 0.7
			return box
		end

		local inputMin = createInput(UDim2.new(1, -105, 0, 4), defaultMin)
		local inputMax = createInput(UDim2.new(1, -55, 0, 4), defaultMax)

		-- Schiene
		local SliderFrame = Instance.new("Frame", Container)
		SliderFrame.Size = UDim2.new(1, -20, 0, 6)
		SliderFrame.Position = UDim2.new(0, 10, 0, 45)
		SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		SliderFrame.BorderSizePixel = 0
		Instance.new("UICorner", SliderFrame)

		local Fill = Instance.new("Frame", SliderFrame)
		Fill.BackgroundColor3 = Theme.Accent
		Fill.BorderSizePixel = 0
		Instance.new("UICorner", Fill)

		-- Buttons
		local function createKnob()
			local btn = Instance.new("TextButton", SliderFrame)
			btn.Size = UDim2.new(0, 16, 0, 16)
			btn.AnchorPoint = Vector2.new(0.5, 0.5)
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btn.Text = ""
			Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
			local st = Instance.new("UIStroke", btn)
			st.Color = Theme.Accent
			st.Thickness = 2
			return btn
		end

		local btnMin = createKnob()
		local btnMax = createKnob()

		local DualSlider = {
			minVal = defaultMin,
			maxVal = defaultMax
		}

		local function updateUI(skipInput)
			local relMin = (DualSlider.minVal - min) / (max - min)
			local relMax = (DualSlider.maxVal - min) / (max - min)

			btnMin.Position = UDim2.fromScale(relMin, 0.5)
			btnMax.Position = UDim2.fromScale(relMax, 0.5)
			Fill.Position = UDim2.fromScale(relMin, 0)
			Fill.Size = UDim2.fromScale(relMax - relMin, 1)

			if not skipInput then
				inputMin.Text = tostring(DualSlider.minVal)
				inputMax.Text = tostring(DualSlider.maxVal)
			end
		end

		-- Slider Dragging
		local function setupDrag(button, isMin)
			local dragging = false
			button.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
			end)
			game:GetService("UserInputService").InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local posX = math.clamp(input.Position.X - SliderFrame.AbsolutePosition.X, 0, SliderFrame.AbsoluteSize.X)
					local rawVal = math.floor(min + (posX / SliderFrame.AbsoluteSize.X) * (max - min))

					if isMin then
						DualSlider.minVal = math.clamp(rawVal, min, DualSlider.maxVal - 1)
					else
						DualSlider.maxVal = math.clamp(rawVal, DualSlider.minVal + 1, max)
					end
					updateUI()
					if callback then pcall(callback, DualSlider.minVal, DualSlider.maxVal) end
				end
			end)
			game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
		end

		setupDrag(btnMin, true)
		setupDrag(btnMax, false)

		-- Text-Input Logik
		local function handleInput(box, isMin)
			box.FocusLost:Connect(function()
				local num = tonumber(box.Text)
				if num then
					if isMin then
						DualSlider.minVal = math.clamp(math.floor(num), min, DualSlider.maxVal - 1)
					else
						DualSlider.maxVal = math.clamp(math.floor(num), DualSlider.minVal + 1, max)
					end
				end
				updateUI()
				if callback then pcall(callback, DualSlider.minVal, DualSlider.maxVal) end
			end)
		end

		handleInput(inputMin, true)
		handleInput(inputMax, false)

		-- Tooltip
		Library:AddTooltip(Container, tooltip, duration)

		updateUI()
		return DualSlider
	end

	-- LABEL
	function Elements:Label(text)
		orderCounter += 1
		local container = Instance.new("Frame", Page)
		container.LayoutOrder = orderCounter
		container.Size = UDim2.new(1,0,0,30)
		container.BackgroundTransparency = 1

		local lbl = Instance.new("TextLabel", container)
		lbl.Size = UDim2.new(1,0,1,0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.Font = Theme.Font
		lbl.TextSize = 16
		lbl.TextColor3 = Theme.Text
		lbl.TextXAlignment = Enum.TextXAlignment.Left

		return lbl
	end

	-- KEYBIND
	function Elements:Keybind(label, defaultKey, callback)
		orderCounter += 1

		local button = Instance.new("TextButton", Page)
		button.LayoutOrder = orderCounter
		button.Size = UDim2.new(1,0,0,45)
		button.Font = Theme.Font or Enum.Font.SourceSans
		button.TextSize = 16
		button.TextColor3 = Theme.Text or Color3.new(1,1,1)
		button.BackgroundColor3 = Theme.Button or Color3.fromRGB(50,50,50)
		button.AutoButtonColor = false
		button.Text = label.." : "..tostring(defaultKey)
		Instance.new("UICorner", button)

		local Keybind = {
			key = defaultKey,
			_listening = false,
			_destroyed = false,
			_connections = {},
			_events = {Changed = {}}
		}

		local UserInputService = game:GetService("UserInputService")

		local function refresh()
			if Keybind._listening then
				button.Text = label.." : <Press Key>"
				button.TextColor3 = Color3.fromRGB(0,170,255)
			else
				button.Text = label.." : "..tostring(Keybind.key)
				button.TextColor3 = Theme.Text or Color3.new(1,1,1)
			end
		end

		-- Button Click -> Start Listening
		table.insert(Keybind._connections, button.MouseButton1Click:Connect(function()
			if Keybind._destroyed then return end
			Keybind._listening = true
			refresh()
		end))

		-- Listen for Key Press without blocking
		table.insert(Keybind._connections, UserInputService.InputBegan:Connect(function(input, processed)
			if Keybind._destroyed then return end
			if Keybind._listening and input.UserInputType == Enum.UserInputType.Keyboard then
				Keybind.key = input.KeyCode.Name
				Keybind._listening = false
				refresh()
				if callback then
					local success, err = pcall(callback, Keybind.key)
					if not success then warn(err) end
				end

				for _,fn in ipairs(Keybind._events.Changed) do
					pcall(fn, Keybind.key)
				end
			end
		end))

		-- API
		function Keybind:Set(newKey)
			if Keybind._destroyed then return end
			Keybind.key = newKey
			refresh()
			if callback then pcall(callback, Keybind.key) end
		end

		function Keybind:Get()
			return Keybind.key
		end

		function Keybind:OnChanged(fn)
			table.insert(Keybind._events.Changed, fn)
			local disconnected = false
			return {
				Disconnect = function()
					if disconnected then return end
					disconnected = true
					for i,v in ipairs(self._events.Changed) do
						if v == fn then
							table.remove(self._events.Changed, i)
							break
						end
					end
				end
			}
		end

		function Keybind:Destroy()
			if Keybind._destroyed then return end
			Keybind._destroyed = true
			for _,c in ipairs(Keybind._connections) do
				c:Disconnect()
			end
			for _,list in pairs(Keybind._events) do
				table.clear(list)
			end
			button:Destroy()
		end

		refresh()
		return Keybind
	end

	-- COLLAPSIBLE SECTION (WITH 1PX DYNAMIC BORDER)
	function Elements:Section(title, defaultOpened)
		orderCounter += 1
		local opened = (defaultOpened ~= nil) and defaultOpened or true

		-- Haupt Container
		local sectionContainer = Instance.new("Frame", Page)
		sectionContainer.LayoutOrder = orderCounter
		sectionContainer.Size = UDim2.new(1, 0, 0, 40)
		sectionContainer.BackgroundTransparency = 1
		sectionContainer.ClipsDescendants = true

		-- Header Button
		local header = Instance.new("TextButton", sectionContainer)
		header.Size = UDim2.new(1, -2, 0, 33)
		header.Position = UDim2.new(0,1,0,1)
		header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		header.BackgroundTransparency = 0.2
		header.Text = ""
		header.AutoButtonColor = false
		Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

		-- 2PX DYNAMISCHER RAHMEN
		local stroke = Instance.new("UIStroke", header)
		stroke.Color = Theme.Accent
		stroke.Thickness = 1 -- 2px wie gewünscht
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Transparency = 0.4

		local sectionTitle = Instance.new("TextLabel", header)
		sectionTitle.Size = UDim2.new(1, -40, 1, 0)
		sectionTitle.Position = UDim2.new(0, 12, 0, 0)
		sectionTitle.BackgroundTransparency = 1
		sectionTitle.Text = "<b>" .. title:upper() .. "</b>"
		sectionTitle.Font = Theme.Font
		sectionTitle.TextSize = 14
		sectionTitle.TextColor3 = Theme.Accent
		sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
		sectionTitle.RichText = true

		local arrow = Instance.new("TextLabel", header)
		arrow.Size = UDim2.new(0, 35, 1, 0)
		arrow.Position = UDim2.new(1, -35, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = opened and "▼" or "▲"
		arrow.Font = Theme.Font
		arrow.TextSize = 12
		arrow.TextColor3 = Theme.Accent

		-- Content Holder
		local content = Instance.new("Frame", sectionContainer)
		content.Position = UDim2.new(0, 5, 0, 40)
		content.Size = UDim2.new(1, -10, 0, 0)
		content.BackgroundTransparency = 1

		local contentLayout = Instance.new("UIListLayout", content)
		contentLayout.Padding = UDim.new(0, 8)
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local SectionElements = {}

		-- AUTOMATISCHE FARB-ANIMATION (Titel, Pfeil & 2px Rahmen)
		task.spawn(function()
			while sectionContainer.Parent do
				-- Phase 1: Zu Secondary
				Tween(sectionTitle, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {TextColor3 = Theme.Secondary})
				Tween(arrow, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {TextColor3 = Theme.Secondary})
				Tween(stroke, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {Color = Theme.Secondary})
				task.wait(2)
				-- Phase 2: Zurück zu Accent
				Tween(sectionTitle, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {TextColor3 = Theme.Accent})
				Tween(arrow, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {TextColor3 = Theme.Accent})
				Tween(stroke, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {Color = Theme.Accent})
				task.wait(2)
			end
		end)

		local function updateSectionHeight()
			if opened then
				local targetHeight = contentLayout.AbsoluteContentSize.Y + 45
				Tween(sectionContainer, {0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, targetHeight)})
				arrow.Text = "▼"
			else
				Tween(sectionContainer, {0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {Size = UDim2.new(1, 0, 0, 40)})
				arrow.Text = "▲"
			end
		end

		header.MouseButton1Click:Connect(function()
			opened = not opened
			updateSectionHeight()
		end)

		contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if opened then updateSectionHeight() end
		end)

		-- Verknüpfung der Elemente für Nested UI
		for name, func in pairs(Elements) do
			if name ~= "Section" then
				SectionElements[name] = function(self, ...)
					local oldPage = Page
					Page = content
					local element = func(Elements, ...)
					Page = oldPage
					return element
				end
			end
		end

		task.delay(0.1, updateSectionHeight)
		return SectionElements
	end

	-- TOOLTIP
	function Library:AddTooltip(parent, infoText, duration)
		if not infoText or infoText == "" then return end

		local showTime = duration or 5

		-- Der "?" Button
		local helpBtn = Instance.new("TextButton", parent)
		helpBtn.Size = UDim2.new(0, 18, 0, 18)
		helpBtn.Position = UDim2.new(1, -25, 0, 5)
		helpBtn.BackgroundColor3 = Theme.Button
		helpBtn.Text = "?"
		helpBtn.Font = Theme.Font
		helpBtn.TextSize = 12
		helpBtn.TextColor3 = Theme.Accent
		helpBtn.ZIndex = 10
		Instance.new("UICorner", helpBtn).CornerRadius = UDim.new(1, 0)

		local stroke = Instance.new("UIStroke", helpBtn)
		stroke.Color = Theme.Accent
		stroke.Thickness = 1
		stroke.Transparency = 0.5

		-- Das Info-Label (Nachricht)
		local infoLabel = Instance.new("TextLabel", parent)
		infoLabel.Size = UDim2.new(1, -10, 0, 35)
		infoLabel.Position = UDim2.new(0, 5, 0, 5)
		infoLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
		infoLabel.TextColor3 = Color3.new(1,1,1)
		infoLabel.Text = infoText
		infoLabel.Font = Theme.Font
		infoLabel.TextSize = 13
		infoLabel.ZIndex = 20 -- Über allem anderen
		infoLabel.Visible = false
		infoLabel.ClipsDescendants = true -- Wichtig für die Ecken des Balkens
		Instance.new("UICorner", infoLabel)

		-- Der Fortschrittsbalken (Direkt im Info-Label)
		local progressBar = Instance.new("Frame", infoLabel)
		progressBar.ZIndex = 21 -- Über dem TextLabel-Hintergrund
		progressBar.Size = UDim2.new(1, 0, 0, 3) -- 3px hoch
		progressBar.Position = UDim2.new(0, 0, 1, -3) -- Ganz unten bündig
		progressBar.BackgroundColor3 = Theme.Accent
		progressBar.BorderSizePixel = 0

		-- Pulsieren Logik (Help Button)
		task.spawn(function()
			while helpBtn.Parent do
				Tween(helpBtn, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {TextColor3 = Theme.Secondary})
				Tween(stroke, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {Color = Theme.Secondary})
				task.wait(2)
				Tween(helpBtn, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {TextColor3 = Theme.Accent})
				Tween(stroke, {2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut}, {Color = Theme.Accent})
				task.wait(2)
			end
		end)

		local showing = false
		helpBtn.MouseButton1Click:Connect(function()
			if showing then return end
			showing = true

			-- Reset & Anzeigen
			infoLabel.Visible = true
			infoLabel.BackgroundTransparency = 1
			infoLabel.TextTransparency = 1
			progressBar.BackgroundTransparency = 1
			progressBar.Size = UDim2.new(1, 0, 0, 3) 

			-- Einblenden Animation
			Tween(infoLabel, {0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundTransparency = 0, TextTransparency = 0})
			Tween(progressBar, {0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundTransparency = 0})

			-- Balken läuft ab
			Tween(progressBar, {showTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In}, {
				Size = UDim2.new(0, 0, 0, 3),
				BackgroundColor3 = Theme.Secondary
			})

			task.wait(showTime)

			-- Ausblenden Animation
			Tween(infoLabel, {0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundTransparency = 1, TextTransparency = 1})
			Tween(progressBar, {0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {BackgroundTransparency = 1})

			task.wait(0.3)
			infoLabel.Visible = false
			showing = false
		end)
	end



	--================ NOTIFICATION TOAST SYSTEM =================--

	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local TextService = game:GetService("TextService")
	local Player = game.Players.LocalPlayer

	local NotificationService = {}

	local ToastGui = Player:FindFirstChild("CyberpunkNotifications") or Instance.new("ScreenGui")
	ToastGui.Name = "CyberpunkNotifications"
	ToastGui.ResetOnSpawn = false
	ToastGui.IgnoreGuiInset = true
	ToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	ToastGui.Parent = Player:WaitForChild("PlayerGui")

	local ToastHolder = ToastGui:FindFirstChild("ToastHolder") or Instance.new("Frame")
	ToastHolder.Name = "ToastHolder"
	ToastHolder.AnchorPoint = Vector2.new(1,1)
	ToastHolder.Position = UDim2.new(1,-20,1,-20)
	ToastHolder.Size = UDim2.new(0,340,1,0)
	ToastHolder.BackgroundTransparency = 1
	ToastHolder.Parent = ToastGui

	local layout = ToastHolder:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", ToastHolder)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Padding = UDim.new(0,10)

	local function tweenGui(obj, props, time, style, dir)
		style = style or Enum.EasingStyle.Quad
		dir = dir or Enum.EasingDirection.Out
		local tween = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
		tween:Play()
		return tween
	end

	local ToastColors = Theme.Toast or {
		Info    = Theme.Accent,
		Success = Color3.fromRGB(0,200,120),
		Warning = Color3.fromRGB(255,180,0),
		Error   = Color3.fromRGB(255,80,80)
	}

	function NotificationService:Notify(title, message, nType, duration)
		nType = nType or "Info"
		duration = duration or 3

		local toast = Instance.new("Frame")
		toast.Size = UDim2.new(1,0,0,1)
		toast.BackgroundColor3 = Theme.Button
		toast.BorderSizePixel = 0
		toast.ClipsDescendants = true
		toast.ZIndex = 100
		toast.Parent = ToastHolder
		Instance.new("UICorner", toast)

		local accent = Instance.new("Frame", toast)
		accent.Size = UDim2.new(0,4,1,0)
		accent.BackgroundColor3 = ToastColors[nType] or Theme.Accent
		accent.BorderSizePixel = 0
		accent.ZIndex = 101

		local titleLabel = Instance.new("TextLabel", toast)
		titleLabel.Position = UDim2.new(0,14,0,8)
		titleLabel.Size = UDim2.new(1,-44,0,18)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Font = Theme.Font
		titleLabel.TextSize = 16
		titleLabel.TextColor3 = Theme.Text
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextYAlignment = Enum.TextYAlignment.Center
		titleLabel.Text = tostring(title)
		titleLabel.ZIndex = 102

		local msgLabel = Instance.new("TextLabel", toast)
		msgLabel.Position = UDim2.new(0,14,0,30)
		msgLabel.Size = UDim2.new(1,-44,0,0)
		msgLabel.BackgroundTransparency = 1
		msgLabel.Font = Theme.Font
		msgLabel.TextSize = 14
		msgLabel.TextColor3 = Theme.Text
		msgLabel.TextXAlignment = Enum.TextXAlignment.Left
		msgLabel.TextYAlignment = Enum.TextYAlignment.Top
		msgLabel.TextWrapped = true
		msgLabel.AutomaticSize = Enum.AutomaticSize.Y
		msgLabel.Text = tostring(message)
		msgLabel.ZIndex = 102

		local close = Instance.new("TextButton", toast)
		close.Size = UDim2.new(0,24,0,24)
		close.Position = UDim2.new(1,-28,0,6)
		close.BackgroundTransparency = 1
		close.Text = "✕"
		close.Font = Theme.Font
		close.TextSize = 16
		close.TextColor3 = Theme.Text
		close.AutoButtonColor = false
		close.ZIndex = 103

		local textSize = TextService:GetTextSize(msgLabel.Text, msgLabel.TextSize, msgLabel.Font, Vector2.new(ToastHolder.AbsoluteSize.X-44, math.huge))
		local targetHeight = textSize.Y + 44

		tweenGui(toast, {Size = UDim2.new(1,0,0,targetHeight)}, 0.35)

		local destroyed = false
		local function destroyToast()
			if destroyed then return end
			destroyed = true
			tweenGui(toast, {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1}, 0.25)
			task.delay(0.3, function()
				if toast and toast.Parent then
					toast:Destroy()
				end
			end)
		end

		close.MouseButton1Click:Connect(destroyToast)
		task.delay(duration, destroyToast)
	end

	Library.Notify = function(title, message, nType, duration)
		NotificationService:Notify(title, message, nType, duration)
	end







	return Elements
end






--================ OPTIONAL SETTINGS TAB DEFINIEREN =================-- 
local function CreateOptionalSettingsTab()
	local SettingsTab = Library:CreateTab("Settings")

	-- Slider: GUI Transparency
	SettingsTab:Slider("GUI Transparency", 0, 1, currentTransparency, function(val)
		currentTransparency = val
		SetMainTransparency(val)
	end)

	-- Toggle: Enable Blur
	local blurToggle = SettingsTab:Toggle("Enable Blur", false, function(on)
		SetBlur(on, 20)
	end)

	-- Color Picker
	SettingsTab:FullRGBPicker("Pick Color", Color3.fromRGB(255,0,0), function(color)
		SetMainBackgroundColor(color)
	end)






	local designNames = {}
	for name, _ in pairs(BgColors) do table.insert(designNames, name) end
	table.sort(designNames)

	SettingsTab:Dropdown("Main Background", designNames, function(selected)
		-- Farbe des Fensters ändern
		if BgColors[selected] then
			SetMainBackgroundColor(BgColors[selected])
		end
		-- Die Animation starten
		ApplySpecialEffect(selected)
	end)






	-- Toggle: Enable Resize
	local resizeToggle = SettingsTab:Toggle("Enable Resize", false, function(on)
		ResizeHandle.Visible = on
	end)

	-- ================= KEYBIND: GUI OPEN/CLOSE =================
	local guiKey = "RightShift" -- Standard Key
	local guiToggleKeybind = SettingsTab:Keybind("Toggle GUI", guiKey, function(newKey)
		guiKey = newKey
		print("GUI Toggle Keybind changed to:", guiKey)
	end)

	-- Dauerhaftes Input Event
	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == guiKey then
			if Main.Visible then
				CloseUI()
			else
				OpenUI()
			end
		end
	end)

	-- ================= TOGGLE: SHOW/HIDE OPEN BUTTON =================
	local showOpenBtnToggle = SettingsTab:Toggle("Show Open Button", true, function(state)
		OpenButton.Visible = state
	end)

	SettingsTab:Toggle("Drag Open Button", false, function(state)
		dragEnabled = state 
	end)


	local designDropdown = SettingsTab:Dropdown("Button Design", {"Standard Neon", "Minimalist O", "Swipe Mode"}, function(selected)
		ApplyButtonDesign(selected)

		if selected == "Swipe Mode" then
			-- 1. Nachricht senden
			Library.Notify(
				"SWIPE MODE ENABLED", 
				"The toggle button is now invisible. Swipe from the left edge of your screen to the right to open the menu.", 
				"Success", 
				7
			)

			task.spawn(function()
				for i = 1, 2 do
					-- Aufleuchten (Rot)
					Tween(SwipeIndicator, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {
						BackgroundTransparency = 0.3,
						BackgroundColor3 = Color3.fromRGB(255, 0, 0),
						Size = UDim2.new(0, 15, 1, 0) -- Wird kurz breiter, damit man es sieht
					})
					task.wait(1)

					-- Verblassen
					Tween(SwipeIndicator, {0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 2, 1, 0)
					})
					task.wait(0.1)
				end
				SwipeIndicator.BackgroundColor3 = Theme.Accent
			end)
		end
	end)
	designDropdown.refreshOnUpdate = true


--[[
	-- Save Settings
	SettingsTab:Button("Save Settings", function()
		SaveGUISettings()
		Library.Notify("Settings", "Settings saved!", "Success", 2)
	end)
]]




	return SettingsTab
end


--================ AUTOMATISCHE TAB-ERSTELLUNG =================--
task.spawn(function()
	-- wartet bis _G.showOptionalSettings definiert wird
	while _G.showOptionalSettings == nil do
		task.wait(0.05)
	end

	if _G.showOptionalSettings then
		CreateOptionalSettingsTab()
	end
end)

return Library
