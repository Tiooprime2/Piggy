-- ╔══════════════════════════════════════════════╗
-- ║         PIGGY SCRIPT by TiooScript           ║
-- ║         UI: Dark Horror Edition              ║
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
    NoClip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    SpeedBoost = false,
    InfiniteJump = false,
    ESP = false,
    Visible = true,
    Minimized = false,
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
    BG       = Color3.fromRGB(6, 6, 10),
    Panel    = Color3.fromRGB(12, 12, 20),
    Card     = Color3.fromRGB(18, 18, 28),
    Accent   = Color3.fromRGB(200, 40, 40),
    AccentDim= Color3.fromRGB(100, 20, 20),
    Text     = Color3.fromRGB(235, 225, 220),
    SubText  = Color3.fromRGB(140, 130, 125),
    ON       = Color3.fromRGB(60, 210, 100),
    OFF      = Color3.fromRGB(200, 50, 50),
    Border   = Color3.fromRGB(40, 15, 15),
    Shadow   = Color3.fromRGB(0, 0, 0),
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
    for k, v in pairs(props) do
        inst[k] = v
    end
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

local function shadow(frame)
    local sh = newInst("Frame", {
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0, 3, 0, 3),
        BackgroundColor3 = C.Shadow,
        BackgroundTransparency = 0.7,
        ZIndex = frame.ZIndex - 1,
        Parent = frame.Parent,
    })
    round(sh, 8)
    return sh
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

-- Subtle noise texture overlay (gradient)
local noise = newInst("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(255,255,255),
    BackgroundTransparency = 0.97,
    ZIndex = 11,
    Parent = Main,
})
round(noise, 10)

-- ══════════════════════════════════════
-- TOP ACCENT LINE
-- ══════════════════════════════════════
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

-- Bleed header bottom edge
newInst("Frame", {
    Size = UDim2.new(1, 0, 0.5, 0),
    Position = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = C.Panel,
    ZIndex = 12,
    Parent = Header,
})

-- Blood drip icon
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

local titleLabel = newInst("TextLabel", {
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

local subLabel = newInst("TextLabel", {
    Size = UDim2.new(1, -120, 0, 16),
    Position = UDim2.new(0, 58, 0, 24),
    BackgroundTransparency = 1,
    Text = "by TiooScript • v1.0",
    TextColor3 = C.SubText,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13,
    Parent = Header,
})

-- Minimize + Close buttons
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
-- TABS BAR
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
local activeTab = "Player"

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
-- TOGGLE CARD BUILDER
-- ══════════════════════════════════════
local function makeCard(parent, label, desc, stateKey, callback)
    local card = newInst("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = C.Card,
        ZIndex = 13,
        Parent = parent,
    })
    round(card, 8)
    stroke(card, C.Border)

    -- Left accent bar
    local bar = newInst("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = C.Accent,
        ZIndex = 14,
        Parent = card,
    })
    round(bar, 3)

    local lbl = newInst("TextLabel", {
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

    local sub = newInst("TextLabel", {
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

    local badge = newInst("TextButton", {
        Size = UDim2.new(0, 48, 0, 22),
        Position = UDim2.new(1, -58, 0.5, -11),
        BackgroundColor3 = State[stateKey] and C.ON or C.OFF,
        Text = State[stateKey] and "ON" or "OFF",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        ZIndex = 14,
        Parent = card,
    })
    round(badge, 11)

    badge.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        local isOn = State[stateKey]
        makeTween(badge, {BackgroundColor3 = isOn and C.ON or C.OFF}, 0.2):Play()
        badge.Text = isOn and "ON" or "OFF"
        if callback then callback(isOn) end
    end)

    return card
end

-- ══════════════════════════════════════
-- SLIDER BUILDER
-- ══════════════════════════════════════
local function makeSlider(parent, label, min, max, default, callback)
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

    local lbl = newInst("TextLabel", {
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

    local fill = newInst("Frame", {
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(60, 140, 255),
        ZIndex = 15,
        Parent = track,
    })
    round(fill, 3)

    local knob = newInst("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min)/(max - min), -7, 0.5, -7),
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
            local pos = inp.UserInputType == Enum.UserInputType.Touch and inp.Position or inp.Position
            local rel = (pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local val = math.floor(min + (max - min) * rel)
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

-- NoClip
makeCard(playerPage, "NO CLIP", "Tembus lewat tembok / dinding", "NoClip", function(on)
    -- handled by RunService loop below
end)

-- Speed Boost
makeCard(playerPage, "SPEED BOOST", "Kecepatan lari lebih tinggi (x2)", "SpeedBoost", function(on)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = on and 32 or State.WalkSpeed
    end
end)

-- Infinite Jump
makeCard(playerPage, "INFINITE JUMP", "Loncat terus-terusan di udara", "InfiniteJump", function(on)
    -- handled by UIS below
end)

-- WalkSpeed Slider
makeSlider(playerPage, "WALK SPEED", 8, 100, 16, function(val)
    State.WalkSpeed = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and not State.SpeedBoost then
        hum.WalkSpeed = val
    end
end)

-- JumpPower Slider
makeSlider(playerPage, "JUMP POWER", 20, 200, 50, function(val)
    State.JumpPower = val
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = val
    end
end)

-- VISUAL PAGE
local visualPage = makePage("Visual")

makeCard(visualPage, "PLAYER ESP", "Lihat semua player lewat tembok", "ESP", function(on)
    -- ESP highlight logic
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("TiooESP")
            if on then
                if not highlight then
                    local h = Instance.new("SelectionBox")
                    h.Name = "TiooESP"
                    h.Adornee = plr.Character
                    h.Color3 = C.Accent
                    h.LineThickness = 0.05
                    h.SurfaceTransparency = 0.7
                    h.SurfaceColor3 = Color3.fromRGB(200, 40, 40)
                    h.Parent = plr.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

makeCard(visualPage, "PIGGY ESP", "Highlight posisi Piggy (NPC)", "NoClip", function(on)
    -- placeholder — Piggy NPC name varies per chapter
end)

makeCard(visualPage, "FULLBRIGHT", "Terangi semua area gelap", "Visible", function(on)
    game:GetService("Lighting").Brightness = on and 10 or 1
    game:GetService("Lighting").FogEnd = on and 100000 or 1000
end)

-- MISC PAGE
local miscPage = makePage("Misc")

makeCard(miscPage, "AUTO COLLECT KEYS", "Auto ambil kunci / item quest", "NoClip", function(on)
    -- placeholder for game-specific item collection
end)

makeCard(miscPage, "ANTI AFK", "Cegah kick karena idle", "Visible", function(on)
    if on then
        local VPS = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VPS:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VPS:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- Info card at bottom of misc
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
    Text = "🩷 TiooScript — Piggy Edition\nby Ridho (Tiooprime2)",
    TextColor3 = C.SubText,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    ZIndex = 14,
    Parent = infoCard,
})

-- ══════════════════════════════════════
-- FOOTER STATUS BAR
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
-- TAB SWITCHING LOGIC
-- ══════════════════════════════════════
for _, name in ipairs(tabNames) do
    tabBtns[name].MouseButton1Click:Connect(function()
        activeTab = name
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
-- NOCLIP LOOP
-- ══════════════════════════════════════
RunService.Stepped:Connect(function()
    if State.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    -- update status bar
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
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    Humanoid.WalkSpeed = State.WalkSpeed
    Humanoid.JumpPower = State.JumpPower
end)

print("[TiooScript] Piggy Script loaded successfully! 🩷")
