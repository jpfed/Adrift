load = function()
  math.randomseed(os.time())
  love.filesystem.require("oo.lua")
  love.filesystem.require("util/util.lua")
  love.filesystem.require("objects/objects.lua")
  love.filesystem.require("objects/levelGenerator.lua")
  love.filesystem.require("graphics/camera.lua")
  love.filesystem.require("sound/sound.lua")
  love.filesystem.require("states/states.lua")
  love.mouse.setVisible(false)
  love.graphics.setFont(love.default_font)
  state.current = state.menu
  love.audio.setChannels(4)
  love.audio.setVolume(0.9)
end

update = function(dt)
  if not love.audio.isPlaying() then love.audio.play(sound.bgm) end
  dt = math.min(dt, 1/15)
  state.current:update(dt)
end

draw = function()
  state.current:draw()
  
  --logger:draw()
end

mousepressed = function(x, y, button)
  state.current:mousepressed(x, y, button)
end

keypressed = function(key)
  if key==love.key_escape then love.system.exit() end
  if key==love.key_r then love.system.restart() end
  state.current:keypressed(key)
end

logger = {
  messages = {},
  
  add = function(l,message)
    table.insert(l.messages,message)
    if table.getn(l.messages) > 20 then table.remove(l.messages,1) end
  end,
  
  draw = function(l)
    for k,v in ipairs(l.messages) do
      love.graphics.draw(v, 10,k*30)
    end
  end
}