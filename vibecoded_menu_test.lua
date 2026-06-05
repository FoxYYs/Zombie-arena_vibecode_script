--[[
	Fluent Mobile Fix — UI Library (Glassmorphism)
	Монолитная библиотека для Roblox, оптимизированная под мобильные устройства.
	Автор: by you
--]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

--==================================================================
-- ТЕМА (глубокий бордовый, эффект стекла)
--==================================================================
local Theme = {
	Background  = Color3.fromRGB(38, 10, 12),   -- основной фон окна
	Topbar      = Color3.fromRGB(46, 13, 15),   -- верхний бар
	Sidebar     = Color3.fromRGB(30, 8, 10),    -- сайдбар
	Element     = Color3.fromRGB(58, 18, 20),   -- фон элементов
	ElementHover= Color3.fromRGB(74, 24, 27),   -- фон при наведении/нажатии
	Stroke      = Color3.fromRGB(110, 40, 45),  -- неоновая обводка (светлее фона)
	Accent      = Color3.fromRGB(196, 64, 64),  -- акцент (вкл. тогглы/слайдеры)
	Text        = Color3.fromRGB(240, 225, 226),-- основной текст
	SubText     = Color3.fromRGB(180, 140, 142),-- вторичный текст
	Knob        = Color3.fromRGB(245, 235, 236),-- ползунок тоггла
}

--==================================================================
-- УТИЛИТЫ
--==================================================================
local Util = {}

function Util.Create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			obj[k] = v
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = obj
	end
	if props and props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

function Util.Corner(parent, radius)
	return Util.Create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 7),
	})
end

