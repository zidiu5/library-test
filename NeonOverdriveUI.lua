--// CYBERPUNK ULTIMATE UI LIBRARY
--// VERSION 2.2 "NEON OVERDRIVE ANIMATED + GLOW"

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

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

local Corner = Instance.new("UICorner", OpenButton)
Corner.CornerRadius = UDim.new(0,6)

local Stroke = Instance.new("UIStroke", OpenButton)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0,0,255)

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
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromScale(0.5,0.8)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Theme.Main
Main.Active = true
Main.Visible = false
Main.ClipsDescendants = true

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
local isOpen = false
Main.Size = UDim2.fromScale(0.5,0.8)

local function OpenUI()
	Main.Visible = true
	Main.Size = UDim2.fromScale(0.45,0.55)
	Main.BackgroundTransparency = currentTransparency
	Tween(Main,{0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out},{
		Size = UDim2.fromScale(0.5,0.8),
		BackgroundTransparency = currentTransparency
	})
end


local function CloseUI()
	Tween(Main,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In},{
		Size = UDim2.fromScale(0.45,0.55),
		BackgroundTransparency = 1
	})
	task.delay(0.25,function()
		Main.Visible = false
	end)
end

OpenButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	if isOpen then
		OpenUI()
	else
		CloseUI()
	end
end)

--================ LIBRARY =================--
local Library = {}
local CurrentPage, CurrentTab

