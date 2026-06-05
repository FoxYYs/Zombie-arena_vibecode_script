--[[
	Fluent Mobile Fix — UI Library (Glassmorphism) v2
	Монолитная библиотека для Roblox, оптимизированная под мобильные устройства.
	Без внешних зависимостей. Готова к заливке на Pastebin.
--]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

--==================================================================
-- ТЕМА
--==================================================================
local Theme = {
	Background   = Color3.fromRGB(38, 10, 12),
	Topbar       = Color3.fromRGB(46, 13, 15),
	Sidebar      = Color3.fromRGB(30, 8, 10),
	Element      = Color3.fromRGB(58, 18, 20),
	ElementHover = Color3.fromRGB(74, 24, 27),
	Stroke       = Color3.fromRGB(110, 40, 45),
	Accent       = Color3.fromRGB(196, 64, 64),
	Text         = Color3.fromRGB(240, 225, 226),
	SubText      = Color3.fromRGB(180, 140, 142),
	Knob         = Color3.fromRGB(245, 235, 236),
	Close        = Color3.fromRGB(196, 44, 44),
}

local SEARCH_ICON        = "rbxassetid://3926305904"
local SEARCH_RECT_OFFSET = Vector2.new(964, 324)
local SEARCH_RECT_SIZE   = Vector2.new(36, 36)

--==================================================================
-- УТИЛИТЫ
--==================================================================
local Util = {}

function Util.Create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then obj[k] = v end
	end
	for _, child in ipairs(children or {}) do child.Parent = obj end
	if props and props.Parent then obj.Parent = props.Parent end
	return obj
end

function Util.Corner(parent, radius)
	return Util.Create("UICorner", { Parent = parent, CornerRadius = UDim.new(0, radius or 7) })
end

function Util.Stroke(parent, color, thickness, transparency)
	return Util.Create("UIStroke", {
		Parent = parent, Color = color or Theme.Stroke,
		Thickness = thickness or 1, Transparency = transparency or 0.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function Util.Tween(obj, time, props, style, dir)
	local info = TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

function Util.SafeCallback(fn, ...)
	if typeof(fn) ~= "function" then return end
	local args = { ... }
	local ok, err = xpcall(function() return fn(table.unpack(args)) end,
		function(e) return debug.traceback(tostring(e), 2) end)
	if not ok then warn("[Fluent] Ошибка в калбэке:\n" .. tostring(err)) end
end

function Util.MakeDraggable(handle, target)
	local dragging, dragInput, dragStart, startPos
	target = target or handle
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, input.Position, target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

--==================================================================
-- БИБЛИОТЕКА
--==================================================================
local Library = {}
Library.__index = Library

function Library:CreateWindow(config)
	config = config or {}
	local Window = setmetatable({}, Library)

	local title    = config.Title    or "Fluent Mobile Fix"
	local subtitle = config.Subtitle or "by you"
	local size     = config.Size     or Vector2.new(520, 320)
	local bgImage  = config.Background
	local bgTrans  = config.BackgroundTransparency or 0.8

	Window.Tabs        = {}
	Window.DefaultSize = size
	Window.CurrentSize = size

	local gui = Util.Create("ScreenGui", {
		Name = "FluentMobileFix", ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
	})
	local okParent = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not okParent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	Window.Gui = gui

	--------------------------------------------------------------
	-- Главное окно
	--------------------------------------------------------------
	local main = Util.Create("Frame", {
		Name = "Main", Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, size.X, 0, size.Y),
		BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.25,
		ClipsDescendants = true,
	})
	Util.Corner(main, 8)
	Util.Stroke(main, Theme.Stroke, 1, 0.3)
	Window.Main = main

	if bgImage then
		local art = Util.Create("ImageLabel", {
			Name = "Art", Parent = main, Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = (typeof(bgImage) == "number") and ("rbxassetid://" .. bgImage) or tostring(bgImage),
			ScaleType = Enum.ScaleType.Crop, ImageTransparency = bgTrans, ZIndex = 0,
		})
		Util.Corner(art, 8)
	end

	--------------------------------------------------------------
	-- Topbar
	--------------------------------------------------------------
	local topbar = Util.Create("Frame", {
		Name = "Topbar", Parent = main, Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Topbar, BackgroundTransparency = 0.2, ZIndex = 5,
	})
	Util.Create("Frame", {
		Parent = topbar, BorderSizePixel = 0, BackgroundColor3 = Theme.Topbar,
		BackgroundTransparency = 0.2, Position = UDim2.new(0, 0, 1, -8),
		Size = UDim2.new(1, 0, 0, 8), ZIndex = 5,
	})
	Util.Corner(topbar, 8)
	Util.MakeDraggable(topbar, main)

	local titleLbl = Util.Create("TextLabel", {
		Name = "Title", Parent = topbar, BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(0, 240, 1, 0),
		Font = Enum.Font.GothamMedium, Text = title, TextColor3 = Theme.Text,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
	})
	local subLbl = Util.Create("TextLabel", {
		Name = "Subtitle", Parent = topbar, BackgroundTransparency = 1,
		Position = UDim2.new(0, 124, 0, 0), Size = UDim2.new(0, 160, 1, 0),
		Font = Enum.Font.Gotham, Text = subtitle, TextColor3 = Theme.SubText,
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
	})
	titleLbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
		subLbl.Position = UDim2.new(0, 14 + titleLbl.TextBounds.X + 8, 0, 0)
	end)
	subLbl.Position = UDim2.new(0, 14 + titleLbl.TextBounds.X + 8, 0, 0)

	local btnHolder = Util.Create("Frame", {
		Name = "Controls", Parent = topbar, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 116, 1, 0),
		BackgroundTransparency = 1, ZIndex = 7,
	})
	Util.Create("UIListLayout", {
		Parent = btnHolder, FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local function ControlButton(order, kind)
		local b = Util.Create("TextButton", {
			Parent = btnHolder, LayoutOrder = order, Size = UDim2.new(0, 30, 0, 24),
			BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, ZIndex = 7,
		})
		Util.Corner(b, 6)
		if kind == "min" then
			Util.Create("Frame", {
				Parent = b, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 11, 0, 2), BackgroundColor3 = Theme.Text,
				BorderSizePixel = 0, ZIndex = 8,
			})
		elseif kind == "max" then
			local sq = Util.Create("Frame", {
				Parent = b, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, ZIndex = 8,
			})
			Util.Corner(sq, 2)
			Util.Stroke(sq, Theme.Text, 1.5, 0)
		elseif kind == "close" then
			for _, rot in ipairs({ 45, -45 }) do
				Util.Create("Frame", {
					Parent = b, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 13, 0, 2), Rotation = rot, BackgroundColor3 = Theme.Text,
					BorderSizePixel = 0, ZIndex = 8,
				})
			end
		end
		b.MouseEnter:Connect(function()
			if kind == "close" then
				Util.Tween(b, 0.15, { BackgroundColor3 = Theme.Close, BackgroundTransparency = 0.1 })
			else
				Util.Tween(b, 0.15, { BackgroundTransparency = 0.45 })
			end
		end)
		b.MouseLeave:Connect(function()
			Util.Tween(b, 0.15, { BackgroundTransparency = 1 })
		end)
		return b
	end

	local minBtn   = ControlButton(1, "min")
	local maxBtn   = ControlButton(2, "max")
	local closeBtn = ControlButton(3, "close")

	--------------------------------------------------------------
	-- Body / Sidebar / Content
	--------------------------------------------------------------
	local body = Util.Create("Frame", {
		Name = "Body", Parent = main, Position = UDim2.new(0, 0, 0, 38),
		Size = UDim2.new(1, 0, 1, -38), BackgroundTransparency = 1, ZIndex = 2,
	})
	local sidebar = Util.Create("Frame", {
		Name = "Sidebar", Parent = body, Size = UDim2.new(0, 150, 1, 0),
		BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.35, ZIndex = 2,
	})
	local searchBox = Util.Create("Frame", {
		Name = "Search", Parent = sidebar, Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -24, 0, 30), BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 0.3, ZIndex = 3,
	})
	Util.Corner(searchBox, 6)
	Util.Stroke(searchBox, Theme.Stroke, 0.8, 0.4)
	Util.Create("ImageLabel", {
		Name = "Icon", Parent = searchBox, Position = UDim2.new(0, 8, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16), BackgroundTransparency = 1, Image = SEARCH_ICON,
		ImageRectOffset = SEARCH_RECT_OFFSET, ImageRectSize = SEARCH_RECT_SIZE,
		ImageColor3 = Theme.SubText, ZIndex = 4,
	})
	local searchInput = Util.Create("TextBox", {
		Name = "Input", Parent = searchBox, Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		PlaceholderText = "Search...", Text = "", TextColor3 = Theme.Text,
		PlaceholderColor3 = Theme.SubText, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 4,
	})
	local tabList = Util.Create("ScrollingFrame", {
		Name = "TabList", Parent = sidebar, Position = UDim2.new(0, 8, 0, 52),
		Size = UDim2.new(1, -16, 1, -60), BackgroundTransparency = 1, ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3,
	})
	Util.Create("UIListLayout", {
		Parent = tabList, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local content = Util.Create("Frame", {
		Name = "Content", Parent = body, Position = UDim2.new(0, 150, 0, 0),
		Size = UDim2.new(1, -150, 1, 0), BackgroundTransparency = 1, ZIndex = 2,
	})
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local q = searchInput.Text:lower()
		for _, tab in ipairs(Window.Tabs) do
			tab.Button.Visible = (q == "") or tab.Name:lower():find(q, 1, true) ~= nil
		end
	end)
	Window.Content, Window.TabList = content, tabList

	--------------------------------------------------------------
	-- Закрыть / Развернуть / Свернуть
	--------------------------------------------------------------
	closeBtn.MouseButton1Click:Connect(function()
		Util.Tween(main, 0.25, { Size = UDim2.new(0, Window.CurrentSize.X, 0, 0), BackgroundTransparency = 1 })
		task.delay(0.28, function() gui:Destroy() end)
	end)

	local maximized = false
	maxBtn.MouseButton1Click:Connect(function()
		maximized = not maximized
		Window.CurrentSize = maximized
			and Vector2.new(math.floor(size.X * 1.25), math.floor(size.Y * 1.25)) or size
		Util.Tween(main, 0.25, { Size = UDim2.new(0, Window.CurrentSize.X, 0, Window.CurrentSize.Y) })
	end)

	-- Плавающая кнопка: СВОЯ независимая позиция
	local floatBtn = Util.Create("TextButton", {
		Name = "FloatToggle", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 70, 0, 160), Size = UDim2.new(0, 48, 0, 48),
		BackgroundColor3 = Theme.Topbar, BackgroundTransparency = 0.1,
		Text = "", AutoButtonColor = false, Visible = false,
	})
	Util.Corner(floatBtn, 12)
	Util.Stroke(floatBtn, Theme.Accent, 1, 0.2)
	Util.Create("ImageLabel", {
		Parent = floatBtn, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 22), BackgroundTransparency = 1, Image = SEARCH_ICON,
		ImageRectOffset = SEARCH_RECT_OFFSET, ImageRectSize = SEARCH_RECT_SIZE, ImageColor3 = Theme.Text,
	})

	local function minimize()
		main.Visible = false
		floatBtn.Visible = true
		floatBtn.Size = UDim2.new(0, 0, 0, 0)
		Util.Tween(floatBtn, 0.2, { Size = UDim2.new(0, 48, 0, 48) }, Enum.EasingStyle.Back)
	end
	local function expand()
		floatBtn.Visible = false
		main.Visible = true
		local cs = Window.CurrentSize
		main.Size = UDim2.new(0, cs.X * 0.9, 0, cs.Y * 0.9)
		Util.Tween(main, 0.22, { Size = UDim2.new(0, cs.X, 0, cs.Y) }, Enum.EasingStyle.Back)
	end
	minBtn.MouseButton1Click:Connect(minimize)

	do
		local dragging, moved, startInput, startPos
		floatBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				dragging, moved = true, false
				startInput, startPos = input.Position, floatBtn.Position
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - startInput
				if delta.Magnitude > 5 then moved = true end
				floatBtn.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				if not moved then expand() end
			end
		end)
	end

	--------------------------------------------------------------
	-- AddTab
	--------------------------------------------------------------
	function Window:AddTab(name, icon)
		local Tab = { Name = name, Window = self }
		local hasIcon = icon ~= nil

		local btn = Util.Create("TextButton", {
			Name = name, Parent = tabList, Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Theme.Element, BackgroundTransparency = 1,
			Text = "", AutoButtonColor = false, ZIndex = 3,
		})
		Util.Corner(btn, 6)
		Tab.Button = btn
		local indicator = Util.Create("Frame", {
			Parent = btn, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 4,
		})
		Util.Corner(indicator, 2)
		Tab.Indicator = indicator
		if hasIcon then
			Util.Create("ImageLabel", {
				Name = "Icon", Parent = btn, Position = UDim2.new(0, 12, 0.5, -9),
				Size = UDim2.new(0, 18, 0, 18), BackgroundTransparency = 1,
				Image = (typeof(icon) == "number") and ("rbxassetid://" .. icon) or tostring(icon),
				ImageColor3 = Theme.Text, ZIndex = 4,
			})
		end
		Util.Create("TextLabel", {
			Name = "Label", Parent = btn, BackgroundTransparency = 1,
			Position = UDim2.new(0, hasIcon and 38 or 14, 0, 0),
			Size = UDim2.new(1, hasIcon and -46 or -22, 1, 0),
			Font = Enum.Font.GothamMedium, Text = name, TextColor3 = Theme.SubText,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
		})

		local page = Util.Create("Frame", {
			Name = name .. "_Page", Parent = content, Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, Visible = false, ZIndex = 2,
		})
		Util.Create("TextLabel", {
			Name = "PageTitle", Parent = page, Position = UDim2.new(0, 24, 0, 14),
			Size = UDim2.new(1, -48, 0, 40), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
			Text = name, TextColor3 = Theme.Text, TextSize = 30,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
		})
		local container = Util.Create("ScrollingFrame", {
			Name = "Items", Parent = page, Position = UDim2.new(0, 24, 0, 64),
			Size = UDim2.new(1, -48, 1, -78), BackgroundTransparency = 1, ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3,
		})
		Util.Create("UIListLayout", {
			Parent = container, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
		})
		Tab.Container, Tab.Page = container, page

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
		btn.MouseButton1Click:Connect(activate)
		btn.MouseEnter:Connect(function()
			if not page.Visible then Util.Tween(btn, 0.12, { BackgroundTransparency = 0.7 }) end
		end)
		btn.MouseLeave:Connect(function()
			if not page.Visible then Util.Tween(btn, 0.12, { BackgroundTransparency = 1 }) end
		end)
		table.insert(self.Tabs, Tab)
		if #self.Tabs == 1 then activate() end

		local function baseFrame(height)
			local f = Util.Create("Frame", {
				Parent = container, Size = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4, ZIndex = 3,
			})
			Util.Corner(f, 7)
			Util.Stroke(f, Theme.Stroke, 0.6, 0.5)
			return f
		end

		-- Section
		function Tab:AddSection(text)
			local holder = Util.Create("Frame", {
				Parent = container, Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1, ZIndex = 3,
			})
			local lbl = Util.Create("TextLabel", {
				Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 2, 0, 0),
				Size = UDim2.new(1, -4, 0, 20), Font = Enum.Font.GothamBold, Text = text,
				TextColor3 = Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			local line = Util.Create("Frame", {
				Parent = holder, Position = UDim2.new(0, 2, 0, 24), Size = UDim2.new(0, 40, 0, 2),
				BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 4,
			})
			Util.Corner(line, 1)
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
				Parent = f, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
				Text = "", AutoButtonColor = false, ZIndex = 4,
			})
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.GothamMedium, Text = opts.Name or "Button",
				TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			b.MouseButton1Down:Connect(function()
				Util.Tween(f, 0.1, { BackgroundColor3 = Theme.ElementHover, BackgroundTransparency = 0.15 })
			end)
			b.MouseButton1Up:Connect(function()
				Util.Tween(f, 0.2, { BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4 })
			end)
			b.MouseButton1Click:Connect(function() Util.SafeCallback(opts.Callback) end)
			return f
		end

		-- Toggle
		function Tab:AddToggle(opts)
			opts = opts or {}
			local state = opts.Default == true
			local f = baseFrame(44)
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -80, 1, 0), Font = Enum.Font.GothamMedium, Text = opts.Name or "Toggle",
				TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			local track = Util.Create("Frame", {
				Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 42, 0, 22),
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
				Parent = f, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 5,
			})
			local function set(v)
				state = v
				Util.Tween(track, 0.18, { BackgroundColor3 = state and Theme.Accent or Theme.Sidebar })
				Util.Tween(knob, 0.18, { Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
				Util.SafeCallback(opts.Callback, state)
			end
			btnT.MouseButton1Click:Connect(function() set(not state) end)
			if state then Util.SafeCallback(opts.Callback, true) end
			return { Set = set }
		end

		-- Slider
		function Tab:AddSlider(opts)
			opts = opts or {}
			local min   = opts.Min or 0
			local max   = opts.Max or 100
			local value = math.clamp(opts.Default or min, min, max)
			local desc  = opts.Description
			local f = baseFrame(desc and 64 or 52)

			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 8),
				Size = UDim2.new(1, -80, 0, 18), Font = Enum.Font.GothamMedium, Text = opts.Name or "Slider",
				TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			if desc then
				Util.Create("TextLabel", {
					Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 25),
					Size = UDim2.new(1, -80, 0, 13), Font = Enum.Font.Gotham, Text = desc,
					TextColor3 = Theme.SubText, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
				})
			end
			local valLbl = Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -14, 0, 8), Size = UDim2.new(0, 60, 0, 18),
				Font = Enum.Font.GothamBold, Text = tostring(value), TextColor3 = Theme.Accent,
				TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4,
			})
			local track = Util.Create("Frame", {
				Parent = f, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -12),
				Size = UDim2.new(1, -28, 0, 6), BackgroundColor3 = Theme.Sidebar, ZIndex = 4,
			})
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
			Util.Stroke(knob, Theme.Knob, 1.2, 0.1)

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
					dragging = true; update(input.Position.X)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position.X) end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end)
			return f
		end

		-- Textbox
		function Tab:AddTextbox(opts)
			opts = opts or {}
			local f = baseFrame(44)
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(0.45, 0, 1, 0), Font = Enum.Font.GothamMedium, Text = opts.Name or "Textbox",
				TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			local box = Util.Create("Frame", {
				Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 150, 0, 28), BackgroundColor3 = Theme.Sidebar,
				BackgroundTransparency = 0.2, ZIndex = 4,
			})
			Util.Corner(box, 6)
			local stroke = Util.Stroke(box, Theme.Stroke, 0.8, 0.5)
			local input = Util.Create("TextBox", {
				Parent = box, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
				BackgroundTransparency = 1, Font = Enum.Font.Gotham, PlaceholderText = opts.Placeholder or "...",
				Text = opts.Default or "", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText,
				TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 5,
			})
			input.Focused:Connect(function()
				Util.Tween(stroke, 0.15, { Color = Theme.Accent, Transparency = 0.1 })
			end)
			input.FocusLost:Connect(function()
				Util.Tween(stroke, 0.15, { Color = Theme.Stroke, Transparency = 0.5 })
				Util.SafeCallback(opts.Callback, input.Text)
			end)
			return f
		end

		-- Dropdown (overlay, ZIndex 30, плашка всегда 44px, авто-скролл)
		function Tab:AddDropdown(opts)
			opts = opts or {}
			local options  = opts.Options or {}
			local selected = opts.Default or (options[1] or "...")
			local open     = false
			local ROW      = 28

			local f = baseFrame(44)
			Util.Create("TextLabel", {
				Parent = f, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0), Font = Enum.Font.GothamMedium, Text = opts.Name or "Dropdown",
				TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
			})
			local header = Util.Create("TextButton", {
				Parent = f, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 150, 0, 28), BackgroundColor3 = Theme.Sidebar,
				BackgroundTransparency = 0.2, Text = "", AutoButtonColor = false, ZIndex = 4,
			})
			Util.Corner(header, 6)
			Util.Stroke(header, Theme.Stroke, 0.8, 0.5)
			local selLbl = Util.Create("TextLabel", {
				Parent = header, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -30, 1, 0), Font = Enum.Font.Gotham, Text = tostring(selected),
				TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
			})
			local arrow = Util.Create("TextLabel", {
				Parent = header, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 14, 0, 14),
				Font = Enum.Font.GothamBold, Text = "v", TextColor3 = Theme.SubText, TextSize = 12, ZIndex = 5,
			})

			local list = Util.Create("Frame", {
				Parent = page, Size = UDim2.new(0, 150, 0, 0), BackgroundColor3 = Theme.Element,
				BackgroundTransparency = 0.02, Visible = false, ClipsDescendants = true, ZIndex = 30,
			})
			Util.Corner(list, 6)
			Util.Stroke(list, Theme.Stroke, 0.8, 0.3)
			Util.Create("UIListLayout", {
				Parent = list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder,
			})
			Util.Create("UIPadding", {
				Parent = list, PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3),
				PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3),
			})

			local function syncPos()
				local hp, pp = header.AbsolutePosition, page.AbsolutePosition
				list.Position = UDim2.new(0, hp.X - pp.X, 0, (hp.Y - pp.Y) + header.AbsoluteSize.Y + 4)
			end
			local function ensureVisible(listH)
				local pageBottom = page.AbsolutePosition.Y + page.AbsoluteSize.Y
				local listBottom = header.AbsolutePosition.Y + header.AbsoluteSize.Y + 4 + listH
				if listBottom > pageBottom then
					local delta = listBottom - pageBottom + 10
					container.CanvasPosition = Vector2.new(container.CanvasPosition.X,
						container.CanvasPosition.Y + delta)
				end
			end

			local function rebuild()
				for _, c in ipairs(list:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				for _, opt in ipairs(options) do
					local row = Util.Create("TextButton", {
						Parent = list, Size = UDim2.new(1, 0, 0, ROW - 2), BackgroundColor3 = Theme.Sidebar,
						BackgroundTransparency = 0.2, Text = "", AutoButtonColor = false, ZIndex = 31,
					})
					Util.Corner(row, 5)
					Util.Create("TextLabel", {
						Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0),
						Size = UDim2.new(1, -16, 1, 0), Font = Enum.Font.Gotham, Text = tostring(opt),
						TextColor3 = (opt == selected) and Theme.Accent or Theme.SubText, TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32,
					})
					row.MouseEnter:Connect(function() Util.Tween(row, 0.1, { BackgroundTransparency = 0 }) end)
					row.MouseLeave:Connect(function() Util.Tween(row, 0.1, { BackgroundTransparency = 0.2 }) end)
					row.MouseButton1Click:Connect(function()
						selected = opt
						selLbl.Text = tostring(opt)
						rebuild()
						open = false
						Util.Tween(arrow, 0.2, { Rotation = 0 })
						Util.Tween(list, 0.18, { Size = UDim2.new(0, 150, 0, 0) })
						task.delay(0.18, function() if not open then list.Visible = false end end)
						Util.SafeCallback(opts.Callback, opt)
					end)
				end
			end
			rebuild()

			local scrollConn
			header.MouseButton1Click:Connect(function()
				open = not open
				if open then
					local listH = #options * ROW + 6
					list.Visible = true
					list.Size = UDim2.new(0, 150, 0, 0)
					syncPos()
					ensureVisible(listH)
					syncPos()
					Util.Tween(arrow, 0.2, { Rotation = 180 })
					Util.Tween(list, 0.2, { Size = UDim2.new(0, 150, 0, listH) })
					scrollConn = container:GetPropertyChangedSignal("CanvasPosition"):Connect(syncPos)
				else
					if scrollConn then scrollConn:Disconnect() end
					Util.Tween(arrow, 0.2, { Rotation = 0 })
					Util.Tween(list, 0.2, { Size = UDim2.new(0, 150, 0, 0) })
					task.delay(0.2, function() if not open then list.Visible = false end end)
				end
			end)

			return {
				Set = function(v) selected = v; selLbl.Text = tostring(v); rebuild() end,
				Refresh = function(n) options = n; rebuild() end,
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
	Size = Vector2.new(520, 320),
	Background = "rbxassetid://0",   -- сюда свой Asset ID арта
	BackgroundTransparency = 0.8,    -- 0 = ярко, 1 = невидимо
})

local Misc = Window:AddTab("Misc", "rbxassetid://10734950309")

Misc:AddSection("Movement")
Misc:AddToggle({ Name = "Noclip", Default = false, Callback = function(s) print("Noclip:", s) end })
Misc:AddSlider({
	Name = "WalkSpeed", Description = "Скорость персонажа",
	Min = 0, Max = 100, Default = 16,
	Callback = function(v)
		local c = LocalPlayer.Character
		if c and c:FindFirstChildOfClass("Humanoid") then
			c:FindFirstChildOfClass("Humanoid").WalkSpeed = v
		end
	end,
})
Misc:AddButton({ Name = "Respawn", Callback = function() print("Кнопка нажата") end })
Misc:AddTextbox({ Name = "Никнейм", Placeholder = "Введите текст...", Callback = function(t) print(t) end })
Misc:AddDropdown({
	Name = "Режим", Options = { "Лёгкий", "Средний", "Сложный" }, Default = "Средний",
	Callback = function(o) print("Выбрано:", o) end,
})

return Library