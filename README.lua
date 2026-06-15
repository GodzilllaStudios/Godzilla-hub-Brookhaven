--[[
    HubUI - Biblioteca de interface para Roblox (feita do zero)
    Como usar: cole este arquivo como um ModuleScript e faça require(),
    ou carregue via loadstring(readfile/HttpGet) se preferir um arquivo só.

    Exemplo de uso está no final do arquivo (seção EXEMPLO).
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------------
-- TEMA / CORES
----------------------------------------------------------------
local Theme = {
    Background   = Color3.fromRGB(22, 22, 27),
    Panel        = Color3.fromRGB(30, 30, 37),
    PanelLight   = Color3.fromRGB(38, 38, 46),
    Stroke       = Color3.fromRGB(54, 54, 64),
    Accent       = Color3.fromRGB(130, 95, 255),
    AccentLight  = Color3.fromRGB(165, 135, 255),
    Text         = Color3.fromRGB(240, 240, 245),
    SubText      = Color3.fromRGB(150, 150, 162),
    Font         = Enum.Font.GothamSemibold,
    FontRegular  = Enum.Font.Gotham,
}

----------------------------------------------------------------
-- FUNÇÕES UTILITÁRIAS
----------------------------------------------------------------
local function New(className, props)
    local inst = Instance.new(className)
    for prop, value in pairs(props) do
        if prop ~= "Parent" then
            inst[prop] = value
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Round(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent,
    })
end

local function Stroke(parent, color, thickness)
    return New("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Parent = parent,
    })
end

local function Tween(obj, props, duration, style, direction)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragStart, startPos = false, nil, nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

----------------------------------------------------------------
-- BIBLIOTECA PRINCIPAL
----------------------------------------------------------------
local Library = {}
Library.__index = Library

