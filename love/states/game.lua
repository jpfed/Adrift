love.filesystem.require("oo.lua")

state.game = {
  
  spColor = love.graphics.newColor(0,0,255),
  wcColor = love.graphics.newColor(255,0,0),
  normalArcColor = love.graphics.newColor(128,128,128),
  normalNodeColor = love.graphics.newColor(255,255,255),
  score = 0,

  collisions = {},
  
  load = function(s)
    state.current = state.game
    s.levelNumber = 0
    s.difficulty = state.options.difficulty
    s.score = 0
    s.ship = nil
    s:startNewLevel()

    s.collisions = objects.loadCollisions()
  end,

  
  enqueueNextLevel = function(s)
    s.waitingForNewLevel = true
  end,
  
  startNewLevel = function(s)
    s.waitingForNewLevel = false
    s.levelNumber = s.levelNumber + 1
    s.background = Level:create(s.difficulty*8 + s.levelNumber, 0.25)
    L = Level:create(s.difficulty*5 + s.levelNumber, 1, true)
    s.level = L

    L:solidify()

    L.boom = BoomOperator:create(s.difficulty)
    L.boom:startObjects()
    
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
      s.ship:draw()
    end
  end,
  
  mousepressed = function(s,x,y,button) 
  
  end,
  
  keypressed = function(s,key) 
    if key==love.key_p then state.current = state.pause end
    if key==love.key_v then s.ship.hasCrystal = true end
    if key==love.key_e then
      table.insert(L.objects, EnergyChunk:create({x=s.ship.x,y=s.ship.y+1}, state.game.difficulty)) 
    end
    if key==love.key_h then
      table.insert(L.objects, Hornet:create(s.ship.x, s.ship.y, state.game.difficulty)) 
    end
    if key==love.key_b then
      table.insert(L.objects, Bomber:create(s.ship.x, s.ship.y, state.game.difficulty)) 
    end
    if key==love.key_d then
      s.ship:switchWeapons()
    end
    if key==love.key_i then
      state.current = state.inventory
    end
  end,
  
  joystickpressed = function(s,j,b)
    if b == 2 then state.current = state.pause end
    if b == 3 then s.ship:switchWeapons() end
  end,
  
  collision = function(a,b,c)
    for k,v in ipairs(state.game.collisions) do
      if tryCollideInteraction(a, b, c, v[1], v[2], v[3]) then return end
    end
  end
}

tryCollideInteraction = function(object1, object2, collisionPoint, predicate1, predicate2, interaction)
  if predicate1(object1) and predicate2(object2) then
    interaction(object1, object2, collisionPoint)
    return true
  elseif predicate1(object2) and predicate2(object1) then
    interaction(object2, object1, collisionPoint)
    return true
  end
  return false
end
