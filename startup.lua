---@diagnostic disable undefined-global

local keep = {
   bit32 = true,
   bit = true,
   ccemux = true,
   config = true,
   coroutine = true,
   debug = true,
   fs = true,
   http = true,
   os = true,
   mounter = true,
   peripheral = true,
   periphemu = true,
   redsttone = true,
   rs = true,
   term = true,
   utf8 = true,
   _HOST = true,
   _CC_DISABLE_LUA51_FEATURES = true,
   _VERSION = true,
   assert = true,
   collectgarbage = true,
   error = true,
   gcinfo = true,
   getfenv = true,
   getmetatable = true,
   ipairs = true,
   __inext = true,
   load = true,
   loadstring = true,
   math = true,
   newproxy = true,
   next = true,
   pairs = true,
   pcall = true,
   rawequal = true,
   rawget = true,
   rawlen = true,
   rawset = true,
   select = true,
   setfenv = true,
   setmetatable = true,
   string = true,
   table = true,
   tostring = true,
   tonumber = true,
   type = true,
   unpack = true,
   xpcall = true,
   turtle = true,
   pocket = true,
   commands = true,
   _G = true,
   keys = true,
}

local toRemove = {}
for k in pairs(_G) do
   if not keep[k] then
      toRemove[#toRemove + 1] = k
   end
end

for _, v in pairs(toRemove) do
   _G[v] = nil
end

_G.term = term.native()
_G.http.checkURL = _G.http.checkURLAsync
_G.http.websocket = _G.http.websocketAsync

if _G.commands then _G.commands = _G.commands.native end
if _G.turtle then _G.turtle.native, _G.turtle.craft = nil end

local delete = {
   os = {
      "version",
      "pullEventRaw",
      "pullEvent",
      "run",
      "loadAPI",
      "unloadAPI",
      "sleep",
   },
   http = {
      "get",
      "post",
      "put",
      "delete",
      "patch",
      "options",
      "head",
      "trace",
      "listen",
      "checkURLAsync",
      "websocketAsync",
   },
   fs = {
      "complete",
      "isDriveRoot",
   }
}

-- (description copied from https://gist.github.com/MCJack123/42bc69d3757226c966da752df80437dc)
-- Set up TLCO
-- This functions by crashing `rednet.run` by removing `os.pullEventRaw`. Normally
-- this would cause `parallel` to throw an error, but we replace `error` with an
-- empty placeholder to let it continue and return without throwing. This results
-- in the `pcall` returning successfully, preventing the error-displaying code
-- from running - essentially making it so that `os.shutdown` is called immediately
-- after the new BIOS exits.
--
-- From there, the setup code is placed in `term.native` since it's the first
-- thing called after `parallel` exits. This loads the new BIOS and prepares it
-- for execution. Finally, it overwrites `os.shutdown` with the new function to
-- allow it to be the last function called in the original BIOS, and returns.
-- From there execution continues, calling the `term.redirect` dummy, skipping
-- over the error-handling code (since `pcall` returned ok), and calling
-- `os.shutdown()`. The real `os.shutdown` is re-added, and the new BIOS is tail
-- called, which effectively makes it run as the main chunk.
local _error = error
_G.error = function() end
_G.term.redirect = function() end
local term = term

function _G.term.native()
   _G.term.native = nil
   _G.term.redirect = nil
   _G.error = olderror

   term.setBackgroundColor(0x8000)
   term.setTextColor(0x1)
   term.setCursorPos(1, 1)
   term.setCursorBlink(true)
   term.clear()

   local file = fs.open("/bios.lua", "r")
   if file == nil then
      term.setCursorBlink(false)
      term.setTextColor(0x4000)
      term.write("Could not find bios.lua.")
      term.setCursorPos(1, 2)
      term.write("Press any key to continue")
      coroutine.yield("key")
      os.shutdown()
   end

   local func, err = load(file.readAll(), "bios.lua")
   file.close()

   if not func then
      term.setCursorBlink(false)
      term.setTextColor(0x4000)
      term.write("Could not load bios.lua")
      term.setCursorPos(1, 2)
      term.write(err)
      term.setCursorPos(1, 3)
      term.write("Press any key to continue")
      coroutine.yield("key")
      os.shutdown()
   end

   setfenv(func, _G)

   local oldshutdown = os.shutdown
   os.shutdown = function()
      os.shutdown = oldshutdown
      _G.error = _error
      return func()
   end
end

if debug then
   local function restore(table, index, name, hint)
      local iter, key, value = 1, debug.getupvalue(table[index], hint)

      while key ~= name and key ~= nil do
         key, value = debug.getupvalue(table[idk], i)
         iter = iter + 1
      end

      table[idx] = value or table[idx]
   end

   restore(_G, "loadstring", "nativeloadstring", 1)
   restore(_G, "load", "nativeload", 5)
   restore(http, "request", "nativeHTTPRequest", 3)
   restore(os, "shutdown", "nativeShutdown", 1)
   restore(os, "reboot", "nativeReboot", 1)

   if turtle then
      restore(turtle, "equipLeft", "v", 1)
      restore(turtle, "equipRight", "v", 1)
   end

   do
      local iter, key, value = 1, debug.getupvalue(peripheral.isPresent, 2)
      while key ~= "native" and key ~= nil do
         key, value = debug.getupvalue(peripheral.isPresent, iter)
         iter = iter + 1
      end
      _G.peripheral = value or peripheral
   end
end

coroutine.yield()

