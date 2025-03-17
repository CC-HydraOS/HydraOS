local window = require("HydraUI.windowComponents.window").new("Dice Game", 11, 8, 15, 3)
local text = require("HydraUI.windowComponents.text")
local button = require("HydraUI.windowComponents.button")
local checkbox = require("HydraUI.windowComponents.checkbox")

local round = 1
local roundText = text.new("Round 1", 7, 2, 1)
window:addComponent(roundText)

local dice = {}
for i = 1, 5 do
   local val = math.random(1, 6)
   dice[i] = {
      text = text.new(tostring(val), 1, i * 2 - 1, 2),
      checkbox = checkbox.new(i * 2 - 1, 3),
      value = val
   }

   window:addComponent(dice[i].text)
   window:addComponent(dice[i].checkbox)
end

local function finish()
   local score = 0
   local sorted = {}
   local counts = {0, 0, 0, 0, 0, 0}

   for _, v in pairs(dice) do
      sorted[#sorted + 1] = v.value
      counts[v.value] = counts[v.value] + 1
      score = score + v.value
   end
   table.sort(sorted)

   local mostInARow = 0
   local inARow = 1
   local previous = -1
   local seen = {}
   for _, v in ipairs(sorted) do
      if seen[v] then goto continue end

      seen[v] = true
      if v - 1 == previous then
         inARow = inARow + 1
      else
         mostInARow = math.max(inARow, mostInARow)
         inARow = 1
      end
      previous = v

      ::continue::
   end
   mostInARow = math.max(inARow, mostInARow)

   if mostInARow ~= 1 then
      score = score + mostInARow * 10
   end

   local highestCount = math.max(table.unpack(counts))
   if highestCount > 1 then
      for i = 6, 1, -1 do
         if counts[i] == highestCount then
            score = score + highestCount * i * 2
            break
         end
      end
   end

   window:addComponent(text.new("Score " .. (" "):rep(math.abs(#tostring(score) - 3)) .. tostring(score), 9, 1, 5))
end

window:addComponent(button.new("Roll Dice", 9, 1, 5, function()
   round = round + 1

   for _, v in pairs(dice) do
      if not v.checkbox.active then
         v.value = math.random(1, 6)
         v.text.text = tostring(v.value)
      end
   end

   roundText.text = string.format("Round %d", round)
   if round == 3 then
      finish()
      return "DELETE"
   end
end))

ui.addWindow(window)

