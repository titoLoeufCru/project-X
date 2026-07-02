local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Nettoyage si le script est relancé (anti-duplication)
if getgenv()._cleanup then
    getgenv()._cleanup()
end
local conns = {}
local function saveConn(c)
    table.insert(conns, c)
    return c
end

-- ==========================================
-- ⚙️ CONFIGURATION GLOBALE
-- ==========================================

-- Config AutoGuard
getgenv().settings = {
    toggleKey = Enum.KeyCode.L,
    maxDist = 2500,
    stopDist = 1.5,
    turnSmooth = 0.04,
    predPower = 0.5,
    flickThreshold = 20,
    flickMult = 1.0,
    maxPredTime = 2.500,
    accelSmooth = 0.3000,
    slowdownRange = 4,
    moveInterval = 0.08,
    moveEpsilon = 0,
    useCurves = true,
    lookAtBall = true,
}
getgenv().guarding = getgenv().guarding or false

-- Config BigFoot (Reach)
getgenv().bigfoot = {
    MasterToggle = true,
    BaseSize = 6,
    Shoot = { Enabled = true, Infinite = false, Comp = false, Size = Vector3.new(6, 7, 6), Offset = Vector3.new(0, 0, 0) },
    Pass = { Enabled = true, Infinite = false, Comp = false, Size = Vector3.new(6, 7, 6), Offset = Vector3.new(0, 0, 0) },
    Long = { Enabled = true, Infinite = false, Comp = false, Size = Vector3.new(6, 7, 6), Offset = Vector3.new(0, 0, 0) },
    Tackle = { Enabled = true, Infinite = false, Comp = false, Size = Vector3.new(6, 7, 6), Offset = Vector3.new(0, 0, 0) },
    Dribble = { Enabled = true, Infinite = false, Comp = false, Size = Vector3.new(6, 7, 6), Offset = Vector3.new(0, 0, 0) },
    Save = { Enabled = true, Infinite = false, Comp = false, Size = Vector3.new(6, 7, 6), Offset = Vector3.new(0, 0, 0) }
}

-- ==========================================
-- 🎨 CREATION DE L'INTERFACE PRINCIPALE
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MpsKillerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

-- [ PARTIE 1 : LE KEY SYSTEM ]
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 0, 0, 0)
KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
KeyFrame.BorderSizePixel = 0
KeyFrame.ClipsDescendants = true
KeyFrame.BackgroundTransparency = 1
KeyFrame.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner", KeyFrame)
KeyCorner.CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", KeyFrame).Color = Color3.fromRGB(45, 45, 55)

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.Position = UDim2.new(0, 0, 0, 20)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "MPS-Killer"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 28
KeyTitle.TextTransparency = 1

local KeyGradient = Instance.new("UIGradient", KeyTitle)
KeyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})

local KeySubTitle = Instance.new("TextLabel", KeyFrame)
KeySubTitle.Size = UDim2.new(1, 0, 0, 20)
KeySubTitle.Position = UDim2.new(0, 0, 0, 55)
KeySubTitle.BackgroundTransparency = 1
KeySubTitle.Text = "Please Enter your key"
KeySubTitle.TextColor3 = Color3.fromRGB(140, 140, 150)
KeySubTitle.Font = Enum.Font.GothamMedium
KeySubTitle.TextSize = 13
KeySubTitle.TextTransparency = 1

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0, 280, 0, 40)
KeyInput.Position = UDim2.new(0.5, -140, 0, 100)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
KeyInput.BorderSizePixel = 0
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter your Key here..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.BackgroundTransparency = 1
KeyInput.TextTransparency = 1
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

local SubmitBtn = Instance.new("TextButton", KeyFrame)
SubmitBtn.Size = UDim2.new(0, 280, 0, 42)
SubmitBtn.Position = UDim2.new(0.5, -140, 0, 160)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
SubmitBtn.BorderSizePixel = 0
SubmitBtn.Text = "Verify Key"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.BackgroundTransparency = 1
SubmitBtn.TextTransparency = 1
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 8)

