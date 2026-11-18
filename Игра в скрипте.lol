-- НАЧАЛО ЧАСТИ 1А
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local parentGui = (gethui and gethui()) or CoreGui or player:WaitForChild("PlayerGui")

if parentGui:FindFirstChild("BloxRoulette3D") then
    parentGui.BloxRoulette3D:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxRoulette3D"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

local SOUNDS = {
    Shot = "rbxassetid://168143115",
    Blank = "rbxassetid://142082166",
    Rack = "rbxassetid://168143162",
    Saw = "rbxassetid://131072992",
    Heal = "rbxassetid://4612375233",
    Win = "rbxassetid://9114021242" -- 8-Bit Retro Win (в духе DOORS Thank You)

}

local function playSFX(soundId, pitch)
    task.spawn(function()
        pcall(function()
            local s = Instance.new("Sound", ScreenGui)
            s.SoundId = soundId
            s.Volume = 0.85
            s.PlaybackSpeed = pitch or 1
            s:Play()
            s.Ended:Connect(function() s:Destroy() end)
            task.delay(3, function() if s then s:Destroy() end end)
        end)
    end)
end
-- КОНЕЦ ЧАСТИ 1А
-- НАЧАЛО ЧАСТИ 1Б
local function makeDraggable(obj, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local MiniLauncher = Instance.new("Frame", ScreenGui)
MiniLauncher.Name = "PromtHackerLauncher"
MiniLauncher.Size = UDim2.new(0, 230, 0, 82)
MiniLauncher.Position = UDim2.new(0, 20, 0.5, -41)
MiniLauncher.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Instance.new("UICorner", MiniLauncher).CornerRadius = UDim.new(0, 8)
local lStroke = Instance.new("UIStroke", MiniLauncher)
lStroke.Color = Color3.fromRGB(180, 35, 35)
lStroke.Thickness = 1.6
makeDraggable(MiniLauncher, MiniLauncher)

local LHeader = Instance.new("TextLabel", MiniLauncher)
LHeader.Size = UDim2.new(1, -35, 0, 22)
LHeader.Position = UDim2.new(0, 8, 0, 4)
LHeader.BackgroundTransparency = 1
LHeader.Text = "⚡ PROMT_HACKER // MODULE"
LHeader.TextColor3 = Color3.fromRGB(150, 150, 165)
LHeader.Font = Enum.Font.Code
LHeader.TextSize = 11
LHeader.TextXAlignment = Enum.TextXAlignment.Left

local UnloadBtn = Instance.new("TextButton", MiniLauncher)
UnloadBtn.Size = UDim2.new(0, 20, 0, 20)
UnloadBtn.Position = UDim2.new(1, -24, 0, 4)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
UnloadBtn.Text = "X"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
UnloadBtn.Font = Enum.Font.Code
UnloadBtn.TextSize = 11
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 4)
UnloadBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local TriggerBtn = Instance.new("TextButton", MiniLauncher)
TriggerBtn.Size = UDim2.new(1, -16, 0, 44)
TriggerBtn.Position = UDim2.new(0, 8, 0, 30)
TriggerBtn.BackgroundColor3 = Color3.fromRGB(155, 30, 30)
TriggerBtn.Text = "🎲 BLOX ROULETTE.3D\n[ НАЖМИ ДЛЯ ЗАПУСКА ]"
TriggerBtn.TextColor3 = Color3.new(1, 1, 1)
TriggerBtn.Font = Enum.Font.Code
TriggerBtn.TextSize = 12
Instance.new("UICorner", TriggerBtn).CornerRadius = UDim.new(0, 6)
-- КОНЕЦ ЧАСТИ 1Б
-- НАЧАЛО ЧАСТИ 1В
local ITEMS_DB = {
    ["Magnifying Glass"] = {Icon = "🔍", Short = "Лупа", Desc = "Показывает текущий патрон в стволе"},
    ["Beer"] = {Icon = "🍺", Short = "Пиво", Desc = "Выбрасывает патрон (вылетает 3D-гильза)"},
    ["Handsaw"] = {Icon = "🪚", Short = "Ножовка", Desc = "Отпиливает 3D-ствол: 2X УРОН (2 HP)"},
    ["Handcuffs"] = {Icon = "⛓️", Short = "Наручники", Desc = "Противник пропускает следующий ход"},
    ["Cigarettes"] = {Icon = "🚬", Short = "Сигареты", Desc = "Восстанавливает +1 заряд здоровья"},
    ["Inverter"] = {Icon = "🔄", Short = "Инвертор", Desc = "Меняет полярность патрона (Боевой <-> Холостой)"},
    ["Burner Phone"] = {Icon = "📱", Short = "Телефон", Desc = "Раскрывает случайный патрон в обойме"},
    ["Expired Medicine"] = {Icon = "💊", Short = "Таблетки", Desc = "50% шанс: +2 HP, 50% шанс: -1 HP"},
    ["Adrenaline"] = {Icon = "💉", Short = "Адреналин", Desc = "Украсть и применить предмет Дилера"}
}

