-- ====================================================================
-- 1. ТВОЙ ИСХОДНЫЙ КОД (Создание меню и вкладок)
-- ====================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Vibecoded shit", "DarkTheme")
-- ===== MISC (SIMPLE FUNCS) =====
local Misc = Window:NewTab("Misc")
local MiscSection = Misc:NewSection("Misc")

-- noclip logic
local noclip = false
game:GetService("RunService").Stepped:Connect(function()
    if not noclip then return end
    local c = game.Players.LocalPlayer.Character
    if c then
        if c:FindFirstChild("HumanoidRootPart") then c.HumanoidRootPart.CanCollide = false end
        if c:FindFirstChild("Torso") then c.Torso.CanCollide = false end
        if c:FindFirstChild("UpperTorso") then c.UpperTorso.CanCollide = false end
    end
end)

MiscSection:CreateToggle("Noclip", "", function(s) noclip = s end)
MiscSection:CreateSlider("WalkSpeed", "", 16, 250, function(value)
    local replyChar = game.Players.LocalPlayer.Character
    if replyChar and replyChar:FindFirstChild("Humanoid") then
        replyChar.Humanoid.WalkSpeed = value
    end
end)


-- ====================================================================
-- 2. СТАБИЛЬНЫЙ ОБНОВЛЕННЫЙ ПАТЧ (БЕЗ ФРИЗОВ И ЗАВИСАНИЙ)
-- ====================================================================
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local TargetGui, MainFrame, HeaderFrame
local canClickCircle = true

-- Функция перетаскивания (со 100% блокировкой клика при движении)
local function makeDraggable(clickFrame, moveFrame)
    clickFrame.Active = true
    local isDragging = false
    local currentTouchInput
    local dragStartPos
    local frameStartPos

    clickFrame.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = true
            currentTouchInput = input
            dragStartPos = input.Position
            frameStartPos = moveFrame.Position
            
            input.Changed:Connect(function() 
                if input.UserInputState == Enum.UserInputState.End then 
                    isDragging = false 
                    task.delay(0.05, function()
                        canClickCircle = true
                    end)
                end 
            end) 
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(input) 
        if isDragging and input == currentTouchInput then 
            local delta = input.Position - dragStartPos
            
            if delta.Magnitude > 3 then
                canClickCircle = false
            end
            
            moveFrame.Position = UDim2.new(
                frameStartPos.X.Scale, 
                frameStartPos.X.Offset + delta.X, 
                frameStartPos.Y.Scale, 
                frameStartPos.Y.Offset + delta.Y
            ) 
        end 
    end)
end

-- Функция инициализации кастомного управления (кнопки сворачивания)
local function InitializeCollapseSystem()
    -- Создаем аккуратную кнопку сворачивания '_' в шапке меню
    local CollapseBtn = Instance.new("TextButton", HeaderFrame) 
    CollapseBtn.Name = "CollapseButton" 
    CollapseBtn.Size = UDim2.fromOffset(25, 25) 
    CollapseBtn.Position = UDim2.new(0.91, 0, 0.05, 0) 
    CollapseBtn.BackgroundTransparency = 1 
    CollapseBtn.Text = "_" 
    CollapseBtn.Font = Enum.Font.GothamBold
    CollapseBtn.TextSize = 18
    CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    CollapseBtn.ZIndex = 5

    -- Создаем красивый сплошной белый кружок с буквой по центру
    local OpenBtn = Instance.new("TextButton", TargetGui) 
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

    local OpenCorner = Instance.new("UICorner", OpenBtn)
    OpenCorner.CornerRadius = UDim.new(1, 0)

    -- Включаем перетаскивание для кружка
    makeDraggable(OpenBtn, OpenBtn)

    -- ЛОГИКА СВОРАЧИВАНИЯ / РАЗВЕРТЫВАНИЯ
    local function toggleUI(shouldHide) 
        if shouldHide then 
            MainFrame.Visible = false 
            OpenBtn.Visible = true 
        else 
            OpenBtn.Visible = false 
            MainFrame.Visible = true 
        end 
    end

    OpenBtn.MouseButton1Click:Connect(function()
        if canClickCircle then
            toggleUI(false)
        end
    end)

    CollapseBtn.MouseButton1Click:Connect(function() 
        toggleUI(true) 
    end)

    -- Включаем тач-драг для главного меню, если мы на мобилке
    if UserInputService.TouchEnabled then
        makeDraggable(HeaderFrame, MainFrame)
    end
end

-- Безопасный асинхронный поиск UI библиотеки без фризов
local function checkGui(child)
    if child:IsA("ScreenGui") then
        local main = child:WaitForChild("Main", 2) -- Ждем "Main" максимум 2 секунды, чтобы не вешать поток
        if main and main:FindFirstChild("MainHeader") then 
            TargetGui = child
            MainFrame = main
            HeaderFrame = main.MainHeader
            return true
        end
    end
    return false
end

-- Проверяем то, что уже загрузилось
for _, child in ipairs(CoreGui:GetChildren()) do
    if checkGui(child) then break end
end

-- Если не нашли сразу, подписываемся на появление новых элементов (идеально для асинхронного Kavo UI)
if not TargetGui then
    local connection
    connection = CoreGui.ChildAdded:Connect(function(child)
        if checkGui(child) then
            connection:Disconnect() -- Отключаем событие, как только нашли нужный UI
            InitializeCollapseSystem()
        end
    end)
else
    InitializeCollapseSystem()
end
