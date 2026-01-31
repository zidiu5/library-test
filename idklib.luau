local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- HAUPT-CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TropicalLibrary_V4_Final"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- MAINFRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.8, 0, 0.8, 0) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundTransparency = 1 
MainFrame.Parent = ScreenGui

local uiAspect = Instance.new("UIAspectRatioConstraint")
uiAspect.AspectRatio = 1.6
uiAspect.Parent = MainFrame

-- HINTERGRUNDBILD
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Image = "rbxassetid://71741897452713" 
BackgroundImage.ScaleType = Enum.ScaleType.Stretch 
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame
Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0.08, 0)

-- TECH-RAHMEN
local techBorder = Instance.new("ImageLabel")
techBorder.Name = "TechBorder"
techBorder.Size = UDim2.new(1.17, 0, 1.31, 0) 
techBorder.Position = UDim2.new(0.505, 0, 0.445, 0) 
techBorder.AnchorPoint = Vector2.new(0.5, 0.5)
techBorder.BackgroundTransparency = 1
techBorder.Image = "rbxassetid://124068506440969"
techBorder.ZIndex = 0
techBorder.Parent = MainFrame

-- HEADER 
local TitleImage = Instance.new("ImageLabel")
TitleImage.Name = "TitleLogo"
TitleImage.Size = UDim2.new(1, 0, 0.24, 0)
TitleImage.Position = UDim2.new(0.5, 0, 0, 0)
TitleImage.AnchorPoint = Vector2.new(0.5, 0)
TitleImage.BackgroundTransparency = 1
TitleImage.Image = "rbxassetid://121594645524269"
TitleImage.ScaleType = Enum.ScaleType.Fit
TitleImage.ImageTransparency = 0.3
TitleImage.ZIndex = 5
TitleImage.Parent = MainFrame

-- LEFT SIDE
local LeftSide = Instance.new("Frame")
LeftSide.Size = UDim2.new(0.55, 0, 0.6, 0)
LeftSide.Position = UDim2.new(0.05, 0, 0.2, 0)
LeftSide.BackgroundTransparency = 1
LeftSide.ZIndex = 5
LeftSide.Parent = MainFrame

-- Tabs (Erweitert um Settings)
local TabScripts = Instance.new("TextButton")
TabScripts.Size = UDim2.new(0.3, 0, 0.15, 0)
TabScripts.BackgroundColor3 = Color3.fromRGB(255, 100, 70)
TabScripts.Text = "SCRIPTS"
TabScripts.TextColor3 = Color3.new(1,1,1)
TabScripts.Font = Enum.Font.GothamBold
TabScripts.ZIndex = 6
TabScripts.Parent = LeftSide
Instance.new("UICorner", TabScripts)

local TabGame = Instance.new("TextButton")
TabGame.Size = UDim2.new(0.3, 0, 0.15, 0)
TabGame.Position = UDim2.new(0.33, 0, 0, 0)
TabGame.BackgroundColor3 = Color3.fromRGB(30, 50, 50)
TabGame.Text = "GAME"
TabGame.TextColor3 = Color3.new(1,1,1)
TabGame.Font = Enum.Font.GothamBold
TabGame.ZIndex = 6
TabGame.Parent = LeftSide
Instance.new("UICorner", TabGame)

local TabSettings = Instance.new("TextButton")
TabSettings.Size = UDim2.new(0.3, 0, 0.15, 0)
TabSettings.Position = UDim2.new(0.66, 0, 0, 0)
TabSettings.BackgroundColor3 = Color3.fromRGB(30, 50, 50)
TabSettings.Text = "SETTINGS"
TabSettings.TextColor3 = Color3.new(1,1,1)
TabSettings.Font = Enum.Font.GothamBold
TabSettings.ZIndex = 6
TabSettings.Parent = LeftSide
Instance.new("UICorner", TabSettings)

-- Games Icons Box
local GamesBox = Instance.new("Frame")
GamesBox.Size = UDim2.new(1, 0, 0.18, 0)
GamesBox.Position = UDim2.new(0, 0, 0.19, 0)
GamesBox.BackgroundColor3 = Color3.new(0,0,0)
GamesBox.BackgroundTransparency = 0.5
GamesBox.ZIndex = 6
GamesBox.Parent = LeftSide
Instance.new("UICorner", GamesBox)
local UIListG = Instance.new("UIListLayout", GamesBox)
UIListG.FillDirection = Enum.FillDirection.Horizontal
UIListG.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListG.VerticalAlignment = Enum.VerticalAlignment.Center
UIListG.Padding = UDim.new(0, 10)

-- Pages Container
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, 0, 0.62, 0)
Pages.Position = UDim2.new(0, 0, 0.38, 0)
Pages.BackgroundTransparency = 1
Pages.ZIndex = 6
Pages.Parent = LeftSide

-- Scrolling Frame Loader
local function createScrollPage()
	local sf = Instance.new("ScrollingFrame")
	sf.Size = UDim2.new(1, 0, 1, 0)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0 
	sf.ScrollBarThickness = 4
	sf.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 230)
	sf.ZIndex = 7
	sf.CanvasSize = UDim2.new(0, 0, 0, 0) 
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	sf.ElasticBehavior = Enum.ElasticBehavior.Always 
	local layout = Instance.new("UIListLayout", sf)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 5)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		sf.ScrollingEnabled = layout.AbsoluteContentSize.Y > sf.AbsoluteSize.Y
	end)
	return sf
end

local ScriptsPage = createScrollPage()
ScriptsPage.Parent = Pages

local GamePage = createScrollPage()
GamePage.Visible = false
GamePage.Parent = Pages

local SettingsPage = createScrollPage()
SettingsPage.Visible = false
SettingsPage.Parent = Pages

-- RIGHT SIDE (Executor)
local ExecFrame = Instance.new("Frame")
ExecFrame.Size = UDim2.new(0.33, 0, 0.65, 0)
ExecFrame.Position = UDim2.new(0.62, 0, 0.2, 0)
ExecFrame.BackgroundColor3 = Color3.fromRGB(5, 15, 15)
ExecFrame.BackgroundTransparency = 0.3
ExecFrame.ZIndex = 5
ExecFrame.ClipsDescendants = true 
ExecFrame.Parent = MainFrame
Instance.new("UICorner", ExecFrame)

local CodeScroll = Instance.new("ScrollingFrame")
CodeScroll.Size = UDim2.new(0.91, 0, 0.76, 0)
CodeScroll.Position = UDim2.new(0.045, 0, 0.03, 0)
CodeScroll.BackgroundTransparency = 0.5
CodeScroll.BackgroundColor3 = Color3.new(0,0,0)
CodeScroll.BorderSizePixel = 0
CodeScroll.ZIndex = 6
CodeScroll.ScrollBarThickness = 4
CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 230)
CodeScroll.ScrollingDirection = Enum.ScrollingDirection.Y
CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0) 
CodeScroll.Parent = ExecFrame
Instance.new("UICorner", CodeScroll)

local CodeEditor = Instance.new("TextBox")
CodeEditor.Size = UDim2.new(1, 0, 1, 0)
CodeEditor.BackgroundTransparency = 1 
CodeEditor.Text = ""
CodeEditor.PlaceholderText = "-- Paste Script here..."
CodeEditor.TextColor3 = Color3.fromRGB(0, 255, 150)
CodeEditor.ClearTextOnFocus = false
CodeEditor.MultiLine = true
CodeEditor.TextXAlignment = Enum.TextXAlignment.Left
CodeEditor.TextYAlignment = Enum.TextYAlignment.Top
CodeEditor.Font = Enum.Font.Code
CodeEditor.TextSize = 14
CodeEditor.TextWrapped = true 
CodeEditor.ZIndex = 7
CodeEditor.Parent = CodeScroll

local pad = Instance.new("UIPadding", CodeEditor)
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)

