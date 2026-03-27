-- ╔══════════════════════════════════════════════╗
-- ║       PIGGY SCRIPT by TiooScript  v2.0       ║
-- ║           features.lua — Logic Module        ║
-- ╚══════════════════════════════════════════════╝
-- Modul ini handle: NoClip, ESP, SpeedBoost,
-- InfiniteJump, Fullbright, AntiAFK, Respawn Handler
-- Dipanggil dari main.lua

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")

local LP   = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

-- ══════════════════════════════════════
-- STATE
-- ══════════════════════════════════════
local S = {
    NoClip       = false,
    SpeedBoost   = false,
    InfiniteJump = false,
    PlayerESP    = false,
    PiggyESP     = false,
    Fullbright   = false,
    AntiAFK      = false,
    WalkSpeed    = 16,
    JumpPower    = 50,
}

-- ══════════════════════════════════════
-- NOCLIP
-- ══════════════════════════════════════
local savedCol = {}

local function setNoClip(char, on)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if on then
                if savedCol[p] == nil then savedCol[p] = p.CanCollide end
                p.CanCollide = false
            else
                p.CanCollide = (savedCol[p] ~= nil) and savedCol[p] or true
                savedCol[p] = nil
            end
        end
    end
end

-- ══════════════════════════════════════
-- ESP — Highlight
-- ══════════════════════════════════════
local HL_NAME = "TiooHL"

local function addHL(char, fill, outline)
    if not char or char:FindFirstChild(HL_NAME) then return end
    local h = Instance.new("Highlight")
    h.Name = HL_NAME
    h.Adornee = char
    h.FillColor = fill
    h.OutlineColor = outline
    h.FillTransparency = 0.45
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
end

local function removeHL(char)
    if not char then return end
    local h = char:FindFirstChild(HL_NAME)
    if h then h:Destroy() end
end

local espConns = {}

local function setPlayerESP(on)
    for _, c in ipairs(espConns) do c:Disconnect() end
    espConns = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if on then
                if plr.Character then
                    addHL(plr.Character, Color3.fromRGB(0,230,80), Color3.fromRGB(0,180,60))
                end
                local c = plr.CharacterAdded:Connect(function(ch)
                    task.wait(0.3)
                    if S.PlayerESP then
                        addHL(ch, Color3.fromRGB(0,230,80), Color3.fromRGB(0,180,60))
                    end
                end)
                table.insert(espConns, c)
            else
                if plr.Character then removeHL(plr.Character) end
            end
        end
    end
end

local piggyTask = nil

local function isPiggyNPC(m)
    if not m:IsA("Model") then return false end
    if not m:FindFirstChildOfClass("Humanoid") then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == m then return false end
    end
    return true
end

local function setPiggyESP(on)
    if piggyTask then task.cancel(piggyTask) piggyTask = nil end
    for _, m in ipairs(workspace:GetDescendants()) do
        if isPiggyNPC(m) then removeHL(m) end
    end
    if not on then return end
    piggyTask = task.spawn(function()
        while S.PiggyESP do
            for _, m in ipairs(workspace:GetDescendants()) do
                if isPiggyNPC(m) then
                    addHL(m, Color3.fromRGB(255,40,40), Color3.fromRGB(200,0,0))
                end
            end
            task.wait(1.5)
        end
    end)
end

-- ══════════════════════════════════════
-- INFINITE JUMP
-- ══════════════════════════════════════
UIS.JumpRequest:Connect(function()
    if not S.InfiniteJump then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ══════════════════════════════════════
-- ANTI AFK
-- ══════════════════════════════════════
local afkConn = nil

local function setAntiAFK(on)
    if afkConn then afkConn:Disconnect() afkConn = nil end
    if not on then return end
    local VU = game:GetService("VirtualUser")
    afkConn = LP.Idled:Connect(function()
        if not S.AntiAFK then return end
        VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

-- ══════════════════════════════════════
-- RESPAWN HANDLER
-- ══════════════════════════════════════
LP.CharacterAdded:Connect(function(char)
    Char = char
    savedCol = {}
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.WalkSpeed = S.WalkSpeed
        hum.JumpPower = S.JumpPower
    end
end)

-- Auto ESP untuk player baru join
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if S.PlayerESP then
            addHL(char, Color3.fromRGB(0,230,80), Color3.fromRGB(0,180,60))
        end
    end)
end)

-- ══════════════════════════════════════
-- EXPORTS — dipake di main.lua
-- ══════════════════════════════════════
return {
    S            = S,
    setNoClip    = setNoClip,
    setPlayerESP = setPlayerESP,
    setPiggyESP  = setPiggyESP,
    setAntiAFK   = setAntiAFK,
    savedCol     = savedCol,
    LP           = LP,
}
