-- ╔══════════════════════════════════════════════╗
-- ║         PIGGY SCRIPT by TiooScript           ║
-- ║         UI: Dark Horror Edition  v1.1        ║
-- ╚══════════════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ══════════════════════════════════════
-- STATE
-- ══════════════════════════════════════
local State = {
    NoClip      = false,
    WalkSpeed   = 16,
    JumpPower   = 50,
    SpeedBoost  = false,
    InfiniteJump= false,
    PlayerESP   = false,
    PiggyESP    = false,
    Fullbright  = false,
    Minimized   = false,
    AntiAFK     = false,
}

-- ══════════════════════════════════════
-- DESTROY OLD GUI
-- ══════════════════════════════════════
local old = CoreGui:FindFirstChild("TiooScriptGUI")
if old then old:Destroy() end

-- ══════════════════════════════════════
-- GUI ROOT
-- ══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TiooScriptGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ══════════════════════════════════════
-- COLOR PALETTE
-- ══════════════════════════════════════
local C = {
    BG        = Color3.fromRGB(6, 6, 10),
    Panel     = Color3.fromRGB(12, 12, 20),
    Card      = Color3.fromRGB(18, 18, 28),
    Accent    = Color3.fromRGB(200, 40, 40),
    AccentDim = Color3.fromRGB(100, 20, 20),
    Text      = Color3.fromRGB(235, 225, 220),
    SubText   = Color3.fromRGB(140, 130, 125),
    ON        = Color3.fromRGB(60, 210, 100),
    OFF       = Color3.fromRGB(200, 50, 50),
    Border    = Color3.fromRGB(40, 15, 15),
    Shadow    = Color3.fromRGB(0, 0, 0),
}

-- ══════════════════════════════════════
-- HELPER FUNCTIONS
-- ══════════════════════════════════════
local function makeTween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    return TweenService:Create(obj, info, props)
end

