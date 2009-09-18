love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimplePhysicsObject.lua")

Projectile = {
  super = SimplePhysicsObject,
  damage = 1,
  heat = 1,
  strikeSound = nil,
  
  
  strike = function(p,s) 
    s.armor = s.armor - p.damage 
    if p.strikeSound ~= nil then love.audio.play(p.strikeSound) end
    p.dead = true
  end,
  
  create = function(P,bod,shp,sound)
    local result = SimplePhysicsObject:create(bod,shp)
    mixin(result, Projectile)
    result.class = Projectile
    result.strikeSound = sound
    return result
  end
}
