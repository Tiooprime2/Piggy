-- ╔══════════════════════════════════════════════╗
-- ║       PIGGY SCRIPT by TiooScript  v2.0       ║
-- ║            main.lua — Entry Point            ║
-- ╚══════════════════════════════════════════════╝
-- Jalanin file ini di executor
-- main.lua akan load ui.lua & features.lua dari GitHub

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting   = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer

-- ══════════════════════════════════════
-- LOAD MODUL DARI GITHUB
-- ══════════════════════════════════════
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Tiooprime2/Piggy/refs/heads/main/ui.lua"
))()

local F = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Tiooprime2/Piggy/refs/heads/main/features.lua"
))()

-- shortcut
local S            = F.S
local setNoClip    = F.setNoClip
local setPlayerESP = F.setPlayerESP
local setPiggyESP  = F.setPiggyESP
local setAntiAFK   = F.setAntiAFK

local pages       = UI.pages
local makeToggle  = UI.makeToggle
local makeSlider  = UI.makeSlider
local makeSection = UI.makeSection
local statusTxt   = UI.statusTxt
local dot         = UI.dot
local closeBtn    = UI.closeBtn
local gui         = UI.gui
local shadow      = UI.shadow
local ACCENT      = UI.ACCENT
local GREEN       = UI.GREEN

-- ══════════════════════════════════════
-- PLAYER PAGE
-- ══════════════════════════════════════
makeSection("Player", "  MOVEMENT")

makeToggle("Player", "NO CLIP", "Tembus lewat tembok / dinding", function(on)
    S.NoClip = on
    if not on then
        setNoClip(LP.Character, false)
        F.savedCol = {}
    end
end)

makeToggle("Player", "SPEED BOOST", "Kecepatan lari x2", function(on)
    S.SpeedBoost = on
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = on and 32 or S.WalkSpeed end
end)

makeToggle("Player", "INFINITE JUMP", "Lompat terus di udara", function(on)
    S.InfiniteJump = on
end)

makeSection("Player", "  STATS")

makeSlider("Player", "WALK SPEED", 8, 100, 16, function(v)
    S.WalkSpeed = v
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and not S.SpeedBoost then hum.WalkSpeed = v end
end)

makeSlider("Player", "JUMP POWER", 20, 200, 50, function(v)
    S.JumpPower = v
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end)

-- ══════════════════════════════════════
-- VISUAL PAGE
-- ══════════════════════════════════════
makeSection("Visual", "  ESP")

makeToggle("Visual", "PLAYER ESP", "Highlight player hijau, tembus tembok", function(on)
    S.PlayerESP = on
    setPlayerESP(on)
end)

makeToggle("Visual", "PIGGY ESP", "Highlight Piggy NPC merah, tembus tembok", function(on)
    S.PiggyESP = on
    setPiggyESP(on)
end)

makeSection("Visual", "  VISUAL")

makeToggle("Visual", "FULLBRIGHT", "Terangi semua area gelap", function(on)
    S.Fullbright = on
    Lighting.Brightness    = on and 8 or 1
    Lighting.FogEnd        = on and 100000 or 1000
    Lighting.GlobalShadows = not on
end)

-- ══════════════════════════════════════
-- MISC PAGE
-- ══════════════════════════════════════
makeSection("Misc", "  UTILITY")

makeToggle("Misc", "ANTI AFK", "Cegah kick saat idle", function(on)
    S.AntiAFK = on
    setAntiAFK(on)
end)

makeSection("Misc", "  INFO")

-- Info card
local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(1, 0, 0, 52)
infoCard.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
infoCard.BorderSizePixel = 0
infoCard.ZIndex = 13
infoCard.Parent = pages["Misc"]

local ic = Instance.new("UICorner")
ic.CornerRadius = UDim.new(0, 9)
ic.Parent = infoCard

local is = Instance.new("UIStroke")
is.Color = Color3.fromRGB(60, 50, 100)
is.Thickness = 1
is.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
is.Parent = infoCard

local infoTitle = Instance.new("TextLabel")
infoTitle.BackgroundTransparency = 1
infoTitle.Size = UDim2.new(1, -16, 0, 18)
infoTitle.Position = UDim2.new(0, 12, 0, 8)
infoTitle.Text = "🩷 TiooScript — Piggy Edition"
infoTitle.TextSize = 11
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextColor3 = Color3.fromRGB(240, 238, 255)
infoTitle.TextXAlignment = Enum.TextXAlignment.Left
infoTitle.ZIndex = 14
infoTitle.Parent = infoCard

local infoSub = Instance.new("TextLabel")
infoSub.BackgroundTransparency = 1
infoSub.Size = UDim2.new(1, -16, 0, 14)
infoSub.Position = UDim2.new(0, 12, 0, 28)
infoSub.Text = "by Ridho (Tiooprime2) • v2.0"
infoSub.TextSize = 9
infoSub.Font = Enum.Font.Gotham
infoSub.TextColor3 = Color3.fromRGB(130, 128, 155)
infoSub.TextXAlignment = Enum.TextXAlignment.Left
infoSub.ZIndex = 14
infoSub.Parent = infoCard

-- ══════════════════════════════════════
-- NOCLIP LOOP + STATUS BAR UPDATE
-- ══════════════════════════════════════
RunService.Stepped:Connect(function()
    if S.NoClip then
        setNoClip(LP.Character, true)
    end
    statusTxt.Text = "Script aktif • NoClip: " .. (S.NoClip and "ON ✓" or "OFF")
    dot.BackgroundColor3 = S.NoClip and ACCENT or GREEN
end)

-- ══════════════════════════════════════
-- CLOSE BUTTON
-- ══════════════════════════════════════
closeBtn.MouseButton1Click:Connect(function()
    setPlayerESP(false)
    setPiggyESP(false)
    S.NoClip = false
    setNoClip(LP.Character, false)
    TweenService:Create(UI.win, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 0),
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(shadow, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
    }):Play()
    task.wait(0.3)
    gui:Destroy()
end)

print("[TiooScript v2.0] Loaded! 🩷")
