love.filesystem.require("oo.lua")
love.filesystem.require("objects/CollectibleObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

WarpCrystal = {
  super = CollectibleObject,
  image = love.graphics.newImage("graphics/warpCrystal.png"),
  sound = love.audio.newSound("sound/crystal.ogg"),
  
  effect = function(self, collector) 
    collector.hasCrystal = true
    if collector == state.game.ship then state.game.score = state.game.score + 10000 end
  end,
  
  create = function(self,world,node)
    local wcBody = love.physics.newBody(world,node.x,node.y,0.25)
    local wcShape = love.physics.newRectangleShape(wcBody,1,1)
    local result = CollectibleObject:create(wcBody, wcShape, WarpCrystal.sound, WarpCrystal.effect)
    mixin(result,RepresentableAsImage)
    mixin(result, WarpCrystal)
    result.class = WarpCrystal
    return result
  end
}
