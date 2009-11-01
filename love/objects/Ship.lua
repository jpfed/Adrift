love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")
love.filesystem.require("objects/composable/Power.lua")
love.filesystem.require("objects/ControlSchemes.lua")
love.filesystem.require("objects/SimpleBullet.lua")
love.filesystem.require("objects/HomingMissile.lua")
love.filesystem.require("objects/ProximityMine.lua")

Ship = {
  super = SimplePhysicsObject,
  
  thrust = 10,

  cvx = nil,
  thruster = nil,
  engine = nil,
  controller = nil,
  
  equipables = nil,
  bulletColor = love.graphics.newColor(0,0,255),
  bulletHighlightColor = love.graphics.newColor(100,100,255,200),
  missileTrailColor = love.graphics.newColor(220,220,230,220),
  
  
  circColor = love.graphics.newColor(32,64,128),
  triColor = love.graphics.newColor(64,128,255),
  cryColor = love.graphics.newColor(255,255,255),
  healthColor = love.graphics.newColor(255,255,255),
  currentWeaponColor = love.graphics.newColor(255,255,255),
  otherWeaponColor = love.graphics.newColor(255,255,255,64),
  
  hasCrystal = false,
  hasFieldDetector = false,
  
  create = function(self, x, y, controlSchemeNumber)
    local bd = love.physics.newBody(L.world,x,y)
    local sh = love.physics.newCircleShape(bd,0.375)
    bd:setMass(0,0,1,1)
    bd:setDamping(0.1)
    bd:setAngularDamping(0.1)
    bd:setAllowSleep(false)
    sh:setRestitution(0.125)
    bd:setAngle(0)
    
    local result = SimplePhysicsObject:create(bd,sh)
    mixin(result, DamageableObject:attribute(20,nil,love.audio.newSound("sound/hornetDeath.ogg"),0))
    mixin(result, Ship)
    result.class = Ship
    
    result.thruster = FireThruster:create(result, 180)
    result.engine = Engine:create(result,Ship.thrust,2,12)
    
    result.controller = ControlSchemes[controlSchemeNumber]
    if result.controller.directional then result.engine.turnRate = 32 end
    
    result.equipables = {}
    
    table.insert(result.equipables, SimpleGun:create({
      parent = result,
      ammo = math.huge,
      mountX = 0.5,
      mountY = 0,
      mountAngle = 0,
      shotsPerSecond = 4,
      name = "SimpleBullet",
      icon = love.graphics.newImage("graphics/simpleBulletIcon.png"),
      spawnProjectile = function(self, params)
        self.ammo = self.ammo + 1
        return SimpleBullet:create(self.parent, params, result.bulletColor, result.bulletHighlightColor)
      end
    }))
    
    table.insert(result.equipables, SimpleGun:create({
      parent = result,
      ammo = 0,
      mountX = 0.5,
      mountY = 0,
      mountAngle = 0,
      shotsPerSecond = 1,
      name = "HomingMissile",
      icon = love.graphics.newImage("graphics/homingMissileIcon.png"),
      spawnProjectile = function(self, params)
        local bestEnemy, bestDistance = nil, math.huge
        for k, v in pairs(L.objects) do
          if AhasAttributeB(v, DamageableObject) then
            local dist = geom.distance_t(self.parent, v)
            if dist < bestDistance then
              bestDistance = dist
              bestEnemy = v
            end
          end
        end
        
        love.audio.play(HomingMissile.fireSound)
        local target = bestEnemy
        return HomingMissile:create(self.parent, target, params, result.bulletColor, result.missileTrailColor)
      end
    }))

    table.insert(result.equipables, SimpleGun:create({
      parent = result,
      ammo = 0,
      mountX = -0.7,
      mountY = 0,
      mountAngle = 180,
      shotsPerSecond = 1,
      name = "ProximityMine",
      icon = love.graphics.newImage("graphics/proximityMineIcon.png"),
      spawnProjectile = function(self, params)
        love.audio.play(ProximityMine.placeSound)
        return ProximityMine:create(self.parent, params, result.bulletColor)
      end
    }))
    
    result.currentWeapon = 1
    
    local s = 0.375
    local pointArray = {1*s,0*s, s*math.cos(math.pi*5/6),s*math.sin(math.pi*5/6), s*math.cos(math.pi*7/6),s*math.sin(math.pi*7/6)}
    result.cvx = Convex:create(result, pointArray, Ship.triColor, Ship.triColor)
    
    result.powers = {
      boost = BoostPower:create(result),
      sidestep = SidestepPower:create(result),
      teleport = TeleportPower:create(result)
    }

    return result
  end,

  -- takes an existing ship and puts it, otherwise unchanged, into a new physics world at a new location.
  warp = function(self, world, x, y)
    self.hasCrystal = false
    local bd = love.physics.newBody(world,x,y)
    local sh = love.physics.newCircleShape(bd,0.375)
    bd:setMass(0,0,1,1)
    bd:setDamping(0.1)
    bd:setAngularDamping(0.1)
    bd:setAllowSleep(false)
    sh:setRestitution(0.125)
    bd:setAngle(0)
    
    self.body = bd
    self.shape = sh
    self.shape:setData(self)
  end,
  
  draw = function(self)
    self.thruster:draw()

    love.graphics.setColor(self.circColor)
    local cx, cy, radius = L:xy(self.x,self.y,0)
    love.graphics.circle(love.draw_fill,cx,cy,0.375*radius,32)
    
    if self.hasCrystal then 
      self.cvx.fillColor = Ship.cryColor
    else
      self.cvx.fillColor = Ship.triColor
    end
    self.cvx:draw()

    for k,power in pairs(self.powers) do
      power:draw()
    end
    
    self:drawHUD()
  end,
  
  drawHUD = function(self)
    if state.current == state.game then
      love.graphics.setColor(self.healthColor)
      love.graphics.rectangle(love.draw_fill,100,590, 700 * self.armor / self.maxArmor,10)
      love.graphics.draw("HP: " .. tostring(self.armor) .. " / " .. tostring(self.maxArmor), 15,598)
      
      for k = 1, #(self.equipables) do
        local x, y = 30*k - 15, 525
        local e = self.equipables[k]
        
        if e.ammo > 0 then
          local img = e.icon
          local w, h = img:getWidth(), img:getHeight()
          love.graphics.draw(img, x+w/2, y+h/2, 0, 25/w)
          
          love.graphics.setColor(0,0,0,math.min(255,math.max(64,math.ceil(255/e.shotsPerSecond))))
          local heat = e.heat
          love.graphics.rectangle(love.draw_fill, x, y + h*(1-heat), 25, h*heat)
        end
        
        if k == self.currentWeapon then
          love.graphics.setColor(self.currentWeaponColor)
        else
          love.graphics.setColor(self.otherWeaponColor)
        end
        local a = self.equipables[k].ammo
        if a == math.huge then a = "--" end
        love.graphics.draw(tostring(a),x,y)
        love.graphics.rectangle(love.draw_line,x,y,25,25)
      end
      
    end
  end,
  
  update = function(self, dt)
    SimplePhysicsObject.update(self,dt)

    for k,power in pairs(self.powers) do
      power:update(dt)
    end
  
    local targVx, targVy, isFiring, isMod1 = self.controller:getAction(self,dt)
    local normVx, normVy = geom.normalize(targVx, targVy)
    local angle = math.rad(self.angle)
    local angX, angY = math.cos(angle), math.sin(angle)
    if normX == 0 and normY == 0 then normX, normY = angX, angY end
    local applyThrust = true
    if isMod1 then
      local forward = geom.dot_product(normVx, normVy, angX, angY) > 0.7
      local left = geom.dot_product(normVx, normVy, angY, -angX) > 0.7
      local right = geom.dot_product(normVx, normVy, -angY, angX) > 0.7
      local back = geom.dot_product(normVx, normVy, angX, angY) < -0.7
      
      if forward then self.powers.boost:trigger() end
      
      if left then 
        applyThrust = false
        self.powers.sidestep.orientation = -1
        self.powers.sidestep:trigger()
      end
      
      if right then
        applyThrust = false
        self.powers.sidestep.orientation = 1
        self.powers.sidestep:trigger()
      end
      if back and self.hasTeleport then
        applyThrust = false
        self.powers.teleport:trigger()
      end
    end
    
    if applyThrust then
      local overallThrust = self.engine:vector(targVx, targVy, dt)
      self.thruster:setIntensity(overallThrust*7.5)
    end
    self.thruster:update(dt)
  
    if self.equipables[self.currentWeapon].ammo == 0 then self:switchWeapons() end
    if isFiring then self.equipables[self.currentWeapon]:fire() end
    for k,v in pairs(self.equipables) do 
      v:update(dt)
    end
  end,
  
  switchWeapons = function(self)
    self.currentWeapon = self.currentWeapon % #(self.equipables) + 1
  end
}