local function newInst(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function round(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = frame
    return corner
end

local function stroke(frame, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Border
    s.Thickness = thickness or 1
    s.Parent = frame
    return s
end

-- ══════════════════════════════════════
-- NOCLIP — simpan collision asli, restore saat OFF
-- ══════════════════════════════════════
local savedCollision = {} -- [BasePart] = originalCanCollide

local function applyNoClip(char, enable)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if enable then
                -- simpan nilai asli sebelum dimatiin
                if savedCollision[part] == nil then
                    savedCollision[part] = part.CanCollide
                end
                part.CanCollide = false
            else
                -- kembalikan nilai asli
                if savedCollision[part] ~= nil then
                    part.CanCollide = savedCollision[part]
                    savedCollision[part] = nil
                else
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ══════════════════════════════════════
-- ESP — pakai Highlight (tidak scale dengan jarak)
-- ══════════════════════════════════════
local ESP_FOLDER_NAME = "TiooESPHighlight"

local function addHighlight(char, fillColor, outlineColor)
    if not char then return end
    -- hapus dulu kalau udah ada
    local old_hl = char:FindFirstChild(ESP_FOLDER_NAME)
    if old_hl then old_hl:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = ESP_FOLDER_NAME
    hl.Adornee = char
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    -- DepthMode = AlwaysOnTop = tembus tembok
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
end

local function removeHighlight(char)
    if not char then return end
    local hl = char:FindFirstChild(ESP_FOLDER_NAME)
    if hl then hl:Destroy() end
end

-- Player ESP (hijau)
local playerESPConns = {}
local function refreshPlayerESP(enable)
    -- bersih koneksi lama
    for _, conn in pairs(playerESPConns) do conn:Disconnect() end
    playerESPConns = {}

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if enable then
                -- pasang sekarang jika char udah ada
                if plr.Character then
                    addHighlight(plr.Character, Color3.fromRGB(0,255,80), Color3.fromRGB(0,200,60))
                end
                -- pasang juga kalau respawn
                local conn = plr.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if State.PlayerESP then
                        addHighlight(char, Color3.fromRGB(0,255,80), Color3.fromRGB(0,200,60))
                    end
                end)
                table.insert(playerESPConns, conn)
            else
                if plr.Character then
                    removeHighlight(plr.Character)
                end
            end
        end
    end
end

-- Piggy NPC ESP (merah)
-- Piggy NPC biasanya punya Humanoid tapi bukan Player
-- Kita scan workspace tiap beberapa detik
local piggyESPConn = nil
local function isPiggyNPC(model)
    -- Cek: punya Humanoid, bukan karakter player
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character == model then return false end
    end
    return true
end

local function refreshPiggyESP(enable)
    if piggyESPConn then
        piggyESPConn:Disconnect()
        piggyESPConn = nil
    end

    -- Hapus semua highlight piggy dulu
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild(ESP_FOLDER_NAME) then
            -- cek apakah ini NPC (bukan player char)
            local isPlayer = false
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character == model then isPlayer = true break end
            end
            if not isPlayer then
                removeHighlight(model)
            end
        end
    end

    if not enable then return end

    -- Scan dan pasang highlight ke Piggy NPC
    local function scanAndHighlight()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and isPiggyNPC(obj) then
                local existing = obj:FindFirstChild(ESP_FOLDER_NAME)
                if not existing then
                    addHighlight(obj, Color3.fromRGB(255,30,30), Color3.fromRGB(255,0,0))
                end
            end
        end
    end

    scanAndHighlight()

    -- Loop terus tiap 2 detik (karena Piggy bisa spawn ulang)
    piggyESPConn = RunService.Heartbeat:Connect(function()
        if not State.PiggyESP then return end
        -- hanya scan setiap ~2 detik biar ringan
    end)

    -- Gunakan task.spawn + loop ringan
    task.spawn(function()
        while State.PiggyESP do
            scanAndHighlight()
            task.wait(2)
        end
    end)
end

-- ══════════════════════════════════════
-- MAIN FRAME
-- ══════════════════════════════════════
local Main = newInst("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 320, 0, 420),
    Position = UDim2.new(0.5, -160, 0.5, -210),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
    ZIndex = 10,
    Parent = ScreenGui,
})
round(Main, 10)
stroke(Main, C.Border, 1.5)

local noise = newInst("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(255,255,255),
    BackgroundTransparency = 0.97,
    ZIndex = 11,
    Parent = Main,
})
round(noise, 10)

-- TOP ACCENT LINE
local topLine = newInst("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = C.Accent,
    ZIndex = 12,
    Parent = Main,
})
newInst("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80,0,0)),
        ColorSequenceKeypoint.new(0.5, C.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80,0,0)),
    }),
    Parent = topLine,
})
Instance.new("UICorner", topLine).CornerRadius = UDim.new(0,10)

-- ══════════════════════════════════════
-- HEADER
-- ══════════════════════════════════════
local Header = newInst("Frame", {
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = C.Panel,
    ZIndex = 12,
    Parent = Main,
})
round(Header, 10)
stroke(Header, C.Border, 1)

newInst("Frame", {
    Size = UDim2.new(1, 0, 0.5, 0),
    Position = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = C.Panel,
    ZIndex = 12,
    Parent = Header,
})

local drip = newInst("TextLabel", {
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(0, 12, 0.5, -18),
    BackgroundColor3 = C.AccentDim,
    Text = "🐷",
    TextScaled = true,
    ZIndex = 13,
    Parent = Header,
})
round(drip, 8)

newInst("TextLabel", {
    Size = UDim2.new(1, -120, 1, 0),
    Position = UDim2.new(0, 58, 0, 0),
    BackgroundTransparency = 1,
    Text = "PIGGY SCRIPT",
    TextColor3 = C.Text,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13,
    Parent = Header,
})

newInst("TextLabel", {
    Size = UDim2.new(1, -120, 0, 16),
    Position = UDim2.new(0, 58, 0, 24),
    BackgroundTransparency = 1,
    Text = "by TiooScript • v1.1",
    TextColor3 = C.SubText,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13,
    Parent = Header,
})