-- [ PARTIE 2 : LE MAIN HUB ]
local HubFrame = Instance.new("Frame", ScreenGui)
HubFrame.Name = "HubFrame"
HubFrame.Size = UDim2.new(0, 0, 0, 0)
HubFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
HubFrame.AnchorPoint = Vector2.new(0.5, 0.5)
HubFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
HubFrame.BorderSizePixel = 0
HubFrame.ClipsDescendants = true
HubFrame.Visible = false
HubFrame.BackgroundTransparency = 1
Instance.new("UICorner", HubFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", HubFrame).Color = Color3.fromRGB(45, 45, 55)

local TopBar = Instance.new("Frame", HubFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.BorderSizePixel = 0

local HubTitle = Instance.new("TextLabel", TopBar)
HubTitle.Size = UDim2.new(1, -20, 1, 0)
HubTitle.Position = UDim2.new(0, 15, 0, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "MPS-Killer Hub"
HubTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 16
HubTitle.TextXAlignment = Enum.TextXAlignment.Left

local TabContainer = Instance.new("Frame", HubFrame)
TabContainer.Size = UDim2.new(0, 130, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabContainer.BorderSizePixel = 0

local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 10)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local TabPadding = Instance.new("UIPadding", TabContainer)
TabPadding.PaddingTop = UDim.new(0, 15)

local ContentContainer = Instance.new("Frame", HubFrame)
ContentContainer.Size = UDim2.new(1, -130, 1, -40)
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.BackgroundTransparency = 1

local function createTabButton(name, layoutOrder, isActive)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(0, 110, 0, 35)
    btn.BackgroundColor3 = isActive and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(35, 35, 40)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.LayoutOrder = layoutOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function createPage(name, isVisible)
    local page = Instance.new("ScrollingFrame", ContentContainer)
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.Visible = isVisible
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.BorderSizePixel = 0

    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)

    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = " " .. name .. " Settings"
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left

    return page
end

local BigFootBtn = createTabButton("BigFoot", 1, true)
local AutoGuardBtn = createTabButton("AutoGuard", 2, false)

local BigFootPage = createPage("BigFoot", true)
local AutoGuardPage = createPage("AutoGuard", false)

-- ==========================================
-- 🛠️ GENERATEURS D'UI (Toggles, Sliders, Keybinds)
-- ==========================================

local function createToggle(parent, text, defaultState, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 25, 0, 25)
    btn.Position = UDim2.new(1, -35, 0.5, -12.5)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 50, 55)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 50, 55)
        }):Play()
        callback(state)
    end)

    return function(newState)
        state = newState
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 50, 55)
    end
end

local function createKeybind(parent, text, defaultKey, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 80, 0, 25)
    btn.Position = UDim2.new(1, -90, 0.5, -12.5)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = defaultKey.Name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local listening = false
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        listening = true
    end)

    saveConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            btn.Text = input.KeyCode.Name
            callback(input.KeyCode)
        end
    end))
end

local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.5, -20, 0, 20)
    valLabel.Position = UDim2.new(0.5, 10, 0, 5)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 14
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", sliderBg)
    local startPercent = (default - min) / (max - min)
    fill.Size = UDim2.new(startPercent, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", sliderBg)
    btn.Size = UDim2.new(1, 0, 1, 20)
    btn.Position = UDim2.new(0, 0, 0, -10)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local dragging = false
    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        
        local val = min + ((max - min) * relX)
        local formatted = math.floor(val * 10) / 10
        valLabel.Text = tostring(formatted)
        callback(formatted)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    saveConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end))
end

-- ==========================================
-- 📱 REMPLISSAGE DES PAGES
-- ==========================================

-- Page BigFoot (Reach)
createToggle(BigFootPage, "Activer BigFoot (Reach)", getgenv().bigfoot.MasterToggle, function(state)
    getgenv().bigfoot.MasterToggle = state
    if not state and getgenv()._reachPart then
        getgenv()._reachPart.Size = Vector3.new(0, 0, 0)
        getgenv()._reachPart.CFrame = CFrame.new(math.huge, math.huge, math.huge)
    end
end)

createSlider(BigFootPage, "Reach Size", 0, 20, getgenv().bigfoot.BaseSize, function(val)
    getgenv().bigfoot.BaseSize = val
    local sizeVec = Vector3.new(val, val + 1, val)
    getgenv().bigfoot.Shoot.Size = sizeVec
    getgenv().bigfoot.Pass.Size = sizeVec
    getgenv().bigfoot.Long.Size = sizeVec
    getgenv().bigfoot.Tackle.Size = sizeVec
    getgenv().bigfoot.Dribble.Size = sizeVec
    getgenv().bigfoot.Save.Size = sizeVec
end)

