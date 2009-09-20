love.filesystem.require("util/geom.lua")
love.filesystem.require("objects/WarpCrystal.lua")
love.filesystem.require("objects/WarpPortal.lua")
love.filesystem.require("objects/EnergyPowerup.lua")
love.filesystem.require("objects/SimpleBullet.lua")
love.filesystem.require("objects/DamageableObject.lua")
love.filesystem.require("objects/Thruster.lua")
love.filesystem.require("objects/Ship.lua")
love.filesystem.require("objects/Hornet.lua")


objects = {
  
  getStartingSpot = function(obs,world, node)
    return WarpPortal:create(world, node)
  end,
  
  getWarpCrystal = function(obs,world, node)
    return WarpCrystal:create(world,node)
  end,

  getEnemy = function(obs,world, node)
    return objects.ships.getShip(world,node.x,node.y,3)
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
      
      -- enemy control
      {
        getAction = function(s,vx,vy,theta,spin)
          local targVx, targVy, targetSpin, isFiring = math.random(3)-2 - vx,math.random(3)-2 - vy,0,false
          local target = state.game.ship
          local targetSpin = 0
          if target ~= nil and geom.distance(s.body:getX(),s.body:getY(),target.body:getX(),target.body:getY()) < camera.width then
            local targetTheta = math.atan2(target.body:getY() - s.body:getY(), target.body:getX() - s.body:getX())
            if s.collisionShock > 0 then targetTheta = targetTheta + s.collisionReaction * 3*math.pi/4 end
            local pointingX,pointingY = math.cos(theta), math.sin(theta)
            local wantX, wantY = math.cos(targetTheta), math.sin(targetTheta)
            local cp = pointingX*wantY - pointingY*wantX
            if cp > 0 then
              targetSpin = 360
            else
              targetSpin = -360
            end
            targVx, targVy = s.thrust*math.cos(theta),s.thrust*math.sin(theta)
            s.collisionShock = math.max(0,s.collisionShock - 1/60)
            isFiring = true
            for k,v in ipairs(state.game.objects) do
              if v.type==objects.ships then
                if not v.friendly and not v==s then
                  local firingFrom = {x = s.body:getX(),y=s.body:getY()}
                  local firingTowards = {x = firingFrom.x + math.cos(theta), y= firingFrom.y + math.sin(theta)}
                  local distToHit = geom.distToLine({x = v.body:getX(),y=v.body:getY()},firingFrom,firingTowards)
                  if distToHit < 1 then isFiring = false end
                end
              end
            end
          end
          return targVx, targVy, targetSpin, isFiring
        end
      },
    },
  
    getShip = function(wld,sx,sy,controllerIndex)
      if controllerIndex == nil then controllerIndex = 2 end
      local controller = objects.ships.controllers[controllerIndex]
      
      local bd = love.physics.newBody(wld,sx,sy)
      local sh
      if controllerIndex < 3 then
        sh = love.physics.newCircleShape(bd,0.375)
        bd:setMass(0,0,1,1)
      else
        local tipx,tipy,rightx,righty,leftx,lefty = objects.ships.getPoints(0,0,math.pi/2)
        sh = love.physics.newPolygonShape(bd,tipx,tipy,rightx,righty,leftx,lefty)
        bd:setMass(0,0,0.5,0.5)
      end
      bd:setDamping(0.1)
      bd:setAngularDamping(0.1)
      bd:setAllowSleep(false)
      sh:setRestitution(0.125)
      bd:setAngle(180)
      local result = DamageableObject:create(bd,sh,state.game.difficulty,nil,love.audio.newSound("sound/hornetDeath.ogg"),1000)
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
      result.thruster = FireThruster:create(result, 90)

      if result.friendly then 
        result.hasCrystal = false
        result.circColor = love.graphics.newColor(32,64,128)
        result.triColor = love.graphics.newColor(64,128,255)
        result.cryColor = love.graphics.newColor(255,255,255)
        result.healthColor = love.graphics.newColor(255,255,255)
        result.armor = 20 
        result.coolRate = 5
        result.super = Ship
        result.class = Ship
      else
        result.enemyColor = love.graphics.newColor(255,0,0)
        result.collisionShock = 0
        result.collisionReaction = math.random(2)*2-3
        sh:setRestitution(1.5)
        result.super = Hornet
        result.class = Hornet
      end
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
      if s.friendly then
        love.graphics.setColor(s.circColor)
        love.graphics.circle(love.draw_fill,cx,cy,0.375*radius,32)
        if s.hasCrystal then 
          love.graphics.setColor(s.cryColor)
        else
          love.graphics.setColor(s.triColor)
        end
      else
        love.graphics.setColor(s.enemyColor)
      end
      love.graphics.triangle(love.draw_fill,tipx,tipy,rightx,righty,leftx,lefty)
      if s.friendly then 
        love.graphics.setColor(s.healthColor)
        love.graphics.rectangle(love.draw_fill,0,590,s.armor*40,10)
      end
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
      
      s.heat = math.max(0,s.heat - dt*s.coolRate)
      
      if isFiring and s.heat == 0 then 
        local bulletColor
        if s.friendly then bulletColor = love.graphics.newColor(0,0,255)
        else bulletColor = love.graphics.newColor(255,0,0) end
        
        local tipx, tipy = objects.ships.getPoints(s.x,s.y,theta)
        
        local bullet = SimpleBullet:create(s,{x=tipx,y=tipy},bulletColor)
        table.insert(state.game.objects,bullet)
        s.heat = s.heat + bullet.heat
      end
      
      local pointX, pointY = math.cos(theta), math.sin(theta)
      s.thruster:setIntensity(geom.dotProduct(targVx-vx,targVy-vy,pointX, pointY)*10)
      s.thruster:update(dt)
    end,
  },
}
