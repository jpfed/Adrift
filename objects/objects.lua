objects = {

  startingSpot = {
    dummy = "dummy"
  },

  getStartingSpot = function(obs,world, node)
    local ssBody = love.physics.newBody(world,node.x,node.y,0)
    local ssShape = love.physics.newCircleShape(ssBody,0.75)
    ssShape:setSensor(true)
    local result = {
      type = objects.startingSpot,
      x = node.x,
      y = node.y,
      image = love.graphics.newImage("graphics/warpPortal.png"),
      body = ssBody,
      shape = ssShape,
      draw = function(o)
        local x,y,scale = camera:xy(o.x,o.y,0)
        love.graphics.draw(o.image,x,y,0,scale/50)
      end,
      update = function(o, dt) end
    }
    result.shape:setData(result)
    logger:add("startingSpot instantiated with type: " .. tostring(result.type))
    return result
  end,

  warpCrystal = {},
  
  getWarpCrystal = function(obs,world, node)
    local wcBody = love.physics.newBody(world,node.x,node.y,0.25)
    local wcShape = love.physics.newRectangleShape(wcBody,1,1)
    logger:add("Crystal located at " .. tostring(node.x) .. ", " .. tostring(node.y))
    local result = {
      type = objects.warpCrystal,
      body = wcBody,
      shape = wcShape,
      image = love.graphics.newImage("graphics/warpCrystal.png"),
      draw = function(o) 
        local x,y,scale = camera:xy(o.x,o.y,0)
        love.graphics.draw(o.image,x,y,0,scale/25)
      end,
      update = function(o, dt) 
        o.x,o.y = o.body:getX(), o.body:getY()
      end,
      cleanup = function(o)
        o.shape:destroy()
        o.body:destroy()
      end
    }
    result.shape:setData(result)
    return result
  end,

  enemies = {
  
  },
  
  getEnemy = function(obs,world, node)
    return objects.ships.getShip(world,node.x,node.y,3)

    -- local result = {
      -- type = objects.enemies,
      -- draw = function(o) 
      -- end,
      -- update = function(o, dt) 
      
      -- end
    -- }
    -- return result
  end,

  powerups = {
  
  },
  
  getPowerup = function(obs,world, node)
    local result = {
      type = objects.powerups,
      draw = function(o) end,
      update = function(o, dt) end
    }
    return result
  end,

  
  weapons = {
    {
      friendlyFire = love.graphics.newColor(0,0,255),
      enemyFire= love.graphics.newColor(255,0,0),
      fire = function(w,s)
        table.insert(state.game.objects,w:getBullet(s))
        s.heat = s.heat + 1
      end,
      
      getBullet = function(w,s)
        local theta = math.pi*s.body:getAngle()/180 + math.pi/2
        local tipx,tipy = objects.ships.getPoints(s.body:getX(),s.body:getY(),theta)
      
        local vx,vy = s.body:getVelocity()
        local mx, my = 12*math.cos(theta), 12*math.sin(theta)
        vx = vx + mx
        vy = vy + my
        local bbody = love.physics.newBody(state.game.world, tipx+mx/60,tipy+my/60,0.01)
        local bshape = love.physics.newCircleShape(bbody, 0.075)
        bbody:setBullet(true)
        bbody:setVelocity(vx,vy)
        bshape:setSensor(true)
        local result = {
          type = objects.weapons,
          body = bbody,
          shape = bshape,
          firer = s,
          draw = objects.weapons[1].draw,
          update = objects.weapons[1].update,
          cleanup = objects.weapons[1].cleanup
        }
        if s.friendly then result.color = w.friendlyFire else result.color = w.enemyFire end
        result.shape:setData(result)
        if s.friendly then logger:add("sx,sy,vx,vy" .. " " .. tostring(s.body:getX()) .. " " .. tostring(s.body:getY()) .. " " .. tostring(vx) .. " " .. tostring(vy)) end
        return result
      end,
      
      draw = function(b) 
        local x,y,scale = camera:xy(b.body:getX(),b.body:getY(),0)
        love.graphics.setColor(b.color)
        love.graphics.circle(love.draw_fill,x,y,scale*0.075)
      end,
      
      update = function(b,dt)  end,
      cleanup = function(b) 
        b.shape:destroy()
        b.body:destroy()
      end
    },
  },
  
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
          local targVx,targVy,targetSpin,isFiring = vx,vy,0,false
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
            if s.collisionShock > 0 then targetTheta = targetTheta + s.collisionReaction*math.pi/2 end
            local pointingX,pointingY = math.cos(theta), math.sin(theta)
            local wantX, wantY = math.cos(targetTheta), math.sin(targetTheta)
            local cp = pointingX*wantY - pointingY*wantX
            if cp > 0 then
              targetSpin = 360
            else
              targetSpin = -360
            end
            targVx, targVy = s.thrust*(1-2*s.collisionShock)*math.cos(theta),s.thrust*(1-2*s.collisionShock)*math.sin(theta)
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
      
      logger:add("Ship located at " .. tostring(sx) .. ", " .. tostring(sy))
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
      local result = {
        type = objects.ships,
        body = bd,
        shape = sh,
        weapons = {objects.weapons[1]},
        activeWeapon = objects.weapons[1],
        armor = state.game.difficulty,
        hasCrystal = false,
        thrust = 10,
        heat = 0,
        coolRate = 1,
        draw = objects.ships.draw,
        control = controller,
        friendly = (controllerIndex < 3),
        update = objects.ships.update,
        cleanup = objects.ships.cleanup,
        circColor = love.graphics.newColor(32,64,128),
        triColor = love.graphics.newColor(64,128,255),
        cryColor = love.graphics.newColor(255,255,255),
        healthColor = love.graphics.newColor(255,255,255),
        enemyColor = love.graphics.newColor(255,0,0),
        collisionShock = 0,
        collisionReaction = 1
      }
      result.collisionReaction = math.random(2)*2-3
      if result.friendly then 
        result.armor = 20 
        result.coolRate = 5
      else
        sh:setRestitution(1.5)
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
    
    if s.armor <=0 and not s.friendly then s.dead = true end
    
      local spRetain = math.exp(-8*dt)
      local spChange = 1-spRetain
      
      local velRetain = math.exp(-2*dt)
      local velChange = 1-velRetain
    
      local theta = math.pi*s.body:getAngle()/180 + math.pi/2
      
      local vx, vy = s.body:getVelocity()
      local spin = s.body:getSpin()
      
      local targVx, targVy, targetSpin,isFiring = s.control.getAction(s,vx,vy,theta,spin)
      
      s.body:setSpin(spin * spRetain + targetSpin * spChange)
      s.body:setVelocity(vx * velRetain + targVx * velChange, vy * velRetain + targVy * velChange)
      
      s.heat = math.max(0,s.heat - dt*s.coolRate)
      
      if isFiring and s.heat == 0 then 
        s.activeWeapon:fire(s)
      end
      
    end,
    cleanup = function(s)
      s.shape:destroy()
      s.body:destroy()
    end
  },
}