BigFootPage.CanvasSize = UDim2.new(0, 0, 0, 2 * 55 + 50)

-- Page AutoGuard
local updateToggleVisual = createToggle(AutoGuardPage, "Activer AutoGuard", getgenv().guarding, function(state)
    getgenv().guarding = state
    if not state then
        getgenv()._ball = nil
        getgenv()._smoothAcc = Vector3.zero
    end
end)

createKeybind(AutoGuardPage, "Touche d'activation", getgenv().settings.toggleKey, function(newKey)
    getgenv().settings.toggleKey = newKey
end)

createSlider(AutoGuardPage, "Max Distance", 100, 5000, getgenv().settings.maxDist, function(val) getgenv().settings.maxDist = val end)
createSlider(AutoGuardPage, "Stop Distance", 0.1, 10, getgenv().settings.stopDist, function(val) getgenv().settings.stopDist = val end)
createSlider(AutoGuardPage, "Prediction Power", 0.1, 2.0, getgenv().settings.predPower, function(val) getgenv().settings.predPower = val end)
createSlider(AutoGuardPage, "Max Pred Time", 0.5, 5.0, getgenv().settings.maxPredTime, function(val) getgenv().settings.maxPredTime = val end)
createSlider(AutoGuardPage, "Accel Smooth", 0.05, 0.95, getgenv().settings.accelSmooth, function(val) getgenv().settings.accelSmooth = val end)

AutoGuardPage.CanvasSize = UDim2.new(0, 0, 0, 7 * 55 + 50)

-- ==========================================
-- 🕹️ LOGIQUE & ANIMATIONS DE L'UI
-- ==========================================

local draggingHub, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingHub = true
        dragStart = input.Position
        startPos = HubFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingHub = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if draggingHub and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        HubFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function switchTab(selectedBtn, selectedPage)
    TweenService:Create(BigFootBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    TweenService:Create(AutoGuardBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    BigFootPage.Visible = false
    AutoGuardPage.Visible = false

    TweenService:Create(selectedBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    selectedPage.Visible = true
end

BigFootBtn.MouseButton1Click:Connect(function() switchTab(BigFootBtn, BigFootPage) end)
AutoGuardBtn.MouseButton1Click:Connect(function() switchTab(AutoGuardBtn, AutoGuardPage) end)

local function spawnKeyUI()
    TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 240), BackgroundTransparency = 0
    }):Play()
    task.wait(0.2)
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(KeyTitle, info, {TextTransparency = 0}):Play()
    TweenService:Create(KeySubTitle, info, {TextTransparency = 0}):Play()
    TweenService:Create(KeyInput, info, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(SubmitBtn, info, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
end
spawnKeyUI()

SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == "admin67sahur" then
        TweenService:Create(KeyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        KeyFrame:Destroy()

        HubFrame.Visible = true
        TweenService:Create(HubFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 550, 0, 400), BackgroundTransparency = 0
        }):Play()
    else
        local originalPos = KeyFrame.Position
        for i = 1, 5 do
            KeyFrame.Position = originalPos + UDim2.new(0, math.random(-8, 8), 0, math.random(-8, 8))
            task.wait(0.03)
        end
        KeyFrame.Position = originalPos
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "Clé invalide !"
    end
end)

-- ==========================================
-- 🚀 BACKEND: BIGFOOT (Reach Logic)
-- ==========================================

-- Variables de Character pour BigFoot
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

saveConn(Player.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end))

-- Détection de la balle (BigFoot System)
local BallFolder = nil
local IsAlternativeBallDetection = false
local AlternativeBalls = {}

if workspace:FindFirstChild("Balls", true) then
    BallFolder = workspace:FindFirstChild("Balls", true)