local ITEM_NAMES = {}
for k in pairs(ITEMS_DB) do table.insert(ITEM_NAMES, k) end
-- КОНЕЦ ЧАСТИ 1В
-- НАЧАЛО ЧАСТИ 2А
local function Launch3DBuckshot()
    if ScreenGui:FindFirstChild("MainFrame") or ScreenGui:FindFirstChild("IntroOrb") then return end

    local GameState = {
        Round = 1, MaxHP = 4, PlayerHP = 4, DealerHP = 4,
        Shells = {}, PlayerItems = {}, DealerItems = {},
        Turn = "Player", SawActive = false,
        DealerCuffed = false, PlayerCuffed = false,
        StealingMode = false, GameOver = false, Busy = false
    }

    local IntroOrb = Instance.new("Frame", ScreenGui)
    IntroOrb.Name = "IntroOrb"
    IntroOrb.Size = UDim2.new(0, 56, 0, 56)
    IntroOrb.Position = UDim2.new(0.5, -28, 0, -70)
    IntroOrb.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    IntroOrb.ZIndex = 20
    Instance.new("UICorner", IntroOrb).CornerRadius = UDim.new(1, 0)
    local orbStroke = Instance.new("UIStroke", IntroOrb)
    orbStroke.Color = Color3.fromRGB(255, 200, 50)
    orbStroke.Thickness = 2

    local BoltLabel = Instance.new("TextLabel", IntroOrb)
    BoltLabel.Size = UDim2.new(1, 0, 1, 0)
    BoltLabel.BackgroundTransparency = 1
    BoltLabel.Text = "⚡"
    BoltLabel.TextColor3 = Color3.fromRGB(255, 225, 65)
    BoltLabel.Font = Enum.Font.Code
    BoltLabel.TextSize = 28
    BoltLabel.ZIndex = 21

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 480, 0, 330)
    MainFrame.Position = UDim2.new(0.5, -240, 0.5, -165)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(100, 25, 25)
    MainStroke.Thickness = 2

    local WinScale = Instance.new("UIScale", MainFrame)
    WinScale.Scale = 0.01

    local FlashOverlay = Instance.new("Frame", MainFrame)
    FlashOverlay.Size = UDim2.new(1, 0, 1, 0)
    FlashOverlay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    FlashOverlay.BackgroundTransparency = 1
    FlashOverlay.ZIndex = 10

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 34)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    makeDraggable(MainFrame, TopBar)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "BLOX ROULETTE"
    Title.TextColor3 = Color3.fromRGB(240, 55, 55)
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
-- КОНЕЦ ЧАСТИ 2А
-- НАЧАЛО ЧАСТИ 2Б
    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, 28, 0, 24)
    MinBtn.Position = UDim2.new(1, -64, 0, 5)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    MinBtn.Text = "_"
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.Font = Enum.Font.Code
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 28, 0, 24)
    CloseBtn.Position = UDim2.new(1, -32, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.Code
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    local Content = Instance.new("Frame", MainFrame)
    Content.Size = UDim2.new(1, -20, 1, -44)
    Content.Position = UDim2.new(0, 10, 0, 38)
    Content.BackgroundTransparency = 1

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Content.Visible = not minimized
        local targetSize = minimized and UDim2.new(0, 600, 0, 34) or UDim2.new(0, 600, 0, 520)
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        local closeTw = TweenService:Create(WinScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
        closeTw:Play()
        closeTw.Completed:Wait()
        MainFrame:Destroy()
    end)

    local function spawnMiniExplosion(impactOffset)
        playSFX(SOUNDS.Shot, 1.85)
        local ring = Instance.new("Frame", ScreenGui)
        ring.Size = UDim2.new(0, 10, 0, 10)
        ring.Position = UDim2.new(0.5, impactOffset.X - 5, 0.5, impactOffset.Y - 5)
        ring.BackgroundTransparency = 1
        ring.ZIndex = 25
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        local rStroke = Instance.new("UIStroke", ring)
        rStroke.Color = Color3.fromRGB(255, 225, 70)
        rStroke.Thickness = 2.5

        TweenService:Create(ring, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 64, 0, 64),
            Position = UDim2.new(0.5, impactOffset.X - 32, 0.5, impactOffset.Y - 32)
        }):Play()
        TweenService:Create(rStroke, TweenInfo.new(0.32), {Transparency = 1}):Play()
        task.delay(0.35, function() if ring then ring:Destroy() end end)

        for i = 1, 6 do
            local spark = Instance.new("Frame", ScreenGui)
            spark.Size = UDim2.new(0, 5, 0, 5)
            spark.Position = UDim2.new(0.5, impactOffset.X, 0.5, impactOffset.Y)
            spark.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 230, 80) or Color3.fromRGB(255, 90, 60)
            spark.ZIndex = 26
            Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)

            local angle = math.rad(i * 60 + math.random(-15, 15))
            local dist = math.random(24, 38)
            TweenService:Create(spark, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, impactOffset.X + math.cos(angle) * dist, 0.5, impactOffset.Y + math.sin(angle) * dist),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 2)
            }):Play()
            task.delay(0.3, function() if spark then spark:Destroy() end end)
        end

        Title.Text = "BLOX ROULETTE ⚡ // 3D EDITION"
        Title.TextColor3 = Color3.fromRGB(255, 230, 100)
        Title.Position = UDim2.new(0, 16, 0, -2)
        TweenService:Create(Title, TweenInfo.new(0.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 12, 0, 0),
            TextColor3 = Color3.fromRGB(240, 55, 55)
        }):Play()
    end

    task.spawn(function()
        playSFX(SOUNDS.Heal, 1.3)
        local slideTw = TweenService:Create(IntroOrb, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -28, 0.5, -28)
        })
        slideTw:Play()
        slideTw.Completed:Wait()

        MainFrame.Visible = true
        TweenService:Create(IntroOrb, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Rotation = 360,
            BackgroundTransparency = 1
        }):Play()
        orbStroke.Transparency = 1

        local openTw = TweenService:Create(WinScale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
        openTw:Play()
        openTw.Completed:Wait()

        local p0, p1, p2 = Vector2.new(-14, -14), Vector2.new(-250, -90), Vector2.new(-172, -246)
        for step = 1, 16 do
            local t = step / 16
            local pos = ((1 - t)^2) * p0 + 2 * (1 - t) * t * p1 + (t^2) * p2
            IntroOrb.Position = UDim2.new(0.5, pos.X, 0.5, pos.Y)
            IntroOrb.Rotation = 360 + (t * 360)
            BoltLabel.TextSize = 28 - (t * 12)
            task.wait(0.016)
        end
        IntroOrb:Destroy()
        spawnMiniExplosion(Vector2.new(-164, -242))
    end)
