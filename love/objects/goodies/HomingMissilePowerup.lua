love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("graphics/RepresentableAsImage.lua")

HomingMissilePowerup = {
  super = SimplePhysicsObject,
  image = love.graphics.newImage("graphics/homingMissileIcon.png"),
  sound = love.audio.newSound("sound/homingMissileCollect.ogg"),
  
  effect = function(self, collector) 
    if collector == state.game.ship then
      for k,v in pairs(collector.equipables) do
        if v.name == "HomingMissile" then 
          local h = collector.equipables[k]
          h.ammo = h.ammo + 5 
        end
      end
      state.game.score = state.game.score + 1000 
      logger:add("You found 5 missiles!")
    end
    self.dead = true
  end,
  
  createBody = function(self,node)
    return love.physics.newBody(L.world,node.x,node.y,0.25)
  end,

  createShape = function(self,body)
    return love.physics.newRectangleShape(body,1,1)
  end,

  create = function(self,node)
    local body = self:createBody(node)
    local shape = self:createShape(body)
    local result = SimplePhysicsObject:create(body, shape)
    mixin(result, CollectibleObject:attribute(HomingMissilePowerup.sound, HomingMissilePowerup.effect))
    mixin(result,RepresentableAsImage)
    mixin(result, HomingMissilePowerup)
    result.class = HomingMissilePowerup
    return result
  end
}
