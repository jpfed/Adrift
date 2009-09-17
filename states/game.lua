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
    s:startNewLevel()
  end,
  
  enqueueNextLevel = function(s)
    s.waitingForNewLevel = true
  end,
  
  startNewLevel = function(s)
    s.waitingForNewLevel = false
    s.levelNumber = s.levelNumber + 1
    s.world = love.physics.newWorld(-1,-1,levelGenerator.maxCol+1,levelGenerator.maxRow+1,0,1, true)
    s.world:setCallback(state.game.collision)
    s.level = getLevel(s.difficulty*10 + s.levelNumber)
    s.background = getLevel(s.difficulty*10 + s.levelNumber)
    s.level.physics = solidify(s.world,s.level.tiles)
    s.level.colors = coloration(1)
    s.background.colors = coloration(0.25)
    s.objects = getObjects(s.world, s.level.nodes,s.difficulty*10)
    s.ship = objects.ships.getShip(s.world, s.level.nodes[1].x, s.level.nodes[1].y,state.options.controlScheme)
    camera.x = s.ship.body:getX()
    camera.y = s.ship.body:getY()
  end,
  
  update = function(s,dt) 
    s.ship:update(dt)
    if s.ship.armor <= 0 then
    state.current = state.loss
    state.loss.ct = 0
    end
    for k,v in ipairs(s.objects) do
      v:update(dt)
    end
    s.world:update(dt)
    
    if s.ship ~= nil then
      camera.x = camera.x * 0.75 + s.ship.body:getX() * 0.25
      camera.y = camera.y * 0.75 + s.ship.body:getY() * 0.25
    end
    
    s:collectGarbage(s.waitingForNewLevel)
    if s.waitingForNewLevel then s:startNewLevel() end
    
  end,
  
  collectGarbage = function(s,newLevel)
    if newLevel then 
      s.objects = {} 
    else
      repeat
        local found = false
        local objectsToKeep = {}
        for k,v in ipairs(s.objects) do
          if not v.dead then 
            table.insert(objectsToKeep, v) 
          else
            found = true
            if v.cleanup ~= nil then v:cleanup() end
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
      if state.current == state.game then love.graphics.draw("Score: " .. tostring(s.score),20,580) end
      s.ship:draw()
    end
  end,
  
  mousepressed = function(s,x,y,button) 
  
  end,
  
  keypressed = function(s,key) 
    if key==love.key_p then state.current = state.pause end
    if key==love.key_v then state.current = state.victory end
  end,
  
  collision = function(a,b,c)
  
    if a==0 or b==0 then -- something just collided with the level
      if a==0 then
        if b.type == objects.ships then b.collisionShock = 1 end
      elseif b==0 then
        if a.type == objects.ships then a.collisionShock = 1 end
      end
    end

    if a.type == objects.weapons or b.type == objects.weapons then
      if a.type == objects.ships then
        a.armor = a.armor - 1
        if a.armor <= 0 and not a.friendly then state.game.score = state.game.score + 1000 end
      elseif b.type == objects.ships then
        b.armor = b.armor - 1
        if b.armor <= 0 and not b.friendly then state.game.score = state.game.score + 1000 end
      end
      if a.type == objects.weapons and a.firer ~= b then a.dead = true end
      if b.type == objects.weapons and b.firer ~= a then b.dead = true end
    end
    
    -- let the ship collect things
    tryCollide( a, b,
      function(maybeCollectible) return AisInstanceOfB(maybeCollectible,CollectibleObject) end, 
      function(maybeShip) return maybeShip.type == objects.ships and maybeShip.friendly end, 
      function(collectible) collectible:collected() end, 
      function(ship) end
    )
    
    -- check if they just finished the level
    tryCollide( a, b,
      function(maybePortal) return AisInstanceOfB(maybePortal, WarpPortal) end,
      function(maybeShip) return maybeShip.type == objects.ships and maybeShip.hasCrystal end,
      function(portal) love.audio.play(portal.sound) end,
      function(ship) state.current = state.victory end
    )
    
  end
}

tryCollide = function(object1, object2, predicate1, predicate2, consequence1, consequence2)
  if predicate1(object1) and predicate2(object2) then
    consequence1(object1)
    consequence2(object2)
  elseif predicate1(object2) and predicate2(object1) then
    consequence1(object2)
    consequence2(object1)
  end
end