local function fullRefresh()
	CodeEditor.Size = UDim2.new(1, 0, 0, 100000) 
	task.wait()
	local textHeight = CodeEditor.TextBounds.Y
	local frameHeight = CodeScroll.AbsoluteSize.Y
	local finalHeight = math.max(frameHeight, textHeight + 40)
	CodeEditor.Size = UDim2.new(1, 0, 0, finalHeight)
	CodeScroll.CanvasSize = UDim2.new(0, 0, 0, finalHeight)
end

CodeEditor:GetPropertyChangedSignal("Text"):Connect(fullRefresh)
CodeEditor.Focused:Connect(fullRefresh)

-- UTILITY BUTTONS
local UtilHolder = Instance.new("Frame")
UtilHolder.Size = UDim2.new(0.9, 0, 0.12, 0)
UtilHolder.Position = UDim2.new(0.05, 0, 0.68, 0)
UtilHolder.BackgroundTransparency = 1
UtilHolder.Parent = ExecFrame

local utilLayout = Instance.new("UIListLayout", UtilHolder)
utilLayout.FillDirection = Enum.FillDirection.Horizontal
utilLayout.Padding = UDim.new(0, 4)
utilLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createUtilBtn(name, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.31, 0, 1, 0)
	btn.BackgroundColor3 = color
	btn.Text = name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 10
	btn.ZIndex = 8
	btn.Parent = UtilHolder
	Instance.new("UICorner", btn)
	return btn
end

local PasteBtn = createUtilBtn("PASTE", Color3.fromRGB(50, 150, 50))
local ClearBtn = createUtilBtn("CLEAR", Color3.fromRGB(150, 50, 50))
local CopyBtn = createUtilBtn("COPY", Color3.fromRGB(60, 60, 60))

local ExecHolder = Instance.new("Frame")
ExecHolder.Size = UDim2.new(0.9, 0, 0.15, 0)
ExecHolder.Position = UDim2.new(0.05, 0, 0.82, 0)
ExecHolder.BackgroundTransparency = 1
ExecHolder.Parent = ExecFrame

local execLayout = Instance.new("UIListLayout", ExecHolder)
execLayout.FillDirection = Enum.FillDirection.Horizontal
execLayout.Padding = UDim.new(0, 5)

local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0.48, 0, 1, 0)
RunBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
RunBtn.Text = "EXECUTE"
RunBtn.TextColor3 = Color3.new(1,1,1)
RunBtn.Font = Enum.Font.GothamBold
RunBtn.ZIndex = 8
RunBtn.Parent = ExecHolder
Instance.new("UICorner", RunBtn)

local ExecClipBtn = Instance.new("TextButton")
ExecClipBtn.Size = UDim2.new(0.48, 0, 1, 0)
ExecClipBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
ExecClipBtn.Text = "EXEC CLIP"
ExecClipBtn.TextColor3 = Color3.new(1,1,1)
ExecClipBtn.Font = Enum.Font.GothamBold
ExecClipBtn.ZIndex = 8
ExecClipBtn.Parent = ExecHolder
Instance.new("UICorner", ExecClipBtn)


-- NOTIFICATION SERVICE CONFIG
local NotificationService = {}

local NotificationColors = {
	Info    = Color3.fromRGB(0, 255, 200), -- Dein Theme.Accent
	Success = Color3.fromRGB(0, 200, 120),
	Warning = Color3.fromRGB(255, 180, 0),
	Error   = Color3.fromRGB(255, 80, 80)
}

-- Holder für die Benachrichtigungen
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.Parent = ScreenGui -- Nutzt dein existierendes ScreenGui
NotificationHolder.Size = UDim2.new(0, 280, 1, -20)
NotificationHolder.Position = UDim2.new(1, -290, 0, 10)
NotificationHolder.BackgroundTransparency = 1

local notifyLayout = Instance.new("UIListLayout", NotificationHolder)
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.Padding = UDim.new(0, 10)

function NotificationService:Notify(title, message, nType, duration)
	nType = nType or "Info"
	duration = duration or 5
	local accentColor = NotificationColors[nType] or NotificationColors.Info

	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.new(1, 0, 0, 70)
	toast.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Dunkler Hintergrund für Kontrast
	toast.BorderSizePixel = 0
	toast.Parent = NotificationHolder
	toast.ClipsDescendants = true
	toast.Transparency = 1 -- Für Animation

	local corner = Instance.new("UICorner", toast)
	corner.CornerRadius = UDim.new(0, 6)

	local stroke = Instance.new("UIStroke", toast)
	stroke.Color = accentColor
	stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = 1

	-- Sidebar (Farblicher Akzentstreifen links)
	local sideBar = Instance.new("Frame", toast)
	sideBar.Size = UDim2.new(0, 4, 1, 0)
	sideBar.BackgroundColor3 = accentColor
	sideBar.BorderSizePixel = 0

	local titleL = Instance.new("TextLabel", toast)
	titleL.Size = UDim2.new(1, -60, 0, 25)
	titleL.Position = UDim2.new(0, 12, 0, 8)
	titleL.BackgroundTransparency = 1
	titleL.Text = title
	titleL.TextColor3 = accentColor
	titleL.Font = Enum.Font.GothamBold
	titleL.TextSize = 14
	titleL.TextXAlignment = Enum.TextXAlignment.Left

	local msgL = Instance.new("TextLabel", toast)
	msgL.Size = UDim2.new(1, -40, 0, 30)
	msgL.Position = UDim2.new(0, 12, 0, 28)
	msgL.BackgroundTransparency = 1
	msgL.Text = message
	msgL.TextColor3 = Color3.fromRGB(200, 200, 200)
	msgL.Font = Enum.Font.Gotham
	msgL.TextSize = 12
	msgL.TextWrapped = true
	msgL.TextXAlignment = Enum.TextXAlignment.Left
	msgL.TextYAlignment = Enum.TextYAlignment.Top

	-- Close Button
	local close = Instance.new("TextButton", toast)
	close.Size = UDim2.new(0, 24, 0, 24)
	close.Position = UDim2.new(1, -28, 0, 6)
	close.BackgroundTransparency = 1
	close.Text = "✕"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.TextColor3 = Color3.fromRGB(150, 150, 150)
	close.AutoButtonColor = false
	close.ZIndex = 103

	-- Animationen & Logik
	local function dismiss()
		TweenService:Create(toast, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), Transparency = 1}):Play()
		task.wait(0.3)
		toast:Destroy()
	end

	close.MouseButton1Click:Connect(dismiss)
	close.MouseEnter:Connect(function() close.TextColor3 = Color3.new(1, 1, 1) end)
	close.MouseLeave:Connect(function() close.TextColor3 = Color3.fromRGB(150, 150, 150) end)

	-- Intro Animation
	toast.Position = UDim2.new(1.2, 0, 0, 0)
	TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0), Transparency = 0.1}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 0.6}):Play()

	task.delay(duration, function()
		if toast and toast.Parent then
			dismiss()
		end
	end)
end

-- BUTTON LOGIC
PasteBtn.MouseButton1Click:Connect(function()
	if getclipboard then CodeEditor.Text = getclipboard() fullRefresh() end
end)

ClearBtn.MouseButton1Click:Connect(function()
	CodeEditor.Text = ""
	local minH = CodeScroll.AbsoluteSize.Y
	CodeEditor.Size = UDim2.new(1, 0, 0, minH)
	CodeScroll.CanvasSize = UDim2.new(0, 0, 0, minH)
end)

CopyBtn.MouseButton1Click:Connect(function()
	if setclipboard then setclipboard(CodeEditor.Text) end
end)

ExecClipBtn.MouseButton1Click:Connect(function()
	if getclipboard then
		local success, err = pcall(function() loadstring(getclipboard())() end)
		if not success then warn("Clip Error: " .. err) end
	end
end)