function Util.Stroke(parent, color, thickness, transparency)
	return Util.Create("UIStroke", {
		Parent = parent,
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Util.Tween(obj, time, props, style, dir)
	local info = TweenInfo.new(
		time or 0.22,
		style or Enum.EasingStyle.Quart,
		dir or Enum.EasingDirection.Out
	)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

-- Безопасный вызов калбэков (ошибки пользователя не ломают UI)
function Util.SafeCallback(fn, ...)
	if typeof(fn) ~= "function" then return end
	local args = { ... }
	local ok, err = xpcall(function()
		return fn(table.unpack(args))
	end, function(e)
		return debug.traceback(tostring(e), 2)
	end)
	if not ok then
		warn("[Fluent] Ошибка в калбэке:\n" .. tostring(err))
	end
end

-- Универсальный перетаскиватель (Mouse + Touch)
function Util.MakeDraggable(handle, target)
	local dragging, dragInput, dragStart, startPos
	target = target or handle

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = input.Position
			startPos  = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--==================================================================
-- БИБЛИОТЕКА
--==================================================================
local Library = {}
Library.__index = Library

local SEARCH_ICON = "rbxassetid://3926305904" -- материал-спрайтшит
local SEARCH_RECT_OFFSET = Vector2.new(964, 324)
local SEARCH_RECT_SIZE   = Vector2.new(36, 36)

function Library:CreateWindow(config)
	config = config or {}
	local Window = setmetatable({}, Library)

	local title    = config.Title    or "Fluent Mobile Fix"
	local subtitle = config.Subtitle or "by you"
	local size     = config.Size     or Vector2.new(520, 320) -- компактный мобильный дефолт
	local bgImage  = config.Background -- asset id картинки-арта (необяз.)

	Window.Tabs = {}
	Window.DefaultSize = size

	--------------------------------------------------------------
	-- ScreenGui
	--------------------------------------------------------------
	local gui = Util.Create("ScreenGui", {
		Name = "FluentMobileFix",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})
	-- Безопасный парентинг (CoreGui -> PlayerGui)
	local ok = pcall(function()
		gui.Parent = game:GetService("CoreGui")
	end)
	if not ok then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	Window.Gui = gui

	--------------------------------------------------------------
	-- Главное окно (стекло)
	--------------------------------------------------------------
	local main = Util.Create("Frame", {
		Name = "Main",
		Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, size.X, 0, size.Y),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 0.25, -- эффект стекла
		ClipsDescendants = true,
	})
	Util.Corner(main, 8)
	Util.Stroke(main, Theme.Stroke, 1, 0.3)
	Window.Main = main

	-- Кастомный арт-фон
	if bgImage then
		local art = Util.Create("ImageLabel", {
			Name = "Art",
			Parent = main,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = (typeof(bgImage) == "number")
				and ("rbxassetid://" .. bgImage) or tostring(bgImage),
			ScaleType = Enum.ScaleType.Crop,
			ImageTransparency = 0.35,
			ZIndex = 0,
		})
		Util.Corner(art, 8)
	end

	--------------------------------------------------------------
	-- Topbar (Windows-стиль)
	--------------------------------------------------------------
	local topbar = Util.Create("Frame", {
		Name = "Topbar",
		Parent = main,
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Topbar,
		BackgroundTransparency = 0.2,
		ZIndex = 5,
	})
	Util.Create("Frame", { -- маскируем нижнее скругление топбара
		Parent = topbar, BorderSizePixel = 0,
		BackgroundColor3 = Theme.Topbar, BackgroundTransparency = 0.2,
		Position = UDim2.new(0, 0, 1, -8), Size = UDim2.new(1, 0, 0, 8), ZIndex = 5,
	})
	Util.Corner(topbar, 8)
	Util.MakeDraggable(topbar, main)

	Util.Create("TextLabel", {
		Name = "Title", Parent = topbar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0, 240, 1, 0),
		Font = Enum.Font.GothamMedium, Text = title,
		TextColor3 = Theme.Text, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
	})
	local titleLbl = topbar.Title
	titleLbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
		topbar:FindFirstChild("Subtitle").Position =
			UDim2.new(0, 14 + titleLbl.TextBounds.X + 8, 0, 0)
	end)
	Util.Create("TextLabel", {
		Name = "Subtitle", Parent = topbar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14 + 110, 0, 0), Size = UDim2.new(0, 160, 1, 0),
		Font = Enum.Font.Gotham, Text = subtitle,
		TextColor3 = Theme.SubText, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
	})

	-- Кнопки управления окном
	local btnHolder = Util.Create("Frame", {
		Name = "Controls", Parent = topbar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 120, 1, 0),
		BackgroundTransparency = 1, ZIndex = 6,
	})
	Util.Create("UIListLayout", {
		Parent = btnHolder, FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local function ControlButton(symbol, order)
		local b = Util.Create("TextButton", {
			Parent = btnHolder, LayoutOrder = order,
			Size = UDim2.new(0, 34, 0, 26),
			BackgroundColor3 = Theme.Element, BackgroundTransparency = 1,
			Text = symbol, Font = Enum.Font.GothamMedium,
			TextColor3 = Theme.Text, TextSize = 14, AutoButtonColor = false, ZIndex = 6,
		})
		Util.Corner(b, 6)
		b.MouseEnter:Connect(function()
			Util.Tween(b, 0.15, { BackgroundTransparency = 0.4 })
		end)
		b.MouseLeave:Connect(function()
			Util.Tween(b, 0.15, { BackgroundTransparency = 1 })
		end)
		return b
	end

	local minBtn   = ControlButton("—", 1)
	local maxBtn   = ControlButton("▢", 2)
	local closeBtn = ControlButton("✕", 3)

	--------------------------------------------------------------
	-- Тело: Sidebar + Content
	--------------------------------------------------------------
	local body = Util.Create("Frame", {
		Name = "Body", Parent = main,
		Position = UDim2.new(0, 0, 0, 38),
		Size = UDim2.new(1, 0, 1, -38),
		BackgroundTransparency = 1, ZIndex = 2,
	})

	local sidebar = Util.Create("Frame", {
		Name = "Sidebar", Parent = body,
		Size = UDim2.new(0, 150, 1, 0),
		BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.35, ZIndex = 2,
	})

	-- Поле поиска (иконка-лупа + текст)
	local searchBox = Util.Create("Frame", {
		Name = "Search", Parent = sidebar,
		Position = UDim2.new(0, 12, 0, 12), Size = UDim2.new(1, -24, 0, 30),
		BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.3, ZIndex = 3,
	})
	Util.Corner(searchBox, 6)
	Util.Stroke(searchBox, Theme.Stroke, 0.8, 0.4)
	Util.Create("ImageLabel", {
		Name = "Icon", Parent = searchBox,
		Position = UDim2.new(0, 8, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1, Image = SEARCH_ICON,
		ImageRectOffset = SEARCH_RECT_OFFSET, ImageRectSize = SEARCH_RECT_SIZE,
		ImageColor3 = Theme.SubText, ZIndex = 4,
	})
	local searchInput = Util.Create("TextBox", {
		Name = "Input", Parent = searchBox,
		Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -40, 1, 0),
		BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		PlaceholderText = "Search...", Text = "",
		TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText,
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, ZIndex = 4,
	})

	-- Список вкладок
	local tabList = Util.Create("ScrollingFrame", {
		Name = "TabList", Parent = sidebar,
		Position = UDim2.new(0, 8, 0, 52), Size = UDim2.new(1, -16, 1, -60),
		BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3,
	})
	Util.Create("UIListLayout", {
		Parent = tabList, Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	-- Контейнер контента вкладок
	local content = Util.Create("Frame", {
		Name = "Content", Parent = body,
		Position = UDim2.new(0, 150, 0, 0), Size = UDim2.new(1, -150, 1, 0),
		BackgroundTransparency = 1, ZIndex = 2,
	})

	-- Поиск: фильтрация вкладок по названию
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local q = searchInput.Text:lower()
		for _, tab in ipairs(Window.Tabs) do
			tab.Button.Visible = (q == "") or tab.Name:lower():find(q, 1, true) ~= nil
		end
	end)

	Window.Content = content
	Window.TabList = tabList

	--------------------------------------------------------------
	-- Логика топбара: закрыть / развернуть / свернуть
	--------------------------------------------------------------
	closeBtn.MouseButton1Click:Connect(function()
		Util.Tween(main, 0.25, {
			Size = UDim2.new(0, size.X, 0, 0),
			BackgroundTransparency = 1,
		})
		task.delay(0.28, function() gui:Destroy() end)
	end)

	local maximized = false
	maxBtn.MouseButton1Click:Connect(function()
		maximized = not maximized
		if maximized then
			Util.Tween(main, 0.25, {
				Size = UDim2.new(0, math.floor(size.X * 1.25), 0, math.floor(size.Y * 1.25)),
			})
		else
			Util.Tween(main, 0.25, { Size = UDim2.new(0, size.X, 0, size.Y) })
		end
	end)

	-- Плавающая мини-кнопка для разворачивания
	local floatBtn = Util.Create("TextButton", {
		Name = "FloatToggle", Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 80, 0, 80), Size = UDim2.new(0, 48, 0, 48),
		BackgroundColor3 = Theme.Topbar, BackgroundTransparency = 0.15,
		Text = "", AutoButtonColor = false, Visible = false,
	})
	Util.Corner(floatBtn, 12)
	Util.Stroke(floatBtn, Theme.Accent, 1, 0.2)
	Util.Create("ImageLabel", {
		Parent = floatBtn, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 22, 0, 22),
		BackgroundTransparency = 1, Image = SEARCH_ICON,
		ImageRectOffset = SEARCH_RECT_OFFSET, ImageRectSize = SEARCH_RECT_SIZE,
		ImageColor3 = Theme.Text,
	})
	Util.MakeDraggable(floatBtn, floatBtn)

	minBtn.MouseButton1Click:Connect(function()
		floatBtn.Position = main.Position
		main.Visible = false
		floatBtn.Visible = true
		floatBtn.Size = UDim2.new(0, 0, 0, 0)
		Util.Tween(floatBtn, 0.2, { Size = UDim2.new(0, 48, 0, 48) },
			Enum.EasingStyle.Back)
	end)

	local dragMoved = false
	floatBtn.MouseButton1Click:Connect(function()
		main.Visible = true
		floatBtn.Visible = false
		main.Size = UDim2.new(0, size.X * 0.9, 0, size.Y * 0.9)
		Util.Tween(main, 0.22, {
			Size = UDim2.new(0, maximized and size.X * 1.25 or size.X,
			                 0, maximized and size.Y * 1.25 or size.Y),
		}, Enum.EasingStyle.Back)
	end)

	--------------------------------------------------------------
	-- Метод AddTab (с поддержкой кастомной иконки)
	--------------------------------------------------------------
	function Window:AddTab(name, icon)
		local Tab = { Name = name, Window = self }

		local hasIcon = icon ~= nil
		local btn = Util.Create("TextButton", {
			Name = name, Parent = tabList,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Theme.Element, BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, ZIndex = 3,
		})
		Util.Corner(btn, 6)
		Tab.Button = btn

		-- индикатор активной вкладки (полоска слева)
		local indicator = Util.Create("Frame", {
			Parent = btn, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 3, 0, 0),
			BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 4,
		})
		Util.Corner(indicator, 2)

		if hasIcon then
			Util.Create("ImageLabel", {
				Name = "Icon", Parent = btn,
				Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.new(0, 18, 0, 18),
				BackgroundTransparency = 1,
				Image = (typeof(icon) == "number") and ("rbxassetid://" .. icon) or tostring(icon),
				ImageColor3 = Theme.Text, ZIndex = 4,
			})
		end

		Util.Create("TextLabel", {
			Name = "Label", Parent = btn,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, hasIcon and 38 or 14, 0, 0),
			Size = UDim2.new(1, hasIcon and -46 or -22, 1, 0),
			Font = Enum.Font.GothamMedium, Text = name,
			TextColor3 = Theme.SubText, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
		})

		-- Заголовок страницы (большой "Misc")
		local page = Util.Create("Frame", {
			Name = name .. "_Page", Parent = content,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, Visible = false, ZIndex = 2,
		})
		Util.Create("TextLabel", {
			Name = "PageTitle", Parent = page,
			Position = UDim2.new(0, 24, 0, 14), Size = UDim2.new(1, -48, 0, 40),
			BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
			Text = name, TextColor3 = Theme.Text, TextSize = 30,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
		})

		local container = Util.Create("ScrollingFrame", {
			Name = "Items", Parent = page,
			Position = UDim2.new(0, 24, 0, 64), Size = UDim2.new(1, -48, 1, -78),
			BackgroundTransparency = 1, ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3,
		})
		Util.Create("UIListLayout", {
			Parent = container, Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		Tab.Container = container
		Tab.Page = page

		-- Переключение вкладок
		local function activate()
			for _, t in ipairs(self.Tabs) do
				t.Page.Visible = false
				Util.Tween(t.Button, 0.15, { BackgroundTransparency = 1 })
				Util.Tween(t.Button.Label, 0.15, { TextColor3 = Theme.SubText })
				Util.Tween(t.Indicator, 0.15, { Size = UDim2.new(0, 3, 0, 0) })
			end
			page.Visible = true
			Util.Tween(btn, 0.15, { BackgroundTransparency = 0.45 })
			Util.Tween(btn.Label, 0.15, { TextColor3 = Theme.Text })
			Util.Tween(indicator, 0.2, { Size = UDim2.new(0, 3, 0, 18) })
		end
		Tab.Indicator = indicator
		btn.MouseButton1Click:Connect(activate)
		btn.MouseEnter:Connect(function()
			if not page.Visible then
				Util.Tween(btn, 0.12, { BackgroundTransparency = 0.7 })
			end
		end)
		btn.MouseLeave:Connect(function()
			if not page.Visible then
				Util.Tween(btn, 0.12, { BackgroundTransparency = 1 })
			end
		end)

		table.insert(self.Tabs, Tab)
		if #self.Tabs == 1 then activate() end

		--==========================================================
		-- ЭЛЕМЕНТЫ ВКЛАДКИ
		--==========================================================

		-- База: фон элемента
		local function baseFrame(height)
			local f = Util.Create("Frame", {
				Parent = container, Size = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4, ZIndex = 3,
			})
			Util.Corner(f, 7)
			Util.Stroke(f, Theme.Stroke, 0.6, 0.5)
			return f
		end

		-- Section (декоративная линия авто-ширины по TextBounds)
		function Tab:AddSection(text)
			local holder = Util.Create("Frame", {
				Parent = container, Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1, ZIndex = 3,
			})
			local lbl = Util.Create("TextLabel", {
				Parent = holder, BackgroundTransparency = 1,
				Position = UDim2.new(0, 2, 0, 0), Size = UDim2.new(1, -4, 0, 20),
				Font = Enum.Font.GothamBold, Text = text,
				TextColor3 = Theme.Text, TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			local line = Util.Create("Frame", {
				Parent = holder, Position = UDim2.new(0, 2, 0, 24),
				Size = UDim2.new(0, 40, 0, 2), BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0, ZIndex = 4,
			})
			Util.Corner(line, 1)
			-- авто-подстройка ширины линии под длину текста
			lbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
				Util.Tween(line, 0.2, { Size = UDim2.new(0, lbl.TextBounds.X, 0, 2) })
			end)
			line.Size = UDim2.new(0, lbl.TextBounds.X, 0, 2)
			return holder
		end

		-- Button
		function Tab:AddButton(opts)
			opts = opts or {}
			local f = baseFrame(44)
			local b = Util.Create("TextButton", {
				Parent = f, Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 4,
			})
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -28, 1, 0),
				Font = Enum.Font.GothamMedium, Text = opts.Name or "Button",
				TextColor3 = Theme.Text, TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			b.MouseButton1Down:Connect(function()
				Util.Tween(f, 0.1, { BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0.15 })
			end)
			b.MouseButton1Up:Connect(function()
				Util.Tween(f, 0.2, { BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4 })
			end)
			b.MouseButton1Click:Connect(function()
				Util.SafeCallback(opts.Callback)
			end)
			return f
		end
		-- Toggle (плавный переезд ползунка)
		function Tab:AddToggle(opts)
			opts = opts or {}
			local state = opts.Default == true
			local f = baseFrame(44)
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -80, 1, 0),
				Font = Enum.Font.GothamMedium, Text = opts.Name or "Toggle",
				TextColor3 = Theme.Text, TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			local track = Util.Create("Frame", {
				Parent = f, AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 42, 0, 22),
				BackgroundColor3 = state and Theme.Accent or Theme.Sidebar, ZIndex = 4,
			})
			Util.Corner(track, 11)
			Util.Stroke(track, Theme.Stroke, 0.8, 0.4)
			local knob = Util.Create("Frame", {
				Parent = track, AnchorPoint = Vector2.new(0, 0.5),
				Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
				Size = UDim2.new(0, 18, 0, 18), BackgroundColor3 = Theme.Knob, ZIndex = 5,
			})
			Util.Corner(knob, 9)
			local btnT = Util.Create("TextButton", {
				Parent = f, Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1, Text = "", ZIndex = 5,
			})
			local function set(v)
				state = v
				Util.Tween(track, 0.18, { BackgroundColor3 = state and Theme.Accent or Theme.Sidebar })
				Util.Tween(knob, 0.18, {
					Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
				}, Enum.EasingStyle.Quart)
				Util.SafeCallback(opts.Callback, state)
			end
			btnT.MouseButton1Click:Connect(function() set(not state) end)
			if state then Util.SafeCallback(opts.Callback, true) end
			return { Set = set }
		end

		-- Slider (плавно следует за пальцем, округление до сотых)
		function Tab:AddSlider(opts)
			opts = opts or {}
			local min  = opts.Min or 0
			local max  = opts.Max or 100
			local value = math.clamp(opts.Default or min, min, max)
			local desc = opts.Description

			local f = baseFrame(desc and 60 or 50)
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 8), Size = UDim2.new(0.5, 0, 0, 18),
				Font = Enum.Font.GothamMedium, Text = opts.Name or "Slider",
				TextColor3 = Theme.Text, TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			if desc then
				Util.Create("TextLabel", {
					Parent = f, BackgroundTransparency = 1,
					Position = UDim2.new(0, 14, 0, 26), Size = UDim2.new(0.6, 0, 0, 14),
					Font = Enum.Font.Gotham, Text = desc,
					TextColor3 = Theme.SubText, TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
				})
			end
			local valLbl = Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(0, -60, 0, 8),
				Size = UDim2.new(0, 50, 0, 18), Font = Enum.Font.GothamBold,
				Text = tostring(value), TextColor3 = Theme.Text, TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4,
			})

			local track = Util.Create("Frame", {
				Parent = f, AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 1, desc and -16 or -14),
				Size = UDim2.new(0, 150, 0, 5),
				BackgroundColor3 = Theme.Sidebar, ZIndex = 4,
			})
			-- позиция метки значения слева от трека
			valLbl.Position = UDim2.new(1, -14 - 150 - 56, 0, 8)
			Util.Corner(track, 3)
			local fill = Util.Create("Frame", {
				Parent = track, Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = Theme.Accent, ZIndex = 5,
			})
			Util.Corner(fill, 3)
			local knob = Util.Create("Frame", {
				Parent = track, AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
				Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Theme.Accent, ZIndex = 6,
			})
			Util.Corner(knob, 7)
			Util.Stroke(knob, Theme.Knob, 1, 0.2)

			local dragging = false
			local function update(px)
				local rel = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				value = math.floor((min + (max - min) * rel) * 100 + 0.5) / 100
				valLbl.Text = tostring(value)
				Util.Tween(fill, 0.06, { Size = UDim2.new(rel, 0, 1, 0) })
				Util.Tween(knob, 0.06, { Position = UDim2.new(rel, 0, 0.5, 0) })
				Util.SafeCallback(opts.Callback, value)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					update(input.Position.X)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
					update(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			return f
		end
		-- Textbox (калбэк при FocusLost даже без Enter)
		function Tab:AddTextbox(opts)
			opts = opts or {}
			local f = baseFrame(44)
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.45, 0, 1, 0),
				Font = Enum.Font.GothamMedium, Text = opts.Name or "Textbox",
				TextColor3 = Theme.Text, TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			local box = Util.Create("Frame", {
				Parent = f, AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 150, 0, 28),
				BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.2, ZIndex = 4,
			})
			Util.Corner(box, 6)
			Util.Stroke(box, Theme.Stroke, 0.8, 0.5)
			local input = Util.Create("TextBox", {
				Parent = box, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
				BackgroundTransparency = 1, Font = Enum.Font.Gotham,
				PlaceholderText = opts.Placeholder or "...", Text = opts.Default or "",
				TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText,
				TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false, ZIndex = 5,
			})
			local stroke = box:FindFirstChildOfClass("UIStroke")
			input.Focused:Connect(function()
				Util.Tween(stroke, 0.15, { Color = Theme.Accent, Transparency = 0.1 })
			end)
			input.FocusLost:Connect(function() -- срабатывает и без enterPressed
				Util.Tween(stroke, 0.15, { Color = Theme.Stroke, Transparency = 0.5 })
				Util.SafeCallback(opts.Callback, input.Text)
			end)
			return f
		end
		-- Dropdown (плавное раскрытие вниз, динамическая высота)
		function Tab:AddDropdown(opts)
			opts = opts or {}
			local options = opts.Options or {}
			local selected = opts.Default or (options[1] or "...")
			local open = false
			local ROW = 30

			local f = baseFrame(44)
			f.ClipsDescendants = true
			f.ZIndex = 4
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1,
				Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0.5, 0, 0, 44),
				Font = Enum.Font.GothamMedium, Text = opts.Name or "Dropdown",
				TextColor3 = Theme.Text, TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
			})
			local header = Util.Create("TextButton", {
				Parent = f, AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 8), Size = UDim2.new(0, 150, 0, 28),
				BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.2,
				Text = "", AutoButtonColor = false, ZIndex = 5,
			})
			Util.Corner(header, 6)
			Util.Stroke(header, Theme.Stroke, 0.8, 0.5)
			local selLbl = Util.Create("TextLabel", {
				Parent = header, BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -30, 1, 0),
				Font = Enum.Font.Gotham, Text = tostring(selected),
				TextColor3 = Theme.Text, TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
			})
			local arrow = Util.Create("TextLabel", {
				Parent = header, BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16), Font = Enum.Font.GothamBold,
				Text = "v", TextColor3 = Theme.SubText, TextSize = 12, ZIndex = 6,
			})

			local listHolder = Util.Create("Frame", {
				Parent = f, Position = UDim2.new(1, -162, 0, 44),
				Size = UDim2.new(0, 150, 0, 0), BackgroundTransparency = 1, ZIndex = 5,
			})
			local listLayout = Util.Create("UIListLayout", {
				Parent = listHolder, Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			local function rebuild()
				for _, c in ipairs(listHolder:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				for _, opt in ipairs(options) do
					local row = Util.Create("TextButton", {
						Parent = listHolder, Size = UDim2.new(1, 0, 0, ROW - 2),
						BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.2,
						Text = "", AutoButtonColor = false, ZIndex = 6,
					})
					Util.Corner(row, 5)
					Util.Create("TextLabel", {
						Parent = row, BackgroundTransparency = 1,
						Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
						Font = Enum.Font.Gotham, Text = tostring(opt),
						TextColor3 = (opt == selected) and Theme.Accent or Theme.SubText,
						TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
					})
					row.MouseEnter:Connect(function()
						Util.Tween(row, 0.1, { BackgroundTransparency = 0 })
					end)
					row.MouseLeave:Connect(function()
						Util.Tween(row, 0.1, { BackgroundTransparency = 0.2 })
					end)
					row.MouseButton1Click:Connect(function()
						selected = opt
						selLbl.Text = tostring(opt)
						rebuild()
						-- авто-закрытие после выбора
						open = false
						Util.Tween(arrow, 0.2, { Rotation = 0 })
						Util.Tween(f, 0.22, { Size = UDim2.new(1, 0, 0, 44) })
						Util.Tween(listHolder, 0.22, { Size = UDim2.new(0, 150, 0, 0) })
						Util.SafeCallback(opts.Callback, opt)
					end)
				end
			end
			rebuild()

			header.MouseButton1Click:Connect(function()
				open = not open
				local listH = #options * ROW
				if open then
					Util.Tween(arrow, 0.2, { Rotation = 180 })
					Util.Tween(f, 0.22, { Size = UDim2.new(1, 0, 0, 44 + listH + 6) })
					Util.Tween(listHolder, 0.22, { Size = UDim2.new(0, 150, 0, listH) })
				else
					Util.Tween(arrow, 0.2, { Rotation = 0 })
					Util.Tween(f, 0.22, { Size = UDim2.new(1, 0, 0, 44) })
					Util.Tween(listHolder, 0.22, { Size = UDim2.new(0, 150, 0, 0) })
				end
			end)

			return {
				Set = function(v)
					selected = v
					selLbl.Text = tostring(v)
					rebuild()
				end,
				Refresh = function(newOpts)
					options = newOpts
					rebuild()
				end,
			}
		end

		return Tab
	end

	return Window
end

--==================================================================
-- ПРИМЕР ИСПОЛЬЗОВАНИЯ
--==================================================================
local Window = Library:CreateWindow({
	Title = "Fluent Mobile Fix",
	Subtitle = "by you",
	Size = Vector2.new(520, 320),                 -- компактный мобильный размер
	Background = "rbxassetid://0",                -- сюда свой Asset ID арта
})

local Misc = Window:AddTab("Misc", "rbxassetid://10734950309") -- иконка шестерёнки

Misc:AddSection("Movement")

Misc:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = function(state)
		print("Noclip:", state)
	end,
})

Misc:AddSlider({
	Name = "WalkSpeed",
	Description = "Скорость персонажа",
	Min = 0, Max = 100, Default = 16,
	Callback = function(value)
		local char = LocalPlayer.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
		end
	end,
})

Misc:AddButton({
	Name = "Respawn",
	Callback = function()
		print("Кнопка нажата")
	end,
})

Misc:AddTextbox({
	Name = "Никнейм",
	Placeholder = "Введите текст...",
	Callback = function(text)
		print("Введено:", text)
	end,
})

Misc:AddDropdown({
	Name = "Режим",
	Options = { "Лёгкий", "Средний", "Сложный" },
	Default = "Средний",
	Callback = function(option)
		print("Выбрано:", option)
	end,
})

return Library