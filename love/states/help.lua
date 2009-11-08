local options = {
  {text = "Done", x = 675, y = 350, w = 60, h = 20,
    action = function() 
    state.current = state.menu
  end}
}

local supplemental = {
  height = 200,
  draw = function(sup,s)
    love.graphics.setColor(s.normalColor)
    love.graphics.draw("Crystal: Find the warp crystal and return it to the warp portal at the beginning of the level to advance.", 75, sup.height)
    love.graphics.draw("Controls: Pilot your ship using the arrow keys, joystick, or gamepad.", 75, sup.height + 25)
    love.graphics.draw("Controls: Radial style: Turn, thrust forward, or reverse.",75,sup.height + 50)
    love.graphics.draw("Controls: Directional style: Indicate the direction you want to move in.", 75, sup.height + 75)
    love.graphics.draw("Fire: Press or hold 'f' or button 1 to fire your weapon.", 75, sup.height + 100)
    love.graphics.draw("Mod: The space bar and button 2 are considered 'mod' keys; use them with" , 75, sup.height + 125)
    love.graphics.draw("other keys/buttons to perform special maneuvers." , 150, sup.height + 150)
    love.graphics.draw("Map: You may press 'p' or button 3 at any time to pause the game and view a map.",75,sup.height + 175)
    love.graphics.draw("Powerups: Collect to increase your score, armor, and abilities.",75,sup.height + 200)
    love.graphics.line(0,sup.height - 50,800,sup.height - 25 )
    love.graphics.line(0,sup.height + 225,800,sup.height + 250 )
  end
}

state.help = getMenu(options, supplemental)


