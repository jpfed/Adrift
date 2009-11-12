love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

WarpCrystal = {
  super = SimplePhysicsObject,
  image = love.graphics.newImage("graphics/warpCrystal.png"),
  sound = love.audio.newSound("sound/crystal.ogg"),
  
  effect = function(self, collector) 
    collector.hasCrystal = true
    if collector == state.game.ship then 
      state.game.score = state.game.score + 10000 
      logger:add("You found the crystal! Return to the warp portal!")
      L.boom:addDefenders()
    end
    self.dead = true
  end,
  
  create = function(self,node)
    local wcBody = love.physics.newBody(L.world,node.x,node.y,0.25)
    local wcShape = love.physics.newRectangleShape(wcBody,1,1)
    local result = SimplePhysicsObject:create(wcBody, wcShape)
    mixin(result, CollectibleObject:attribute(WarpCrystal.sound, WarpCrystal.effect))
    mixin(result,RepresentableAsImage)
    mixin(result, WarpCrystal)
    result.class = WarpCrystal
    return result
  end
}
