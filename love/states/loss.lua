state.loss = {
  update = function(s,dt) 
    s.ct = math.min(1,s.ct + dt)
  end,
  draw = function(s) 
    state.game:draw()
    love.graphics.setColor(love.graphics.newColor(0,0,0,255*s.ct))
    love.graphics.rectangle(love.draw_fill,0,0,800,600)
    love.graphics.setColor(love.graphics.newColor(255,255,255))
    love.graphics.draw("Game Over", 350,300)
  end,
  mousepressed = function(s,x,y,button) end,
  keypressed = function(s,key) 
    state.current = state.menu
  end
}