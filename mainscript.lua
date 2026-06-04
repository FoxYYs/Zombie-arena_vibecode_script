-- 1. Твой исходный код создания меню
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Tutorial", "BloodTheme")
local Misc = Window:NewTab("Misc")
local Section = Misc:NewSection("Misc")
Section:NewButton("nothing")

-- 2. СТРУКТУРИРОВАННЫЙ ПАТЧ ДЛЯ МОБИЛЬНОГО ТАЧА И СВОРАЧИВАНИЯ
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

-- Если устройство поддерживает тач, включаем фикс перетаскивания
if UserInputService.TouchEnabled then
    HeaderFrame.Active = true
    
    local isDragging = false
    local currentTouchInput
    local dragStartPos
    local frameStartPos
    
    HeaderFrame.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.Touch then 
            isDragging = true
            currentTouchInput = input
            dragStartPos = input.Position
            frameStartPos = MainFrame.Position
            
            -- Отслеживаем окончание тача
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
            MainFrame.Position = UDim2.new(
                frameStartPos.X.Scale, 
                frameStartPos.X.Offset + delta.X, 
                frameStartPos.Y.Scale, 
                frameStartPos.Y.Offset + delta.Y
            ) 
        end 
    end)
end

-- Создаем кнопку сворачивания (внутри шапки меню)
local CollapseBtn = Instance.new("TextButton", HeaderFrame) 
CollapseBtn.Name = "CollapseButton" 
CollapseBtn.Size = UDim2.fromOffset(20, 20) 
CollapseBtn.Position = UDim2.new(0.91, 0, 0.155, 0) 
CollapseBtn.BackgroundColor3 = Color3.fromRGB(240, 50, 50) -- Сделал её красной под BloodTheme
CollapseBtn.Text = "" 
CollapseBtn.AutoButtonColor = false 
CollapseBtn.ZIndex = 3 

local CollapseCorner = Instance.new("UICorner", CollapseBtn)
CollapseCorner.CornerRadius = UDim.new(1, 0)

-- Создаем кнопку разворачивания (кружок, который появится при скрытии)
local OpenBtn = Instance.new("TextButton", TargetGui) 
OpenBtn.Visible = false 
OpenBtn.Text = "◉" 
OpenBtn.Font = Enum.Font.GothamBold 
OpenBtn.TextSize = 16 
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Темная кнопка, чтобы не слепила
OpenBtn.Size = UDim2.fromOffset(30, 30) 
OpenBtn.AutoButtonColor = false 
OpenBtn.ZIndex = 9999 

local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(1, 0)

-- Логика переключения режимов Видимый / Скрытый
local isHidden = false

local function toggleUI(shouldHide) 
    isHidden = shouldHide 
    MainFrame.Visible = not shouldHide 
    OpenBtn.Visible = shouldHide 
    
    if shouldHide then 
        OpenBtn.Position = MainFrame.Position -- Кружок появится ровно там, где было меню
    end 
end

-- Биндим клики на обе кнопки
CollapseBtn.MouseButton1Click:Connect(function() 
    toggleUI(not isHidden) 
end)

OpenBtn.MouseButton1Click:Connect(function() 
    toggleUI(false) 
end)
