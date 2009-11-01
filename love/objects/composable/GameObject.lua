love.filesystem.require("oo.lua")

GameObject = {
  x = 0,
  y = 0,
  angle = 0,
  dead = false,
  
  
  create = function(self,x,y)
    local result = {}
    mixin(result,GameObject)
    result.class = GameObject
    result.x = x
    result.y = y
    return result
  end,
  
  draw = function(self) end,
  update = function(self, dt) end,
  cleanup = function(self) end,
  
}
