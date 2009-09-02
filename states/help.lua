state.help = getMenu()
state.help.options = {
  {text = "Done", x = 675, y = 350, w = 60, h = 20,
    action = function() 
    state.current = state.menu
  end}
}

state.help.supplemental = {
  draw = function(sup,s)
    love.graphics.setColor(s.normalColor)
    love.graphics.draw("Pilot your ship using the arrow keys.", 75, 200)
    love.graphics.draw("Use 'f' to fire your weapon.", 75, 225)
    love.graphics.draw("Use 's' to suck nearby objects (including powerups) towards your ship.",75,250)
    love.graphics.draw("Use the spacebar to switch weapons.", 75, 275)
    love.graphics.draw("Collect valuable minerals as you go to increase your score.", 75, 300)
    love.graphics.draw("Find a warp crystal and return it to the beginning of the level to advance.", 75, 325)
    love.graphics.line(0,125,800,125)
    love.graphics.line(0,400,800,400)
  end

}