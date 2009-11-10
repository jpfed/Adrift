love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")

Planner = {
  
  create = function(self, parent)
    local result = {parent = parent, attitudes = {}}
    mixin(result, Planner)
    result.class = Planner
    return result
  end,
  
  addStrategy = function(self, attitude, objectSource, weight, otherParams)
    local toInsert = {attitude = attitude, objectSource = objectSource, weight = weight}
    if otherParams ~= nil then mixin(toInsert, otherParams) end
    table.insert(self.attitudes, toInsert)
  end,

  getEngineAction = function(self)
    local moveX, moveY, pointX, pointY = 0, 0, 0, 0
    for ak,av in pairs(self.attitudes) do
      local mx, my, px, py = av:attitude(self, moveX, moveY)
      mx, my = geom.normalize(mx, my)
      moveX, moveY = moveX + av.weight*mx, moveY + av.weight*my
      px, py = geom.normalize(px, py)
      pointX, pointY = pointX + av.weight*px, pointY + av.weight*py
    end
    moveX, moveY = geom.normalize(moveX, moveY)
    pointX, pointY = geom.normalize(pointX, pointY)
    return moveX, moveY, pointX, pointY
  end,
  
}

AI = {

  --------------- attitudes
  
  
  
  -- approach the closest of the relevant objects
  tag = function(self, planner, mx, my)
    local closestObject, closestDistance = nil, math.huge
    local parent = planner.parent
    local objects = self:objectSource(parent)
    for k, v in pairs(objects) do
      local dist = geom.distance_t(parent, v)
      if dist < closestDistance then
        closestDistance = dist
        closestObject = v
      end
    end
    local tx, ty = closestObject.x - parent.x, closestObject.y - parent.y
    return tx, ty, tx, ty
  end,
  
  -- approach the weighted center of the relevant objects
  approach = function(self, planner, mx, my)
    local tx, ty = 0, 0
    local parent = planner.parent
    local parentX, parentY = parent.x, parent.y
    local objects = self:objectSource(parent)
    for k, v in pairs(objects) do
      local dx, dy = v.x - parentX, v.y - parentY
      local norm = math.max(0.01, dx*dx + dy*dy)
      tx, ty = tx + dx/norm, ty + dy/norm
    end
    return tx, ty, tx, ty
  end,
  
  -- flee the weighted center of the relevant objects
  flee = function(self, planner, mx, my)
    local px, py
    mx, my, px, py = AI.approach(self, planner, mx, my)
    return -mx, -my, -px, -py
  end,
  
  -- back away from the weighted center of the relevant objects
  regard = function(self, planner, mx, my)
    local px, py
    mx, my, px, py = AI.approach(self, planner, mx, my)
    return -mx, -my, px, py
  end,
  
  -- turn away from the relevant objects, trying to stay as much on course as possible
  dodge = function(self, planner, mx, my)
    local tx, ty = 0, 0
    local parent = planner.parent
    local parentX, parentY = parent.x, parent.y
    local objects = self:objectSource(parent)
    for k, v in pairs(objects) do
      local dx, dy = v.x - parentX, v.y - parentY
      
      local x1, y1 = -dy, dx
      local x2, y2 = dy, -dx
      local norm = math.max(0.01, dx*dx + dy*dy)
      if mx*x1 + my*y1 > 0 then
        tx, ty = tx + x1/norm, ty + y1/norm
      else
        tx, ty = tx + x2/norm, ty + y2/norm
      end
    end
    return tx, ty, mx, my
  end,

  
  
  
  --------------- object sources
  
  
  
  humanPlayer = function(self, parent)
    return {{x = state.game.ship.x, y = state.game.ship.y}}
  end,
  
  -- predicts the human player's position a couple of frames from now
  playerAnticipator = function(self, parent)
    if self.coords == nil then 
      self.coords = {} 
      for k = 1,3 do
        self.coords[k] = {x = state.game.ship.x, y = state.game.ship.y}
      end
    end
    local c = self.coords
    
    if self.cursor == nil then self.cursor = 1 end
    c[self.cursor] = {x = state.game.ship.x, y = state.game.ship.y}
    self.cursor = self.cursor % 3 + 1
    
    local p1, p2, p3 = c[self.cursor], c[self.cursor  % 3 + 1], c[(self.cursor + 1) % 3 + 1]
    
    local cx, cy = p2.x, p2.y
    local bx, by = (p3.x - p1.x) / 2, (p3.y - p1.y) / 2
    local ax, ay = p3.x - bx - cx, p3.y - by - cy
    
    local t = 3 -- 1 + dist/speed, but 3 is ok for now
    
    local predX, predY = t*t*ax + t*bx + cx, t*t*ax + t*bx + cy
    
    return {{x = predX, y = predY}}
  end,
  
  nearbyWalls = function(numRadiusSteps, numAngleSteps)
    return function(self, parent)
      local result = {}
      for r = 1,numRadiusSteps do
        for a = 1,numAngleSteps do
          local theta = a*2*math.pi/numAngleSteps
          local x, y = parent.x + r*math.cos(theta), parent.y + r*math.sin(theta)
          if L:solidAt(x,y) then table.insert(result, {x = x, y = y}) end
        end
      end
      return result
    end
  end,

  approachingProjectiles = function(self, parent)
    local result = {}
    local parentVx, parentVy = 0, 0
    if parent.body ~= nil then parentVx, parentVy = parent.body:getVelocity() end
    for k,v in pairs(L.objects) do
      if kindOf(v, Projectile) then 
        local insert = true
        local projVx, projVy = 0, 0
        if v.body ~= nil then projVx, projVy = v.body:getVelocity() end
        
        local relVx, relVy = projVx - parentVx, projVy - parentVy
        local relPosX, relPosY = v.x - parent.x, v.y - parent.y
        
        insert = ((relPosX*relVx + relPosY*relVy) <= 0)
        
        if insert then table.insert(result, v) end 
      end
    end
    return result
  end,
  
  allProjectiles = function(self, parent)
    local result = {}
    for k, v in pairs(L.objects) do
      if kindOf(v, Projectile) then
        table.insert(result, v)
      end
    end
    return result
  end,
  
  otherAgents = function(self, parent)
    local result = {}
    for k, v in pairs(L.objects) do
      if not kindOf(v,Projectile) and not kindOf(v, CollectibleObject) then table.insert(result, {x = v.x, y = v.y}) end
    end
    return result
  end,
  
  collectibles = function(self, parent)
    local result = {}
    for k, v in pairs(L.objects) do
      if kindOf(v, CollectibleObject) then table.insert(result, v) end
    end
    return result
  end,
}
