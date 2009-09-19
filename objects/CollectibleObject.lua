love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimplePhysicsObject.lua")

CollectibleObject = {
  super = SimplePhysicsObject,
  sound = {},
  
  
  create = function(self,bod,shp,snd,effectFunc)
    local result = SimplePhysicsObject:create(bod,shp)
    mixin(result,CollectibleObject)
    result.class = CollectibleObject
    result.sound = snd
    result.effect = effectFunc
    printall(result, "CollectibleObject")
    return result
  end,
  
  effect = function(self) end,
  
  collected = function(self, collector)
    love.audio.play(self.sound)
    self:effect(collector)
    self.dead = true
  end
  
}