local btnMin = newInst("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -60, 0.5, -13),
    BackgroundColor3 = C.Card,
    Text = "—",
    TextColor3 = C.SubText,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    ZIndex = 14,
    Parent = Header,
})
round(btnMin, 6)
stroke(btnMin, C.Border)

local btnClose = newInst("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -28, 0.5, -13),
    BackgroundColor3 = Color3.fromRGB(80, 15, 15),
    Text = "✕",
    TextColor3 = C.Accent,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    ZIndex = 14,
    Parent = Header,
})
round(btnClose, 6)
stroke(btnClose, C.Accent, 1)

-- ══════════════════════════════════════
-- TABS
-- ══════════════════════════════════════
local TabBar = newInst("Frame", {
    Size = UDim2.new(1, -16, 0, 32),
    Position = UDim2.new(0, 8, 0, 58),
    BackgroundColor3 = C.Panel,
    ZIndex = 12,
    Parent = Main,
})
round(TabBar, 8)
stroke(TabBar, C.Border)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = TabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 4)
tabPad.PaddingTop = UDim.new(0, 4)
tabPad.PaddingBottom = UDim.new(0, 4)
tabPad.Parent = TabBar

local tabNames = {"Player", "Visual", "Misc"}
local tabBtns = {}
local tabPages = {}

for i, name in ipairs(tabNames) do
    local btn = newInst("TextButton", {
        Size = UDim2.new(0, 88, 1, 0),
        BackgroundColor3 = i == 1 and C.Accent or C.Card,
        Text = name,
        TextColor3 = i == 1 and Color3.fromRGB(255,255,255) or C.SubText,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 13,
        LayoutOrder = i,
        Parent = TabBar,
    })
    round(btn, 6)
    tabBtns[name] = btn
end

-- ══════════════════════════════════════
-- CONTENT AREA
-- ══════════════════════════════════════
local ContentArea = newInst("Frame", {
    Size = UDim2.new(1, -16, 1, -108),
    Position = UDim2.new(0, 8, 0, 96),
    BackgroundTransparency = 1,
    ZIndex = 12,
    Parent = Main,
})

-- ══════════════════════════════════════
-- CARD BUILDER
-- ══════════════════════════════════════
local function makeCard(parent, label, desc, initState, callback)
    local card = newInst("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = C.Card,
        ZIndex = 13,
        Parent = parent,
    })
    round(card, 8)
    stroke(card, C.Border)

    local bar = newInst("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = C.Accent,
        ZIndex = 14,
        Parent = card,
    })
    round(bar, 3)

    newInst("TextLabel", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = card,
    })

    newInst("TextLabel", {
        Size = UDim2.new(1, -80, 0, 16),
        Position = UDim2.new(0, 14, 0, 30),
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = C.SubText,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = card,
    })

    local currentState = initState or false
    local badge = newInst("TextButton", {
        Size = UDim2.new(0, 48, 0, 22),
        Position = UDim2.new(1, -58, 0.5, -11),
        BackgroundColor3 = currentState and C.ON or C.OFF,
        Text = currentState and "ON" or "OFF",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        ZIndex = 14,
        Parent = card,
    })
    round(badge, 11)

    badge.MouseButton1Click:Connect(function()
        currentState = not currentState
        makeTween(badge, {BackgroundColor3 = currentState and C.ON or C.OFF}, 0.2):Play()
        badge.Text = currentState and "ON" or "OFF"
        if callback then callback(currentState) end
    end)

    return card
end