RunBtn.MouseButton1Click:Connect(function()
	-- Wir versuchen das Script auszuführen
	local success, err = pcall(function() 
		local func = loadstring(CodeEditor.Text)
		if func then
			func()
		else
			error("Syntax Error in Script") -- Falls loadstring fehlschlägt
		end
	end)

	if success then
		-- Benutzt jetzt den NotificationService mit dem Typ "Success"
		NotificationService:Notify("EXECUTION", "Script executed successfully!", "Success", 3)
	else
		-- Benutzt jetzt den NotificationService mit dem Typ "Error"
		NotificationService:Notify("EXECUTION ERROR", "Check F9 Console for details", "Error", 5)
		warn("Exec Error: " .. tostring(err))
	end
end)

-- USER FOOTER
local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(0, 30, 0, 30)
Footer.Position = UDim2.new(0.05, 0, 0.85, 0)
Footer.BackgroundTransparency = 1
Footer.ZIndex = 5
Footer.Parent = MainFrame

local ProfileImg = Instance.new("ImageLabel")
ProfileImg.Size = UDim2.new(1, 0, 1, 0)
ProfileImg.Position = UDim2.new(0, 0, 0, 0)
ProfileImg.Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
ProfileImg.ZIndex = 6
ProfileImg.Parent = Footer
Instance.new("UICorner", ProfileImg).CornerRadius = UDim.new(1, 0)

local Welcome = Instance.new("TextLabel")
Welcome.Position = UDim2.new(2.3, 0, 0, 0)
Welcome.Size = UDim2.new(1, -60, 1, 0)
Welcome.Text = "Welcome, " .. LocalPlayer.Name .. "!"
Welcome.TextColor3 = Color3.new(1,1,1)
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.BackgroundTransparency = 1
Welcome.Font = Enum.Font.GothamMedium
Welcome.TextSize = 18
Welcome.ZIndex = 6
Welcome.Parent = Footer

-- PAGE LOGIC
local function addScript(parent, name, code)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0.2, 0)
	btn.BackgroundColor3 = Color3.fromRGB(20, 40, 45)
	btn.BackgroundTransparency = 0.4
	btn.Text = "    " .. name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 8
	btn.Parent = parent
	Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(function() CodeEditor.Text = code end)
end

local function showPage(pageName)
	ScriptsPage.Visible = (pageName == "Scripts")
	GamePage.Visible = (pageName == "Game")
	SettingsPage.Visible = (pageName == "Settings")
	TabScripts.BackgroundColor3 = (pageName == "Scripts") and Color3.fromRGB(255, 100, 70) or Color3.fromRGB(30, 50, 50)
	TabGame.BackgroundColor3 = (pageName == "Game") and Color3.fromRGB(255, 100, 70) or Color3.fromRGB(30, 50, 50)
	TabSettings.BackgroundColor3 = (pageName == "Settings") and Color3.fromRGB(255, 100, 70) or Color3.fromRGB(30, 50, 50)
end

TabScripts.MouseButton1Click:Connect(function() showPage("Scripts") end)
TabGame.MouseButton1Click:Connect(function() showPage("Game") end)
TabSettings.MouseButton1Click:Connect(function() showPage("Settings") end)

local function addGame(name, color, content)
	local g = Instance.new("TextButton")
	g.Size = UDim2.new(0.09, 0, 0.7, 0)
	g.BackgroundColor3 = color
	g.Text = ""
	g.ZIndex = 7
	g.Parent = GamesBox
	Instance.new("UICorner", g)

	g.MouseButton1Click:Connect(function()
		-- REINIGUNG: Löscht absolut ALLES in der GamePage (Buttons, TextBoxen, Slider, Frames)
		for _, child in pairs(GamePage:GetChildren()) do
			if child:IsA("GuiObject") then -- Erwischt alles Visuelle außer Layouts
				child:Destroy()
			end
		end

		-- Inhalt neu laden
		if type(content) == "function" then
			content() 
		elseif type(content) == "table" then
			for _, s in pairs(content) do 
				addScript(GamePage, s.n, s.c) 
			end
		end

		TabGame.Text = name:upper()
		showPage("Game")
	end)
end



-- ==========================================
-- ERWEITERTE LIBRARY-ELEMENTE (Voll kompatibel)
-- ==========================================

-- BUTTON
local function addExtraButton(parent, text, callback, tooltip)
	-- UI Element erstellen
	local b = Instance.new("TextButton")
	b.Name = text .. "_Button"
	b.Parent = parent
	b.Size = UDim2.new(1, 0, 0.2, 0) 
	b.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	b.BackgroundTransparency = 0.4
	b.Text = "    " .. text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Merriweather
	b.TextSize = 12
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.AutoButtonColor = false 
	b.ZIndex = 8
	Instance.new("UICorner", b)

	-- Hover & Click Effekte (Tropical Style)
	local baseColor = Color3.fromRGB(30, 50, 55)
	local hoverColor = Color3.fromRGB(40, 70, 80)
	local clickColor = Color3.fromRGB(0, 255, 200) 

	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor, BackgroundTransparency = 0.2}):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = baseColor, BackgroundTransparency = 0.4}):Play()
	end)

	b.MouseButton1Click:Connect(function()
		-- Kurzer Flash Effekt
		b.BackgroundColor3 = clickColor
		task.wait(0.1)
		b.BackgroundColor3 = hoverColor

		-- Callback sicher ausführen
		if callback then
			local success, err = pcall(callback)
			if not success then warn("Button Error: " .. err) end
		end
	end)

	-- Tooltip Logik (Falls Library:AddTooltip existiert)
	-- Library:AddTooltip(b, tooltip) 

	return b
end

-- TOGGLE
local function addToggle(parent, name, default, callback)
	local state = default
	local btn = Instance.new("TextButton", parent)
	btn.Name = name .. "_Toggle"
	btn.Size = UDim2.new(1, 0, 0, 25) 
	btn.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	btn.BackgroundTransparency = 0.4
	btn.Text = "    " .. name .. ": " .. (state and "ON" or "OFF")
	btn.TextColor3 = state and Color3.fromRGB(0, 255, 200) or Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Merriweather
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 8
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn)

	-- Visuelle Updates
	local function updateVisuals()
		local targetColor = state and Color3.fromRGB(0, 255, 200) or Color3.new(1, 1, 1)
		TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = targetColor}):Play()
		btn.Text = "    " .. name .. ": " .. (state and "ON" or "OFF")
	end

	btn.Activated:Connect(function()
		state = not state
		updateVisuals()
		if callback then 
			local success, err = pcall(function() callback(state) end)
			if not success then warn("Toggle Error: " .. err) end
		end
	end)

	-- Hover Effekt wie beim Button
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
	end)
	return btn
end

