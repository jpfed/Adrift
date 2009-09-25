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
  
  ships = {
  
    getPoints = function(cx,cy,theta)
      local p = math.pi
      
      local tipx, tipy = cx+0.375*math.cos(theta), cy+0.375*math.sin(theta)
      local rightx, righty = cx+0.375*math.cos(theta + 5*p/6), cy+0.375*math.sin(theta + 5*p/6)
      local leftx, lefty = cx+0.375*math.cos(theta - 5*p/6), cy+0.375*math.sin(theta - 5*p/6)
      return tipx, tipy, rightx, righty, leftx, lefty
    end,
  
    controllers = {
      -- friendly (radial keyboard) control
      {
        getAction = function(s,vx,vy,theta,spin)
          local targVx,targVy,targetSpin,isFiring = 0,0,0,false
          if love.keyboard.isDown(love.key_up)  then 
            targVx, targVy = s.thrust*math.cos(theta), s.thrust*math.sin(theta)
          end
          if love.keyboard.isDown(love.key_down)  then 
            targVx, targVy = -s.thrust*math.cos(theta), -s.thrust*math.sin(theta)
          end
          if love.keyboard.isDown(love.key_left)  then 
            targetSpin = -360
          end
          if love.keyboard.isDown(love.key_right)  then 
            targetSpin = 360
          end
          isFiring = love.keyboard.isDown(love.key_f)
          return targVx,targVy,targetSpin,isFiring
        end
      },
      
      -- friendly (eight-directional) control
      {
        getAction = function(s,vx,vy,theta,spin)
          local targVx,targVy,targetSpin,isFiring = vx,vy,0,false
          local targX, targY, turn = 0,0, false
          if love.keyboard.isDown(love.key_up)  then 
            targY, turn = targY-1,true
          end
          if love.keyboard.isDown(love.key_down)  then 
            targY, turn = targY+1,true
          end
          if love.keyboard.isDown(love.key_left)  then 
            targX, turn = targX-1,true
          end
          if love.keyboard.isDown(love.key_right)  then 
            targX, turn = targX+1,true
          end
          targX, targY = geom.normalize(targX, targY)
          local pointingX,pointingY = math.cos(theta), math.sin(theta)
          if turn then
            local cp = geom.crossProduct(pointingX,pointingY,targX,targY)
            if cp > 0 then
              targetSpin = 360
            else
              targetSpin = -360
            end
          end
          local thrust = geom.dotProduct(pointingX,pointingY,targX,targY)
          targVx, targVy = thrust*s.thrust*math.cos(theta), thrust*s.thrust*math.sin(theta)
          isFiring = love.keyboard.isDown(love.key_f)
          return targVx,targVy,targetSpin,isFiring
        end
      },
    },
  
    getShip = function(wld,sx,sy,controllerIndex)
      if controllerIndex == nil then controllerIndex = 2 end
      local controller = objects.ships.controllers[controllerIndex]
      
      local bd = love.physics.newBody(wld,sx,sy)
      local sh = love.physics.newCircleShape(bd,0.375)
      bd:setMass(0,0,1,1)
      bd:setDamping(0.1)
      bd:setAngularDamping(0.1)
      bd:setAllowSleep(false)
      sh:setRestitution(0.125)
      bd:setAngle(180)
      local result = SimplePhysicsObject:create(bd,sh)
      mixin(result, DamageableObject:prepareAttribute(20,nil,love.audio.newSound("sound/hornetDeath.ogg"),0))
      
      local properties = {
        thrust = 10,
        heat = 0,
        coolRate = 1,
        control = controller,
        friendly = (controllerIndex < 3),
        draw = objects.ships.draw,
        update = objects.ships.update,
      }
      mixin(result,properties)
      result.thruster = FireThruster:create(result, 0)
      result.engine = Engine:create(result,result.thrust,2,8)
      
      result.gun = SimpleGun:create(result, 0, 0.5, 90, 5, love.graphics.newColor(0,0,255))
      
      result.hasCrystal = false
      result.circColor = love.graphics.newColor(32,64,128)
      result.triColor = love.graphics.newColor(64,128,255)
      result.cryColor = love.graphics.newColor(255,255,255)
      result.healthColor = love.graphics.newColor(255,255,255)
      result.super = Ship
      result.class = Ship
      
      result.shape:setData(result)
     
      return result
    end,
    
    draw = function(s)
      local wcx, wcy = s.body:getX(), s.body:getY()
      local theta = math.pi*s.body:getAngle()/180 + math.pi/2
      
      local wtipx, wtipy, wrightx, wrighty,wleftx,wlefty = objects.ships.getPoints(wcx,wcy,theta)
      
      local cx, cy, radius = camera:xy(wcx,wcy,0)
      local tipx, tipy = camera:xy(wtipx, wtipy, 0)
      local rightx, righty = camera:xy(wrightx, wrighty, 0)
      local leftx, lefty = camera:xy(wleftx, wlefty, 0)
      
      s.thruster:draw()
      love.graphics.setColor(s.circColor)
      love.graphics.circle(love.draw_fill,cx,cy,0.375*radius,32)
      if s.hasCrystal then 
        love.graphics.setColor(s.cryColor)
      else
        love.graphics.setColor(s.triColor)
      end
      love.graphics.triangle(love.draw_fill,tipx,tipy,rightx,righty,leftx,lefty)
      love.graphics.setColor(s.healthColor)
      love.graphics.rectangle(love.draw_fill,0,590,s.armor*40,10)
      
    end,
    
    update = function(s,dt)
      s.x = s.body:getX()
      s.y = s.body:getY()
      s.angle = s.body:getAngle()

      local vx, vy = s.body:getVelocity()
      local theta = math.rad(s.body:getAngle()+90)
      local spin = s.body:getSpin()
      local targVx, targVy, targetSpin, isFiring = s.control.getAction(s,vx,vy,theta,spin)

      local velRetain = math.exp(-2*dt)
      local velChange = 1-velRetain
      
      s.body:setVelocity(vx * velRetain + targVx * velChange, vy * velRetain + targVy * velChange)

      if targetSpin == 0 then
        local spRetain = math.exp(-8 * dt)
        s.body:setSpin(spin * spRetain)
      else
        s.body:setSpin(targetSpin * dt * 40)
      end
      
      --local overallThrust = s.engine:vector(targVx, targVy, dt)
      
      s.heat = math.max(0,s.heat - dt*s.coolRate)
      
      if isFiring then s.gun:fire() end
      s.gun:update(dt)
      
      local pointX, pointY = math.cos(theta), math.sin(theta)
      s.thruster:setIntensity(geom.dotProduct(targVx-vx,targVy-vy,pointX, pointY)*10)
      s.thruster:update(dt)
    end,
  },
}
