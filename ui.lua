-- ╔══════════════════════════════════════════════╗
-- ║       PIGGY SCRIPT by TiooScript  v2.0       ║
-- ║              ui.lua — UI Module              ║
-- ╚══════════════════════════════════════════════╝
-- Modul ini handle: Window, Header, TabBar, ScrollArea,
-- StatusBar, Card Builders (Toggle, Slider, Section)
-- Dipanggil dari main.lua

local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")

-- ══════════════════════════════════════
-- CLEANUP OLD
-- ══════════════════════════════════════
local oldGui = CoreGui:FindFirstChild("TiooGui")
if oldGui then oldGui:Destroy() end

-- ══════════════════════════════════════
-- WARNA
-- ══════════════════════════════════════
local BG      = Color3.fromRGB(14, 14, 20)
local SURFACE = Color3.fromRGB(22, 22, 32)
local CARD    = Color3.fromRGB(28, 28, 42)
local ACCENT  = Color3.fromRGB(110, 80, 255)
local ACCENT2 = Color3.fromRGB(80, 55, 200)
local TEXT    = Color3.fromRGB(240, 238, 255)
local MUTED   = Color3.fromRGB(130, 128, 155)
local GREEN   = Color3.fromRGB(50, 210, 110)
local RED     = Color3.fromRGB(220, 60, 60)
local BORDER  = Color3.fromRGB(45, 44, 65)

-- ══════════════════════════════════════
-- HELPER
-- ══════════════════════════════════════
local function tw(obj, props, t, style)
    TweenService:Create(obj, TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

local function border(obj, col, thick)
    local s = Instance.new("UIStroke")
    s.Color = col or BORDER
    s.Thickness = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
end

local function lbl(props)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextColor3 = TEXT
    t.TextSize = 13
    for k, v in pairs(props) do t[k] = v end
    return t
end

-- ══════════════════════════════════════
-- GUI ROOT
-- ══════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "TiooGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = CoreGui

-- ══════════════════════════════════════
-- WINDOW
-- ══════════════════════════════════════
local WIN_W, WIN_H = 300, 440

local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(0, WIN_W + 20, 0, WIN_H + 20)
shadow.Position = UDim2.new(0.5, -(WIN_W/2+10), 0.5, -(WIN_H/2+10))
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.55
shadow.BorderSizePixel = 0
shadow.ZIndex = 9
shadow.Parent = gui
corner(shadow, 14)

local win = Instance.new("Frame")
win.Name = "Window"
win.Size = UDim2.new(0, WIN_W, 0, WIN_H)
win.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
win.BackgroundColor3 = BG
win.BorderSizePixel = 0
win.ZIndex = 10
win.ClipsDescendants = true
win.Parent = gui
corner(win, 12)
border(win, BORDER, 1)

-- ══════════════════════════════════════
-- HEADER
-- ══════════════════════════════════════
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = SURFACE
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = win

local hBorder = Instance.new("Frame")
hBorder.Size = UDim2.new(1, 0, 0, 1)
hBorder.Position = UDim2.new(0, 0, 1, -1)
hBorder.BackgroundColor3 = BORDER
hBorder.BorderSizePixel = 0
hBorder.ZIndex = 12
hBorder.Parent = header

local iconBg = Instance.new("Frame")
iconBg.Size = UDim2.new(0, 30, 0, 30)
iconBg.Position = UDim2.new(0, 12, 0.5, -15)
iconBg.BackgroundColor3 = ACCENT2
iconBg.ZIndex = 12
iconBg.Parent = header
corner(iconBg, 8)

lbl({
    Size = UDim2.new(1,0,1,0),
    Text = "🐷",
    TextScaled = true,
    ZIndex = 13,
    Parent = iconBg,
})

lbl({
    Size = UDim2.new(0, 120, 0, 20),
    Position = UDim2.new(0, 50, 0, 7),
    Text = "PIGGY SCRIPT",
    TextSize = 13,
    TextColor3 = TEXT,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
    Parent = header,
})

lbl({
    Size = UDim2.new(0, 120, 0, 14),
    Position = UDim2.new(0, 50, 0, 28),
    Text = "v2.0 • by Tiooprime2",
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextColor3 = MUTED,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
    Parent = header,
})

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -56, 0.5, -12)
minBtn.BackgroundColor3 = CARD
minBtn.Text = "—"
minBtn.TextColor3 = MUTED
minBtn.TextSize = 11
minBtn.Font = Enum.Font.GothamBold
minBtn.ZIndex = 13
minBtn.Parent = header
corner(minBtn, 6)
border(minBtn, BORDER)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(60,20,20)
closeBtn.Text = "✕"
closeBtn.TextColor3 = RED
closeBtn.TextSize = 10
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 13
closeBtn.Parent = header
corner(closeBtn, 6)
border(closeBtn, Color3.fromRGB(80,30,30))

