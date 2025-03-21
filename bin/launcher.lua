local window = require("HydraUI.windowComponents.window").new("HyLauncher", 12, 16, 2, 3)
local button = require("HydraUI.windowComponents.button")

window:addComponent(button.new("Calculator", 10, 1, 1, function()
   kernel.processes.run("/bin/calculator.lua")
end))
window:addComponent(button.new(" HyPlayer ", 10, 1, 2, function()
   kernel.processes.run("/bin/hyplayer.lua")
end))
window:addComponent(button.new("Dice Game!", 10, 1, 3, function()
   kernel.processes.run("/bin/dicegame.lua")
end))

ui.addWindow(window)

