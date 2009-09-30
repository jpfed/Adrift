state.pause = {
  
  shipMapColor = love.graphics.newColor(255,255,255),
  enemyMapColor = love.graphics.newColor(255,0,0),
  powerupMapColor = love.graphics.newColor(128,255,128),
  crystalMapColor = love.graphics.newColor(128,192,255),
  portalMapColor = love.graphics.newColor(128,192,255),
  otherMapColor = love.graphics.newColor(128,128,128),
  
  
  update = function(s,dt)
  end,
  
  draw = function(s) 
    local g = state.game
    camera:renderMap(g.level.tiles,g.ship.hasFullMap)
    if g.ship.hasFieldDetector then
      for k,v in ipairs(g.objects) do
        if v.body ~= nil then
          local wx,wy = v.body:getPosition()
          local x,y,w = camera:xyMap(wx,wy)
          if v.type == objects.ships then
            if v.friendly then
              love.graphics.setColor(s.shipMapColor)
              w = w*2
            else
              love.graphics.setColor(s.enemyMapColor)
            end
          elseif v.type == objects.powerups then
            love.graphics.setColor(s.powerupMapColor)
          elseif v.type == objects.warpCrystal then
            love.graphics.setColor(s.crystalMapColor)
          elseif v.type == objects.startingSpot then
            love.graphics.setColor(s.portalMapColor)
          else
            love.graphics.setColor(s.otherMapColor)
            w = w/2
          end
          love.graphics.rectangle(love.draw_fill,x-w/2,y-w/2,w,w)
        end
      end
    end
    local wx,wy = g.ship.body:getPosition()
    local x,y,w = camera:xyMap(wx,wy)
    love.graphics.setColor(s.shipMapColor)
    love.graphics.rectangle(love.draw_fill,x-w,y-w,w*2,w*2)

  end,
  
  mousepressed = function(s,x,y,button) end,
  
  keypressed = function(s,key) 
    state.current = state.game
  end
}