love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimplePhysicsObject.lua")

DamageableObject = {
  super = SimplePhysicsObject,
  armor = 1,
  create = function(d,body,shape,hp, damageSound, deathSound, pointsForDestroying)
    local result = SimplePhysicsObject:create(body,shape)
    mixin(result, DamageableObject)
    result.class = DamageableObject
    result.armor = hp
    result.damageSound = damageSound
    result.deathSound = deathSound
    result.points = pointsForDestroying
    return result
  end,
  
  damage = function(self, amount)
    self.armor = self.armor - amount
    if self.armor > 0 then 
      if self.damageSound ~= nil then love.audio.play(self.damageSound) end
    else
      love.audio.play(self.deathSound)
      self.dead = true
      state.game.score = state.game.score + self.points
    end
  end
  
}
