mock = function() 
  local t = {}
  setmetatable(t, {__call = mock})
  return t
end

love = {}
love.filesystem = {}
love.graphics = {}

love.graphics.newColor = mock
love.graphics.newImage = mock
love.graphics.newParticleSystem = mock

-- code originally from http://lua-users.org/wiki/LuaModulesLoader
local function love_load(path)
  local errmsg = ""
  local real_path = "../love/" .. path
  local file = io.open(real_path, "rb")
  if file then
    -- Compile and return the module
    return assert(loadstring(assert(file:read("*a")), filename))
  end
  return "no love file '"..filename.."' (checked with love_test loader)"
end

-- Install the loader so that it's called just before the normal Lua loader
table.insert(package.loaders, 2, love_load)


love.filesystem.require = function(x)
  require(x)
end
