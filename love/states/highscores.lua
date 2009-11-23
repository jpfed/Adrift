state.highscores = {
  ct = 0,
  update = function(s,dt) 
    s.ct = math.min(1,s.ct + dt)
    -- TODO: It would be cool to scroll through all the high scores slowly
  end,
  draw = function(self) 
    love.graphics.setColor(love.graphics.newColor(0,0,0))
    love.graphics.rectangle(love.draw_fill,0,0,800,600)
    love.graphics.setColor(love.graphics.newColor(255,255,255))
    love.graphics.draw("HIGH SCORES", 350,50)
    if self.scores then
      for i, v in ipairs(self.scores) do
        local line = i .. " -- " .. v[1] .. " -- " .. v[2]
        love.graphics.draw(line, 50,80 + (i*20))
      end
    else
      self:init()
    end
  end,
  go = function()
    state.menu:reset()
    state.current = state.menu
  end,
  register = function(self)
    local score = state.game.score
    -- TODO: This is where it would be nice to have nethack-style "Died by own bullet" display
    local reason = os.date("Died " .. state.game.levelNumber .. " warps deep on difficulty " .. state.game.difficulty .. ", %c")
    if Opt.highscores == nil then Opt.highscores = {} end
    Opt.highscores[score] = reason
    state.options:save()
    self:init() 
  end,
  init = function(self)
    -- Sort the score keys and get the top 10
    local i = 0
    local orderedScores = {}
    self.scores = {}
    for k, v in pairs(Opt.highscores) do
      table.insert(orderedScores, k)
    end
    table.sort(orderedScores, function (a,b) return a>b end)

    for i, score in ipairs(orderedScores) do
      if i>20 then break end
      self.scores[i] = {score, Opt.highscores[score]}
    end
  end,
  mousepressed = function(s,x,y,button) s.go() end,
  keypressed = function(s,key) s.go() end,
  joystickpressed = function(s,j,b) s.go() end,
}