-- ══════════════════════════════════════
-- SLIDER BUILDER
-- ══════════════════════════════════════
local function makeSlider(parent, label, minV, maxV, default, callback)
    local card = newInst("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = C.Card,
        ZIndex = 13,
        Parent = parent,
    })
    round(card, 8)
    stroke(card, C.Border)

    local bar2 = newInst("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = Color3.fromRGB(60, 140, 255),
        ZIndex = 14,
        Parent = card,
    })
    round(bar2, 3)

    newInst("TextLabel", {
        Size = UDim2.new(0.7, 0, 0, 18),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.Text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = card,
    })

    local valLbl = newInst("TextLabel", {
        Size = UDim2.new(0.3, -14, 0, 18),
        Position = UDim2.new(0.7, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = C.Accent,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 14,
        Parent = card,
    })

    local track = newInst("Frame", {
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 36),
        BackgroundColor3 = C.Panel,
        ZIndex = 14,
        Parent = card,
    })
    round(track, 3)
    stroke(track, C.Border)

    local initRel = (default - minV) / (maxV - minV)
    local fill = newInst("Frame", {
        Size = UDim2.new(initRel, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(60, 140, 255),
        ZIndex = 15,
        Parent = track,
    })
    round(fill, 3)

    local knob = newInst("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(initRel, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 16,
        Parent = track,
    })
    round(knob, 7)
    stroke(knob, Color3.fromRGB(60,140,255), 1.5)

    local dragging = false
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(minV + (maxV - minV) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLbl.Text = tostring(val)
            if callback then callback(val) end
        end
    end)

    return card
end

-- ══════════════════════════════════════
-- PAGE BUILDER
-- ══════════════════════════════════════
local function makePage(name)
    local page = newInst("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Accent,
        ZIndex = 12,
        Visible = name == "Player",
        Parent = ContentArea,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = page
    tabPages[name] = page
    return page
end

-- ══════════════════════════════════════
-- PAGES + FEATURES
-- ══════════════════════════════════════

-- PLAYER PAGE
local playerPage = makePage("Player")

makeCard(playerPage, "NO CLIP", "Tembus lewat tembok / dinding", false, function(on)
    State.NoClip = on
    if not on then
        -- Restore collision langsung saat OFF
        applyNoClip(LocalPlayer.Character, false)
        savedCollision = {}
    end
end)

makeCard(playerPage, "SPEED BOOST", "Kecepatan lari lebih tinggi (x2)", false, function(on)
    State.SpeedBoost = on
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = on and 32 or State.WalkSpeed
    end
end)

makeCard(playerPage, "INFINITE JUMP", "Loncat terus-terusan di udara", false, function(on)
    State.InfiniteJump = on
end)

makeSlider(playerPage, "WALK SPEED", 8, 100, 16, function(val)
    State.WalkSpeed = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and not State.SpeedBoost then
        hum.WalkSpeed = val
    end
end)

makeSlider(playerPage, "JUMP POWER", 20, 200, 50, function(val)
    State.JumpPower = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = val end
end)

-- VISUAL PAGE
local visualPage = makePage("Visual")

makeCard(visualPage, "PLAYER ESP", "Highlight player (hijau, tembus tembok)", false, function(on)
    State.PlayerESP = on
    refreshPlayerESP(on)
end)

makeCard(visualPage, "PIGGY ESP", "Highlight Piggy NPC (merah, tembus tembok)", false, function(on)
    State.PiggyESP = on
    refreshPiggyESP(on)
end)

makeCard(visualPage, "FULLBRIGHT", "Terangi semua area gelap", false, function(on)
    State.Fullbright = on
    local Lighting = game:GetService("Lighting")
    Lighting.Brightness = on and 10 or 1
    Lighting.FogEnd = on and 100000 or 1000
    Lighting.GlobalShadows = not on
end)

-- MISC PAGE
local miscPage = makePage("Misc")

makeCard(miscPage, "ANTI AFK", "Cegah kick karena idle", false, function(on)
    State.AntiAFK = on
    if on then
        local VPS = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if State.AntiAFK then
                VPS:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VPS:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end
        end)
    end
end)

local infoCard = newInst("Frame", {
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = Color3.fromRGB(10, 10, 18),
    ZIndex = 13,
    Parent = miscPage,
})
round(infoCard, 8)
stroke(infoCard, C.AccentDim)
newInst("TextLabel", {
    Size = UDim2.new(1, -16, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Text = "🩷 TiooScript — Piggy Edition\nby Ridho (Tiooprime2) • v1.1",
    TextColor3 = C.SubText,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    ZIndex = 14,
    Parent = infoCard,
})

-- ══════════════════════════════════════
-- FOOTER
-- ══════════════════════════════════════
local footer = newInst("Frame", {
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 0, 1, -24),
    BackgroundColor3 = C.Panel,
    ZIndex = 12,
    Parent = Main,
})
round(footer, 10)
newInst("Frame", {
    Size = UDim2.new(1, 0, 0.5, 0),
    BackgroundColor3 = C.Panel,
    ZIndex = 12,
    Parent = footer,
})

