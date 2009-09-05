local opts = {

  {text = "Eight-directional Controls", x = 100, y = 200, w = 180, h = 20,
    action = function()  
      state.options.controlScheme = 2
  end},

  {text = "Radial Controls", x = 100, y = 250, w = 115, h = 20,
    action = function()  
      state.options.controlScheme = 1
  end},
  
  
  
  {text = "Normal", x = 500, y = 200, w = 75, h = 20,
    action = function()
      state.options.difficulty = 1
  end},
  
  {text = "Hard", x = 500, y = 250, w = 60, h = 20,
    action = function() 
      state.options.difficulty = 2
  end},
  
  {text = "Insane", x = 500, y = 300, w = 75, h = 20,
    action = function() 
      state.options.difficulty = 3
  end},
  
  {text = "Done", x = 300, y = 500, w = 60, h = 20,
    action = function() 
      state.current = state.menu
  end},
}

local supplemental = {
  draw = function(sup, s)
    local controlsOption = s.options[3-state.options.controlScheme]
    local difficultyOption = s.options[state.options.difficulty + 2]
    love.graphics.setColor(s.highlightColor)
    love.graphics.circle(love.draw_fill, controlsOption.x - 30, controlsOption.y - 5, 8, 32)
    love.graphics.circle(love.draw_fill, difficultyOption.x - 30, difficultyOption.y - 5, 8, 32)
    love.graphics.setColor(s.normalColor)
  end
}

state.options = getMenu(opts, supplemental)

state.options.difficulty = 1
state.options.controlScheme = 1