-- TEXTBOX
local function addTextBox(parent, placeholder, callback)
	local box = Instance.new("TextBox", parent)
	box.Name = placeholder .. "_TextBox"
	box.Size = UDim2.new(1, 0, 0.2, 0) 
	box.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	box.BackgroundTransparency = 0.4
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.Text = ""
	box.TextColor3 = Color3.fromRGB(0, 255, 200)
	box.Font = Enum.Font.Merriweather
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.ZIndex = 8

	local pad = Instance.new("UIPadding", box)
	pad.PaddingLeft = UDim.new(0, 15)
	Instance.new("UICorner", box)

	-- LIVE LOGIK: Reagiert sofort beim Tippen
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if callback then
			-- Wir geben nur den Text weiter, da enterPressed hier nicht existiert
			local success, err = pcall(function() callback(box.Text) end)
			if not success then warn("TextBox Live Error: " .. err) end
		end
	end)

	-- Hover & Focus Effekte bleiben für die Optik
	box.MouseEnter:Connect(function()
		TweenService:Create(box, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
	end)
	box.MouseLeave:Connect(function()
		if not box:IsFocused() then
			TweenService:Create(box, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
		end
	end)

	box.Focused:Connect(function()
		TweenService:Create(box, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
	end)
	box.FocusLost:Connect(function()
		TweenService:Create(box, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
	end)

	return box
end

-- SLIDER
local function addSlider(parent, label, min, max, default, precision, callback)
	precision = precision or 0
	local SliderObj = { _value = default, _enabled = true }

	local function round(number, decimals)
		local power = 10^(decimals or 0)
		return math.floor(number * power + 0.5) / power
	end

	local container = Instance.new("Frame", parent)
	container.Name = label .. "_Slider"
	container.Size = UDim2.new(1, 0, 0, 40)
	container.BackgroundTransparency = 1

	local textLabel = Instance.new("TextLabel", container)
	textLabel.Size = UDim2.new(1, -55, 0, 20)
	textLabel.Position = UDim2.new(0, 10, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = label .. ": " .. tostring(round(default))
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.Merriweather
	textLabel.TextSize = 12
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 5

	local sliderBack = Instance.new("Frame", container)
	sliderBack.Size = UDim2.new(1, -65, 0, 4)
	sliderBack.Position = UDim2.new(0, 10, 0, 28)
	sliderBack.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	sliderBack.BorderSizePixel = 0
	sliderBack.ZIndex = 5
	Instance.new("UICorner", sliderBack)

	local sliderFill = Instance.new("Frame", sliderBack)
	sliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
	sliderFill.BorderSizePixel = 0
	sliderFill.ZIndex = 6
	Instance.new("UICorner", sliderFill)

	-- TOGGLE BUTTON: ZIndex auf 15 erhöhen, damit er ÜBER dem TouchHandler liegt
	local toggleBtn = Instance.new("TextButton", container)
	toggleBtn.Size = UDim2.new(0, 40, 0, 22)
	toggleBtn.Position = UDim2.new(1, -45, 0, 8)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 55, 60)
	toggleBtn.Text = "ON"
	toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
	toggleBtn.Font = Enum.Font.Merriweather
	toggleBtn.TextSize = 10
	toggleBtn.ZIndex = 15 
	toggleBtn.Active = true -- Mobile Hitbox Aktivierung
	Instance.new("UICorner", toggleBtn)

	-- TOUCH HANDLER: ZIndex 10 (liegt unter dem ToggleBtn)
	local touchHandler = Instance.new("TextButton", sliderBack)
	touchHandler.Size = UDim2.new(1, 20, 5, 0)
	touchHandler.Position = UDim2.new(0, -10, -2, 0)
	touchHandler.BackgroundTransparency = 1
	touchHandler.Text = ""
	touchHandler.ZIndex = 10

	local dragging = false

	local function update(input)
		if not SliderObj._enabled then return end
		local x = math.clamp(input.Position.X - sliderBack.AbsolutePosition.X, 0, sliderBack.AbsoluteSize.X)
		local val = min + (x / sliderBack.AbsoluteSize.X) * (max - min)

		SliderObj._value = val
		sliderFill.Size = UDim2.new(math.clamp((val - min)/(max - min), 0, 1), 0, 1, 0)
		textLabel.Text = label .. ": " .. tostring(round(val))

		if callback then pcall(callback, val) end
	end

	-- Toggle Logik mit Mobile-Sicherung
	toggleBtn.Activated:Connect(function()
		SliderObj._enabled = not SliderObj._enabled
		if SliderObj._enabled then
			toggleBtn.Text = "ON"
			toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
			sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
		else
			toggleBtn.Text = "OFF"
			toggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
			sliderFill.BackgroundColor3 = Color3.fromRGB(170, 0, 3)
		end
		if callback then pcall(callback, SliderObj._value) end
	end)

	-- Slider Dragging Logik
	touchHandler.InputBegan:Connect(function(input)
		if not SliderObj._enabled then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local scroll = container:FindFirstAncestorOfClass("ScrollingFrame")
			if scroll then scroll.ScrollingEnabled = false end
			update(input)
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			local scroll = container:FindFirstAncestorOfClass("ScrollingFrame")
			if scroll then scroll.ScrollingEnabled = true end
		end
	end)

	return SliderObj
end

-- DROPDOWN
local function addDropdown(parent, label, options, multiselect, callback)
	local DropdownObject = {
		opened = false,
		selection = {},
		options = options or {}
	}

	-- Haupt-Container: Er kontrolliert, was man sieht
	local container = Instance.new("Frame", parent)
	container.Name = label .. "_Dropdown"
	container.Size = UDim2.new(1, 0, 0, 25) -- Startet klein
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true -- WICHTIG: Schneidet Optionen beim Schließen ab
	container.ZIndex = 5

	local title = Instance.new("TextButton", container)
	title.Size = UDim2.new(1, 0, 0, 25)
	title.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	title.BackgroundTransparency = 0.4
	title.Text = "    " .. label .. "  ▼"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.Merriweather
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.AutoButtonColor = false
	title.ZIndex = 7 
	Instance.new("UICorner", title)

	-- OptionContainer: Ist immer voll da, wird aber vom Parent versteckt
	local optionContainer = Instance.new("Frame", container)
	optionContainer.Position = UDim2.new(0, 0, 0, 35)
	optionContainer.Size = UDim2.new(1, 0, 0, 500) 
	optionContainer.BackgroundTransparency = 1
	optionContainer.ZIndex = 6

	local layout = Instance.new("UIListLayout", optionContainer)
	layout.Padding = UDim.new(0, 5)

	local function buildOptions()
		for _, child in pairs(optionContainer:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end

		for _, opt in pairs(DropdownObject.options) do
			local oBtn = Instance.new("TextButton", optionContainer)
			oBtn.Size = UDim2.new(1, 0, 0, 25)
			oBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 45)
			oBtn.BackgroundTransparency = 0.4
			oBtn.Text = multiselect and "      [ ] " .. tostring(opt) or "      " .. tostring(opt)
			oBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			oBtn.Font = Enum.Font.Merriweather
			oBtn.TextSize = 11
			oBtn.TextXAlignment = Enum.TextXAlignment.Left
			oBtn.ZIndex = 7
			Instance.new("UICorner", oBtn)

			oBtn.Activated:Connect(function()
				if multiselect then
					DropdownObject.selection[opt] = not DropdownObject.selection[opt]
					oBtn.Text = DropdownObject.selection[opt] and "      [X] " .. tostring(opt) or "      [ ] " .. tostring(opt)
					oBtn.TextColor3 = DropdownObject.selection[opt] and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(200, 200, 200)
					if callback then pcall(callback, opt, DropdownObject.selection[opt], DropdownObject.selection) end
				else
					title.Text = "    " .. label .. ": " .. tostring(opt) .. "  ▼"
					DropdownObject.opened = false
					TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 25)}):Play()
					if callback then pcall(callback, opt) end
				end
			end)
		end
	end

	buildOptions()

	title.Activated:Connect(function()
		DropdownObject.opened = not DropdownObject.opened

		-- Wir animieren die Größe des ÄUẞEREN Containers
		local targetHeight = DropdownObject.opened and (45 + layout.AbsoluteContentSize.Y + 5) or 25

		TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
			Size = UDim2.new(1, 0, 0, targetHeight)
		}):Play()

		title.Text = "    " .. label .. (DropdownObject.opened and "  ▲" or "  ▼")
	end)

	return DropdownObject
end

