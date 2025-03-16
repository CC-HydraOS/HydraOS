local fs = fs

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

loadfile("HydraKernel/init.lua", nil, _G)("HydraKernel.init")