function Library:CreateWindow(config)
    config = config or {}
    local title    = config.Title or "Hub"
    local subtitle = config.SubTitle or "by você"
    local size     = config.Size or UDim2.new(0, 580, 0, 380)

    -- ScreenGui
    local ScreenGui = New("ScreenGui", {
        Name = "HubUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"),
    })

    -- Janela principal
    local Main = New("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui,
    })
    Round(Main, 10)
    Stroke(Main, Theme.Stroke, 1)

    -- Barra superior
    local TopBar = New("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = Main,
    })
    Round(TopBar, 10)

    -- corrige cantos arredondados só na parte de cima
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = TopBar,
    })

    local AccentBar = New("Frame", {
        Size = UDim2.new(0, 4, 0.6, 0),
        Position = UDim2.new(0, 14, 0.2, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = TopBar,
    })
    Round(AccentBar, 4)

    New("TextLabel", {
        Text = title,
        Font = Theme.Font,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 28, 0, 4),
        Size = UDim2.new(0, 300, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    New("TextLabel", {
        Text = subtitle,
        Font = Theme.FontRegular,
        TextSize = 12,
        TextColor3 = Theme.SubText,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 28, 0, 22),
        Size = UDim2.new(0, 300, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    -- Botão fechar
    local CloseBtn = New("TextButton", {
        Text = "×",
        Font = Theme.Font,
        TextSize = 20,
        TextColor3 = Theme.SubText,
        BackgroundColor3 = Theme.PanelLight,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0, 9),
        AutoButtonColor = false,
        Parent = TopBar,
    })
    Round(CloseBtn, 6)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(220, 70, 70)}, 0.15)
        Tween(CloseBtn, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.PanelLight}, 0.15)
        Tween(CloseBtn, {TextColor3 = Theme.SubText}, 0.15)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0,0,0,0)}, 0.2)
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    -- Botão minimizar
    local MinBtn = New("TextButton", {
        Text = "—",
        Font = Theme.Font,
        TextSize = 16,
        TextColor3 = Theme.SubText,
        BackgroundColor3 = Theme.PanelLight,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -72, 0, 9),
        AutoButtonColor = false,
        Parent = TopBar,
    })
    Round(MinBtn, 6)
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {BackgroundColor3 = Theme.Stroke}, 0.15)
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {BackgroundColor3 = Theme.PanelLight}, 0.15)
    end)

    MakeDraggable(Main, TopBar)

    -- Sidebar (abas)
    local Sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, -56),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    local TabList = New("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = Sidebar,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = Sidebar,
    })

    -- Linha divisória
    New("Frame", {
        Size = UDim2.new(0, 1, 1, -56),
        Position = UDim2.new(0, 150, 0, 56),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = Main,
    })

    -- Área de conteúdo
    local Content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -151, 1, -56),
        Position = UDim2.new(0, 151, 0, 56),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    local Window = {
        ScreenGui = ScreenGui,
        Main = Main,
        Sidebar = Sidebar,
        Content = Content,
        Tabs = {},
        FirstTab = nil,
    }

    MinBtn.MouseButton1Click:Connect(function()
        Content.Visible = not Content.Visible
        Sidebar.Visible = not Sidebar.Visible
        local newSize = Content.Visible and size or UDim2.new(0, size.X.Offset, 0, 56)
        Tween(Main, {Size = newSize}, 0.2)
    end)

    ----------------------------------------------------------------
    -- ABAS
    ----------------------------------------------------------------
    function Window:CreateTab(name)
        local TabButton = New("TextButton", {
            Text = name,
            Font = Theme.FontRegular,
            TextSize = 14,
            TextColor3 = Theme.SubText,
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            AutoButtonColor = false,
            Parent = Sidebar,
        })
        Round(TabButton, 7)

        local TabPage = New("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.new(1, -10, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            Parent = Content,
        })

        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = TabPage,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 6),
            Parent = TabPage,
        })

        local Tab = { Button = TabButton, Page = TabPage }

        local function selectTab()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, {BackgroundTransparency = 1, TextColor3 = Theme.SubText}, 0.15)
            end
            TabPage.Visible = true
            Tween(TabButton, {BackgroundTransparency = 0, TextColor3 = Theme.Text}, 0.15)
        end

        TabButton.MouseButton1Click:Connect(selectTab)
        TabButton.MouseEnter:Connect(function()
            if not TabPage.Visible then
                Tween(TabButton, {BackgroundTransparency = 0.6}, 0.15)
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if not TabPage.Visible then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
            end
        end)

        table.insert(Window.Tabs, Tab)
        if not Window.FirstTab then
            Window.FirstTab = true
            selectTab()
        end

        ------------------------------------------------------------
        -- ELEMENTOS
        ------------------------------------------------------------

        -- Label / texto de seção
        function Tab:AddLabel(text)
            New("TextLabel", {
                Text = text,
                Font = Theme.Font,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Parent = TabPage,
            })
        end

        -- Botão
        function Tab:AddButton(text, callback)
            callback = callback or function() end

            local Btn = New("TextButton", {
                Text = text,
                Font = Theme.FontRegular,
                TextSize = 14,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Panel,
                Size = UDim2.new(1, 0, 0, 36),
                AutoButtonColor = false,
                Parent = TabPage,
            })
            Round(Btn, 7)
            Stroke(Btn, Theme.Stroke, 1)

            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.PanelLight}, 0.15)
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.Panel}, 0.15)
            end)
            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.Accent}, 0.08)
                task.wait(0.08)
                Tween(Btn, {BackgroundColor3 = Theme.PanelLight}, 0.15)
                callback()
            end)

            return Btn
        end

        -- Toggle
        function Tab:AddToggle(text, default, callback)
            callback = callback or function() end
            local state = default or false

            local Holder = New("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Panel,
                Parent = TabPage,
            })
            Round(Holder, 7)
            Stroke(Holder, Theme.Stroke, 1)

            New("TextLabel", {
                Text = text,
                Font = Theme.FontRegular,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Parent = Holder,
            })

            local Switch = New("Frame", {
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = state and Theme.Accent or Theme.Stroke,
                Parent = Holder,
            })
            Round(Switch, 10)

            local Knob = New("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = Switch,
            })
            Round(Knob, 8)

            local Click = New("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = Holder,
            })

            Click.MouseButton1Click:Connect(function()
                state = not state
                Tween(Switch, {BackgroundColor3 = state and Theme.Accent or Theme.Stroke}, 0.15)
                Tween(Knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.15)
                callback(state)
            end)

            return {
                Set = function(_, value)
                    state = value
                    Tween(Switch, {BackgroundColor3 = state and Theme.Accent or Theme.Stroke}, 0.15)
                    Tween(Knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.15)
                    callback(state)
                end
            }
        end

        -- Slider
        function Tab:AddSlider(text, min, max, default, callback)
            callback = callback or function() end
            min, max = min or 0, max or 100
            local value = math.clamp(default or min, min, max)

            local Holder = New("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Theme.Panel,
                Parent = TabPage,
            })
            Round(Holder, 7)
            Stroke(Holder, Theme.Stroke, 1)

            local Label = New("TextLabel", {
                Text = text,
                Font = Theme.FontRegular,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -24, 0, 18),
                Parent = Holder,
            })

            local ValueLabel = New("TextLabel", {
                Text = tostring(value),
                Font = Theme.Font,
                TextSize = 13,
                TextColor3 = Theme.AccentLight,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 6),
                Size = UDim2.new(0, 48, 0, 18),
                Parent = Holder,
            })

            local Track = New("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Stroke,
                Parent = Holder,
            })
            Round(Track, 3)

            local function ratio()
                return (value - min) / (max - min)
            end

            local Fill = New("Frame", {
                Size = UDim2.new(ratio(), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                Parent = Track,
            })
            Round(Fill, 3)

            local dragging = false

            local function update(input)
                local relative = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * relative + 0.5)
                Fill.Size = UDim2.new(relative, 0, 1, 0)
                ValueLabel.Text = tostring(value)
                callback(value)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)

            return {
                Set = function(_, newValue)
                    value = math.clamp(newValue, min, max)
                    Fill.Size = UDim2.new(ratio(), 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    callback(value)
                end
            }
        end

        -- Dropdown
        function Tab:AddDropdown(text, options, default, callback)
            callback = callback or function() end
            options = options or {}
            local selected = default or options[1]
            local open = false

            local Holder = New("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Panel,
                ClipsDescendants = true,
                ZIndex = 2,
                Parent = TabPage,
            })
            Round(Holder, 7)
            Stroke(Holder, Theme.Stroke, 1)

            New("TextLabel", {
                Text = text,
                Font = Theme.FontRegular,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.5, 0, 0, 36),
                ZIndex = 2,
                Parent = Holder,
            })

            local SelectedLabel = New("TextLabel", {
                Text = tostring(selected),
                Font = Theme.Font,
                TextSize = 13,
                TextColor3 = Theme.AccentLight,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -36, 0, 0),
                Size = UDim2.new(0.5, 24, 0, 36),
                ZIndex = 2,
                Parent = Holder,
            })

            local Toggle = New("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                ZIndex = 3,
                Parent = Holder,
            })

            local List = New("Frame", {
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, #options * 28 + 6),
                BackgroundColor3 = Theme.PanelLight,
                ZIndex = 2,
                Parent = Holder,
            })
            Round(List, 6)
            New("UIListLayout", {Padding = UDim.new(0, 2), Parent = List})
            New("UIPadding", {PaddingTop = UDim.new(0,3), PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), Parent = List})

            for _, opt in ipairs(options) do
                local OptBtn = New("TextButton", {
                    Text = tostring(opt),
                    Font = Theme.FontRegular,
                    TextSize = 13,
                    TextColor3 = Theme.SubText,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    ZIndex = 2,
                    Parent = List,
                })
                OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {TextColor3 = Theme.Text}, 0.1) end)
                OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {TextColor3 = Theme.SubText}, 0.1) end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    SelectedLabel.Text = tostring(opt)
                    callback(opt)
                    open = false
                    Tween(Holder, {Size = UDim2.new(1, 0, 0, 36)}, 0.15)
                end)
            end

            Toggle.MouseButton1Click:Connect(function()
                open = not open
                local target = open and UDim2.new(1, 0, 0, 38 + #options * 28 + 6) or UDim2.new(1, 0, 0, 36)
                Tween(Holder, {Size = target}, 0.18)
            end)

            return {
                Set = function(_, opt)
                    selected = opt
                    SelectedLabel.Text = tostring(opt)
                    callback(opt)
                end
            }
        end

        return Tab
    end

    ----------------------------------------------------------------
    -- NOTIFICAÇÕES
    ----------------------------------------------------------------
    function Window:Notify(title, text, duration)
        duration = duration or 3

        local Notif = New("Frame", {
            Size = UDim2.new(0, 260, 0, 70),
            Position = UDim2.new(1, -280, 1, -90),
            BackgroundColor3 = Theme.Panel,
            BackgroundTransparency = 0,
            Parent = ScreenGui,
        })
        Round(Notif, 8)
        Stroke(Notif, Theme.Stroke, 1)

        local AccentStripe = New("Frame", {
            Size = UDim2.new(0, 4, 1, -16),
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = Theme.Accent,
            Parent = Notif,
        })
        Round(AccentStripe, 2)

        New("TextLabel", {
            Text = title,
            Font = Theme.Font,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 10),
            Size = UDim2.new(1, -30, 0, 18),
            Parent = Notif,
        })

        New("TextLabel", {
            Text = text,
            Font = Theme.FontRegular,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 30),
            Size = UDim2.new(1, -30, 0, 36),
            Parent = Notif,
        })

        Notif.Position = UDim2.new(1, 20, 1, -90)
        Tween(Notif, {Position = UDim2.new(1, -280, 1, -90)}, 0.3, Enum.EasingStyle.Back)

        task.delay(duration, function()
            Tween(Notif, {Position = UDim2.new(1, 20, 1, -90)}, 0.3, Enum.EasingStyle.Back)
            task.wait(0.3)
            Notif:Destroy()
        end)
    end

    return Window
end

return Library

--[[
    ====================== EXEMPLO DE USO ======================

    local Library = loadstring(game:HttpGet("URL_DO_SEU_RAW_GITHUB"))()

    local Window = Library:CreateWindow({
        Title = "Meu Hub",
        SubTitle = "v1.0",
        Size = UDim2.new(0, 580, 0, 380),
    })

    local TabMain = Window:CreateTab("Principal")
    local TabSettings = Window:CreateTab("Configurações")

    TabMain:AddLabel("Funções gerais")

    TabMain:AddButton("Clique aqui", function()
        Window:Notify("Aviso", "Você clicou no botão!", 3)
    end)

    TabMain:AddToggle("Ativar voo", false, function(state)
        print("Voo:", state)
    end)

    TabMain:AddSlider("Velocidade", 0, 100, 16, function(value)
        print("Velocidade:", value)
    end)

    TabMain:AddDropdown("Modo", {"Padrão", "Turbo", "Stealth"}, "Padrão", function(opt)
        print("Modo selecionado:", opt)
    end)

    =============================================================
]]
