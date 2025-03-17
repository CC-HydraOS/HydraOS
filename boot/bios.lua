local fs = fs
local term = term

function loadfile(path, mode, env)
   if type(mode) == "table" and env == nil then
      mode, env = nil, mode
   end

   local file = fs.open(path, "r")
   if not file then return nil, "File not found." end

   local func, err = load(file.readAll(), "/" .. path:gsub("^/", ""), mode, env)
   file.close()

   return func, err
end

function dofile(path)
   local func, err = loadfile(path, nil, _G)

   return func and func() or err
end

function os.version()
   return "HydraOS 1.0.0"
end


local function write(text)
   local x, y = term.getCursorPos()
   local width = term.getSize()

   term.write(text:sub(1, width - x))

   local iter = 0
   for i = (width - x), #text, width do
      iter = iter + 1

      if (y + iter) > width then
         term.scroll(1)
         y = y - 1
      end
      term.setCursorPos(1, y + iter)

      term.write(text:sub(i, i + width - 1))
   end

   term.setCursorPos(1, y + iter + 1)
end

local function onFailed(error)
   term.setTextColor(0x4000)

   error = error--[[:gsub("^.-:[0-9]-: ", "")]] .. "\n" .. debug.traceback():gsub("^.-\n", "")

   term.setCursorPos(1, 1)
   write("Error running HydraOS")

   for str in error:gmatch("[^\n]+") do
      write(str)
   end

   while coroutine.yield() do
   end
end

xpcall(assert(loadfile("/boot/kernel/init.lua", nil, _G)), onFailed, "HydraKernel.init")

