mock = function() 
  local t = {}
  setmetatable(t, {__call = mock, __index = mock, __newindex = mock})
  return t
end

love = {}
love.filesystem = {}
love.graphics = mock()
L = mock()
state = mock()


-- code originally from http://lua-users.org/wiki/LuaModulesLoader
local function love_load(path)
  local errmsg = ""
  local real_path = "../love/" .. path
  local file = io.open(real_path, "rb")
  if file then
    -- Compile and return the module
    return assert(loadstring(assert(file:read("*a")), real_path))
  end
  return "no love file '"..path.."' (checked with love_test loader)"
end

-- Install the loader so that it's called just before the normal Lua loader
table.insert(package.loaders, 2, love_load)


love.filesystem.require = function(x)
  require(x)
end
