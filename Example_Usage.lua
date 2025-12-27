--[[
    Example Usage Script for O-X Panel
    
    This script demonstrates how to use the O-X Panel in your Roblox game
    Place this script in a LocalScript in StarterPlayer > StarterPlayerScripts
    
    The O-X Panel is designed to work with third-party software and is fully responsive
    on both PC and Mobile devices with drag functionality.
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the module to be available
-- If you place OXPanel as a ModuleScript in ReplicatedStorage,
-- adjust the require path accordingly
local OXPanel = require(game.ReplicatedStorage:WaitForChild("OXPanel"))

-- Create a new panel instance with custom config
local panel = OXPanel.new("O-X PANEL v1.0", {
    width = 350,
    height = 500,
    position = UDim2.new(0.5, -175, 0.5, -250),
    draggable = true,
    showCloseButton = true,
    showMinimizeButton = true,
})

-- Set the parent to display the panel
panel:setParent(playerGui)

-- ============================================
-- PANEL CONTENT SETUP
-- ============================================

-- Title and description labels
panel:addLabel("═════════════════════════════════════")
panel:addLabel("Welcome to O-X Panel!")
panel:addLabel("Red and Black Professional Theme")
panel:addLabel("═════════════════════════════════════")

-- Action Buttons
panel:addButton("Execute Action", function()
    print("[O-X Panel] Action executed!")
    -- Add your custom logic here
end)

panel:addButton("Toggle Feature", function()
    print("[O-X Panel] Feature toggled!")
    -- Add your custom logic here
end)

panel:addButton("Settings", function()
    print("[O-X Panel] Opening settings...")
    -- Add your custom logic here
end)

-- Information labels
panel:addLabel("─────────────────────────────────────")
panel:addLabel("Status: Online")
panel:addLabel("Version: 1.0")

-- Text input example
panel:addTextBox("Enter command...", function(text, enterPressed)
    if enterPressed then
        print("[O-X Panel] Command entered: " .. text)
    end
end)

-- Advanced button example
panel:addButton("Advanced Control", function()
    print("[O-X Panel] Advanced control activated")
    -- Third-party software integration point
end)

-- ============================================
-- ADVANCED USAGE
-- ============================================

-- Access the main frame for custom modifications
local mainFrame = panel:getMainFrame()
-- You can now modify mainFrame as needed for advanced customization

-- Example: Toggle panel visibility
local function togglePanel()
    mainFrame.Visible = not mainFrame.Visible
    print("[O-X Panel] Visibility toggled")
end

-- Example: Reposition the panel programmatically
local function repositionPanel(x, y)
    mainFrame.Position = UDim2.new(0, x, 0, y)
    print("[O-X Panel] Panel repositioned to (" .. x .. ", " .. y .. ")")
end

-- ============================================
-- THIRD-PARTY SOFTWARE INTEGRATION
-- ============================================

-- This is where you would integrate with third-party software
-- For example, if using an external API or tool:
--
-- panel:addButton("Connect to External Tool", function()
--     -- Call your third-party API here
--     externalTool:sendCommand("action_name")
--     print("[O-X Panel] Connected to external tool")
-- end)

print("[O-X Panel] O-X Panel initialized successfully!")
print("[O-X Panel] Panel is fully draggable and responsive on PC and Mobile")
