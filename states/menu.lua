getMenu = function(opts, extras)
  
  return {
    
    normalColor = love.graphics.newColor(128,128,128),
    highlightColor = love.graphics.newColor(255,255,255),
    
    xMargin = 15,
    yMargin = 13,
    
    cursor = {
      x = 400,
      y = 300,
      selected = 0,
      
      draw = function(c,s) 
        if c.selected > 0 then
          love.graphics.setColor(s.highlightColor)
          c.rep = "x"
          local so = s.options[c.selected]
          love.graphics.rectangle(love.draw_line,so.x - s.xMargin,so.y - s.yMargin,so.w,so.h)
        else
          love.graphics.setColor(s.normalColor)
          c.rep = "+"
        end
        love.graphics.draw(c.rep,c.x,c.y)
      end,
      
      update = function(c) 
        c.x = love.mouse.getX()
        c.y = love.mouse.getY()
      end
    },

    options = opts,
    supplemental = extras,
    
    update = function(s,dt) 
      s.cursor:update()
      local found = false
      for k,v in ipairs(s.options) do
        if s.cursor.x > v.x - s.xMargin and s.cursor.x < v.x + v.w - s.xMargin then
          if s.cursor.y > v.y - s.yMargin and s.cursor.y < v.y + v.h - s.yMargin then
            s.cursor.selected = k
            found = true
          end
        end
      end
      if not found then s.cursor.selected = 0 end
    end,
    
    draw = function(s) 
      s.cursor:draw(s)
      s.supplemental:draw(s)
      love.graphics.setColor(s.normalColor)
      for k,v in ipairs(s.options) do
        love.graphics.draw(v.text,v.x,v.y)
      end
    end,
    
    mousepressed = function(s,x,y,button) 
      if s.cursor.selected > 0 then s.options[s.cursor.selected].action() end
    end,
    
    keypressed = function(s,key) 
      if key ~= love.key_return then return end
      if s.cursor.selected > 0 then s.options[s.cursor.selected].action() end
    end
  }
end

local options = {
  
  {text = "Easy", x = 500, y = 200, w = 60, h = 20,
    action = function()  
    state.game:load(1)
  end},
  
  {text = "Medium", x = 500, y = 250, w = 75, h = 20,
    action = function()  
    state.game:load(2)
  end},
  
  {text = "Hard", x = 500, y = 300, w = 60, h = 20,
    action = function()  
    state.game:load(3)
  end},
  
  {text = "Help", x = 500, y = 350, w = 60, h = 20,
    action = function()
    state.current = state.help
  end},
  
  {text = "Quit", x = 500, y = 400, w = 60, h = 20,
    action = function() 
    love.system.exit()
  end}
}

local supplemental = {
  draw = function(sup,s)
    love.graphics.setColor(s.normalColor)
    love.graphics.line(425,150,425,450)
    love.graphics.line(600,150,600,450)
    love.graphics.line(275,0,425,150)
    love.graphics.line(750,0,600,150)
    love.graphics.line(425,450,275,600)
    love.graphics.line(600,450,750,600)
  end
}

state.menu = getMenu(options, supplemental)