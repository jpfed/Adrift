love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

MaxEnergyPowerup = {
  super = SimplePhysicsObject,
  image = love.graphics.newImage("graphics/MaxHpPlus.png"),
  sound = love.audio.newSound("sound/MaxHpPlus.ogg"),
  
  effect = function(self, collector) 
    if kindOf(collector, DamageableObject) then
      collector.maxArmor = collector.maxArmor + 1
      collector.armor = math.min(collector.maxArmor, collector.armor + 2)
      if collector == state.game.ship then 
        state.game.score = state.game.score + 500 
        logger:add("Max HP increased to " ..  tostring(collector.maxArmor) .. "!")  
      end
    end
    self.dead = true
  end,
  
  create = function(self,node)
    local epBody = love.physics.newBody(L.world,node.x,node.y,0.25)
    local epShape = love.physics.newRectangleShape(epBody,0.5,0.5)
    local result = SimplePhysicsObject:create(epBody, epShape)
    mixin(result, CollectibleObject:attribute(MaxEnergyPowerup.sound, MaxEnergyPowerup.effect))
    mixin(result,RepresentableAsImage)
    result.imageSize = 2
    mixin(result, MaxEnergyPowerup)
    result.class = MaxEnergyPowerup
    return result
  end
}