local statusDot = newInst("Frame", {
    Size = UDim2.new(0, 7, 0, 7),
    Position = UDim2.new(0, 10, 0.5, -3.5),
    BackgroundColor3 = C.ON,
    ZIndex = 13,
    Parent = footer,
})
round(statusDot, 4)

local statusLbl = newInst("TextLabel", {
    Size = UDim2.new(1, -30, 1, 0),
    Position = UDim2.new(0, 22, 0, 0),
    BackgroundTransparency = 1,
    Text = "Script Active • NoClip: OFF",
    TextColor3 = C.SubText,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13,
    Parent = footer,
})

-- ══════════════════════════════════════
-- TAB SWITCHING
-- ══════════════════════════════════════
for _, name in ipairs(tabNames) do
    tabBtns[name].MouseButton1Click:Connect(function()
        for _, n in ipairs(tabNames) do
            local isActive = n == name
            makeTween(tabBtns[n], {
                BackgroundColor3 = isActive and C.Accent or C.Card,
                TextColor3 = isActive and Color3.fromRGB(255,255,255) or C.SubText
            }, 0.2):Play()
            tabPages[n].Visible = isActive
        end
    end)
end

-- ══════════════════════════════════════
-- MINIMIZE / CLOSE
-- ══════════════════════════════════════
btnMin.MouseButton1Click:Connect(function()
    State.Minimized = not State.Minimized
    if State.Minimized then
        makeTween(Main, {Size = UDim2.new(0, 320, 0, 52)}, 0.3):Play()
        btnMin.Text = "+"
    else
        makeTween(Main, {Size = UDim2.new(0, 320, 0, 420)}, 0.3):Play()
        btnMin.Text = "—"
    end
end)

btnClose.MouseButton1Click:Connect(function()
    -- cleanup ESP sebelum destroy
    refreshPlayerESP(false)
    refreshPiggyESP(false)
    makeTween(Main, {BackgroundTransparency = 1, Size = UDim2.new(0, 320, 0, 0)}, 0.3):Play()
    task.wait(0.35)
    ScreenGui:Destroy()
end)

-- ══════════════════════════════════════
-- DRAGGABLE
-- ══════════════════════════════════════
local draggingUI, dragStart, startPos
Header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        draggingUI = true
        dragStart = inp.Position
        startPos = Main.Position
    end
end)
Header.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        draggingUI = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if draggingUI and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ══════════════════════════════════════
-- NOCLIP LOOP — hanya aktif saat NoClip ON
-- ══════════════════════════════════════
RunService.Stepped:Connect(function()
    if State.NoClip then
        local char = LocalPlayer.Character
        if char then
            applyNoClip(char, true)
        end
    end
    statusLbl.Text = "Script Active • NoClip: " .. (State.NoClip and "ON ✓" or "OFF")
    statusDot.BackgroundColor3 = State.NoClip and C.Accent or C.ON
end)

-- ══════════════════════════════════════
-- INFINITE JUMP
-- ══════════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ══════════════════════════════════════
-- CHARACTER RESPAWN HANDLER
-- ══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    savedCollision = {} -- reset cache collision saat respawn
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    Humanoid.WalkSpeed = State.WalkSpeed
    Humanoid.JumpPower = State.JumpPower
end)

-- ══════════════════════════════════════
-- AUTO UPDATE ESP SAAT PLAYER LAIN JOIN
-- ══════════════════════════════════════
Players.PlayerAdded:Connect(function(plr)
    if State.PlayerESP then
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if State.PlayerESP then
                addHighlight(char, Color3.fromRGB(0,255,80), Color3.fromRGB(0,200,60))
            end
        end)
    end
end)

print("[TiooScript] Piggy Script v1.1 loaded! Bug fixes: NoClip restore + Highlight ESP 🩷")