function Library:CreateTab(name)
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

	local Elements = {}

	-- BUTTON
	function Elements:Button(text, callback)
		local b = Instance.new("TextButton", Page)
		b.Size = UDim2.new(1,0,0,45)
		b.Text = text
		b.Font = Theme.Font
		b.TextSize = 16
		b.BackgroundColor3 = Theme.Button
		b.TextColor3 = Theme.Text
		Instance.new("UICorner", b)
		b.MouseButton1Click:Connect(callback)
	end

	-- TOGGLE
	function Elements:Toggle(text, callback)
		local t = Instance.new("TextButton", Page)
		t.Size = UDim2.new(1,0,0,45)
		t.Text = text
		t.Font = Theme.Font
		t.TextSize = 16
		t.BackgroundColor3 = Theme.Button
		t.TextColor3 = Theme.Text
		t.AutoButtonColor = false
		Instance.new("UICorner", t)
		local on = false

		local Glow = Instance.new("Frame", t)
		Glow.AnchorPoint = Vector2.new(0.5,0.5)
		Glow.Position = UDim2.fromScale(0.5,0.5)
		Glow.Size = UDim2.fromOffset(50,50)
		Glow.BackgroundColor3 = Theme.Accent
		Glow.BackgroundTransparency = 0.85
		Glow.ZIndex = t.ZIndex - 1
		local GlowCorner = Instance.new("UICorner", Glow)
		GlowCorner.CornerRadius = UDim.new(0,8)
		local GlowStroke = Instance.new("UIStroke", Glow)
		GlowStroke.Thickness = 3
		GlowStroke.Transparency = 0.65

		t.MouseButton1Click:Connect(function()
			on = not on
			if on then
				Tween(t,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(0,0,0)})
				Tween(Glow,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{BackgroundColor3 = Theme.Accent})
				Tween(GlowStroke,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{Color = Theme.Accent})
			else
				Tween(t,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{BackgroundColor3 = Theme.Button, TextColor3 = Theme.Text})
				Tween(Glow,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{BackgroundColor3 = Color3.fromRGB(0,0,0)})
				Tween(GlowStroke,{0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out},{Color = Color3.fromRGB(0,0,0)})
			end
			callback(on)
		end)
	end

	-- TEXTBOX
	function Elements:TextBox(placeholder, callback)
		local box = Instance.new("TextBox", Page)
		box.Size = UDim2.new(1,0,0,45)
		box.PlaceholderText = placeholder
		box.Font = Theme.Font
		box.TextSize = 16
		box.BackgroundColor3 = Theme.Button
		box.TextColor3 = Theme.Accent
		box.PlaceholderColor3 = Theme.DarkText
		box.ClearTextOnFocus = false
		Instance.new("UICorner", box)
		box.Text = ""
		box.FocusLost:Connect(function(enter)
			if enter then callback(box.Text) end
		end)
	end

	--================ ELEMENTS: DROPDOWN =================--
	function Elements:Dropdown(label, options, callback)
		local container = Instance.new("Frame", Page)
		container.Size = UDim2.new(1,0,0,40)
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true

		local layout = Instance.new("UIListLayout", container)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0,5) -- Abstand zwischen Title und Options

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
		optionContainer.Size = UDim2.new(1,0,0,0) -- collapsed
		optionContainer.BackgroundTransparency = 1
		optionContainer.ClipsDescendants = true

		local optionLayout = Instance.new("UIListLayout", optionContainer)
		optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		optionLayout.Padding = UDim.new(0,5) -- Abstand zwischen Options

		for _, opt in ipairs(options) do
			local btnContainer = Instance.new("Frame", optionContainer)
			btnContainer.Size = UDim2.new(1,0,0,30)
			btnContainer.BackgroundTransparency = 1

			local btn = Instance.new("TextButton", btnContainer)
			btn.Size = UDim2.new(1,0,1,0)
			btn.BackgroundColor3 = Theme.Button
			btn.TextColor3 = Theme.Text
			btn.Text = opt
			btn.Font = Theme.Font
			btn.TextSize = 14
			btn.AutoButtonColor = false
			Instance.new("UICorner", btn)

			btn.MouseButton1Click:Connect(function()
				title.Text = label.." ▼ "..opt
				callback(opt)
				Tween(optionContainer, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {Size = UDim2.new(1,0,0,0)})
			end)
		end

		local opened = false
		title.MouseButton1Click:Connect(function()
			opened = not opened
			local targetHeight = opened and (#options*35) or 0 -- 30 + 5 Abstand
			Tween(optionContainer, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {Size = UDim2.new(1,0,0,targetHeight)})
		end)

		-- Container passt sich automatisch an die OptionContainer-Höhe an
		optionContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			container.Size = UDim2.new(1,0,0,40 + optionContainer.AbsoluteSize.Y)
		end)
	end

	--================ ELEMENTS: SLIDER =================--
	function Elements:Slider(label, min, max, default, callback)
		local Container = Instance.new("Frame", Page)
		Container.Size = UDim2.new(1,0,0,60) -- mehr Höhe für Label
		Container.BackgroundTransparency = 1

		-- Label über dem Slider
		local TextLabel = Instance.new("TextLabel", Container)
		TextLabel.Size = UDim2.new(1,0,0,20)
		TextLabel.Position = UDim2.new(0,0,0,0)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Text = label.." : "..tostring(default)
		TextLabel.Font = Theme.Font
		TextLabel.TextSize = 16
		TextLabel.TextColor3 = Theme.Text
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Slider Background
		local SliderFrame = Instance.new("Frame", Container)
		SliderFrame.Size = UDim2.new(1, -50, 0, 10)
		SliderFrame.Position = UDim2.new(0,0,0,30)
		SliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,70)
		SliderFrame.BorderSizePixel = 0
		SliderFrame.AnchorPoint = Vector2.new(0,0)
		Instance.new("UICorner", SliderFrame)

		-- Slider Fill
		local SliderFill = Instance.new("Frame", SliderFrame)
		SliderFill.Size = UDim2.new((default-min)/(max-min),0,1,0)
		SliderFill.BackgroundColor3 = Theme.Accent
		SliderFill.BorderSizePixel = 0
		Instance.new("UICorner", SliderFill)

		-- ON/OFF Button rechts
		local ToggleBtn = Instance.new("TextButton", Container)
		ToggleBtn.Size = UDim2.new(0,40,0,30)
		ToggleBtn.Position = UDim2.new(1,-45,0,25)
		ToggleBtn.Text = "ON"
		ToggleBtn.Font = Theme.Font
		ToggleBtn.TextSize = 14
		ToggleBtn.BackgroundColor3 = Theme.Button
		ToggleBtn.TextColor3 = Theme.Text
		Instance.new("UICorner", ToggleBtn)

		local enabled = true
		ToggleBtn.MouseButton1Click:Connect(function()
			enabled = not enabled
			if enabled then
				ToggleBtn.Text = "ON"
				ToggleBtn.BackgroundColor3 = Theme.Button
				ToggleBtn.TextColor3 = Theme.Text
			else
				ToggleBtn.Text = "OFF"
				ToggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
				ToggleBtn.TextColor3 = Color3.fromRGB(120,120,120)
			end
		end)

		-- Dragging
		local dragging = false
		SliderFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)
		SliderFrame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		SliderFrame.InputChanged:Connect(function(input)
			if dragging and enabled and input.UserInputType == Enum.UserInputType.MouseMovement then
				local x = math.clamp(input.Position.X - SliderFrame.AbsolutePosition.X, 0, SliderFrame.AbsoluteSize.X)
				SliderFill.Size = UDim2.new(x/SliderFrame.AbsoluteSize.X,0,1,0)
				local value = min + (x/SliderFrame.AbsoluteSize.X)*(max-min)
				TextLabel.Text = label.." : "..math.floor(value) -- live Wert
				pcall(function() callback(value) end) -- Fehler abfangen
			end
		end)
	end

	--================ ELEMENTS: FULL RGB PICKER =================--
	function Elements:FullRGBPicker(label, defaultColor, callback)
		local container = Instance.new("Frame", Page)
		container.Size = UDim2.new(1,0,0,40)
		container.BackgroundTransparency = 1
		container.ClipsDescendants = false -- WICHTIG: sonst wird Picker abgeschnitten

		local layout = Instance.new("UIListLayout", container)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0,5)

		local title = Instance.new("TextButton", container)
		title.Size = UDim2.new(1,0,0,40)
		title.BackgroundColor3 = Theme.Button
		title.Text = label.." ▼"
		title.Font = Theme.Font
		title.TextSize = 16
		title.TextColor3 = Theme.Text
		title.AutoButtonColor = false
		Instance.new("UICorner", title)

		-- PARENT PickerContainer direkt auf Page, NICHT auf container
		local pickerContainer = Instance.new("Frame", Page)
		pickerContainer.Size = UDim2.new(0,200,0,160)
		pickerContainer.Position = UDim2.new(0,container.AbsolutePosition.X,0,container.AbsolutePosition.Y+40)
		pickerContainer.BackgroundColor3 = Theme.Button
		Instance.new("UICorner", pickerContainer)
		pickerContainer.Visible = false
		pickerContainer.ZIndex = 20

		local pickerCircle = Instance.new("ImageLabel", pickerContainer)
		pickerCircle.Size = UDim2.new(0,150,0,150)
		pickerCircle.Position = UDim2.new(0,0,0,0)
		pickerCircle.BackgroundTransparency = 1
		pickerCircle.Image = "rbxassetid://99441834088327" -- kein Bild
		pickerCircle.BackgroundColor3 = Color3.fromRGB(50,50,50) -- optional Hintergrund
		pickerCircle.ScaleType = Enum.ScaleType.Fit
		pickerCircle.ZIndex = 21

		local sliderContainer = Instance.new("Frame", pickerContainer)
		sliderContainer.Size = UDim2.new(0,30,0,150)
		sliderContainer.Position = UDim2.new(0,160,0,0)
		sliderContainer.BackgroundColor3 = Color3.fromRGB(50,50,50)
		Instance.new("UICorner", sliderContainer)
		sliderContainer.ZIndex = 21

		local sliderFill = Instance.new("Frame", sliderContainer)
		sliderFill.Size = UDim2.new(1,0,1,0)
		sliderFill.BackgroundColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", sliderFill)

		local cursor = Instance.new("Frame", pickerCircle)
		cursor.Size = UDim2.new(0,10,0,10)
		cursor.AnchorPoint = Vector2.new(0.5,0.5)
		cursor.BackgroundColor3 = Color3.new(1,1,1)
		cursor.BorderSizePixel = 0
		Instance.new("UICorner", cursor)
		cursor.Position = UDim2.new(0.5,0,0.5,0)
		cursor.ZIndex = 22

		local opened, draggingCircle, draggingSlider = false,false,false
		local hue, sat, val = 0,1,1
		local mouse = Player:GetMouse()

		local function HSVtoRGB(h,s,v)
			local i = math.floor(h*6)
			local f = h*6 - i
			local p = v*(1-s)
			local q = v*(1-f*s)
			local t = v*(1-(1-f)*s)
			i = i % 6
			if i==0 then return Color3.new(v,t,p) end
			if i==1 then return Color3.new(q,v,p) end
			if i==2 then return Color3.new(p,v,t) end
			if i==3 then return Color3.new(p,q,v) end
			if i==4 then return Color3.new(t,p,v) end
			if i==5 then return Color3.new(v,p,q) end
		end

		-- Farbvorschau rechts im Button
		local colorPreview = Instance.new("Frame", title)
		colorPreview.Size = UDim2.new(0,25,0,25)
		colorPreview.Position = UDim2.new(1,-30,0.5,-12.5)
		colorPreview.BackgroundColor3 = defaultColor
		colorPreview.BorderSizePixel = 0
		Instance.new("UICorner", colorPreview)

		-- updateColor passt jetzt nur die Vorschau an, nicht den ganzen Button
		local function updateColor()
			local color = HSVtoRGB(hue,sat,val)
			colorPreview.BackgroundColor3 = color -- nur kleine Vorschau
			pcall(callback,color)
		end

		title.MouseButton1Click:Connect(function()
			opened = not opened
			pickerContainer.Visible = opened
			title.Text = label..(opened and " ▲" or " ▼")
		end)

		-- Circle Input
		pickerCircle.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingCircle=true end
		end)
		pickerCircle.InputEnded:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingCircle=false end
		end)

		-- Slider Input
		sliderContainer.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=true end
		end)
		sliderContainer.InputEnded:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=false end
		end)

		-- Mouse move
		UIS.InputChanged:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement then
				local mx,my = mouse.X,mouse.Y
				if draggingCircle then
					local localPos = Vector2.new(mx-pickerCircle.AbsolutePosition.X,my-pickerCircle.AbsolutePosition.Y)
					local nx = (localPos.X/pickerCircle.AbsoluteSize.X-0.5)*2
					local ny = (localPos.Y/pickerCircle.AbsoluteSize.Y-0.5)*2
					local r = math.sqrt(nx^2+ny^2)
					if r<=1 then
						local angle = math.atan2(ny,nx)
						if angle<0 then angle=angle+2*math.pi end
						hue=angle/(2*math.pi)
						sat=math.clamp(r,0,1)
						cursor.Position=UDim2.new(localPos.X/pickerCircle.AbsoluteSize.X,0,localPos.Y/pickerCircle.AbsoluteSize.Y,0)
						updateColor()
					end
				end
				if draggingSlider then
					local y = math.clamp(my-sliderContainer.AbsolutePosition.Y,0,sliderContainer.AbsoluteSize.Y)
					val=1-y/sliderContainer.AbsoluteSize.Y
					sliderFill.Size=UDim2.new(1,0,y/sliderContainer.AbsoluteSize.Y,0)
					updateColor()
				end
			end
		end)
	end





	return Elements