else
    IsAlternativeBallDetection = true
    for _, child in pairs(workspace:GetChildren()) do
        local ballNames = {"fakeBaIlExpIoiter", "fakeBall", "MPS", "TPS", "CSF", "l̸̼̔il̷͎̅ḭ̴͘iḮ̷̙il̶̼̈́il̴̘̕Ĩ̵̹į̴̌"}
        if table.find(ballNames, child.Name) then
            table.insert(AlternativeBalls, child)
        end
    end
end

-- Création de la ReachPart
if getgenv()._reachPart then getgenv()._reachPart:Destroy() end
local ReachPart = Instance.new("Part")
ReachPart.Name = tostring(math.random(100000, 999999))
ReachPart.Size = Vector3.new(0, 0, 0)
ReachPart.CFrame = CFrame.new(math.huge, math.huge, math.huge)
ReachPart.Anchored = true
ReachPart.CanCollide = false
ReachPart.CanTouch = true
ReachPart.CanQuery = false
ReachPart.Massless = true
ReachPart.Transparency = 1  -- INVISIBLE
ReachPart.Material = Enum.Material.SmoothPlastic
ReachPart.CastShadow = false
ReachPart.Parent = workspace
getgenv()._reachPart = ReachPart

-- Hooks
local originalGetClosestPointOnSurface
originalGetClosestPointOnSurface = hookmetamethod(Instance.new("Part"), "__index", newcclosure(function(self, key)
    if key == "GetClosestPointOnSurface" and not checkcaller() then
        return function(part, point) return point end
    end
    return originalGetClosestPointOnSurface(self, key)
end))

local originalNamecall
originalNamecall = hookmetamethod(Instance.new("Part"), "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and method == "GetClosestPointOnSurface" then
        local point = ...
        return point
    end
    return originalNamecall(self, ...)
end))

pcall(function()
    for _, func in pairs(getgc(true)) do
        if typeof(func) == "function" then
            local functionName = debug.info(func, "n")
            if functionName == "reachcheck" or functionName == "touchingcheck" then
                hookfunction(func, newcclosure(function() return false end))
            elseif functionName == "IsBallBoundingHitbox" then
                hookfunction(func, newcclosure(function() return true end))
            end
        end
    end
end)

