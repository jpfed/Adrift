require 'lunity'
require 'love_test'
love.filesystem.require("objects/composable/Explosion.lua")
module( 'TEST_EXPLOSION', lunity )

function test_Initializes_Defaults()
  local x = FireyExplosion:create(1,7,60,1.0)
  assertEqual( x.life, 0 )
  assertEqual( x.class, Explosion )
end

