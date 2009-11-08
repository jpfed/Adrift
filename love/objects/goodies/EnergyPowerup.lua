love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

EnergyPowerup = {
  super = SimplePhysicsObject,
  image = love.graphics.newImage("graphics/HpPlus.png"),
  sound = love.audio.newSound("sound/HpPlus.ogg"),
  
  effect = function(self, collector) 
    if kindOf(collector, DamageableObject) then
      collector.armor = math.min(collector.maxArmor, collector.armor + 1)
      if collector == state.game.ship then state.game.score = state.game.score + 100 end
      self.dead = true
    end
  end,
  
  create = function(self,node)
    local epBody = love.physics.newBody(L.world,node.x,node.y,0.25)
    local epShape = love.physics.newRectangleShape(epBody,0.5,0.5)
    local result = SimplePhysicsObject:create(epBody, epShape)
    mixin(result, CollectibleObject:attribute(EnergyPowerup.sound, EnergyPowerup.effect))
    mixin(result, RepresentableAsImage)
    mixin(result, EnergyPowerup)
    result.imageSize = 2
    result.class = EnergyPowerup
    return result
  end
}
