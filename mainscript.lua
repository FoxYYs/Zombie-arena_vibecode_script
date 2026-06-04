-- ====================================================================
-- 1. ТВОЙ ИСХОДНЫЙ КОД (Создание меню и вкладок)
-- ====================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Tutorial", "BloodTheme")
local Misc = Window:NewTab("Misc")
local Section = Misc:NewSection("Misc")
Section:NewButton("nothing")

-- ====================================================================
-- 2. СЮДА МЫ ВСТАВИЛИ НАШ ИСПРАВЛЕННЫЙ ПАТЧ (В самый конец скрипта)
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

-- Универсальная функция перетаскивания (с умным разделением на драг/клик)
local function makeDraggable(clickFrame, moveFrame, isCircle, onTrueClick)
    clickFrame.Active = true
    local isDragging = false
    local currentTouchInput
    local dragStartPos
    local frameStartPos
    
    local touchStartTime = 0
    local hasMovedFar = false

    clickFrame.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
            isDragging = true
            currentTouchInput = input
            dragStartPos = input.Position
            frameStartPos = moveFrame.Position
            
            touchStartTime = os.clock()
            hasMovedFar = false
            
            input.Changed:Connect(function() 
                if input.UserInputState == Enum.UserInputState.End then 
                    isDragging = false 
                    
                    -- Проверяем: если держал меньше 0.3 сек и палец не улетел далеко — это КЛИК
                    local touchDuration = os.clock() - touchStartTime
                    if touchDuration < 0.3 and not hasMovedFar then
                        if onTrueClick then onTrueClick() end
                    end
                end 
            end) 
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(input) 
        if isDragging and input == currentTouchInput then 
            local delta = input.Position - dragStartPos
            
            -- Если палец сдвинулся больше чем на 5 пикселей, считаем это движением
            if delta.Magnitude > 5 then
                hasMovedFar = true
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

-- Включаем тач-драг для главного меню (просто таскать, без кликов)
if UserInputService.TouchEnabled then
    makeDraggable(HeaderFrame, MainFrame, false, nil)
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
OpenBtn.AutoButtonColor = true 
OpenBtn.ZIndex = 9999 

local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(1, 0)

-- Логика сворачивания / развертывания
local isHidden = false

local function toggleUI(shouldHide) 
    isHidden = shouldHide 
    
    if shouldHide then 
        -- СВОРАЧИВАЕМ: Кружок появляется там, где была кнопка '_'
        OpenBtn.Position = UDim2.new(0, CollapseBtn.AbsolutePosition.X, 0, CollapseBtn.AbsolutePosition.Y)
        MainFrame.Visible = false 
        OpenBtn.Visible = true 
    else 
        -- РАЗВОРАЧИВАЕМ: Меню прыгает ровно туда, куда ты перетащил кружок
        -- Смещаем на 300 пикселей влево, чтобы под пальцем был правый верхний угол меню
        MainFrame.Position = UDim2.new(0, OpenBtn.AbsolutePosition.X - 300, 0, OpenBtn.AbsolutePosition.Y)
        OpenBtn.Visible = false 
        MainFrame.Visible = true 
    end 
end

-- Включаем перетаскивание для кружка и вешаем на него функцию открытия при чистом клике
makeDraggable(OpenBtn, OpenBtn, true, function()
    toggleUI(false) -- Сработает только при быстром тапе без перетаскивания
end)

-- Клик по кнопке '_' в меню всегда сворачивает его
CollapseBtn.MouseButton1Click:Connect(function() 
    toggleUI(true) 
end)