-- DROPDOWN SEARCH
local function addDropdownSearch(parent, label, options, multiselect, callback)
	local Dropdown = {
		opened = false,
		options = options or {},
		selection = {}
	}

	local container = Instance.new("Frame", parent)
	container.Name = label .. "_SearchDropdown"
	container.Size = UDim2.new(1, 0, 0, 25)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.ZIndex = 5 -- Basis Ebene

	local title = Instance.new("TextButton", container)
	title.Size = UDim2.new(1, 0, 0, 25)
	title.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	title.BackgroundTransparency = 0.4
	title.Text = "    " .. label .. "  ▼"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.Merriweather
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.AutoButtonColor = false
	title.ZIndex = 10 -- Über dem Container
	Instance.new("UICorner", title)

	local body = Instance.new("Frame", container)
	body.Position = UDim2.new(0, 0, 0, 30)
	body.Size = UDim2.new(1, 0, 0, 0)
	body.BackgroundTransparency = 1
	body.ZIndex = 10 -- Gleiche Ebene wie Title

	local search = Instance.new("TextBox", body)
	search.Size = UDim2.new(1, 0, 0, 25)
	search.BackgroundColor3 = Color3.fromRGB(20, 40, 45)
	search.BackgroundTransparency = 0.3
	search.PlaceholderText = "Search..."
	search.Text = ""
	search.TextColor3 = Color3.fromRGB(0, 255, 200)
	search.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	search.Font = Enum.Font.Merriweather
	search.TextSize = 11
	search.ZIndex = 15 -- HÖCHSTE PRIORITÄT (Damit sie auf Mobile klickbar ist)
	search.Active = true -- Wichtig für Input
	Instance.new("UICorner", search)

	local searchPad = Instance.new("UIPadding", search)
	searchPad.PaddingLeft = UDim.new(0, 10)

	local optionHolder = Instance.new("Frame", body)
	optionHolder.Position = UDim2.new(0, 0, 0, 30)
	optionHolder.Size = UDim2.new(1, 0, 0, 0)
	optionHolder.BackgroundTransparency = 1
	optionHolder.ZIndex = 10

	local layout = Instance.new("UIListLayout", optionHolder)
	layout.Padding = UDim.new(0, 5)

	local function updateHeight()
		if not Dropdown.opened then return end
		local targetHeight = 30 + 30 + layout.AbsoluteContentSize.Y + 5
		TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
	end

	local function build(filter)
		for _, v in pairs(optionHolder:GetChildren()) do
			if v:IsA("TextButton") then v:Destroy() end
		end
		filter = filter and filter:lower() or ""
		for _, opt in pairs(Dropdown.options) do
			if filter == "" or tostring(opt):lower():find(filter) then
				local oBtn = Instance.new("TextButton", optionHolder)
				oBtn.Size = UDim2.new(1, 0, 0, 25)
				oBtn.BackgroundColor3 = Color3.fromRGB(25, 45, 50)
				oBtn.BackgroundTransparency = 0.4
				oBtn.Text = multiselect and (Dropdown.selection[opt] and "      [X] " or "      [ ] ") .. tostring(opt) or "      " .. tostring(opt)
				oBtn.TextColor3 = (multiselect and Dropdown.selection[opt]) and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(200, 200, 200)
				oBtn.Font = Enum.Font.Merriweather
				oBtn.TextSize = 11
				oBtn.TextXAlignment = Enum.TextXAlignment.Left
				oBtn.ZIndex = 12 -- Unter der Searchbar, aber über dem Background
				Instance.new("UICorner", oBtn)

				oBtn.Activated:Connect(function()
					if multiselect then
						Dropdown.selection[opt] = not Dropdown.selection[opt]
						oBtn.Text = (Dropdown.selection[opt] and "      [X] " or "      [ ] ") .. tostring(opt)
						oBtn.TextColor3 = Dropdown.selection[opt] and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(200, 200, 200)
						if callback then pcall(callback, opt, Dropdown.selection[opt], Dropdown.selection) end
					else
						title.Text = "    " .. label .. ": " .. tostring(opt) .. "  ▼"
						Dropdown.opened = false
						TweenService:Create(container, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 25)}):Play()
						if callback then pcall(callback, opt) end
					end
				end)
			end
		end
		updateHeight()
	end

	search:GetPropertyChangedSignal("Text"):Connect(function()
		build(search.Text)
	end)

	title.Activated:Connect(function()
		Dropdown.opened = not Dropdown.opened
		if Dropdown.opened then
			container.ZIndex = 100 -- Ganze Gruppe nach vorn
			build(search.Text)
		else
			task.delay(0.3, function() if not Dropdown.opened then container.ZIndex = 5 end end)
			TweenService:Create(container, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 25)}):Play()
		end
		title.Text = "    " .. label .. (Dropdown.opened and "  ▲" or "  ▼")
	end)

	return Dropdown
end

-- DUAL SLIDER
local function addDualSlider(parent, label, min, max, defMin, defMax, callback)
	local DualSlider = { minVal = defMin, maxVal = defMax }

	local container = Instance.new("Frame", parent)
	container.Name = label .. "_DualSlider"
	container.Size = UDim2.new(1, 0, 0, 50)
	container.BackgroundTransparency = 1

	local textLabel = Instance.new("TextLabel", container)
	textLabel.Size = UDim2.new(1, -110, 0, 20)
	textLabel.Position = UDim2.new(0, 10, 0, 5)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = label
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.Merriweather
	textLabel.TextSize = 12
	textLabel.TextXAlignment = Enum.TextXAlignment.Left

	local function createInput(posX, default)
		local box = Instance.new("TextBox", container)
		box.Size = UDim2.new(0, 40, 0, 20)
		box.Position = UDim2.new(1, posX, 0, 5)
		box.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
		box.TextColor3 = Color3.fromRGB(0, 255, 200)
		box.Text = tostring(default)
		box.Font = Enum.Font.Merriweather
		box.TextSize = 10
		box.ZIndex = 15
		box.Active = true
		Instance.new("UICorner", box)
		return box
	end

	local inMin = createInput(-95, defMin)
	local inMax = createInput(-45, defMax)

	local sliderBack = Instance.new("Frame", container)
	sliderBack.Size = UDim2.new(1, -30, 0, 4)
	sliderBack.Position = UDim2.new(0, 15, 0, 35)
	sliderBack.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	sliderBack.ZIndex = 5
	Instance.new("UICorner", sliderBack)

	local fill = Instance.new("Frame", sliderBack)
	fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
	fill.ZIndex = 6
	Instance.new("UICorner", fill)

	local function createKnob()
		local knob = Instance.new("TextButton", sliderBack)
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Text = ""
		knob.ZIndex = 12
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
		local stroke = Instance.new("UIStroke", knob)
		stroke.Color = Color3.fromRGB(0, 255, 200)
		stroke.Thickness = 2
		return knob
	end

	local btnMin = createKnob()
	local btnMax = createKnob()

	-- DIESE FUNKTION FIXT DEIN PROBLEM:
	local function updateUI(updateText)
		local relMin = math.clamp((DualSlider.minVal - min) / (max - min), 0, 1)
		local relMax = math.clamp((DualSlider.maxVal - min) / (max - min), 0, 1)

		-- Knobs sofort an die berechnete Position setzen
		btnMin.Position = UDim2.fromScale(relMin, 0.5)
		btnMax.Position = UDim2.fromScale(relMax, 0.5)

		-- Fill Balken anpassen
		fill.Position = UDim2.fromScale(relMin, 0)
		fill.Size = UDim2.fromScale(relMax - relMin, 1)

		if updateText then
			inMin.Text = tostring(math.floor(DualSlider.minVal))
			inMax.Text = tostring(math.floor(DualSlider.maxVal))
		end
	end

	local function setupDrag(button, isMin)
		local dragging = false
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local scroll = container:FindFirstAncestorOfClass("ScrollingFrame")
				if scroll then scroll.ScrollingEnabled = false end
			end
		end)

		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local x = math.clamp(input.Position.X - sliderBack.AbsolutePosition.X, 0, sliderBack.AbsoluteSize.X)
				local val = min + (x / sliderBack.AbsoluteSize.X) * (max - min)

				if isMin then
					DualSlider.minVal = math.clamp(math.floor(val), min, DualSlider.maxVal - 1)
				else
					DualSlider.maxVal = math.clamp(math.floor(val), DualSlider.minVal + 1, max)
				end

				updateUI(true) -- Text mit-aktualisieren beim Ziehen
				if callback then pcall(callback, DualSlider.minVal, DualSlider.maxVal) end
			end
		end)

		game:GetService("UserInputService").InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				local scroll = container:FindFirstAncestorOfClass("ScrollingFrame")
				if scroll then scroll.ScrollingEnabled = true end
			end
		end)
	end

	-- Textbox Logik (Fix: Aktualisiert Knobs nach Eingabe)
	local function handleInput(box, isMin)
		box.FocusLost:Connect(function()
			local n = tonumber(box.Text)
			if n then
				if isMin then 
					DualSlider.minVal = math.clamp(math.floor(n), min, DualSlider.maxVal - 1)
				else 
					DualSlider.maxVal = math.clamp(math.floor(n), DualSlider.minVal + 1, max) 
				end
			end
			updateUI(true) -- Knobs an neue Text-Position springen lassen
			if callback then pcall(callback, DualSlider.minVal, DualSlider.maxVal) end
		end)
	end

	setupDrag(btnMin, true)
	setupDrag(btnMax, false)
	handleInput(inMin, true)
	handleInput(inMax, false)

	updateUI(true)
	return DualSlider
