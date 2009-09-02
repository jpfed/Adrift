state.pause = {
  
  bgColor = love.graphics.newColor(0,0,0,192),
  txtColor = love.graphics.newColor(255,255,255),
  fontBig = false,
  
  update = function(s,dt) 
    if not s.fontBig then
    love.graphics.setFont(love.default_font,36)
    s.fontBig = true
    end
  end,
  
  draw = function(s) 
    state.game:draw()
    love.graphics.setColor(s.bgColor)
    love.graphics.rectangle(love.draw_fill,0,0,800,600)
    love.graphics.setColor(s.txtColor)
    love.graphics.setFont(love.default_font,36)
    love.graphics.draw("Paused", 337, 300)
  end,
  
  mousepressed = function(s,x,y,button) end,
  
  keypressed = function(s,key) 
    if key==love.key_p then 
      s.fontBig = false
      love.graphics.setFont(love.default_font,12)
      state.current = state.game 
    end
  end
}