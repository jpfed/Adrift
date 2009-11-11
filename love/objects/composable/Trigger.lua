love.filesystem.require("util/geom.lua")

Trigger = function(x, y, conditionFunc, conditionArgs, consequenceFunc, consequenceArgs)
  return {
    x = x,
    y = y,
    draw = function(self) end,
    update = function(self, dt)
      if not self.dead and conditionFunc(unpack(conditionArgs)) then 
        consequenceFunc(unpack(consequenceArgs)) 
        self.dead = true
      end
    end
  }
end

ProximityCondition = function(x,y,triggerDistance)
  local s = state.game.ship
  return (geom.distance(x,y,s.x,s.y) < triggerDistance)
end

DelayedEnemy = function(Class, x, y, difficulty, triggerDistance)
  local f = function(cl, cx, cy, cd) L:addObject(Class:create(cx,cy,cd)) end
  return Trigger(x, y, ProximityCondition, {x, y, triggerDistance}, f, {Class,x,y,difficulty})
end

DelayedPowerup = function(Class, node, triggerDistance)
  local f = function(cl, cn) L:addObject(Class:create(cn)) end
  return Trigger(node.x, node.y, ProximityCondition, {node.x, node.y, triggerDistance}, f, {Class,node})
end