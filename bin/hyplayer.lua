local window = require("HydraUI.windowComponents.window").new("HyPlayer", 11, 4, 15, 15)
local button = require("HydraUI.windowComponents.button")

local function findAudioDisc()
   return kernel.peripherals.find("drive", function(_, drive)
      return drive.hasAudio()
   end)[1]
end

window:addComponent(button.new("Play", 4, 1, 1, function()
   local drive = findAudioDisc()
   if drive then drive.playAudio() end
end))

window:addComponent(button.new("Stop", 4, 6, 1, function()
   local drive = findAudioDisc()
   if drive then drive.stopAudio() end
end))

ui.addWindow(window)

