-- ╔══════════════════════════════════════════════╗
-- ║       MAIN LOADER by TiooScript  v2.0        ║
-- ║     Modular System — GitHub Integration      ║
-- ╚══════════════════════════════════════════════╝

-- URL Database
local UI_URL = "https://raw.githubusercontent.com/Tiooprime2/Piggy/refs/heads/main/ui.lua"
local FEAT_URL = "https://raw.githubusercontent.com/Tiooprime2/Piggy/refs/heads/main/features.lua"

-- Function Loader (Anti-Error)
local function safeLoad(name, url)
    local success, content = pcall(game.HttpGet, game, url)
    if success then
        local func, err = loadstring(content)
        if func then
            print("[TiooLoader] " .. name .. " Loaded! 🩷")
            return func()
        else
            warn("[TiooLoader] Error in " .. name .. " Code: " .. err)
        end
    else
        warn("[TiooLoader] Failed to fetch " .. name .. " from GitHub!")
    end
end

-- ══════════════════════════════════════
-- EXECUTION
-- ══════════════════════════════════════

-- 1. Load UI Engine Terlebih Dahulu
local TiooUI = safeLoad("UI Engine", UI_URL)

-- 2. Load Fitur Logic
local TiooFeatures = safeLoad("Features", FEAT_URL)

-- 3. Notifikasi Sukses
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "TiooScript v2.0",
    Text = "Piggy Edition Ready to Use! 🐷",
    Duration = 5
})
