love.filesystem.require("oo.lua")
love.filesystem.require("objects/CollectibleObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

EnergyPowerup = {
  super = CollectibleObject,
  image = love.graphics.newImage("graphics/energyPowerup.png"),
  sound = love.audio.newSound("sound/energyPowerup.ogg"),
  
  effect = function(self) 
    state.game.ship.armor = state.game.ship.armor + 1
    state.game.score = state.game.score + 100
  end,
  
  create = function(self,world,node)
    local epBody = love.physics.newBody(world,node.x,node.y,0.25)
    local epShape = love.physics.newRectangleShape(epBody,0.5,0.5)
    local result = CollectibleObject:create(epBody, epShape, EnergyPowerup.sound, EnergyPowerup.effect)
    mixin(result,RepresentableAsImage)
    mixin(result, EnergyPowerup)
    result.imageSize = 2
    result.class = EnergyPowerup
    return result
  end
}
