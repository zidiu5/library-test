--// CYBERPUNK ULTIMATE UI LIBRARY
--// VERSION 2.3 "NEON OVERDRIVE ANIMATED + GLOW"

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local SavedWindowSize = nil


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

if SavedWindowSize then
	Main.Size = SavedWindowSize
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
local isOpen = false
Main.Size = UDim2.fromScale(0.5,0.8)

local function OpenUI()
	Main.Visible = true
	local targetSize = SavedWindowSize or DEFAULT_SIZE
	Main.Size = targetSize - UDim2.fromOffset(40, 40)
	Main.BackgroundTransparency = currentTransparency
	Tween(Main, {0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out}, {
		Size = targetSize,
		BackgroundTransparency = currentTransparency
	})
end



local function CloseUI()
	local targetSize = SavedWindowSize or DEFAULT_SIZE

	Tween(Main, {0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In}, {
		Size = targetSize - UDim2.fromOffset(40, 40),
		BackgroundTransparency = 1
	})

	task.delay(0.25, function()
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
	
	function Elements:Button(text, callback)
		orderCounter += 1
		local b = Instance.new("TextButton", Page)
		b.LayoutOrder = orderCounter
		b.Size = UDim2.new(1,0,0,45)
		b.Text = text
		b.Font = Theme.Font
		b.TextSize = 16
		b.BackgroundColor3 = Theme.Button
		b.TextColor3 = Theme.Text
		Instance.new("UICorner", b)
		b.MouseButton1Click:Connect(callback)
	end

	function Elements:Toggle(text, callback)
		orderCounter += 1
		local t = Instance.new("TextButton", Page)
		t.LayoutOrder = orderCounter
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
		Glow.BackgroundTransparency = 1
		Glow.ZIndex = t.ZIndex - 1
		Instance.new("UICorner", Glow)
		local GlowStroke = Instance.new("UIStroke", Glow)
		GlowStroke.Thickness = 3
		GlowStroke.Transparency = 1

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

	function Elements:TextBox(placeholder, callback)
		orderCounter += 1
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
		Instance.new("UICorner", box)
		box.Text = ""
		box.FocusLost:Connect(function(enter)
			if enter then callback(box.Text) end
		end)
	end

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
		local DropdownObject = {}
		DropdownObject.opened = false
		DropdownObject.multiselect = multiselect
		DropdownObject.refreshOnUpdate = false
		DropdownObject.selection = {}

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
				if DropdownObject.multiselect then
					checkbox = Instance.new("Frame", btn)
					checkbox.Size = UDim2.new(0,20,0,20)
					checkbox.Position = UDim2.new(0,5,0.5,-10)
					checkbox.BackgroundColor3 = DropdownObject.selection[opt] and Theme.Accent or Color3.fromRGB(0,0,0)
					checkbox.BorderSizePixel = 1
					Instance.new("UICorner", checkbox)
					DropdownObject.selection[opt] = DropdownObject.selection[opt] or false
				end

				btn.MouseButton1Click:Connect(function()
					if DropdownObject.multiselect then
						DropdownObject.selection[opt] = not DropdownObject.selection[opt]
						if checkbox then
							checkbox.BackgroundColor3 = DropdownObject.selection[opt] and Theme.Accent or Color3.fromRGB(0,0,0)
						end
						if callback then pcall(callback, DropdownObject.selection) end
					else
						title.Text = label.." ▼ "..tostring(opt)
						if callback then pcall(callback, opt) end
						DropdownObject.opened = false
						Tween(optionContainer,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size = UDim2.new(1,0,0,0)})
					end
				end)

				table.insert(optionButtons, btnContainer)
			end

			-- Multi-Select: Zeige alle bereits ausgewählten sofort
			if DropdownObject.multiselect then
				for opt,val in pairs(DropdownObject.selection) do
					for _, btnContainer in ipairs(optionButtons) do
						local btn = btnContainer:FindFirstChildWhichIsA("TextButton")
						if btn and btn.Text == opt then
							local cb = btn:FindFirstChildWhichIsA("Frame")
							if cb then
								cb.BackgroundColor3 = val and Theme.Accent or Color3.fromRGB(0,0,0)
							end
						end
					end
				end
			end
		end

		buildOptions()

		title.MouseButton1Click:Connect(function()
			DropdownObject.opened = not DropdownObject.opened
			local totalHeight = 0
			for _, btn in ipairs(optionButtons) do
				totalHeight = totalHeight + btn.Size.Y.Offset
			end
			local padding = (#optionButtons > 1) and (#optionButtons - 1) * 5 or 0
			if DropdownObject.opened then totalHeight = totalHeight + padding else totalHeight = 0 end
			Tween(optionContainer,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size = UDim2.new(1,0,0,totalHeight)})
			title.Text = label..(DropdownObject.opened and " ▲" or " ▼")
		end)

		optionContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			container.Size = UDim2.new(1,0,0, title.Size.Y.Offset + optionContainer.AbsoluteSize.Y + 5)
		end)

		function DropdownObject:SetOptions(newOptions)
			options = newOptions or {}
			-- Multi-Select: reset selection, Single-Select: nichts nötig
			if DropdownObject.multiselect then
				for k,_ in pairs(DropdownObject.selection) do DropdownObject.selection[k] = false end
			end
			if self.refreshOnUpdate then buildOptions() end
			local totalHeight = 0
			for _, btn in ipairs(optionButtons) do
				totalHeight = totalHeight + btn.Size.Y.Offset
			end
			local padding = (#optionButtons > 1) and (#optionButtons - 1) * 5 or 0
			optionContainer.Size = UDim2.new(1,0,0,self.opened and totalHeight + padding or 0)
		end

		function DropdownObject:GetOptions()
			return options
		end

		function DropdownObject:Refresh()
			buildOptions()
			local totalHeight = 0
			for _, btn in ipairs(optionButtons) do
				totalHeight = totalHeight + btn.Size.Y.Offset
			end
			local padding = (#optionButtons > 1) and (#optionButtons - 1) * 5 or 0
			optionContainer.Size = UDim2.new(1,0,0,self.opened and totalHeight + padding or 0)
		end

		return DropdownObject
	end
	
	function Elements:DropdownSearch(label, options, callback, multiselect)
		options = options or {}
		multiselect = multiselect or false

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

		-- BUILD OPTIONS
		local function build(filter)
			for _,v in ipairs(optionButtons) do v:Destroy() end
			table.clear(optionButtons)

			filter = filter and filter:lower() or ""

			for i,opt in ipairs(options) do
				if filter ~= "" and not tostring(opt):lower():find(filter) then
					continue
				end

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
						checkbox.BackgroundColor3 = Dropdown.selection[opt] and Theme.Accent or Color3.fromRGB(0,0,0)
						if callback then callback(Dropdown.selection) end
					else
						title.Text = label.." ▼ "..tostring(opt)
						if callback then callback(opt) end
						Dropdown.opened = false
						Tween(body,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size = UDim2.new(1,0,0,0)})
					end
				end)

				table.insert(optionButtons, row)
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

			if Dropdown.opened then
				task.wait()
				local h = 32 + layout.AbsoluteContentSize.Y + (#optionButtons > 0 and 5 or 0)
				Tween(body,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size = UDim2.new(1,0,0,h)})
			else
				Tween(body,{0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out},{Size = UDim2.new(1,0,0,0)})
			end
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


	--================ ELEMENTS: FULL RGB PICKER =================--
	function Elements:FullRGBPicker(label, defaultColor, callback)
		orderCounter += 1
		local container = Instance.new("Frame", Page)
		container.Size = UDim2.new(1,0,0,40) -- Starthöhe nur für Button
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true
		container.LayoutOrder = orderCounter

		-- UIListLayout für vertikales stacking innerhalb des Pickers (optional)
		local layout = Instance.new("UIListLayout", container)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0,5)

		-- BUTTON
		local title = Instance.new("TextButton", container)
		title.Size = UDim2.new(1,0,0,40)
		title.BackgroundColor3 = Theme.Button
		title.Text = label.." ▼"
		title.Font = Theme.Font
		title.TextSize = 16
		title.TextColor3 = Theme.Text
		title.AutoButtonColor = false
		Instance.new("UICorner", title)

		-- Farbvorschau
		local colorPreview = Instance.new("Frame", title)
		colorPreview.Size = UDim2.new(0,25,0,25)
		colorPreview.Position = UDim2.new(1,-30,0.5,-12.5)
		colorPreview.BackgroundColor3 = defaultColor
		colorPreview.BorderSizePixel = 0
		Instance.new("UICorner", colorPreview)

		-- PICKER CONTAINER (Teil des UIListLayouts!)
		local pickerContainer = Instance.new("Frame", container)
		pickerContainer.Size = UDim2.new(1,0,0,160)
		pickerContainer.BackgroundColor3 = Theme.Button
		pickerContainer.ClipsDescendants = true
		Instance.new("UICorner", pickerContainer)
		pickerContainer.Visible = false

		-- Color Circle
		local pickerCircle = Instance.new("ImageLabel", pickerContainer)
		pickerCircle.Size = UDim2.new(0,145,0,145)
		pickerCircle.Position = UDim2.new(0,3,0.03,0)
		pickerCircle.BackgroundTransparency = 1
		pickerCircle.Image = "rbxassetid://99441834088327"
		pickerCircle.ScaleType = Enum.ScaleType.Fit

		-- Slider
		local sliderContainer = Instance.new("Frame", pickerContainer)
		sliderContainer.Size = UDim2.new(0,30,0,145)
		sliderContainer.Position = UDim2.new(0,180,0.03,0)
		sliderContainer.BackgroundColor3 = Color3.fromRGB(50,50,50)
		Instance.new("UICorner", sliderContainer)

		local sliderFill = Instance.new("Frame", sliderContainer)
		sliderFill.Size = UDim2.new(1,0,1,0)
		sliderFill.BackgroundColor3 = Color3.new(1,1,1)
		Instance.new("UICorner", sliderFill)

		-- Cursor
		local cursor = Instance.new("Frame", pickerCircle)
		cursor.Size = UDim2.new(0,10,0,10)
		cursor.AnchorPoint = Vector2.new(0.5,0.5)
		cursor.BackgroundColor3 = Color3.new(1,1,1)
		cursor.BorderSizePixel = 0
		Instance.new("UICorner", cursor)
		cursor.Position = UDim2.new(0.5,0,0.5,0)

		local opened, draggingCircle, draggingSlider = false,false,false
		local hue, sat, val = 0,1,1

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

		local function updateColor()
			local color = HSVtoRGB(hue,sat,val)
			colorPreview.BackgroundColor3 = color
			pcall(callback,color)
		end

		-- TOGGLE PICKER
		title.MouseButton1Click:Connect(function()
			opened = not opened
			pickerContainer.Visible = opened
			title.Text = label..(opened and " ▲" or " ▼")

			-- dynamische Höhe des Containers anpassen
			container.Size = UDim2.new(1,0,0,40 + (opened and 160 or 0))
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
			if not (draggingCircle or draggingSlider) then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

			local mx,my = input.Position.X, input.Position.Y

			if draggingCircle then
				local localPos = Vector2.new(mx - pickerCircle.AbsolutePosition.X, my - pickerCircle.AbsolutePosition.Y)
				local nx = (localPos.X / pickerCircle.AbsoluteSize.X - 0.5) * 2
				local ny = (localPos.Y / pickerCircle.AbsoluteSize.Y - 0.5) * 2
				local r = math.sqrt(nx*nx + ny*ny)
				if r <= 1 then
					local angle = math.atan2(ny, nx)
					if angle < 0 then angle += math.pi*2 end
					hue = angle / (math.pi*2)
					sat = math.clamp(r,0,1)
					cursor.Position = UDim2.fromScale(localPos.X / pickerCircle.AbsoluteSize.X, localPos.Y / pickerCircle.AbsoluteSize.Y)
					updateColor()
				end
			end

			if draggingSlider then
				local y = math.clamp(my - sliderContainer.AbsolutePosition.Y,0,sliderContainer.AbsoluteSize.Y)
				val = 1 - y / sliderContainer.AbsoluteSize.Y
				sliderFill.Size = UDim2.new(1,0,y/sliderContainer.AbsoluteSize.Y,0)
				updateColor()
			end
		end)
	end

	function Elements:Slider(label, min, max, default, callback)
		orderCounter += 1
		local Container = Instance.new("Frame", Page)
		Container.LayoutOrder = orderCounter
		Container.Size = UDim2.new(1,0,0,60)
		Container.BackgroundTransparency = 1

		local TextLabel = Instance.new("TextLabel", Container)
		TextLabel.Size = UDim2.new(1, -50, 0, 20)
		TextLabel.Position = UDim2.new(0,0,0,0)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Text = label.." : "..tostring(default)
		TextLabel.Font = Theme.Font
		TextLabel.TextSize = 16
		TextLabel.TextColor3 = Theme.Text
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left

		local SliderFrame = Instance.new("Frame", Container)
		SliderFrame.Size = UDim2.new(1, -50, 0, 10)
		SliderFrame.Position = UDim2.new(0,0,0,30)
		SliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,70)
		SliderFrame.BorderSizePixel = 0
		Instance.new("UICorner", SliderFrame)

		local SliderFill = Instance.new("Frame", SliderFrame)
		SliderFill.Size = UDim2.new((default-min)/(max-min),0,1,0)
		SliderFill.BackgroundColor3 = Theme.Accent
		SliderFill.BorderSizePixel = 0
		Instance.new("UICorner", SliderFill)

		local ToggleBtn = Instance.new("TextButton", Container)
		ToggleBtn.Size = UDim2.new(0,40,0,30)
		ToggleBtn.Position = UDim2.new(1,-45,0,15)
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

		local dragging = false
		SliderFrame.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
		end)
		SliderFrame.InputEnded:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
		end)
		SliderFrame.InputChanged:Connect(function(input)
			if dragging and enabled and (input.UserInputType==Enum.UserInputType.MouseMovement) then
				local x = math.clamp(input.Position.X - SliderFrame.AbsolutePosition.X, 0, SliderFrame.AbsoluteSize.X)
				SliderFill.Size = UDim2.new(x / SliderFrame.AbsoluteSize.X,0,1,0)
				local value = min + (x/SliderFrame.AbsoluteSize.X)*(max-min)
				TextLabel.Text = label.." : "..math.floor(value)
				pcall(callback, value)
			end
		end)
	end

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


	--================ NOTIFICATION TOAST SYSTEM =================--

	local RunService = game:GetService("RunService")

	local NotificationService = {}

	local ToastGui = Instance.new("ScreenGui")
	ToastGui.Name = "CyberpunkNotifications"
	ToastGui.ResetOnSpawn = false
	ToastGui.IgnoreGuiInset = true
	ToastGui.Parent = Player:WaitForChild("PlayerGui")

	local ToastHolder = Instance.new("Frame", ToastGui)
	ToastHolder.AnchorPoint = Vector2.new(1,1)
	ToastHolder.Position = UDim2.new(1,-20,1,-20)
	ToastHolder.Size = UDim2.new(0,340,1,0)
	ToastHolder.BackgroundTransparency = 1
	ToastHolder.ZIndex = 100

	local ToastLayout = Instance.new("UIListLayout", ToastHolder)
	ToastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ToastLayout.Padding = UDim.new(0,10)

	local ToastColors = {
		Info    = Theme.Accent,
		Success = Color3.fromRGB(0,200,120),
		Warning = Color3.fromRGB(255,180,0),
		Error   = Color3.fromRGB(255,80,80)
	}

	function NotificationService:Notify(title, message, nType, duration)
		nType = nType or "Info"
		duration = duration or 3

		-- ROOT TOAST
		local toast = Instance.new("Frame", ToastHolder)
		toast.Size = UDim2.new(1,0,0,1)
		toast.BackgroundColor3 = Theme.Button
		toast.BackgroundTransparency = 0
		toast.ZIndex = 101
		toast.ClipsDescendants = true
		Instance.new("UICorner", toast)

		-- ACCENT STRIP
		local accent = Instance.new("Frame", toast)
		accent.Size = UDim2.new(0,4,1,0)
		accent.BackgroundColor3 = ToastColors[nType] or Theme.Accent
		accent.BorderSizePixel = 0
		accent.ZIndex = 102

		-- TITLE
		local titleLabel = Instance.new("TextLabel", toast)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Position = UDim2.new(0,14,0,8)
		titleLabel.Size = UDim2.new(1,-44,0,18)
		titleLabel.Text = tostring(title)
		titleLabel.Font = Theme.Font
		titleLabel.TextSize = 16
		titleLabel.TextColor3 = Theme.Text
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextYAlignment = Enum.TextYAlignment.Center
		titleLabel.ZIndex = 103

		-- MESSAGE
		local msgLabel = Instance.new("TextLabel", toast)
		msgLabel.BackgroundTransparency = 1
		msgLabel.Position = UDim2.new(0,14,0,30)
		msgLabel.Size = UDim2.new(1,-44,0,0)
		msgLabel.TextWrapped = true
		msgLabel.AutomaticSize = Enum.AutomaticSize.Y
		msgLabel.Text = tostring(message)
		msgLabel.Font = Theme.Font
		msgLabel.TextSize = 14
		msgLabel.TextColor3 = Theme.Text
		msgLabel.TextXAlignment = Enum.TextXAlignment.Left
		msgLabel.TextYAlignment = Enum.TextYAlignment.Top
		msgLabel.ZIndex = 103

		-- CLOSE BUTTON
		local close = Instance.new("TextButton", toast)
		close.Size = UDim2.new(0,24,0,24)
		close.Position = UDim2.new(1,-28,0,6)
		close.BackgroundTransparency = 1
		close.Text = "✕"
		close.Font = Theme.Font
		close.TextSize = 16
		close.TextColor3 = Theme.Text
		close.AutoButtonColor = false
		close.ZIndex = 104

		-- WAIT FOR LAYOUT
		msgLabel:GetPropertyChangedSignal("AbsoluteSize"):Wait()
		RunService.RenderStepped:Wait()

		local targetHeight = msgLabel.AbsoluteSize.Y + 44

		-- SHOW ANIMATION
		TweenService:Create(
			toast,
			TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Size = UDim2.new(1,0,0,targetHeight)}
		):Play()

		local function destroyToast()
			TweenService:Create(
				toast,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Size = UDim2.new(1,0,0,0),
					BackgroundTransparency = 1
				}
			):Play()
			task.delay(0.3, function()
				toast:Destroy()
			end)
		end

		close.MouseButton1Click:Connect(destroyToast)
		task.delay(duration, destroyToast)
	end

	-- PUBLIC API
	Library.Notify = function(title, message, nType, duration)
		NotificationService:Notify(title, message, nType, duration)
	end





	return Elements