-- КОНЕЦ ЧАСТИ 2Б
-- НАЧАЛО ЧАСТИ 2В
    local StatusBar = Instance.new("Frame", Content)
    StatusBar.Size = UDim2.new(1, 0, 0, 42)
    StatusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", StatusBar).CornerRadius = UDim.new(0, 6)

    local DealerHPLabel = Instance.new("TextLabel", StatusBar)
    DealerHPLabel.Size = UDim2.new(0.38, 0, 1, 0)
    DealerHPLabel.Position = UDim2.new(0, 10, 0, 0)
    DealerHPLabel.BackgroundTransparency = 1
    DealerHPLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    DealerHPLabel.Font = Enum.Font.Code
    DealerHPLabel.TextSize = 15
    DealerHPLabel.TextXAlignment = Enum.TextXAlignment.Left

    local DealerFace = Instance.new("TextLabel", StatusBar)
    DealerFace.Size = UDim2.new(0.24, 0, 1, 0)
    DealerFace.Position = UDim2.new(0.38, 0, 0, 0)
    DealerFace.BackgroundTransparency = 1
    DealerFace.Text = "[ 👁️ _ 👁️ ]"
    DealerFace.TextColor3 = Color3.fromRGB(255, 200, 90)
    DealerFace.Font = Enum.Font.Code
    DealerFace.TextSize = 15

    local PlayerHPLabel = Instance.new("TextLabel", StatusBar)
    PlayerHPLabel.Size = UDim2.new(0.38, -10, 1, 0)
    PlayerHPLabel.Position = UDim2.new(0.62, 0, 0, 0)
    PlayerHPLabel.BackgroundTransparency = 1
    PlayerHPLabel.TextColor3 = Color3.fromRGB(85, 255, 130)
    PlayerHPLabel.Font = Enum.Font.Code
    PlayerHPLabel.TextSize = 15
    PlayerHPLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Viewport = Instance.new("ViewportFrame", Content)
    Viewport.Size = UDim2.new(1, 0, 0, 135)
    Viewport.Position = UDim2.new(0, 0, 0, 48)
    Viewport.BackgroundColor3 = Color3.fromRGB(8, 10, 9)
    Viewport.Ambient = Color3.fromRGB(130, 130, 140)
    Viewport.LightColor = Color3.fromRGB(255, 230, 210)
    Viewport.LightDirection = Vector3.new(-1, -2, -1)
    Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Viewport).Color = Color3.fromRGB(50, 75, 55)

    local WorldModel = Instance.new("WorldModel", Viewport)
    local Camera = Instance.new("Camera", Viewport)
    Camera.CFrame = CFrame.new(Vector3.new(0, 3.2, 4.8), Vector3.new(0, 0.3, -0.5))
    Viewport.CurrentCamera = Camera

    local TableTop = Instance.new("Part", WorldModel)
    TableTop.Size = Vector3.new(10, 0.4, 7)
    TableTop.Position = Vector3.new(0, -0.2, 0)
    TableTop.Anchored = true
    TableTop.Color = Color3.fromRGB(24, 52, 34)
    TableTop.Material = Enum.Material.SmoothPlastic

    local TableBorder = Instance.new("Part", WorldModel)
    TableBorder.Size = Vector3.new(10.4, 0.5, 7.4)
    TableBorder.Position = Vector3.new(0, -0.3, 0)
    TableBorder.Anchored = true
    TableBorder.Color = Color3.fromRGB(45, 28, 18)

    local GunRoot = Instance.new("Part", WorldModel)
    GunRoot.Size = Vector3.new(0.2, 0.2, 0.2)
    GunRoot.Transparency = 1
    GunRoot.Anchored = true
    GunRoot.CFrame = CFrame.new(0, 0.35, 0)

    local function makeGunPart(size, offset, color)
        local p = Instance.new("Part", WorldModel)
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.Metal
        p.Anchored = true
        p.CFrame = GunRoot.CFrame * CFrame.new(offset)
        return p
    end

    local Stock = makeGunPart(Vector3.new(0.26, 0.36, 1.1), Vector3.new(0, -0.05, 1.1), Color3.fromRGB(95, 50, 25))
    local Receiver = makeGunPart(Vector3.new(0.3, 0.32, 0.9), Vector3.new(0, 0.05, 0.2), Color3.fromRGB(35, 35, 40))
    local Pump = makeGunPart(Vector3.new(0.32, 0.26, 0.8), Vector3.new(0, -0.04, -0.7), Color3.fromRGB(85, 45, 20))
    local BarrelBase = makeGunPart(Vector3.new(0.22, 0.22, 1.3), Vector3.new(0, 0.1, -0.8), Color3.fromRGB(55, 55, 62))
    local BarrelTip = makeGunPart(Vector3.new(0.21, 0.21, 0.8), Vector3.new(0, 0.1, -1.8), Color3.fromRGB(55, 55, 62))

    local function syncGunParts()
        Stock.CFrame = GunRoot.CFrame * CFrame.new(0, -0.05, 1.1)
        Receiver.CFrame = GunRoot.CFrame * CFrame.new(0, 0.05, 0.2)
        Pump.CFrame = GunRoot.CFrame * CFrame.new(0, -0.04, -0.7)
        BarrelBase.CFrame = GunRoot.CFrame * CFrame.new(0, 0.1, -0.8)
        BarrelTip.CFrame = GunRoot.CFrame * CFrame.new(0, 0.1, -1.8)
        BarrelTip.Transparency = GameState.SawActive and 1 or 0
    end
