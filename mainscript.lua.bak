local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FoxYYs/Zombie-arena_vibecode_script/refs/heads/main/vibecoded_ui_lib.lua"))()
local Killaura = loadstring(game:HttpGet("https://raw.githubusercontent.com/FoxYYs/Zombie-arena_vibecode_script/refs/heads/main/killaura.lua"))()

-- Инициализируем окно через твою новую либу
local Window = Library:CreateWindow({
	Title = "Vibecoded shit",
	Size = Vector2.new(520, 320),
	Background = "rbxassetid://121343473918667", -- твой арт на фоне
	BackgroundTransparency = 0.8,
})

local Icons = {
    Combat = "rbxassetid://14939026750", -- Sword
    Misc = "rbxassetid://13321880293", -- Component
    Settings = "rbxassetid://13321817096"  -- Settings
}


-- COMBAT --
local Combat = Window:AddTab("Combat", Icons.Combat)
Combat:AddSection("Kill Aura")

-- Тоггл киллауры
Combat:AddToggle({
    Name = "Killaura",
    Default = false,
    Callback = function(state)
        Killaura.Enabled = state
    end
})

-- Ползунок радиуса
Combat:AddSlider({
    Name = "Attack Radius",
    Min = 10,
    Max = 150,
    Default = 60,
    Callback = function(value)
        Killaura.Radius = value
    end
})

-- Ползунок задержки тика (в миллисекундах, пересчитывается в секунды для модуля)
Combat:AddSlider({
    Name = "Tick Delay",
    Min = 0.1,
    Max = 10,
    Default = 1,
    Callback = function(value)
        Killaura.TickDelay = value
    end
})

-- MISC --
local Misc = Window:AddTab("Misc", Icons.Misc)
Misc:AddSection("Misc")

-- Noclip logic
local noclip = false
local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer

runService.Stepped:Connect(function()
    if not noclip then return end
    
    local character = player.Character
    if character then
        -- Проходимся циклом по ВСЕМ элементам персонажа
        for _, part in ipairs(character:GetChildren()) do
            -- Если это часть тела (BasePart), вырубаем коллизию
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)


-- Переносим Тоггл Noclip на новые рельсы
Misc:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = function(s)
		noclip = s
	end
})

-- Переносим Слайдер WalkSpeed на новые рельсы
Misc:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 250,
	Default = 16,
	Callback = function(value)
		local replyChar = game.Players.LocalPlayer.Character
		if replyChar and replyChar:FindFirstChild("Humanoid") then
			replyChar.Humanoid.WalkSpeed = value
		end
	end
})