end

-- LABEL
local function addLabel(parent, text)
	local LabelObj = {}

	-- Container für korrektes Padding
	local container = Instance.new("Frame", parent)
	container.Name = text .. "_Label"
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel", container)
	lbl.Size = UDim2.new(1, -10, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0) -- Ein kleines Einrücken sieht edler aus
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.Merriweather
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200) -- Etwas weicheres Weiß
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 5

	-- API: Text nachträglich ändern
	function LabelObj:Set(newText)
		lbl.Text = newText
	end

	-- API: Farbe ändern (z.B. für Warnungen)
	function LabelObj:SetColor(color)
		lbl.TextColor3 = color
	end

	return LabelObj
end

-- KEYBIND
local function addKeybind(parent, label, defaultKey, callback)
	local Keybind = { key = defaultKey, _listening = false }
	local UIS = game:GetService("UserInputService")

	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0.2, 0)
	container.BackgroundTransparency = 1

	local btn = Instance.new("TextButton", container)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Position = UDim2.new(0, 0, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 50, 55)
	btn.BackgroundTransparency = 0.4
	btn.Text = "    " .. label 
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Merriweather
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 5
	Instance.new("UICorner", btn)

	-- ...und nutzen NUR dieses Label rechts für die Anzeige des Keys
	local keyDisplay = Instance.new("TextLabel", btn)
	keyDisplay.Size = UDim2.new(0, 100, 1, 0)
	keyDisplay.Position = UDim2.new(1, -110, 0, 0)
	keyDisplay.BackgroundTransparency = 1
	keyDisplay.Text = "[" .. tostring(Keybind.key) .. "]"
	keyDisplay.TextColor3 = Color3.fromRGB(0, 255, 200)
	keyDisplay.Font = Enum.Font.Merriweather
	keyDisplay.TextSize = 11
	keyDisplay.TextXAlignment = Enum.TextXAlignment.Right
	keyDisplay.ZIndex = 6

	local function updateUI(isListening)
		Keybind._listening = isListening
		if isListening then
			keyDisplay.Text = "[...]"
			keyDisplay.TextColor3 = Color3.fromRGB(255, 200, 0) -- Orange beim Warten
		else
			keyDisplay.Text = "[" .. tostring(Keybind.key) .. "]"
			keyDisplay.TextColor3 = Color3.fromRGB(0, 255, 200) -- Tropical Green wenn fertig
		end
	end

	btn.Activated:Connect(function()
		if UIS.TouchEnabled and not UIS.KeyboardEnabled then
			keyDisplay.Text = "[N/A PC]"
			task.delay(1, function() updateUI(false) end)
			return 
		end
		updateUI(true)
	end)

	UIS.InputBegan:Connect(function(input, processed)
		if Keybind._listening and input.UserInputType == Enum.UserInputType.Keyboard then
			-- Verhindert, dass man Escape oder Tab als Keybind nutzt (optional)
			if input.KeyCode == Enum.KeyCode.Escape then
				updateUI(false)
				return
			end

			Keybind.key = input.KeyCode.Name
			updateUI(false) -- Hier wird jetzt der neue Key sofort angezeigt

			if callback then 
				pcall(callback, Keybind.key) 
			end
		end
	end)

	return Keybind
end

-- TOOLTIPP
local function addTooltip(element, infoText, duration)
	if not element or not infoText or infoText == "" then return end
	local showTime = duration or 5

	local function fastTween(obj, time, prop)
		game:GetService("TweenService"):Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), prop):Play()
	end

	-- Falls das Element ClipsDescendants hat, müssen wir es für den Tooltip kurz ausschalten
	-- oder sicherstellen, dass alles INSIDE ist.
	element.ClipsDescendants = true 

	local helpBtn = Instance.new("TextButton", element)
	helpBtn.Name = "HelpBtn"
	helpBtn.Size = UDim2.new(0, 20, 0, 20)
	-- Position etwas weiter links (-35 statt -25), um sicherzugehen
	helpBtn.Position = UDim2.new(0.9, 0, 0.15, 0) 
	helpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	helpBtn.Text = "?"
	helpBtn.Font = Enum.Font.GothamBold
	helpBtn.TextSize = 12
	helpBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
	helpBtn.ZIndex = 100 -- EXTREM HOCH
	Instance.new("UICorner", helpBtn).CornerRadius = UDim.new(1, 0)

	local stroke = Instance.new("UIStroke", helpBtn)
	stroke.Color = Color3.fromRGB(0, 255, 200)
	stroke.Thickness = 1.5

	local infoLabel = Instance.new("TextLabel", element)
	infoLabel.Size = UDim2.new(1, 0, 1, 0)
	infoLabel.Position = UDim2.new(0, 0, 0, 0)
	infoLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	infoLabel.TextColor3 = Color3.new(1, 1, 1)
	infoLabel.Text = " " .. infoText
	infoLabel.Font = Enum.Font.Merriweather
	infoLabel.TextSize = 12
	infoLabel.ZIndex = 200 -- NOCH HÖHER
	infoLabel.Visible = false
	Instance.new("UICorner", infoLabel)

	local progressBar = Instance.new("Frame", infoLabel)
	progressBar.Size = UDim2.new(1, 0, 0, 3)
	progressBar.Position = UDim2.new(0, 0, 1, -3)
	progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
	progressBar.ZIndex = 201

	local showing = false
	helpBtn.Activated:Connect(function()
		if showing then return end
		showing = true

		infoLabel.Visible = true
		infoLabel.BackgroundTransparency = 1
		infoLabel.TextTransparency = 1

		fastTween(infoLabel, 0.3, {BackgroundTransparency = 0, TextTransparency = 0})

		local t = game:GetService("TweenService"):Create(progressBar, TweenInfo.new(showTime, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})
		t:Play()

		task.wait(showTime)

		fastTween(infoLabel, 0.3, {BackgroundTransparency = 1, TextTransparency = 1})
		task.wait(0.3)
		infoLabel.Visible = false
		progressBar.Size = UDim2.new(1, 0, 0, 3) -- Reset für nächstes Mal
		showing = false
	end)
end

