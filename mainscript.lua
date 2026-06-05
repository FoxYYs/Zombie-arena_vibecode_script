-- ====================================================================
-- 1. ТВОЙ ИСХОДНЫЙ КОД (Создание меню и вкладок)
-- ====================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Vibecoded shit", "DarkTheme")
-- ===== MISC (SIMPLE FUNCS) =====
local Misc = Window:NewTab("Misc")
local Section = Misc:NewSection("Misc")

Section:NewButton("nothing")


-- ====================================================================
-- ПАТЧ ДЛЯ TOUCH + СВОРАЧИВАНИЯ
-- ====================================================================
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local TargetGui
local MainFrame
local HeaderFrame
local OpenBtn

local canClickCircle = true

local function findKavoGui()
	for _, child in ipairs(CoreGui:GetChildren()) do
		if child:IsA("ScreenGui") then
			local main = child:FindFirstChild("Main")
			local header = main and main:FindFirstChild("MainHeader")
			if main and header then
				return child, main, header
			end
		end
	end
end

local function makeDraggable(handle, frame)
	handle.Active = true

	local dragging = false
	local dragInput
	local dragStart
	local startPos
	local moved = false

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = frame.Position
			dragInput = input
			canClickCircle = true
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput and startPos then
			local delta = input.Position - dragStart

			if delta.Magnitude > 4 then
				moved = true
				canClickCircle = false
			end

			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragging and (
			input == dragInput
			or input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			dragging = false
			task.delay(0.05, function()
				canClickCircle = not moved
			end)
		end
	end)
end

local function toggleUI(showMain)
	if not MainFrame then
		return
	end

	MainFrame.Visible = showMain
	if OpenBtn then
		OpenBtn.Visible = not showMain
	end
end

local function initializePatch()
	if TargetGui then
		return
	end

	local gui, main, header = findKavoGui()
	if not gui then
		return
	end

	TargetGui = gui
	MainFrame = main
	HeaderFrame = header

	local CollapseBtn = Instance.new("TextButton")
	CollapseBtn.Name = "CollapseButton"
	CollapseBtn.Parent = HeaderFrame
	CollapseBtn.Size = UDim2.fromOffset(25, 25)
	CollapseBtn.Position = UDim2.new(0.91, 0, 0.05, 0)
	CollapseBtn.BackgroundTransparency = 1
	CollapseBtn.Text = ""
	CollapseBtn.AutoButtonColor = true
	CollapseBtn.Font = Enum.Font.GothamBold
	CollapseBtn.TextSize = 18
	CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	CollapseBtn.ZIndex = 9999
	CollapseBtn.Active = true

	OpenBtn = Instance.new("TextButton")
	OpenBtn.Name = "OpenButton"
	OpenBtn.Parent = TargetGui
	OpenBtn.Visible = false
	OpenBtn.Text = "M"
	OpenBtn.Font = Enum.Font.GothamBold
	OpenBtn.TextSize = 16
	OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	OpenBtn.Size = UDim2.fromOffset(45, 45)
	OpenBtn.Position = UDim2.new(0.85, 0, 0.5, 0)
	OpenBtn.AutoButtonColor = true
	OpenBtn.ZIndex = 9999
	OpenBtn.Active = true

	local openCorner = Instance.new("UICorner")
	openCorner.CornerRadius = UDim.new(1, 0)
	openCorner.Parent = OpenBtn

	makeDraggable(OpenBtn, OpenBtn)

	CollapseBtn.Activated:Connect(function()
		toggleUI(false)
	end)

	OpenBtn.Activated:Connect(function()
		if canClickCircle then
			toggleUI(true)
		end
	end)

	if UserInputService.TouchEnabled then
		makeDraggable(HeaderFrame, MainFrame)
	end
end

task.defer(function()
	for _ = 1, 60 do
		initializePatch()
		if TargetGui then
			break
		end
		task.wait(0.1)
	end
end)