-- КОНЕЦ ЧАСТИ 2В
-- НАЧАЛО ЧАСТИ 2Г
    local GunStatusLabel = Instance.new("TextLabel", Viewport)
    GunStatusLabel.Size = UDim2.new(1, -16, 0, 26)
    GunStatusLabel.Position = UDim2.new(0, 8, 1, -28)
    GunStatusLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    GunStatusLabel.BackgroundTransparency = 0.35
    GunStatusLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    GunStatusLabel.Font = Enum.Font.Code
    GunStatusLabel.TextSize = 12
    Instance.new("UICorner", GunStatusLabel).CornerRadius = UDim.new(0, 4)

    local DealerInvFrame = Instance.new("Frame", Content)
    DealerInvFrame.Size = UDim2.new(1, 0, 0, 42)
    DealerInvFrame.Position = UDim2.new(0, 0, 0, 190)
    DealerInvFrame.BackgroundColor3 = Color3.fromRGB(24, 18, 20)
    Instance.new("UICorner", DealerInvFrame).CornerRadius = UDim.new(0, 6)
    local DLayout = Instance.new("UIListLayout", DealerInvFrame)
    DLayout.FillDirection = Enum.FillDirection.Horizontal
    DLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    DLayout.Padding = UDim.new(0, 8)
    DLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local PlayerInvFrame = Instance.new("Frame", Content)
    PlayerInvFrame.Size = UDim2.new(1, 0, 0, 54)
    PlayerInvFrame.Position = UDim2.new(0, 0, 0, 238)
    PlayerInvFrame.BackgroundColor3 = Color3.fromRGB(18, 24, 20)
    Instance.new("UICorner", PlayerInvFrame).CornerRadius = UDim.new(0, 6)
    local PLayout = Instance.new("UIListLayout", PlayerInvFrame)
    PLayout.FillDirection = Enum.FillDirection.Horizontal
    PLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PLayout.Padding = UDim.new(0, 8)
    PLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local TooltipLabel = Instance.new("TextLabel", Content)
    TooltipLabel.Size = UDim2.new(1, 0, 0, 20)
    TooltipLabel.Position = UDim2.new(0, 0, 0, 296)
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.Text = "Наведи на предмет, чтобы увидеть эффект"
    TooltipLabel.TextColor3 = Color3.fromRGB(120, 195, 255)
    TooltipLabel.Font = Enum.Font.Code
    TooltipLabel.TextSize = 12

    local SubLog = Instance.new("TextLabel", Content)
    SubLog.Size = UDim2.new(1, 0, 0, 34)
    SubLog.Position = UDim2.new(0, 0, 0, 320)
    SubLog.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
    SubLog.TextColor3 = Color3.fromRGB(190, 190, 190)
    SubLog.Font = Enum.Font.Code
    SubLog.TextSize = 11
    SubLog.TextWrapped = true
    Instance.new("UICorner", SubLog).CornerRadius = UDim.new(0, 5)

    local ShootDealerBtn = Instance.new("TextButton", Content)
    ShootDealerBtn.Size = UDim2.new(0.48, 0, 0, 62)
    ShootDealerBtn.Position = UDim2.new(0, 0, 1, -66)
    ShootDealerBtn.BackgroundColor3 = Color3.fromRGB(165, 35, 35)
    ShootDealerBtn.Text = "🔫 ВЫСТРЕЛИТЬ В ДИЛЕРА"
    ShootDealerBtn.TextColor3 = Color3.new(1, 1, 1)
    ShootDealerBtn.Font = Enum.Font.Code
    ShootDealerBtn.TextSize = 14
    Instance.new("UICorner", ShootDealerBtn).CornerRadius = UDim.new(0, 6)

    local ShootSelfBtn = Instance.new("TextButton", Content)
    ShootSelfBtn.Size = UDim2.new(0.48, 0, 0, 62)
    ShootSelfBtn.Position = UDim2.new(0.52, 0, 1, -66)
    ShootSelfBtn.BackgroundColor3 = Color3.fromRGB(40, 95, 160)
    ShootSelfBtn.Text = "🔫 ВЫСТРЕЛИТЬ В СЕБЯ"
    ShootSelfBtn.TextColor3 = Color3.new(1, 1, 1)
    ShootSelfBtn.Font = Enum.Font.Code
    ShootSelfBtn.TextSize = 14
    Instance.new("UICorner", ShootSelfBtn).CornerRadius = UDim.new(0, 6)
