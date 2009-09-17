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
    printall(result, "GameObject")
    return result
  end,
  
  draw = function(self) end,
  update = function(self, dt) end,
  cleanup = function(self)
    for k,v in ipairs(self) do
      if v.cleanup ~= nil then v:cleanup() end
    end
  end,
  
}
