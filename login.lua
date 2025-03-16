local function mkPassword(password, key)
   if not key then key = math.random(32, 127) end

   password = password .. string.char(key)

   local split = {}
   for i = 1, #password, 2 do
      split[#split + 1] = password:sub(i, i + 1)
   end

   local final = {}
   for _, v in ipairs(split) do
      local toInsert = 255

      for i = 1, 2 do
         toInsert = bit32.band(toInsert, bit32.rrotate(string.byte(v:sub(i, i)) or 0xff, i))
      end

      final[#final + 1] = toInsert
   end

   local truefinal = ""
   for _, v in ipairs(final) do
      truefinal = truefinal .. "$" .. tostring(v)
   end

   return key .. truefinal
end

local function checkPassword(password, secret)
   return mkPassword(password, tonumber(secret:match("^[0-9]+"))) == secret
end

local function readPassword()
   local password = ""

   while true do
      local event, val = kernel.events.awaitEvent()

      if event == "key" then
         if val == keys.enter then
            print()
            return password
         elseif val == keys.backspace then
            password = password:gsub(".$", "")
         end
      elseif event == "char" then
         password = password .. val
      end
   end
end

local hashFile = fs.open("/etc/passwd", "r")

if not hashFile or hashFile.readAll() == "" then
   local file = assert(fs.open("/etc/passwd", "w"))

   term.write("new password: ")
   file.write(mkPassword(readPassword()))
   print()

   hashFile = assert(fs.open("/etc/passwd", "r"))
end

hashFile.seek("set", 0)
local hash = hashFile.readAll()

term.write("password: ")
while true do
   if checkPassword(readPassword(), hash) then
      break
   else
      print("Password incorrect")
   end

   term.write("password: ")
end
term.clear()