-- Boucle Reach
saveConn(RunService.RenderStepped:Connect(function()
    if HumanoidRootPart and Humanoid then
        if getgenv().bigfoot.MasterToggle then
            local currentReachType = nil
            local reachData = nil
            
            if (Character:FindFirstChild("Shoot") or Character:FindFirstChild("Kick")) and getgenv().bigfoot.Shoot.Enabled then
                currentReachType = "Shoot"; reachData = getgenv().bigfoot.Shoot
            elseif Character:FindFirstChild("Pass") and getgenv().bigfoot.Pass.Enabled then
                currentReachType = "Pass"; reachData = getgenv().bigfoot.Pass
            elseif Character:FindFirstChild("Long") and getgenv().bigfoot.Long.Enabled then
                currentReachType = "Long"; reachData = getgenv().bigfoot.Long
            elseif Character:FindFirstChild("Tackle") and getgenv().bigfoot.Tackle.Enabled then
                currentReachType = "Tackle"; reachData = getgenv().bigfoot.Tackle
            elseif Character:FindFirstChild("Dribble") and getgenv().bigfoot.Dribble.Enabled then
                currentReachType = "Dribble"; reachData = getgenv().bigfoot.Dribble
            elseif (Character:FindFirstChild("Save") or Character:FindFirstChild("Clear") or Character:FindFirstChild("GK")) and getgenv().bigfoot.Save.Enabled then
                currentReachType = "Save"; reachData = getgenv().bigfoot.Save
            end
            
            if currentReachType == nil or reachData.Infinite then
                ReachPart.Size = Vector3.new(0, 0, 0)
                ReachPart.CFrame = CFrame.new(math.huge, math.huge, math.huge)
            else
                ReachPart.Size = reachData.Size
                ReachPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(reachData.Offset)
                
                task.spawn(function()
                    local overlapParams = OverlapParams.new()
                    overlapParams.FilterType = Enum.RaycastFilterType.Include
                    
                    if IsAlternativeBallDetection then
                        overlapParams.FilterDescendantsInstances = AlternativeBalls
                    else
                        overlapParams.FilterDescendantsInstances = {BallFolder}
                    end
                    
                    local ballsInRange = workspace:GetPartsInPart(ReachPart, overlapParams)
                    if #ballsInRange > 0 then
                        table.sort(ballsInRange, function(a, b)
                            return (a.Position - HumanoidRootPart.Position).Magnitude < (b.Position - HumanoidRootPart.Position).Magnitude
                        end)
                        
                        local closestBall = ballsInRange[1]
                        for _, part in pairs(Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                firetouchinterest(part, closestBall, 0)
                                firetouchinterest(part, closestBall, 1)
                            end
                        end
                    end
                end)
            end
        else
            ReachPart.Size = Vector3.new(0, 0, 0)
            ReachPart.CFrame = CFrame.new(math.huge, math.huge, math.huge)
        end
    end
end))


-- ==========================================
-- 🧠 BACKEND: AUTOGUARD
-- ==========================================

local grav = workspace.Gravity or 196.2
local ballNames = { ["VEF"]=true, ["TPS"]=true, ["ROFI"]=true, ["PRS"]=true, ["MPS"]=true, ["LPFI"]=true, ["Ball"]=true, ["CBM"]=true, ["Football"]=true, ["VRF"]=true }

getgenv()._ball = nil
getgenv()._smoothAcc = Vector3.zero
local lastVel = Vector3.zero
local lastTime = tick()
local focused = true
local trackedBalls = {}
local trackedSet = {}
local lastMoveAt = 0
local lastMoveTarget = nil

local function root(p) local c = p.Character return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end
local function hum(p) local c = p.Character return c and c:FindFirstChildWhichIsA("Humanoid") end

local function walking()
    local h = hum(Player)
    if h and h.MoveDirection.Magnitude > 0.1 then return true end
    for _, k in ipairs({ Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D }) do
        if UserInputService:IsKeyDown(k) then return true end
    end
    return false
end

local function isBall(obj) return obj:IsA("BasePart") and ballNames[obj.Name] == true end

local function trackBall(obj)
    if not obj or not isBall(obj) or trackedSet[obj] then return end
    trackedSet[obj] = true
    trackedBalls[#trackedBalls + 1] = obj
end

local function untrackBall(obj)
    if not obj or not trackedSet[obj] then return end
    trackedSet[obj] = nil
    for i = #trackedBalls, 1, -1 do
        if trackedBalls[i] == obj then table.remove(trackedBalls, i) break end
    end
end

local function findBall(pos)
    local closest, dist = nil, math.huge
    for i = #trackedBalls, 1, -1 do
        local v = trackedBalls[i]
        if not (v and v.Parent) then
            trackedSet[v] = nil
            table.remove(trackedBalls, i)
        else
            local d = (pos - v.Position).Magnitude
            if d < dist then dist = d; closest = v end
        end
    end
    return closest
end

for _, v in ipairs(workspace:GetDescendants()) do trackBall(v) end
saveConn(workspace.DescendantAdded:Connect(trackBall))
saveConn(workspace.DescendantRemoving:Connect(untrackBall))

local function issueMove(humanoid, pos)
    if not humanoid or not pos then return end
    local s = getgenv().settings
    local minInt = type(s.moveInterval) == "number" and s.moveInterval or 0
    local eps = type(s.moveEpsilon) == "number" and s.moveEpsilon or 0
    local now = tick()
    if minInt > 0 and now - lastMoveAt < minInt and lastMoveTarget then
        if (pos - lastMoveTarget).Magnitude <= eps then return end
    end
    lastMoveAt = now
    lastMoveTarget = pos
    humanoid:MoveTo(pos)
end

local function landingSpot(pos, vel, floor)
    local g = workspace.Gravity or grav
    local h = pos.Y - floor
    if h < 0.5 then return Vector3.new(pos.X, floor, pos.Z), 0 end
    local d = vel.Y * vel.Y + 2 * g * h
    if d < 0 then return Vector3.new(pos.X, floor, pos.Z), 0 end
    local t = math.clamp((vel.Y + math.sqrt(d)) / g, 0, getgenv().settings.maxPredTime)

    local sAcc = getgenv()._smoothAcc
    local lx, lz
    if getgenv().settings.useCurves then
        lx = pos.X + vel.X * t + 0.5 * sAcc.X * t * t
        lz = pos.Z + vel.Z * t + 0.5 * sAcc.Z * t * t
    else
        lx = pos.X + vel.X * t; lz = pos.Z + vel.Z * t
    end
    return Vector3.new(lx, floor, lz), t
end

local function groundPredict(bpos, bvel, mpos)
    local s = getgenv().settings
    local sAcc = getgenv()._smoothAcc
    local flick = Vector2.new(sAcc.X, sAcc.Z).Magnitude > s.flickThreshold
    local pt = math.min(s.predPower * (flick and s.flickMult or 1), s.maxPredTime)
    local pv = flick and s.useCurves and (bvel + sAcc * 0.15) or bvel

    local fut = s.useCurves and (bpos + pv * pt + 0.5 * sAcc * pt * pt) or (bpos + pv * pt)
    return Vector3.new(fut.X, mpos.Y, fut.Z)
end

local function updateAcc(vel)
    local now = tick()
    local dt = now - lastTime
    if dt >= 0.005 then
        local raw = (vel - lastVel) / dt
        if raw.Magnitude > 500 then raw = raw.Unit * 500 end
        getgenv()._smoothAcc = getgenv()._smoothAcc:Lerp(raw, math.clamp(getgenv().settings.accelSmooth, 0.05, 0.95))
        lastVel = vel
        lastTime = now
    end
end

local scanner = task.spawn(function()
    while task.wait(0.35) do
        if getgenv().guarding then
            local r = root(Player)
            if r then
                local found = findBall(r.Position)
                getgenv()._ball = (found and found.Parent) and found or nil
            end
        else
            getgenv()._ball = nil
        end
    end
end)

saveConn(RunService.Heartbeat:Connect(function()
    if not getgenv().guarding then return end

    local myRoot, myHum = root(Player), hum(Player)
    local ball = getgenv()._ball

    if not (myRoot and myHum and ball and ball.Parent) or myHum.Health <= 0 or walking() then return end

    local bp, mp, bv = ball.Position, myRoot.Position, ball.AssemblyLinearVelocity
    updateAcc(bv)

    local dist = Vector2.new(mp.X - bp.X, mp.Z - bp.Z).Magnitude
    if dist > getgenv().settings.maxDist then
        if not focused then issueMove(myHum, mp) end
        return
    end

    local inAir = bp.Y > (mp.Y + 2)
    local target
    if inAir then
        local land, t = landingSpot(bp, bv, mp.Y)
        target = (t > 0.05 and t < getgenv().settings.maxPredTime) and land or Vector3.new(bp.X, mp.Y, bp.Z)
    else
        target = groundPredict(bp, bv, mp)
    end

    local gap = Vector2.new(target.X - mp.X, target.Z - mp.Z).Magnitude
    if gap > getgenv().settings.stopDist then
        issueMove(myHum, gap < getgenv().settings.slowdownRange and mp + (target - mp) * (gap / getgenv().settings.slowdownRange) or target)
    end

    if getgenv().settings.lookAtBall and dist < 10 then
        local look = inAir and bp or target
        local cf = CFrame.lookAt(mp, Vector3.new(look.X, mp.Y, look.Z))
        myRoot.CFrame = myRoot.CFrame:Lerp(cf, math.clamp(getgenv().settings.turnSmooth * (1 + (10 - dist) / 10), 0.05, 0.25))
    end
end))

saveConn(Player.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end))
saveConn(UserInputService.WindowFocused:Connect(function() focused = true end))
saveConn(UserInputService.WindowFocusReleased:Connect(function() focused = false end))

saveConn(UserInputService.InputBegan:Connect(function(key, gpe)
    if not gpe and key.KeyCode == getgenv().settings.toggleKey then
        getgenv().guarding = not getgenv().guarding
        if updateToggleVisual then updateToggleVisual(getgenv().guarding) end
        if not getgenv().guarding then getgenv()._ball = nil; getgenv()._smoothAcc = Vector3.zero end
    end
end))

getgenv()._cleanup = function()
    for _, c in ipairs(conns) do if c.Connected then c:Disconnect() end end
    table.clear(conns)
    if scanner then task.cancel(scanner) end
    if getgenv()._reachPart then getgenv()._reachPart:Destroy() end
    if ScreenGui then ScreenGui:Destroy() end
end
