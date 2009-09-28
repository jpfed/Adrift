love.filesystem.require("util/geom.lua")
love.filesystem.require("objects/goodies/WarpCrystal.lua")
love.filesystem.require("objects/goodies/WarpPortal.lua")
love.filesystem.require("objects/goodies/EnergyPowerup.lua")
love.filesystem.require("objects/SimpleBullet.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/Thruster.lua")
love.filesystem.require("objects/Ship.lua")
love.filesystem.require("objects/enemies/Hornet.lua")
love.filesystem.require("objects/enemies/Eel.lua")

objects = {
  
  getStartingSpot = function(obs,world, node)
    return WarpPortal:create(world, node)
  end,
  
  getWarpCrystal = function(obs,world, node)
    return WarpCrystal:create(world,node)
  end,

  getEnemy = function(obs,world, node)
    if math.random(2)==2 then return Hornet:create(world, node.x, node.y, state.game.difficulty) end --objects.ships.getShip(world,node.x,node.y,3) end
    return Eel:create(world,node.x,node.y, 3)
  end,

  getPowerup = function(obs,world, node)
    return EnergyPowerup:create(world,node)
  end,
  
}