-- ══════════════════════════════════════
-- TAB BAR
-- ══════════════════════════════════════
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -20, 0, 30)
tabBar.Position = UDim2.new(0, 10, 0, 58)
tabBar.BackgroundColor3 = SURFACE
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 11
tabBar.Parent = win
corner(tabBar, 8)
border(tabBar, BORDER)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 3)
tabPad.PaddingRight = UDim.new(0, 3)
tabPad.PaddingTop = UDim.new(0, 3)
tabPad.PaddingBottom = UDim.new(0, 3)
tabPad.Parent = tabBar

-- ══════════════════════════════════════
-- SCROLL AREA
-- ══════════════════════════════════════
local scrollArea = Instance.new("ScrollingFrame")
scrollArea.Size = UDim2.new(1, 0, 1, -100)
scrollArea.Position = UDim2.new(0, 0, 0, 96)
scrollArea.BackgroundTransparency = 1
scrollArea.BorderSizePixel = 0
scrollArea.ScrollBarThickness = 3
scrollArea.ScrollBarImageColor3 = ACCENT
scrollArea.ScrollBarImageTransparency = 0.3
scrollArea.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollArea.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
scrollArea.ScrollingDirection = Enum.ScrollingDirection.Y
scrollArea.ZIndex = 11
scrollArea.Parent = win

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = scrollArea

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 8)
listPad.PaddingBottom = UDim.new(0, 10)
listPad.PaddingLeft = UDim.new(0, 10)
listPad.PaddingRight = UDim.new(0, 10)
listPad.Parent = scrollArea

-- ══════════════════════════════════════
-- STATUS BAR
-- ══════════════════════════════════════
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 28)
statusBar.Position = UDim2.new(0, 0, 1, -28)
statusBar.BackgroundColor3 = SURFACE
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 11
statusBar.Parent = win

local statusTopLine = Instance.new("Frame")
statusTopLine.Size = UDim2.new(1, 0, 0, 1)
statusTopLine.BackgroundColor3 = BORDER
statusTopLine.BorderSizePixel = 0
statusTopLine.ZIndex = 12
statusTopLine.Parent = statusBar

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 7, 0, 7)
dot.Position = UDim2.new(0, 10, 0.5, -3.5)
dot.BackgroundColor3 = GREEN
dot.BorderSizePixel = 0
dot.ZIndex = 13
dot.Parent = statusBar
corner(dot, 4)

local statusTxt = lbl({
    Size = UDim2.new(1, -28, 1, 0),
    Position = UDim2.new(0, 22, 0, 0),
    Text = "Script aktif • NoClip: OFF",
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextColor3 = MUTED,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13,
    Parent = statusBar,
})

-- ══════════════════════════════════════
-- TAB + PAGE SYSTEM
-- ══════════════════════════════════════
local tabNames   = {"Player", "Visual", "Misc"}
local tabBtns    = {}
local pages      = {}
local activePage = "Player"

for _, name in ipairs(tabNames) do
    local frame = Instance.new("Frame")
    frame.Name = "Page_"..name
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Visible = (name == "Player")
    frame.BorderSizePixel = 0
    frame.ZIndex = 12
    frame.LayoutOrder = 1
    frame.Parent = scrollArea

    local fl = Instance.new("UIListLayout")
    fl.Padding = UDim.new(0, 6)
    fl.SortOrder = Enum.SortOrder.LayoutOrder
    fl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    fl.Parent = frame

    pages[name] = frame
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 86, 1, 0)
    btn.BackgroundColor3 = i == 1 and ACCENT or Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = i == 1 and 0 or 1
    btn.Text = name
    btn.TextColor3 = i == 1 and TEXT or MUTED
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 12
    btn.LayoutOrder = i
    btn.Parent = tabBar
    corner(btn, 6)
    tabBtns[name] = btn

    btn.MouseButton1Click:Connect(function()
        if activePage == name then return end
        activePage = name
        scrollArea.CanvasPosition = Vector2.new(0, 0)
        for _, n in ipairs(tabNames) do
            local isActive = n == name
            tw(tabBtns[n], {
                BackgroundColor3 = isActive and ACCENT or Color3.fromRGB(0,0,0),
                BackgroundTransparency = isActive and 0 or 1,
                TextColor3 = isActive and TEXT or MUTED,
            }, 0.18)
            pages[n].Visible = isActive
        end
    end)
