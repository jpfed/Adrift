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
    if shp ~= nil then
      result.shape = shp
      result.shape:setData(result)
    end
    return result 
  end,
  
  update = function(self,dt)
    GameObject.update(self,dt)
    self.body:setSleep(false)
    self.x = self.body:getX()
    self.y = self.body:getY()
    self.angle = self.body:getAngle()
  end,
  
  cleanup = function(self)
    GameObject.cleanup(self)
    if self.shape ~= nil then
      self.shape:setSensor(true)
      self.shape:setData(nil)
      self.shape:destroy()
      self.shape = nil
    end
    self.body:destroy()
    self.body = nil
  end
}
