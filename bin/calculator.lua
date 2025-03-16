local window = require("HydraUI.windowComponents.window").new("Calculator", 11, 11)
local button = require("HydraUI.windowComponents.button")

local text

local buttons = {
   {
      "(", ")", "^", "/"
   },
   {
      "7", "8", "9", "*"
   },
   {
      "4", "5", "6", "-"
   },
   {
      "1", "2", "3", "+"
   },
   {
      "<", "0", ".", "="
   }
}

local function evaluate()
   local func = load("return " .. text.text)

   if not func then
      text.text = "Error             "
      return
   end

   local success, solution = pcall(func)

   if not success then
      text.text = "Error             "
      return
   end

   local newText = tostring(solution)
   text.text = newText .. (" "):rep(18 - #newText)
end

text = button.new("                  ", 9, 1, 1, evaluate)
window:addComponent(text)

for y, tbl in ipairs(buttons) do
   for x, btn in ipairs(tbl) do
      local btnX = x * 2
      local btnY = y + 3
      if btn == "=" then
         window:addComponent(button.new(btn, 1, btnX, btnY, evaluate))
      elseif btn == "<" then
         window:addComponent(button.new(btn, 1, btnX, btnY, function()
            local newText = text.text:gsub(" *$", ""):gsub(".$", "")
            text.text = newText .. (" "):rep(18 - #newText)
         end))
      else
         window:addComponent(button.new(btn, 1, btnX, btnY, function()
            local newText = text.text:gsub(" *$", "") .. btn
            text.text = newText .. (" "):rep(18 - #newText)
         end))
      end
   end
end

ui.addWindow(window)

