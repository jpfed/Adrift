love.filesystem.require("util/geom.lua")
love.filesystem.require("objects/goodies/WarpCrystal.lua")
love.filesystem.require("objects/goodies/WarpPortal.lua")
love.filesystem.require("objects/goodies/EnergyPowerup.lua")
love.filesystem.require("objects/goodies/MaxEnergyPowerup.lua")
love.filesystem.require("objects/goodies/TeleportPowerup.lua")
love.filesystem.require("objects/goodies/BoosterPowerup.lua")
love.filesystem.require("objects/goodies/HomingMissilePowerup.lua")
love.filesystem.require("objects/goodies/ProximityMinePowerup.lua")
love.filesystem.require("objects/goodies/MineralChunk.lua")
love.filesystem.require("objects/SimpleBullet.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/Thruster.lua")
love.filesystem.require("objects/Ship.lua")
love.filesystem.require("objects/enemies/Hornet.lua")
love.filesystem.require("objects/enemies/Eel.lua")
love.filesystem.require("objects/enemies/HornetEgg.lua")
love.filesystem.require("objects/enemies/Leech.lua")
love.filesystem.require("objects/enemies/Grasshopper.lua")
love.filesystem.require("objects/enemies/Turret.lua")
love.filesystem.require("objects/enemies/Bomber.lua")

objects = {
  
  getStartingSpot = function(obs, node)
    return WarpPortal:create(node)
  end,
  
  getWarpCrystal = function(obs, node)
    return WarpCrystal:create(node)
  end,

  getEnemy = function(obs, node, difficulty)
    local r = math.random()
    if r<0.2 then return Hornet:create(node.x, node.y, difficulty) end 
    if r<0.4 then return HornetEgg:create(node.x, node.y, difficulty) end
    -- TODO: this should create it starting on the ground or attached to a wall somehow
    if r<0.5 then return Turret:create(node.x, node.y, difficulty) end
    if r<0.7 then return Bomber:create(node.x, node.y, difficulty) end
    return Eel:create(node.x,node.y, difficulty)
  end,

  getCreature = function(obs, node, difficulty)
    return Grasshopper:create(node.x + 0.1, node.y, difficulty)
  end,

  getPowerup = function(obs,node)
    local r = math.random()
    if r<0.05 then return TeleportPowerup:create(node) end
    if r<0.15 then return BoosterPowerup:create(node) end
    if r<0.3 then return MaxEnergyPowerup:create(node) end
    if r<0.4 then return ProximityMinePowerup:create(node) end
    if r<0.5 then return HomingMissilePowerup:create(node) end
    if r<0.75 then return MineralChunk:create(node) end
    return EnergyPowerup:create(node)
  end,
  
}
