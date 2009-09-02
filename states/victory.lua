state.victory = {

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
    love.graphics.draw("Level " .. tostring(state.game.levelNumber) .. " complete!", 250, 200)
    love.graphics.draw("Press any key to start the next level!", 100, 300)
  end,
  
  mousepressed = function(s,x,y,button) end,
  
  keypressed = function(s,key) 
    state.game:enqueueNextLevel()
    state.current = state.game
    love.graphics.setFont(love.default_font,12)
    s.fontBig = false
  end
}