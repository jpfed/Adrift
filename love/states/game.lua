love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/DamageableObject.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")
love.filesystem.require("objects/goodies/WarpPortal.lua")
love.filesystem.require("objects/goodies/MineralChunk.lua")

state.game = {
  
  spColor = love.graphics.newColor(0,0,255),
  wcColor = love.graphics.newColor(255,0,0),
  scoreColor = love.graphics.newColor(255,255,255),
  normalArcColor = love.graphics.newColor(128,128,128),
  normalNodeColor = love.graphics.newColor(255,255,255),
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
    s.background = Level:create(s.difficulty*10 + s.levelNumber, 0.25)
    L = Level:create(s.difficulty*10 + s.levelNumber, 1, true)
    s.level = L
    L:solidify()
    L:generateObjects(s.difficulty)
    
    if s.ship == nil then
      s.ship = Ship:create(L.nodes[1].x, L.nodes[1].y, state.options.controlScheme)
    else
      s.ship:cleanup()
      s.ship:warp(L.world, L.nodes[1].x, L.nodes[1].y)
    end
    
    L.camera.idealX = s.ship.body:getX()
    L.camera.idealY = s.ship.body:getY()
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
      s.level:update(dt)
    end
    
  end,
  
  draw = function(s) 
    if not s.waitingForNextLevel then
      s.background:draw(12)
      s.level:draw(0)
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
    if key==love.key_e then
      table.insert(L.objects, HornetEgg:create(s.ship.x, s.ship.y, state.game.difficulty)) 
    end
    if key==love.key_h then
      table.insert(L.objects, Hornet:create(s.ship.x, s.ship.y, state.game.difficulty)) 
    end
    if key==love.key_t then
      table.insert(L.objects, Turret:create(s.ship.x, s.ship.y+1, state.game.difficulty)) 
    end
    if key==love.key_l then
      table.insert(L.objects, Leech:create(s.ship.x, s.ship.y, state.game.difficulty)) 
    end
    if key==love.key_g then
      table.insert(L.objects, Grasshopper:create(s.ship.x, s.ship.y, state.game.difficulty)) 
    end
    if key==love.key_d then
      s.ship:switchWeapons()
    end
  end,
  
  joystickpressed = function(s,j,b)
    if b == 2 then state.current = state.pause end
    if b == 3 then s.ship:switchWeapons() end
  end,
  
  collision = function(a,b,c)
    if tryCollideInteraction(a, b,
      function(maybeDead) return a == nil or a.dead end,
      function(anythingElse) return true end,
      function(maybeDead, anythingElse) end
    ) then return end
  
    if tryCollideInteraction( a, b,
      function(maybeWall) return maybeWall == L.physics end,
      function(maybeHornet) return AisInstanceOfB(maybeHornet, Hornet) end,
      function(wall, hornet) hornet:collided() end
    ) then return end

    if tryCollideInteraction( a, b,
      function(maybeProjectile) return AhasAttributeB(maybeProjectile,Projectile) end,
      function(maybeDamageable) return AhasAttributeB(maybeDamageable, DamageableObject) end,
      function(projectile, damageable) projectile:touchDamageable(damageable) end
    ) then return end
    
    if tryCollideInteraction( a, b,
      function(maybeProxMine) return AisInstanceOfB(maybeProxMine,ProximityMine) end,
      function(whatever) return whatever ~= nil end,
      function(prox, thing) prox:explode(thing) end
    ) then return end
    
    if tryCollideInteraction( a, b,
      function(maybeProjectile) return AhasAttributeB(maybeProjectile,Projectile) end,
      function(whatever) return whatever ~= nil end,
      function(projectile, whatever) projectile.dead = true end
    ) then return end
    
    if tryCollideInteraction( a, b,
      function(maybeEel) return AisInstanceOfB(maybeEel, Eel) end,
      function(maybeShip) return AisInstanceOfB(maybeShip, Ship) end,
      function(eel, ship) eel:shock(ship) end    
    ) then return end
    
    if tryCollideInteraction( a, b,
      function(maybeHopper) return AisInstanceOfB(maybeHopper, Grasshopper) end,
      function(maybe) return AhasAttributeB(maybe, DamageableObject) end,
      function(hopper, thing) local x, y = c:getPosition(); hopper:jump_off(thing, {x,y}) end
    ) then return end

    if tryCollideInteraction( a, b,
      function(maybeHopper) return AisInstanceOfB(maybeHopper, Grasshopper) end,
      function(maybeWall) return maybeWall == L.physics end,
      function(hopper, wall) local x,y = c:getPosition(); hopper.touchedWall = {x,y} end
    ) then return end

    -- let collectors collect things
    if tryCollideInteraction( a, b,
      function(x) return AhasAttributeB(x, CollectibleObject) end, 
      function(x) return AhasAttributeB(x, CollectorObject) end, 
      function(collectible, hobo)
        if collectible.dead or hobo.dead then return end
        hobo:inventoryAdd(collectible)
        collectible:collected(hobo)
      end
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
