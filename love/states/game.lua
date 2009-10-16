love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("objects/goodies/WarpPortal.lua")

state.game = {
  
  spColor = love.graphics.newColor(0,0,255),
  wcColor = love.graphics.newColor(255,0,0),
  scoreColor = love.graphics.newColor(255,255,255),
  normalArcColor = love.graphics.newColor(128,128,128),
  normalNodeColor = love.graphics.newColor(255,255,255),
  objects = {},
  score = 0,
  
  load = function(s)
    state.current = state.game
    s.levelNumber = 0
    s.difficulty = state.options.difficulty
    s.score = 0
    s.ship = nil
    s:startNewLevel()
    
  end,
  
  enqueueNextLevel = function(s)
    s.waitingForNewLevel = true
  end,
  
  startNewLevel = function(s)
    s.waitingForNewLevel = false
    s.levelNumber = s.levelNumber + 1
    s.world = love.physics.newWorld(-1,-1,Level.maxCol+1,Level.maxRow+1,0,1, true)
    s.world:setCallback(state.game.collision)
    s.level = Level:create(s.difficulty*10 + s.levelNumber, 1, true)
    s.background = Level:create(s.difficulty*10 + s.levelNumber, 0.25)
    s.level:solidify(s.world)
    
    -- TODO: move these into the level proper
    -- TODO: move world into the level also?
    s.objects = s.level:generateObjects(s.difficulty*10)
    
    if s.ship == nil then
      s.ship = Ship:create(s.world, s.level.nodes[1].x, s.level.nodes[1].y, state.options.controlScheme)
    else
      s.ship:cleanup()
      s.ship:warp(s.world, s.level.nodes[1].x, s.level.nodes[1].y)
    end
    
    camera.x = s.ship.body:getX()
    camera.y = s.ship.body:getY()
  end,
  
  update = function(s,dt) 
    if s.waitingForNewLevel then
      s:startNewLevel()
    else
      s.ship:update(dt)
      if s.ship.armor <= 0 then
      state.current = state.loss
      state.loss.ct = 0
      end
      for k,v in ipairs(s.objects) do
        v:update(dt)
      end

      if s.ship ~= nil then
        camera.x = camera.x * 0.75 + s.ship.body:getX() * 0.25
        camera.y = camera.y * 0.75 + s.ship.body:getY() * 0.25
      end
      
      s.world:update(dt)
      s:collectGarbage(s.waitingForNewLevel)
    end
    
  end,
  
  collectGarbage = function(s,newLevel)
    if newLevel then 
      s.objects = {} 
    else
      repeat
        local found = false
        local objectsToKeep = {}
        for k,v in ipairs(s.objects) do
          if v.dead then 
            found = true
            if v.cleanup ~= nil then v:cleanup() end
          else
            table.insert(objectsToKeep, v) 
          end
        end
        s.objects = objectsToKeep
      until not found
    end
  end,
  
  draw = function(s) 
    if not s.waitingForNextLevel then
      camera:render(s.background.tiles, 12, s.background.colors)
      camera:render(s.level.tiles, 0, s.level.colors)
      for k,v in ipairs(s.objects) do
        v:draw()
      end
      love.graphics.setColor(s.scoreColor)
      if state.current == state.game then love.graphics.draw("Score: " .. tostring(s.score),15,580) end
      s.ship:draw()
    end
  end,
  
  mousepressed = function(s,x,y,button) 
  
  end,
  
  keypressed = function(s,key) 
    if key==love.key_p then state.current = state.pause end
    if key==love.key_v then s.ship.hasCrystal = true end
    if key==love.key_x then
      -- DAN'S EXPLOSION TESTER
      local explosion = FireyExplosion:create(s.ship.x,s.ship.y,60,3.0)
      table.insert(state.game.objects,explosion)
    end
  end,
  
  joystickpressed = function(s,j,b)
    if b == 2 then state.current = state.pause end
  end,
  
  collision = function(a,b,c)
    if tryCollideInteraction(a, b,
      function(maybeDead) return a == nil or a.dead end,
      function(anythingElse) return true end,
      function(maybeDead, anythingElse) end
    ) then return end
  
    if tryCollideInteraction( a, b,
      function(maybeWall) return maybeWall == 0 end,
      function(maybeHornet) return AisInstanceOfB(maybeHornet, Hornet) end,
      function(wall, hornet) hornet.collisionShock = 1 end
    ) then return end

    if tryCollideInteraction( a, b,
      function(maybeProjectile) return AisInstanceOfB(maybeProjectile,Projectile) end,
      function(maybeDamageable) return AhasAttributeB(maybeDamageable, DamageableObject) end,
      function(projectile, damageable) projectile:strike(damageable) end
    ) then return end
    
    if tryCollideInteraction( a, b,
      function(maybeProjectile) return AisInstanceOfB(maybeProjectile,Projectile) end,
      function(whatever) return whatever ~= nil end,
      function(projectile, whatever) projectile.dead = true end
    ) then return end
    
    if tryCollideInteraction( a, b,
      function(maybeEel) return AisInstanceOfB(maybeEel, Eel) end,
      function(maybeShip) return AisInstanceOfB(maybeShip, Ship) end,
      function(eel, ship) eel:shock(ship) end    
    ) then return end
    
    -- let the ship collect things
    if tryCollideInteraction( a, b,
      function(maybeCollectible) return AisInstanceOfB(maybeCollectible,CollectibleObject) end, 
      function(maybeShip) return AisInstanceOfB(maybeShip, Ship) end, 
      function(collectible, ship) collectible:collected(ship) end
    ) then return end
    
    -- check if they just finished the level
    if tryCollideInteraction( a, b,
      function(maybePortal) return AisInstanceOfB(maybePortal, WarpPortal) end,
      function(maybeShip) return AisInstanceOfB(maybeShip, Ship) and maybeShip.hasCrystal end,
      function(portal, ship) love.audio.play(portal.sound); state.current = state.victory end
    ) then return end
    
  end
}

tryCollide = function(object1, object2, predicate1, predicate2, consequence1, consequence2)
  if predicate1(object1) and predicate2(object2) then
    consequence1(object1)
    consequence2(object2)
    return true
  elseif predicate1(object2) and predicate2(object1) then
    consequence1(object2)
    consequence2(object1)
    return true
  end
  return false
end

tryCollideInteraction = function(object1, object2, predicate1, predicate2, interaction)
  if predicate1(object1) and predicate2(object2) then
    interaction(object1, object2)
    return true
  elseif predicate1(object2) and predicate2(object1) then
    interaction(object2, object1)
    return true
  end
  return false
end
