love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

ProximityMinePowerup = {
  super = SimplePhysicsObject,
  image = love.graphics.newImage("graphics/proximityMineIcon.png"),
  sound = love.audio.newSound("sound/proximityMineCollect.ogg"),
  
  effect = function(self, collector) 
    for k,v in pairs(collector.equipables) do
      if v.name == "ProximityMine" then 
        local m = collector.equipables[k]
        m.ammo = m.ammo + 5 
      end
    end
    if collector == state.game.ship then
      state.game.score = state.game.score + 1000 
      logger:add("You found 5 proximity mines!")
    end
    self.dead = true
  end,
  
  create = function(self,node)
    local body = love.physics.newBody(L.world,node.x,node.y,0.25)
    local shape = love.physics.newRectangleShape(body,1,1)
    local result = SimplePhysicsObject:create(body, shape)
    mixin(result, CollectibleObject:attribute(ProximityMinePowerup.sound, ProximityMinePowerup.effect))
    mixin(result,RepresentableAsImage)
    mixin(result, ProximityMinePowerup)
    result.class = ProximityMinePowerup
    return result
  end
}