end




--================ DEMO =================--

-- Combat Tab
local Combat = Library:CreateTab("Combat")
Combat:Button("Attack", function() print("Attack Clicked") end)
Combat:Toggle("Stealth Mode", function(state) print("Stealth:", state) end)
Combat:TextBox("Enter command...", function(text) print("Command:", text) end)
Combat:Dropdown("Mode", {"Option 1","Option 2","Option 3"}, function(opt) print("Selected:", opt) end)
Combat:Slider("Damage", 0, 100, 50, function(val) print("Damage:", val) end)

-- Utility Tab
local Utility = Library:CreateTab("Utility")
Utility:Button("Heal", function() print("Heal Clicked") end)
Utility:Toggle("Auto Farm", function(state) print("Auto Farm:", state) end)
Utility:TextBox("Enter path...", function(text) print("Path:", text) end)
Utility:Dropdown("Speed Mode", {"Fast","Normal","Slow"}, function(opt) print("Speed:", opt) end)
Utility:Slider("Speed", 0, 500, 250, function(val) print("Speed:", val) end)

-- Settings Tab
local Settings = Library:CreateTab("Settings")
Settings:Button("Save", function() print("Save Clicked") end)
Settings:Toggle("Dark Mode", function(state) print("Dark Mode:", state) end)
Settings:TextBox("Username...", function(text) print("Username:", text) end)
Settings:Dropdown("Graphics", {"Low","Medium","High"}, function(opt) print("Graphics:", opt) end)
Settings:Slider("Volume", 0, 100, 75, function(val) print("Volume:", val) end)