end


--================ OPTIONAL SETTINGS TAB DEFINIEREN =================--
-- Funktion, die den Tab erstellt
local function CreateOptionalSettingsTab()
	local SettingsTab = Library:CreateTab("Settings")

	-- Inhalte Tab nur einmal definieren
	SettingsTab:Slider("GUI Transparency", 0, 1, currentTransparency, function(val)
		currentTransparency = val
		SetMainTransparency(val)
	end)

	SettingsTab:Toggle("Enable Blur", function(on)
		SetBlur(on, 20)
	end)

	SettingsTab:FullRGBPicker("Pick Color", Color3.fromRGB(255,0,0), function(color)
		SetMainBackgroundColor(color)
	end)

	local bgDropdown = SettingsTab:Dropdown("Background Color", {"Atlantic","Red","Purple","Cyan"}, function(opt)
		SetMainBackgroundColor(BgColors[opt])
	end)
	bgDropdown.refreshOnUpdate = true

	SettingsTab:Toggle("Enable Resize", function(on)
		ResizeHandle.Visible = on
	end)

	return SettingsTab
end

-- Überwachung, ob der Tab automatisch erstellt werden soll
-- Dies liest die Variable showOptionalSettings, sobald sie irgendwo gesetzt wird
task.spawn(function()
	-- Wartet bis showOptionalSettings definiert wird
	while _G.showOptionalSettings == nil do
		task.wait(0.05)
	end

	if _G.showOptionalSettings then
		CreateOptionalSettingsTab()
	end
end)
