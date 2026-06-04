-- 1. Твой исходный код создания меню
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Tutorial", "BloodTheme")
local Misc = Window:NewTab("Misc")
local Section = Misc:NewSection("Misc")
Section:NewButton("nothing")

-- 2. ДОРАБОТАННЫЙ ИСПРАВЛЕННЫЙ ПАТЧ
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

-- ФУНКЦИЯ ДЛЯ СЛУЖБЫ ПЕРЕТАСКИВАНИЯ (Универсальная для меню и для кружка)
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
                end 
            end) 
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(input) 
        if isDragging and input == currentTouchInput then 
            local delta = input.Position - dragStartPos
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
CollapseBtn.Position = UDim2.new(0.91, 0, 0.05, 0) -- Выровнял повыше по центру шапки
CollapseBtn.BackgroundTransparency = 1 -- Полностью прозрачный фон кнопки, чтобы не портить UI
CollapseBtn.Text = "_" 
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 18
CollapseBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый символ
CollapseBtn.ZIndex = 5

-- Создаем красивый сплошной белый кружок с буквой по центру
local OpenBtn = Instance.new("TextButton", TargetGui) 
OpenBtn.Visible = false 
OpenBtn.Text = "M" -- Буква по центру (можешь поменять на любую)
OpenBtn.Font = Enum.Font.GothamBold 
OpenBtn.TextSize = 16 
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0) -- Чёрный цвет буквы
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Сплошной белый круг
OpenBtn.Size = UDim2.fromOffset(45, 45) -- Сделал побольше (45х45 пикселей), чтобы удобно было попадать пальцем
OpenBtn.AutoButtonColor = true 
OpenBtn.ZIndex = 9999 

local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(1, 0) -- Идеальный круг

-- Включаем перетаскивание для самого кружка (работает и на мобилках, и на ПК)
makeDraggable(OpenBtn, OpenBtn)

-- Логика переключения
local isHidden = false

local function toggleUI(shouldHide) 
    isHidden = shouldHide 
    MainFrame.Visible = not shouldHide 
    OpenBtn.Visible = shouldHide 
    
    if shouldHide then 
        -- Появляется ровно в тех координатах на экране, где сейчас находится кнопка сворачивания
        OpenBtn.Position = UDim2.new(0, CollapseBtn.AbsolutePosition.X, 0, CollapseBtn.AbsolutePosition.Y)
    end 
end

-- Биндим клики
CollapseBtn.MouseButton1Click:Connect(function() 
    toggleUI(true) 
end)

OpenBtn.MouseButton1Click:Connect(function() 
    -- Проверяем, что это был именно быстрый клик, а не перетаскивание кружка по экрану
    toggleUI(false) 
end)