end

-- ══════════════════════════════════════
-- CARD BUILDERS
-- ══════════════════════════════════════

-- Toggle Card
local function makeToggle(pageName, labelTxt, descTxt, callback)
    local page = pages[pageName]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.BackgroundColor3 = CARD
    card.BorderSizePixel = 0
    card.ZIndex = 13
    card.Parent = page
    corner(card, 9)
    border(card, BORDER)

    local strip = Instance.new("Frame")
    strip.Size = UDim2.new(0, 3, 0.55, 0)
    strip.Position = UDim2.new(0, 0, 0.225, 0)
    strip.BackgroundColor3 = ACCENT
    strip.BorderSizePixel = 0
    strip.ZIndex = 14
    strip.Parent = card
    corner(strip, 2)

    lbl({
        Size = UDim2.new(1, -76, 0, 20),
        Position = UDim2.new(0, 14, 0, 8),
        Text = labelTxt,
        TextSize = 12,
        TextColor3 = TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = card,
    })

    lbl({
        Size = UDim2.new(1, -76, 0, 14),
        Position = UDim2.new(0, 14, 0, 30),
        Text = descTxt,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = card,
    })

    local togBg = Instance.new("Frame")
    togBg.Size = UDim2.new(0, 42, 0, 22)
    togBg.Position = UDim2.new(1, -52, 0.5, -11)
    togBg.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
    togBg.ZIndex = 14
    togBg.Parent = card
    corner(togBg, 11)
    border(togBg, BORDER)

    local togKnob = Instance.new("Frame")
    togKnob.Size = UDim2.new(0, 16, 0, 16)
    togKnob.Position = UDim2.new(0, 3, 0.5, -8)
    togKnob.BackgroundColor3 = MUTED
    togKnob.ZIndex = 15
    togKnob.Parent = togBg
    corner(togKnob, 8)

    local state = false

    local togBtn = Instance.new("TextButton")
    togBtn.Size = UDim2.new(1, 0, 1, 0)
    togBtn.BackgroundTransparency = 1
    togBtn.Text = ""
    togBtn.ZIndex = 16
    togBtn.Parent = togBg

    local function updateVisual(on)
        tw(togBg, {BackgroundColor3 = on and ACCENT or Color3.fromRGB(40,40,58)}, 0.2)
        tw(togKnob, {
            Position = on and UDim2.new(1,-19, 0.5,-8) or UDim2.new(0,3, 0.5,-8),
            BackgroundColor3 = on and TEXT or MUTED,
        }, 0.2)
    end

    togBtn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual(state)
        if callback then callback(state) end
    end)

    return card
end

