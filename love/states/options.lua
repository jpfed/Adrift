local opts = {

  {text = "Radial Keyboard Controls", x = 100, y = 125, w = 180, h = 20,
    action = function()  
      state.options.controlScheme = 1
  end},

  {text = "Eight-directional Keyboard Controls", x = 100, y = 175, w = 245, h = 20,
    action = function()  
      state.options.controlScheme = 2
  end},

  {text = "Radial Gamepad Controls", x = 100, y = 225, w = 180, h = 20,
    action = function()  
      state.options.controlScheme = 3
  end},

  {text = "Eight-directional Gamepad Controls", x = 100, y = 275, w = 245, h = 20,
    action = function()  
      state.options.controlScheme = 4
  end},
  
  {text = "Radial Joystick Controls", x = 100, y = 325, w = 165, h = 20,
    action = function()  
      state.options.controlScheme = 5
  end},

  {text = "Eight-directional Joystick Controls", x = 100, y = 375, w = 230, h = 20,
    action = function()  
      state.options.controlScheme = 6
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
  
  {text = "Done", x = 500, y = 500, w = 60, h = 20,
    action = function() 
      state.current = state.menu
  end},
}

local supplemental = {
  draw = function(sup, s)
    local controlsOption = s.options[state.options.controlScheme]
    local difficultyOption = s.options[state.options.difficulty + 6]
    love.graphics.setColor(s.highlightColor)
    love.graphics.circle(love.draw_fill, controlsOption.x - 30, controlsOption.y - 4, 8, 32)
    love.graphics.circle(love.draw_fill, difficultyOption.x - 30, difficultyOption.y - 4, 8, 32)
    love.graphics.setColor(s.normalColor)
    love.graphics.line(400,425,400,600)
    love.graphics.line(400,425,000,425)
    love.graphics.line(650,75,000,75)
    love.graphics.line(650,75,650,600)
  end
}

state.options = getMenu(opts, supplemental)

state.options.difficulty = 1
state.options.controlScheme = 1