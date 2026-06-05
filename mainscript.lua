-- ====================================================================
-- 1. ТВОЙ ИСХОДНЫЙ КОД (Создание меню и вкладок)
-- ====================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Tutorial", "Serpent")
local Misc = Window:NewTab("Misc")
local Section = Misc:NewSection("Misc")
Section:NewButton("nothing")

-- ====================================================================
-- 2. СТАБИЛЬНЫЙ ОБНОВЛЕННЫЙ ПАТЧ (БЕЗ УЛЕТАНИЙ И БАГОВ С ТАПОМ)
-- ====================================================================
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local TargetGui, MainFrame, HeaderFrame

-- Цикл безопасного поиска UI библиотеки в CoreGui
repeat 
    task.wait() 
    for _, child in ipairs(CoreGui:GetChildren()) do 
        local main = child:FindFirstChild("Main") 
        if child:IsA("ScreenGui") and main and main:FindFirstChild("MainHeader") then 
            TargetGui = child
            MainFrame = main
            HeaderFrame = main.MainHeader 
            break 
        end 
    end 
until TargetGui

-- Переменная, которая скажет кнопке, можно ли кликать
local canClickCircle = true

-- Функция перетаскивания (теперь со 100% блокировкой клика при движении)
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
                    -- Небольшая задержка, чтобы клик не выстрелил сразу после отпускания пальца
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
            
            -- Если сдвинулся хоть немного — это драг, кликать нельзя!
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

-- Включаем тач-драг для главного меню
if UserInputService.TouchEnabled then
    makeDraggable(HeaderFrame, MainFrame)
end

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
-- Стартовая позиция кружка (справа по центру экрана, чтобы не мешал)
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
        -- Просто скрываем меню и показываем кружок там, где он СЕЙЧАС находится
        MainFrame.Visible = false 
        OpenBtn.Visible = true 
    else 
        -- Просто скрываем кружок и показываем меню там, где оно СЕЙЧАС находится
        OpenBtn.Visible = false 
        MainFrame.Visible = true 
    end 
end

-- Обработка клика по кружку (сработает только если canClickCircle == true)
OpenBtn.MouseButton1Click:Connect(function()
    if canClickCircle then
        toggleUI(false)
    end
end)

-- Клик по кнопке '_' в меню всегда сворачивает его
CollapseBtn.MouseButton1Click:Connect(function() 
    toggleUI(true) 
end)
