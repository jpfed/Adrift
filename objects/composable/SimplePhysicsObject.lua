love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/GameObject.lua")

SimplePhysicsObject = {
  super = GameObject,
  body = nil,
  shape = nil,
  
  create = function(self, bod, shp)
    local result = GameObject:create(bod:getX(),bod:getY())
    mixin(result,SimplePhysicsObject)
    result.class = SimplePhysicsObject
    result.body = bod
    result.shape = shp
    result.shape:setData(result)
    return result 
  end,
  
  update = function(self,dt)
    GameObject.update(self,dt)
    self.x = self.body:getX()
    self.y = self.body:getY()
    self.angle = self.body:getAngle()
  end,
  
  cleanup = function(self)
    GameObject.cleanup(self)
    self.shape:destroy()
    self.body:destroy()
  end
}
