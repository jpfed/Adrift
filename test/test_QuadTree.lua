require 'lunity'
require 'love_test'
love.filesystem.require("util/quadtree.lua")
module( 'TEST_QUADTREE', lunity )

function test_SimpleStore()
  local p1 = {x=0, y=0}
  local p2 = {x=10, y=10}
  local qt = QuadTree:create(1,p1,p2)
  local rect = {p1=p1, p2=p2}
  qt:insert(rect)

  local c = qt:collisions(rect)

  assertEqual( #c, 1 )
  -- Of course this doesn't prove anything... yet...
end


runTests { useANSI = true }