-- Visuals Tab
local Visuals = Library:CreateTab("Visuals")
Visuals:Button("Show Effects", function() print("Show Effects") end)
Visuals:Toggle("Shaders", function(state) print("Shaders:", state) end)
Visuals:TextBox("Effect name...", function(text) print("Effect:", text) end)
Visuals:Dropdown("Color", {"Red","Green","Blue"}, function(opt) print("Color:", opt) end)
Visuals:Slider("Brightness", 0, 100, 50, function(val) print("Brightness:", val) end)

-- Audio Tab
local Audio = Library:CreateTab("Audio")
Audio:Button("Play Music", function() print("Play Music") end)
Audio:Toggle("Mute", function(state) print("Mute:", state) end)
Audio:TextBox("Track name...", function(text) print("Track:", text) end)
Audio:Dropdown("Quality", {"Low","Normal","High"}, function(opt) print("Quality:", opt) end)
Audio:Slider("Volume", 0, 100, 50, function(val) print("Volume:", val) end)

-- Misc Tab
local Misc = Library:CreateTab("Misc")
Misc:Button("Random Action", function() print("Random Action") end)
Misc:Toggle("Enable Random", function(state) print("Random:", state) end)
Misc:TextBox("Notes...", function(text) print("Notes:", text) end)
Misc:Dropdown("Option", {"X","Y","Z"}, function(opt) print("Option:", opt) end)
Misc:Slider("Random Value", -50, 50, 0, function(val) print("Random Value:", val) end)

--================ OPTIONAL SETTINGS TAB =================--
local Settings = Library:CreateTab("Settings")

-- Transparenz Slider
Settings:Slider("GUI Transparency", 0, 1, currentTransparency, function(val)
	currentTransparency = val
	SetMainTransparency(val)
end)

-- Blur Toggle
Settings:Toggle("Enable Blur", function(on)
	SetBlur(on, 20)
end)


Settings:FullRGBPicker("Pick Color", Color3.fromRGB(255,0,0), function(color)
	print("Selected color:", color)
	SetMainBackgroundColor(color)
end)


-- Background Color Dropdown
Settings:Dropdown("Background Color", {"Atlantic","Red","Purple","Cyan"}, function(opt)
	SetMainBackgroundColor(BgColors[opt])
end)
