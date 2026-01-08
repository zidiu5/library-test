--// CYBERPUNK ULTIMATE UI LIBRARY
--// VERSION 2.69.Fucking shit

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

-- Keybind + Drag Toggle
guiKey = GameConfig.GuiKey or "RightShift"
DragEnabled = GameConfig.DragEnabled or false




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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
OpenButton.ZIndex = 100
OpenButton.Active = true -- nötig für Input, NICHT für Drag

local Corner = Instance.new("UICorner", OpenButton)
Corner.CornerRadius = UDim.new(0,6)

local Stroke = Instance.new("UIStroke", OpenButton)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,0,255)

--================ DRAG SETTINGS =================--
dragEnabled = GameConfig.DragEnabled or false
guiKey = GameConfig.GuiKey or "RightShift"
local dragging = false
local dragStartPos = nil
local buttonStartPos = nil
local potentialClick = false

local DRAG_THRESHOLD = 6

--================ INPUT BEGAN =================--
OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		potentialClick = true

		if dragEnabled then
			dragStartPos = input.Position
			buttonStartPos = OpenButton.Position
			dragging = false
		else
			dragStartPos = nil
			dragging = false
		end
	end
end)


--================ INPUT CHANGED =================--
UIS.InputChanged:Connect(function(input)
	if not dragEnabled then return end
	if not dragStartPos then return end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStartPos

		if math.abs(delta.X) > DRAG_THRESHOLD
			or math.abs(delta.Y) > DRAG_THRESHOLD then
			dragging = true
			potentialClick = false
		end

		if dragging then
			OpenButton.Position =
				buttonStartPos + UDim2.fromOffset(delta.X, delta.Y)
		end
	end
end)


--================ INPUT ENDED =================--
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		if potentialClick then
			if isOpen then
				CloseUI()
			else
				OpenUI()
			end
		end

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


-- Hover
OpenButton.MouseEnter:Connect(function()
	Tween(OpenButton,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
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
end)

OpenButton.MouseLeave:Connect(function()
	Tween(OpenButton,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{
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
end)

--================ MAIN FRAME =================--
local SavedGuiSize = GameConfig.GuiSize or {X=0.5, Y=0.8, OffsetX=0, OffsetY=0}
local SavedGuiPosition = GameConfig.GuiPosition or {X=0.5, Y=0.5, OffsetX=0, OffsetY=0}
local SavedMainColor = Config:TableToColor(GameConfig.MainColor, Theme.Main)

local Main = Instance.new("Frame", ScreenGui)

Main.ZIndex = 50


Main.Size = UDim2.new(SavedGuiSize.X, SavedGuiSize.OffsetX, SavedGuiSize.Y, SavedGuiSize.OffsetY)
Main.Position = UDim2.new(SavedGuiPosition.X, SavedGuiPosition.OffsetX, SavedGuiPosition.Y, SavedGuiPosition.OffsetY)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = SavedMainColor
Main.Visible = false
Main.ClipsDescendants = true




-- Beispiel: Speichern von GUI-Größe
function SaveGUISettings()
	local PLACE_KEY = "Place_" .. game.PlaceId
	Config.Data[PLACE_KEY] = Config.Data[PLACE_KEY] or {}
	local GameConfig = Config.Data[PLACE_KEY]

	-- Größe & Position speichern
	GameConfig.GuiSize = { X = Main.Size.X.Scale, Y = Main.Size.Y.Scale, OffsetX = Main.Size.X.Offset, OffsetY = Main.Size.Y.Offset }
	GameConfig.GuiPosition = { X = Main.Position.X.Scale, Y = Main.Position.Y.Scale, OffsetX = Main.Position.X.Offset, OffsetY = Main.Position.Y.Offset }

	-- Toggle, Keybind, Farbe
	GameConfig.GuiKey = guiKey
	GameConfig.DragEnabled = dragEnabled
	GameConfig.MainColor = Config:ColorToTable(Main.BackgroundColor3)

	Config:Set(PLACE_KEY, GameConfig)
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




--================ SETTINGS FUNCTIONS =================--

-- Background colors
local BgColors = {
	Atlantic = Color3.fromRGB(10,10,18),
	Red = Color3.fromRGB(150,20,20),
	Purple = Color3.fromRGB(60,0,60),
	Cyan = Color3.fromRGB(0,100,150)
}

-- Change background color
local function SetMainBackgroundColor(color)
	Tween(Main, {0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out}, {BackgroundColor3 = color})
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
local DEFAULT_SIZE = UDim2.fromScale(0.5, 0.8)


OpenUI = function()
	if isOpen then return end
	isOpen = true

	Main.Visible = true
	local targetSize = SavedWindowSize or DEFAULT_SIZE
	Main.Size = targetSize - UDim2.fromOffset(40, 40)
	Main.BackgroundTransparency = currentTransparency

	Tween(Main, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
		Size = targetSize,
		BackgroundTransparency = currentTransparency
	})
end



CloseUI = function()
	if not isOpen then return end
	isOpen = false

	local targetSize = SavedWindowSize or DEFAULT_SIZE
	Tween(Main, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {
		Size = targetSize - UDim2.fromOffset(40, 40),
		BackgroundTransparency = 1
	})

	task.delay(0.25, function()
		Main.Visible = false
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
	function Elements:Button(text, callback)
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

		return Button
	end

	-- TOGGLE
	function Elements:Toggle(text, default, callback)
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
	function Elements:Slider(label, min, max, default, callback, precision)
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

		return Slider
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

	-- Dropdown: Background Color
	local bgDropdown = SettingsTab:Dropdown("Background Color", {"Atlantic","Red","Purple","Cyan"}, function(opt)
		SetMainBackgroundColor(BgColors[opt])
	end)
	bgDropdown.refreshOnUpdate = true

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
			if isOpen then
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

		if not state then
			dragging = false
			dragStartPos = nil
		end
	end)
	
	-- Save Settings
	SettingsTab:Button("Save Settings", function()
		SaveGUISettings()
		Library.Notify("Settings", "Settings saved!", "Success", 2)
	end)





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