-- SECTION
local function addSection(parent, title, defaultOpened)
	local opened = (defaultOpened ~= nil) and defaultOpened or false

	-- Haupt Container (Wird direkt ins ScrollingFrame gepackt)
	local sectionContainer = Instance.new("Frame", parent)
	sectionContainer.Name = title .. "_Section"
	sectionContainer.Size = UDim2.new(1, 0, 0, 35) -- Start-Höhe (nur Header)
	sectionContainer.BackgroundTransparency = 1
	sectionContainer.ClipsDescendants = true

	-- Header Button
	local header = Instance.new("TextButton", sectionContainer)
	header.Size = UDim2.new(1, -10, 0, 30)
	header.Position = UDim2.new(0, 5, 0, 0)
	header.BackgroundColor3 = Color3.fromRGB(20, 35, 40)
	header.BackgroundTransparency = 0.3
	header.Text = ""
	header.AutoButtonColor = false
	Instance.new("UICorner", header)
	header.ZIndex = 10

	local stroke = Instance.new("UIStroke", header)
	stroke.Color = Color3.fromRGB(0, 255, 200)
	stroke.Thickness = 1
	stroke.Transparency = 0.5

	local sectionTitle = Instance.new("TextLabel", header)
	sectionTitle.Size = UDim2.new(1, -40, 1, 0)
	sectionTitle.Position = UDim2.new(0, 12, 0, 0)
	sectionTitle.BackgroundTransparency = 1
	sectionTitle.Text = title:upper()
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.TextSize = 12
	sectionTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left

	local arrow = Instance.new("TextLabel", header)
	arrow.Size = UDim2.new(0, 30, 1, 0)
	arrow.Position = UDim2.new(1, -30, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = opened and "▼" or "▲"
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 12
	arrow.TextColor3 = Color3.fromRGB(0, 255, 200)

	-- Content Holder (Hier kommen die Toggles/Slider rein)
	local content = Instance.new("Frame", sectionContainer)
	content.Position = UDim2.new(0, 10, 0, 35)
	content.Size = UDim2.new(1, -20, 0, 0)
	content.BackgroundTransparency = 1

	local contentLayout = Instance.new("UIListLayout", content)
	contentLayout.Padding = UDim.new(0, 5)

	-- Pulsieren Animation für den Rahmen (Tropical Style)
	task.spawn(function()
		while sectionContainer.Parent do
			local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			TweenService:Create(stroke, tweenInfo, {Transparency = 0.8}):Play()
			TweenService:Create(sectionTitle, tweenInfo, {TextTransparency = 0.3}):Play()
			break -- Startet den Loop nur einmal dank Repeat -1
		end
	end)

	local function updateSectionHeight()
		local targetHeight = opened and (contentLayout.AbsoluteContentSize.Y + 45) or 35
		TweenService:Create(sectionContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, targetHeight)
		}):Play()
		arrow.Text = opened and "▼" or "▲"
	end

	header.Activated:Connect(function()
		opened = not opened
		updateSectionHeight()
	end)

	-- WICHTIG: Wenn sich der Inhalt ändert, muss die Höhe mitwachsen
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if opened then updateSectionHeight() end
	end)

	-- Wir geben den Content-Frame zurück, damit man Elemente darin adden kann
	return content
end




local guiDraggable = true 

-- DRAGGABLE LOGIC 
local dragging, dragStart, startPos
BackgroundImage.Active = true -- Ermöglicht Input-Events auf dem Bild

BackgroundImage.InputBegan:Connect(function(input)
	if not guiDraggable then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		local connection
		connection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				connection:Disconnect()
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end
end)





-- --- OPEN/CLOSE TOGGLE SYSTEM ---
local dragOpenButtonEnabled = true
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "TropicalToggle"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleBtn.Text = "T"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 230)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 20
ToggleBtn.ZIndex = 100
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0.3, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 255, 230)
ToggleStroke.Thickness = 2



local SwipeZone = Instance.new("Frame", ScreenGui)
SwipeZone.Size = UDim2.new(0.1, 0, 1, 0)
SwipeZone.BackgroundTransparency = 1
SwipeZone.Visible = false

local menuOpen = true
local currentMode = "Neon"

local function toggleMenu(forceState)
	if forceState ~= nil then menuOpen = forceState else menuOpen = not menuOpen end
	local targetPos = menuOpen and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 1.5, 0)
	TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = targetPos}):Play()
	ToggleBtn.Text = menuOpen and "X" or (currentMode == "Minimal" and "O" or "T")
end

-- VARIANTEN-LOGIK
local function setToggleMode(mode)
	currentMode = mode
	ToggleBtn.Visible = (mode ~= "Swipe")
	SwipeZone.Visible = (mode == "Swipe")

	if mode == "Neon" then
		ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
		ToggleStroke.Enabled = true
		ToggleBtn.Text = "T"
	elseif mode == "Minimal" then
		ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
		ToggleStroke.Enabled = false
		ToggleBtn.Text = "O"
	elseif mode == "Swipe" then
		-- TUTORIAL: 2x ROT BLINKEN
		task.spawn(function()
			for i = 1, 2 do
				local flash = Instance.new("Frame", ScreenGui)
				flash.Size = UDim2.new(0.02, 0, 0.5, 0)
				flash.Position = UDim2.new(0, 0, 0.25, 0)
				flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				Instance.new("UICorner", flash)
				task.wait(0.2)
				flash:Destroy()
				task.wait(0.2)
			end
		end)
	end
end

-- SETTINGS BUTTONS ERSTELLEN (Design & Touch-Fix wie addScript)
local function createSettingsOption(name, mode)
	local btn = Instance.new("TextButton", SettingsPage)
	-- Größe und Look wie deine Scripts
	btn.Size = UDim2.new(1, 0, 0.2, 0) 
	btn.BackgroundColor3 = Color3.fromRGB(20, 40, 45)
	btn.BackgroundTransparency = 0.5
	btn.Text = "    " .. name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 8
	Instance.new("UICorner", btn)

	-- Nutzt Activated (besser für Touch) statt MouseButton1Click
	btn.Activated:Connect(function() setToggleMode(mode) end)
end




-- ==========================================
-- SETTINGS SEITE LOGIK
-- ==========================================

-- MODI DROPDOWN
addDropdown(SettingsPage, "Menu Toggle Mode", {"Neon", "Minimal", "Swipe"}, false, function(selected)
	print("Modus gewechselt zu: " .. selected)
	setToggleMode(selected)
end)

-- DRAG OPEN BUTTON TOGGLE
addToggle(SettingsPage, "Drag Open Button", true, function(state)
	dragOpenButtonEnabled = state

end)

-- DRAG GUI TOGGLE
addToggle(SettingsPage, "Drag GUI allowed", true, function(state)
	guiDraggable = state
end)




-- --- SYNCHRONIZED TOGGLE SYSTEM ---
local ToggleKey = Enum.KeyCode.RightControl -- Standard-Taste

-- Diese Funktion ersetzt das alte toggleUI und nutzt deine vorhandene Logik
local function runKeybindToggle()
	-- Wir rufen einfach deine bestehende Funktion auf
	-- Das sorgt dafür, dass Position, Tween und der Button-Text (X/T) gleichzeitig aktualisiert werden
	toggleMenu() 
end

-- Keybind in die Settings-Seite einbauen
addKeybind(SettingsPage, "Toggle Menu", "RightControl", function(newKey)
	local success, code = pcall(function() return Enum.KeyCode[newKey] end)
	if success then
		ToggleKey = code
		print("Keybind aktualisiert: " .. tostring(code))
	end
end)

-- Globaler Listener für die Taste
UserInputService.InputBegan:Connect(function(input, processed)
	-- processed wird ignoriert, damit man das Menü immer schließen kann
	if input.KeyCode == ToggleKey then
		runKeybindToggle()
	end
end)



-- CLOSE BUTTON
local closeUI = Instance.new("TextButton", SettingsPage)
closeUI.Size = UDim2.new(1, 0, 0.2, 0)
closeUI.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeUI.BackgroundTransparency = 0.4
closeUI.Text = "    CLOSE GUI"
closeUI.TextColor3 = Color3.new(1,1,1)
closeUI.TextXAlignment = Enum.TextXAlignment.Left
closeUI.ZIndex = 8
Instance.new("UICorner", closeUI)
closeUI.Activated:Connect(function() toggleMenu(false) end)


