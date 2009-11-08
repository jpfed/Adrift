love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/Convex.lua")
love.filesystem.require("objects/HomingMissile.lua")
love.filesystem.require("objects/goodies/ArmorPowerup.lua")

Turret = {
  super = SimplePhysicsObject,
  
  cvx = nil,
    lineColor = love.graphics.newColor(128,64,128),
    fillColor = love.graphics.newColor(64,64,64),
    
  deathSound = love.audio.newSound("sound/hornetDeath.ogg"),
    
  bulletColor = love.graphics.newColor(128,64,128),
  missileTrailColor = love.graphics.newColor(230,220,220,220),
  
  create = function(self, x, y, difficulty)
    local bd = love.physics.newBody(L.world,x,y,1)
    bd:setMass(0,0,4,1)
    bd:setDamping(0.01)
    bd:setAngularDamping(0.01)
    bd:setAllowSleep(false)
    bd:setAngle(180)
    
    local result = SimplePhysicsObject:create(bd)
    
    mixin(result,DamageableObject:attribute(difficulty,nil,Turret.deathSound, 1000))
    
    mixin(result,Turret)
    result.class = Turret
    
    
    local s = 0.4
    local pointArray = {2*s,0*s, 2*s,2*s, 0*s,3*s, -2*s,2*s, -2*s,-0*s}
 
    result.cvx = Convex:create(result, pointArray, self.lineColor, self.fillColor)


    result.gun = SimpleGun:create({
      parent = result,
      ammo = 100,
      mountX = 0,
      mountY = 3.2*s,
      mountAngle = math.pi/2,
      shotsPerSecond = 0.5,
      spawnProjectile = function(self, params)
        -- TODO: set self.mountAngle to a sensible angle?
        love.audio.play(HomingMissile.fireSound)
        local target = state.game.ship
        return HomingMissile:create(self.parent, target, params, result.bulletColor, result.missileTrailColor)
      end
    })

    return result
  end,
  
  update = function(self, dt)
    SimplePhysicsObject.update(self, dt)
    local dist = geom.distance_t(self, state.game.ship)
    if dist <= 30 then
      self.gun:fire()
    end
    self.gun:update(dt)
  end,
  
  draw = function(self)
    self.cvx:draw()
  end,
  
  cleanup = function(self)
    self.cvx:cleanup()
    SimplePhysicsObject.cleanup(self)
    -- TODO: drop missiles maybe!
    if math.random() < 0.25 then L:addObject(ArmorPowerup:create(self)) end
  end
}