-- Slider Card
local function makeSlider(pageName, labelTxt, minV, maxV, defVal, callback)
    local page = pages[pageName]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 58)
    card.BackgroundColor3 = CARD
    card.BorderSizePixel = 0
    card.ZIndex = 13
    card.Parent = page
    corner(card, 9)
    border(card, BORDER)

    local strip = Instance.new("Frame")
    strip.Size = UDim2.new(0, 3, 0.55, 0)
    strip.Position = UDim2.new(0, 0, 0.225, 0)
    strip.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    strip.BorderSizePixel = 0
    strip.ZIndex = 14
    strip.Parent = card
    corner(strip, 2)

    lbl({
        Size = UDim2.new(0.6, 0, 0, 18),
        Position = UDim2.new(0, 14, 0, 7),
        Text = labelTxt,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = card,
    })

    local valBox = Instance.new("Frame")
    valBox.Size = UDim2.new(0, 38, 0, 18)
    valBox.Position = UDim2.new(1, -48, 0, 7)
    valBox.BackgroundColor3 = SURFACE
    valBox.BorderSizePixel = 0
    valBox.ZIndex = 14
    valBox.Parent = card
    corner(valBox, 5)
    border(valBox, BORDER)

    local valL = lbl({
        Size = UDim2.new(1, 0, 1, 0),
        Text = tostring(defVal),
        TextSize = 10,
        TextColor3 = Color3.fromRGB(80, 160, 255),
        ZIndex = 15,
        Parent = valBox,
    })

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -24, 0, 5)
    trackBg.Position = UDim2.new(0, 12, 0, 37)
    trackBg.BackgroundColor3 = SURFACE
    trackBg.BorderSizePixel = 0
    trackBg.ZIndex = 14
    trackBg.Parent = card
    corner(trackBg, 3)
    border(trackBg, BORDER)

    local rel0 = (defVal - minV) / (maxV - minV)

    local trackFill = Instance.new("Frame")
    trackFill.Size = UDim2.new(rel0, 0, 1, 0)
    trackFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    trackFill.BorderSizePixel = 0
    trackFill.ZIndex = 15
    trackFill.Parent = trackBg
    corner(trackFill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 13, 0, 13)
    knob.Position = UDim2.new(rel0, -6, 0.5, -6)
    knob.BackgroundColor3 = TEXT
    knob.BorderSizePixel = 0
    knob.ZIndex = 16
    knob.Parent = trackBg
    corner(knob, 7)

    local inputCatch = Instance.new("TextButton")
    inputCatch.Size = UDim2.new(1, -24, 0, 24)
    inputCatch.Position = UDim2.new(0, 12, 0, 30)
    inputCatch.BackgroundTransparency = 1
    inputCatch.Text = ""
    inputCatch.ZIndex = 17
    inputCatch.Parent = card

    local dragging = false

    local function applyPos(inputX)
        local abs = trackBg.AbsolutePosition.X
        local sz  = trackBg.AbsoluteSize.X
        local rel = math.clamp((inputX - abs) / sz, 0, 1)
        local val = math.floor(minV + (maxV - minV) * rel + 0.5)
        trackFill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -6, 0.5, -6)
        valL.Text = tostring(val)
        if callback then callback(val) end
    end

    inputCatch.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            applyPos(inp.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            applyPos(inp.Position.X)
        end
    end)

    return card
end

-- Section Label
local function makeSection(pageName, txt)
    local page = pages[pageName]
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 18)
    f.BackgroundTransparency = 1
    f.ZIndex = 13
    f.Parent = page

    lbl({
        Size = UDim2.new(1, 0, 1, 0),
        Text = txt,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextColor3 = MUTED,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = f,
    })
    return f
end

-- ══════════════════════════════════════
-- DRAGGABLE WINDOW
-- ══════════════════════════════════════
local dragging, dragStart, winStart
header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        winStart  = win.Position
    end
end)
header.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        local d = inp.Position - dragStart
        win.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + d.X,
            winStart.Y.Scale, winStart.Y.Offset + d.Y
        )
        shadow.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + d.X - 10,
            winStart.Y.Scale, winStart.Y.Offset + d.Y - 10
        )
    end
end)

-- ══════════════════════════════════════
-- MINIMIZE
-- ══════════════════════════════════════
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tw(win, {Size = UDim2.new(0, WIN_W, 0, 50)}, 0.25)
        tw(shadow, {Size = UDim2.new(0, WIN_W+20, 0, 70)}, 0.25)
        minBtn.Text = "+"
    else
        tw(win, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.25)
        tw(shadow, {Size = UDim2.new(0, WIN_W+20, 0, WIN_H+20)}, 0.25)
        minBtn.Text = "—"
    end
end)

-- ══════════════════════════════════════
-- EXPORTS — dipake di main.lua
-- ══════════════════════════════════════
return {
    gui         = gui,
    win         = win,
    shadow      = shadow,
    closeBtn    = closeBtn,
    pages       = pages,
    statusTxt   = statusTxt,
    dot         = dot,
    makeToggle  = makeToggle,
    makeSlider  = makeSlider,
    makeSection = makeSection,
    -- warna (biar modul lain bisa pakai)
    ACCENT      = ACCENT,
    GREEN       = GREEN,
}
