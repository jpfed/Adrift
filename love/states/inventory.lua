state.inventory = {

  color_line = love.graphics.newColor(200,200,200),
  color_fade = love.graphics.newColor(0,0,2,192),

  x = 20,
  y = 20,
  w = 760,
  h = 400,

  start = function(s)
  end,

  update = function(s,dt) 
    local ship = state.game.ship
    local targVx, targVy, isFiring, isMod1 = ship.controller:getAction(ship,dt)
  end,

  draw = function(s) 
    love.graphics.setColor(s.color_fade)
    love.graphics.rectangle(love.draw_fill,s.x,s.y,s.w,s.h)
    love.graphics.setColor(s.color_line)
    love.graphics.rectangle(love.draw_line,s.x,s.y,s.w,s.h)

    love.graphics.draw("INVENTORY!",s.x+10,s.y+20)
  end,

  keypressed = function(s,key) 
    if key == love.key_return then
      logger:add("UHHH")
    elseif key == love.key_i then
      state.current = state.game
    end
  end,
}