-- TOGGLE BTN DRAG & TOUCH FIX
local tDragging, tStart, tPos, inputStart
local hasMoved = false

-- TOGGLE BTN DRAG & TOUCH FIX (KORRIGIERT)
local tDragging, tStart, tPos, inputStart
local hasMoved = false

ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		tDragging = true
		tStart = input.Position
		inputStart = input.Position
		tPos = ToggleBtn.Position
		hasMoved = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		-- HIER IST DIE WICHTIGE PRÜFUNG:
		if not dragOpenButtonEnabled then return end 

		local delta = input.Position - tStart
		if delta.Magnitude > 5 then
			hasMoved = true
			ToggleBtn.Position = UDim2.new(tPos.X.Scale, tPos.X.Offset + delta.X, tPos.Y.Scale, tPos.Y.Offset + delta.Y)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if tDragging then
			tDragging = false
			-- Klick-Logik (Menü öffnen/schließen)
			if not hasMoved or (input.Position - inputStart).Magnitude < 10 then
				toggleMenu()
			end
		end
	end
end)



-- SWIPE DETECTION FIX
local swipeData = nil
SwipeZone.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
		swipeData = input.Position 
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if swipeData and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
		local deltaX = input.Position.X - swipeData.X
		if deltaX > 50 then 
			toggleMenu(true) 
		end
		swipeData = nil
	end
end)






-- BEISPIEL ANWENDUNG IN DEINEM SKRIPT:

-- Ein Script-Button (hast du schon)
addScript(ScriptsPage, "Fly Script", "print('Fly Loaded')")

addExtraButton(ScriptsPage, "Destroy Map", function()
	print("Map weg!")
end)

-- Ein Toggle (NEU)
addToggle(ScriptsPage, "Auto-Farm", false, function(state)
	print("Farm ist jetzt:", state)
end)

return Library











--[[

addGame("Blox", Color3.fromRGB(255, 50, 50), function()
	-- Beispiel: Speed über TextBox eingeben
	addTextBox(GamePage, "Enter Walkspeed...", function(text)
		local speed = tonumber(text)
		if speed then
			LocalPlayer.Character.Humanoid.WalkSpeed = speed
			-- print("Live Speed: " .. speed) -- Optional zum Testen im Output
		end
	end)

	addToggle(GamePage, "Auto Farm", false, function(s)
		print("Farm ist:", s)
	end)

	addDropdown(GamePage, "Wähle Team", {"Rot", "Blau", "Grün"}, false, function(selected)
		print("Team gewählt: " .. selected)
	end)

	-- 2. Multi-Dropdown
	addDropdown(GamePage, "Auto-Kill Mobs", {"Zombie", "Vampir", "Ork"}, true, function(option, state, allSelections)
		print(option .. " ist jetzt: " .. (state and "AN" or "AUS"))
	end)

	addExtraButton(GamePage, "Destroy Map", function()
		print("Map weg!")
	end)
	
	local playerNames = {}
	for _, p in pairs(game.Players:GetPlayers()) do table.insert(playerNames, p.Name) end


	-- 2. Das Search Dropdown mit vielen Optionen
	local fruits = {
		"Apple", "Banana", "Blueberry", "Blackberry", 
		"Cherry", "Coconut", "Dragonfruit", "Grape", 
		"Kiwi", "Lemon", "Mango", "Melon", 
		"Orange", "Papaya", "Peach", "Pear", 
		"Pineapple", "Raspberry", "Strawberry", "Watermelon"
	}

	addDropdownSearch(GamePage, "Search Fruits", fruits, false, function(selected)
		print("Du hast gewählt: " .. selected)
	end)

	-- 3. Ein Multi-Select Search Dropdown zum Testen der Checkboxen
	addDropdownSearch(GamePage, "Multi-Pick (Fruits)", {"Apple", "Banana", "Pear", "Mango"}, true, function(opt, state)
		print("Frucht: " .. opt .. " | Status: " .. (state and "An" or "Aus"))
	end)

	-- 4. Ein Button darunter, um zu sehen ob das Dropdown ihn überlappt
	addExtraButton(GamePage, "Check Overlay", function()
		print("Button wurde geklickt (ZIndex Test)")
	end)
	
	-- Walkspeed mit 1 Nachkommastelle
	addSlider(GamePage, "Speed", 16, 200, 16, 1, function(v)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
	end)

	-- Gravity mit 2 Nachkommastellen
	addSlider(GamePage, "Gravity", 0, 196, 196, 2, function(v)
		workspace.Gravity = v
	end)


	-- Werte von 0 bis 1000 Meter, Default: 50 bis 300
	addDualSlider(GamePage, "Target Distance", 0, 1000, 50, 300, function(minDist, maxDist)
		print("Suche Ziele zwischen: " .. minDist .. "m und " .. maxDist .. "m")
		-- Hier würde dein Code kommen: 
		-- if dist > minDist and dist < maxDist then ...
	end)

	-- Ein Search-Dropdown darunter
	local players = {"All Players", "Enemies Only", "Friends Only", "Whitelisted"}
	addDropdownSearch(GamePage, "Filter Targets", players, false, function(selected)
		print("Modus: " .. selected)
	end)

end)

addGame("Main", Color3.fromRGB(0, 255, 200), function()
	-- Ein einfaches Trenn-Label (Überschrift)
	addLabel(GamePage, "--- SERVER INFO ---")

	-- Ein Label, das wir später aktualisieren
	local timeLabel = addLabel(GamePage, "Time: 00:00")
	local playerLabel = addLabel(GamePage, "Players: " .. #game.Players:GetPlayers())

	-- Kleiner Loop zum Testen der Update-Funktion
	task.spawn(function()
		while task.wait(1) do
			local time = os.date("%X")
			timeLabel:Set("Current Time: " .. time)
		end
	end)

	addLabel(GamePage, "--- CHEATS ---")

	addToggle(GamePage, "Infinite Jump", false, function(state)
		print("Jump state:", state)
	end)
end)

addGame("Settings", Color3.fromRGB(100, 100, 100), function()
	addLabel(GamePage, "--- CONTROLS ---")


	-- Beispiel 2: Keybind kombiniert mit einer Funktion
	local flyEnabled = false
	addKeybind(GamePage, "Fly Script", "F", function(newKey)
		print("Fly-Taste ist jetzt: " .. newKey)
	end)

	-- Logik, die den Keybind tatsächlich nutzt (globaler Listener)
	game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode.Name == "F" then -- Hier müsste die Variable Keybind.key geprüft werden
			flyEnabled = not flyEnabled
			print("Fly ist jetzt: " .. (flyEnabled and "AN" or "AUS"))
		end
	end)
end)

addGame("Combat", Color3.fromRGB(255, 50, 50), function()
	-- 1. Erstelle die Section
	local combatSection = addSection(GamePage, "Legit Features", true)

	-- 2. Nutze 'combatSection' als Parent statt 'GamePage'
	local kAura = addToggle(combatSection, "Kill Aura", false, function(s) print(s) end)
	addTooltip(kAura, "Attacks entities smoothly.", 3)

	addSlider(combatSection, "Range", 1, 20, 10, function(v) print(v) end)

	-- Du kannst sogar eine zweite Section darunter machen
	local miscSection = addSection(GamePage, "Misc Extras", false)
	addToggle(miscSection, "Auto-Toxic", false, function() end)
	
	addToggle(combatSection, "Silent Aim", false, function(state)
		if state then
			NotificationService:Notify("COMBAT", "Silent Aim activated", "Info", 2)
		else
			NotificationService:Notify("COMBAT", "Silent Aim deactivated", "Warning", 2)
		end
	end)
end)

]]