-- КОНЕЦ ЧАСТИ 2Г (Вся Часть 2 готова!)
-- НАЧАЛО ЧАСТИ 3А
    local function animate3DGun(targetType, isLive)
        local targetCF
        if targetType == "Dealer" then
            targetCF = CFrame.new(0, 0.8, -0.4) * CFrame.Angles(math.rad(10), 0, 0)
        elseif targetType == "Player" then
            targetCF = CFrame.new(0, 0.9, 0.6) * CFrame.Angles(math.rad(-15), math.rad(180), 0)
        else
            targetCF = CFrame.new(0, 0.35, 0) * CFrame.Angles(0, math.rad(90), 0)
        end

        for step = 1, 10 do
            GunRoot.CFrame = GunRoot.CFrame:Lerp(targetCF, 0.35)
            syncGunParts()
            task.wait(0.02)
        end

        task.wait(0.25)

        if isLive then
            playSFX(SOUNDS.Shot, 0.95)
            FlashOverlay.BackgroundColor3 = Color3.fromRGB(255, 20, 20)
            FlashOverlay.BackgroundTransparency = 0.3
            TweenService:Create(FlashOverlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()

            local recoilCF = targetCF * CFrame.new(0, 0.3, 0.7) * CFrame.Angles(math.rad(25), 0, 0)
            GunRoot.CFrame = recoilCF
            syncGunParts()

            local origPos = MainFrame.Position
            for _ = 1, 6 do
                MainFrame.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + math.random(-12, 12), origPos.Y.Scale, origPos.Y.Offset + math.random(-12, 12))
                task.wait(0.025)
            end
            MainFrame.Position = origPos
        else
            playSFX(SOUNDS.Blank, 1.1)
            FlashOverlay.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
            FlashOverlay.BackgroundTransparency = 0.75
            TweenService:Create(FlashOverlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        end

        task.wait(0.2)

        local restCF = CFrame.new(0, 0.35, 0) * CFrame.Angles(0, math.rad(90), 0)
        for step = 1, 10 do
            GunRoot.CFrame = GunRoot.CFrame:Lerp(restCF, 0.35)
            syncGunParts()
            task.wait(0.02)
        end
    end

    local function spawn3DShell(isLive)
        task.spawn(function()
            local shell = Instance.new("Part", WorldModel)
            shell.Size = Vector3.new(0.18, 0.18, 0.45)
            shell.Color = isLive and Color3.fromRGB(220, 35, 35) or Color3.fromRGB(35, 130, 235)
            shell.Material = Enum.Material.SmoothPlastic
            shell.Anchored = true
            shell.CFrame = CFrame.new(0, 0.7, 0)

            local endPos = Vector3.new(math.random(-25, 25)/10, 0.1, math.random(-15, 15)/10)
            local endRot = CFrame.Angles(math.rad(90), math.rad(math.random(0, 360)), 0)

            for i = 1, 12 do
                local t = i / 12
                local arcY = math.sin(t * math.pi) * 1.4
                local curPos = Vector3.new(0, 0.7, 0):Lerp(endPos, t) + Vector3.new(0, arcY, 0)
                shell.CFrame = CFrame.new(curPos) * endRot
                task.wait(0.025)
            end
            task.wait(1.5)
            if shell then shell:Destroy() end
        end)
    end

    local function setLog(mainText, color, subText)
        GunStatusLabel.Text = mainText
        GunStatusLabel.TextColor3 = color or Color3.fromRGB(235, 235, 235)
        if subText then SubLog.Text = subText end
    end

    local function updateHPUI()
        local dStr = string.rep("⚡", math.max(0, GameState.DealerHP))
        local pStr = string.rep("⚡", math.max(0, GameState.PlayerHP))
        DealerHPLabel.Text = "DEALER: " .. (dStr ~= "" and dStr or "💀")
        PlayerHPLabel.Text = "YOU: " .. (pStr ~= "" and pStr or "💀")
        syncGunParts()
    end

    local UseItem, DealerTurn
-- КОНЕЦ ЧАСТИ 3А
-- НАЧАЛО ЧАСТИ 3В
    local function startNewGame()
        GameState.Round = 1
        GameState.MaxHP = math.random(3, 5)
        GameState.PlayerHP = GameState.MaxHP
        GameState.DealerHP = GameState.MaxHP
        GameState.PlayerItems = {}
        GameState.DealerItems = {}
        GameState.Turn = "Player"
        GameState.DealerCuffed = false
        GameState.PlayerCuffed = false
        GameState.GameOver = false
        GameState.Busy = false
        ShootDealerBtn.Text = "🔫 ВЫСТРЕЛИТЬ В ДИЛЕРА"
        ShootSelfBtn.Text = "🔫 ВЫСТРЕЛИТЬ В СЕБЯ"
        loadShotgun()
    end

    local function checkEndCondition()
        if GameState.PlayerHP <= 0 then
            GameState.GameOver = true
            DealerFace.Text = "[ 😈 ‿ 😈 ]"
            setLog("💀 ТЫ ПОГИБ. ДИЛЕР ЗАБРАЛ ВСЁ.", Color3.fromRGB(255, 60, 60), "Нажми любую кнопку выстрела для рестарта.")
            ShootDealerBtn.Text = "🔄 ИГРАТЬ СНОВА"
            ShootSelfBtn.Text = "🔄 ИГРАТЬ СНОВА"
            return true
        elseif GameState.DealerHP <= 0 then
            GameState.Round += 1
            DealerFace.Text = "[ ❌ _ ❌ ]"
            if GameState.Round > 3 then
                GameState.GameOver = true
                playSFX(SOUNDS.Win, 1.0)
                setLog("🏆 ПОБЕДА В DOUBLE OR NOTHING!", Color3.fromRGB(80, 255, 130), "Ты вынес весь банк! Жми кнопку чтобы сыграть еще.")
                ShootDealerBtn.Text = "🔄 ИГРАТЬ СНОВА"
                ShootSelfBtn.Text = "🔄 ИГРАТЬ СНОВА"
                return true
            else
                GameState.MaxHP = math.random(4, 6)
                GameState.PlayerHP = GameState.MaxHP
                GameState.DealerHP = GameState.MaxHP
                GameState.PlayerItems = {}
                GameState.DealerItems = {}
                setLog("🔥 ДИЛЕР ПОВЕРЖЕН! РАУНД " .. GameState.Round, Color3.fromRGB(100, 255, 150), "Заряжаем новую партию...")
                task.wait(1.4)
                loadShotgun()
                return true
            end
        end

        if #GameState.Shells == 0 then
            task.wait(0.8)
            loadShotgun()
        end
        return false
    end

    local function switchTurn(nextTurn)
        GameState.Turn = nextTurn
        if nextTurn == "Dealer" then
            if GameState.DealerCuffed then
                GameState.DealerCuffed = false
                setLog("⛓️ Дилер в наручниках и пропускает ход!", Color3.fromRGB(120, 200, 255), "Снова твой ход.")
                GameState.Turn = "Player"
                return
            end
            task.spawn(DealerTurn)
        else
            if GameState.PlayerCuffed then
                GameState.PlayerCuffed = false
                setLog("⛓️ Ты в наручниках и пропускаешь ход!", Color3.fromRGB(255, 120, 120), "Ход переходит Дилеру...")
                GameState.Turn = "Dealer"
                task.spawn(DealerTurn)
            else
                setLog("ТВОЙ ХОД", Color3.fromRGB(120, 255, 150), "Используй предметы или нажимай на спуск.")
            end
        end
    end
-- КОНЕЦ ЧАСТИ 3В (Вся Часть 3 готова!)
-- НАЧАЛО ЧАСТИ 4А
    UseItem = function(who, itemName)
        local isPlayer = (who == "Player")
        local actorName = isPlayer and "Ты" or "Дилер"

        if itemName == "Magnifying Glass" then
            playSFX(SOUNDS.Rack, 1.3)
            if isPlayer then
                local current = GameState.Shells[1]
                setLog("🔍 ЛУПА: В СТВОЛЕ " .. (current and "🔴 БОЕВОЙ!" or "🔵 ХОЛОСТОЙ!"), current and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(90, 190, 255))
            else
                DealerFace.Text = "[ 🧐 _ 👁️ ]"
                setLog("🔍 Дилер проверил патронник лупой...", Color3.fromRGB(210, 210, 210))
            end

        elseif itemName == "Beer" then
            playSFX(SOUNDS.Rack, 1.1)
            local ejected = table.remove(GameState.Shells, 1)
            spawn3DShell(ejected)
            setLog("🍺 " .. actorName .. " выпил пиво: вылетел " .. (ejected and "🔴 БОЕВОЙ!" or "🔵 ХОЛОСТОЙ!"), Color3.fromRGB(255, 200, 100))
            updateHPUI()
            if #GameState.Shells == 0 then task.wait(0.8); loadShotgun() end

        elseif itemName == "Handsaw" then
            playSFX(SOUNDS.Saw, 1.0)
            GameState.SawActive = true
            setLog("🪚 3D-СТВОЛ ОТПИЛЕН! Следующий выстрел = 2 УРОНА!", Color3.fromRGB(255, 100, 50))
            updateHPUI()

        elseif itemName == "Handcuffs" then
            playSFX(SOUNDS.Rack, 0.8)
            if isPlayer then
                GameState.DealerCuffed = true
                setLog("⛓️ Дилер закован в наручники!", Color3.fromRGB(120, 210, 255))
            else
                GameState.PlayerCuffed = true
                setLog("⛓️ Дилер заковал тебя в наручники!", Color3.fromRGB(255, 110, 110))
            end

        elseif itemName == "Cigarettes" then
            playSFX(SOUNDS.Heal, 1.0)
            if isPlayer then GameState.PlayerHP = math.min(GameState.MaxHP, GameState.PlayerHP + 1)
            else GameState.DealerHP = math.min(GameState.MaxHP, GameState.DealerHP + 1) end
            setLog("🚬 " .. actorName .. " восстановил +1 HP.", Color3.fromRGB(120, 255, 150))
            updateHPUI()

        elseif itemName == "Inverter" then
            playSFX(SOUNDS.Blank, 1.5)
            if #GameState.Shells > 0 then
                GameState.Shells[1] = not GameState.Shells[1]
                setLog("🔄 ИНВЕРТОР: Полярность патрона изменена!", Color3.fromRGB(200, 130, 255))
            end

        elseif itemName == "Burner Phone" then
            playSFX(SOUNDS.Blank, 1.8)
            if isPlayer then
                if #GameState.Shells > 1 then
                    local idx = math.random(2, #GameState.Shells)
                    setLog(string.format("📱 ТЕЛЕФОН: «%d-й патрон — %s»", idx, GameState.Shells[idx] and "🔴 БОЕВОЙ" or "🔵 ХОЛОСТОЙ"), Color3.fromRGB(130, 255, 220))
                else
                    setLog("📱 ТЕЛЕФОН: «В стволе остался последний патрон...»", Color3.fromRGB(180, 180, 180))
                end
            else
                DealerFace.Text = "[ 😏 _ 👁️ ]"
                setLog("📱 Дилер прослушал одноразовый телефон...", Color3.fromRGB(200, 200, 200))
            end

        elseif itemName == "Expired Medicine" then
            if math.random(1, 2) == 1 then
                playSFX(SOUNDS.Heal, 1.1)
                if isPlayer then GameState.PlayerHP = math.min(GameState.MaxHP, GameState.PlayerHP + 2)
                else GameState.DealerHP = math.min(GameState.MaxHP, GameState.DealerHP + 2) end
                setLog("💊 ТАБЛЕТКИ: Повезло! +2 HP!", Color3.fromRGB(100, 255, 140))
            else
                playSFX(SOUNDS.Blank, 0.6)
                if isPlayer then GameState.PlayerHP -= 1 else GameState.DealerHP -= 1 end
                setLog("💊 ТАБЛЕТКИ: Отравление! -1 HP!", Color3.fromRGB(255, 70, 70))
            end
            updateHPUI()
            checkEndCondition()

        elseif itemName == "Adrenaline" then
            playSFX(SOUNDS.Heal, 1.4)
            if isPlayer then
                if #GameState.DealerItems == 0 then
                    setLog("💉 У Дилера нет предметов! Адреналин сгорел.", Color3.fromRGB(180, 180, 180))
                else
                    GameState.StealingMode = true
                    setLog("💉 АДРЕНАЛИН! Кликни на любой золотой предмет Дилера!", Color3.fromRGB(255, 220, 60))
                end
            else
                if #GameState.PlayerItems > 0 then
                    local stolen = table.remove(GameState.PlayerItems, math.random(1, #GameState.PlayerItems))
                    setLog("💉 Дилер украл твой предмет: " .. ITEMS_DB[stolen].Short .. "!", Color3.fromRGB(255, 100, 100))
                    renderInventories()
                    task.wait(0.8)
                    if stolen ~= "Adrenaline" then UseItem("Dealer", stolen) end
                end
            end
        end
        renderInventories()
    end
-- КОНЕЦ ЧАСТИ 4А
-- НАЧАЛО ЧАСТИ 4Б
    local function fireShot(shooter, target)
        if #GameState.Shells == 0 or GameState.Busy then return end
        GameState.Busy = true

        local isLive = table.remove(GameState.Shells, 1)
        local dmg = GameState.SawActive and 2 or 1
        GameState.SawActive = false

        animate3DGun(target, isLive)
        spawn3DShell(isLive)

        if isLive then
            if target == "Dealer" then
                GameState.DealerHP -= dmg
                DealerFace.Text = "[ 😵 _ 😵 ]"
                setLog("💥 БАХ! БОЕВОЙ! Дилер получил -" .. dmg .. " HP!", Color3.fromRGB(255, 70, 70))
            else
                GameState.PlayerHP -= dmg
                DealerFace.Text = "[ 😈 ‿ 😈 ]"
                setLog("💥 БАХ! БОЕВОЙ! Ты получил -" .. dmg .. " HP!", Color3.fromRGB(255, 50, 50))
            end
            updateHPUI()
            GameState.Busy = false
            if checkEndCondition() then return end
            switchTurn(shooter == "Player" and "Dealer" or "Player")
        else
            setLog("💨 *ЩЕЛК* — ХОЛОСТОЙ ПАТРОН!", Color3.fromRGB(110, 190, 255))
            updateHPUI()
            GameState.Busy = false
            if checkEndCondition() then return end
            if shooter == target then
                if shooter == "Player" then
                    setLog("💨 ХОЛОСТОЙ В СЕБЯ! Ты сохраняешь ход.", Color3.fromRGB(110, 255, 170))
                else
                    task.wait(0.6)
                    task.spawn(DealerTurn)
                end
            else
                switchTurn(shooter == "Player" and "Dealer" or "Player")
            end
        end
    end

    DealerTurn = function()
        if GameState.GameOver or GameState.Turn ~= "Dealer" then return end
        DealerFace.Text = "[ 👁️ _ 👁️ ]"
        setLog("🤖 Дилер оценивает шансы...", Color3.fromRGB(255, 180, 180))
        task.wait(0.9)

        local knownShell = nil
        local i = 1
        while i <= #GameState.DealerItems do
            if GameState.GameOver or #GameState.Shells == 0 then break end
            local item = GameState.DealerItems[i]
            local used = false

            if item == "Cigarettes" and GameState.DealerHP < GameState.MaxHP then
                table.remove(GameState.DealerItems, i); UseItem("Dealer", item); used = true
            elseif item == "Magnifying Glass" and knownShell == nil then
                table.remove(GameState.DealerItems, i); local _, first = next(GameState.Shells); knownShell = first; UseItem("Dealer", item); used = true
            elseif item == "Inverter" and knownShell == false then
                table.remove(GameState.DealerItems, i); knownShell = true; UseItem("Dealer", item); used = true
            elseif item == "Handcuffs" and not GameState.PlayerCuffed and #GameState.Shells > 1 then
                table.remove(GameState.DealerItems, i); UseItem("Dealer", item); used = true
            elseif item == "Handsaw" and not GameState.SawActive and knownShell == true then
                table.remove(GameState.DealerItems, i); UseItem("Dealer", item); used = true
            elseif item == "Beer" and knownShell == nil and #GameState.Shells > 1 then
                table.remove(GameState.DealerItems, i); UseItem("Dealer", item); used = true
            end

            if used then renderInventories(); task.wait(0.9) else i += 1 end
        end

        if GameState.GameOver or #GameState.Shells == 0 then return end

        local liveCount, blankCount = 0, 0
        for _, s in ipairs(GameState.Shells) do if s then liveCount += 1 else blankCount += 1 end end

        local shootPlayer = (knownShell ~= nil) and knownShell or (liveCount >= blankCount)
        if shootPlayer then
            setLog("🤖 Дилер наводит 3D-дробовик на ТЕБЯ...", Color3.fromRGB(255, 100, 100))
            fireShot("Dealer", "Player")
        else
            setLog("🤖 Дилер приставляет дуло к СЕБЕ...", Color3.fromRGB(150, 200, 255))
            fireShot("Dealer", "Dealer")
        end
    end

    ShootDealerBtn.MouseButton1Click:Connect(function()
        if GameState.GameOver then startNewGame() return end
        if GameState.Turn == "Player" and not GameState.StealingMode and not GameState.Busy then
            fireShot("Player", "Dealer")
        end
    end)

    ShootSelfBtn.MouseButton1Click:Connect(function()
        if GameState.GameOver then startNewGame() return end
        if GameState.Turn == "Player" and not GameState.StealingMode and not GameState.Busy then
            fireShot("Player", "Player")
        end
    end)

    startNewGame()
end

TriggerBtn.MouseButton1Click:Connect(Launch3DBuckshot)
-- КОНЕЦ ЧАСТИ 4Б (Финал!)
