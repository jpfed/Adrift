require 'lunity'
require 'love_test'
love.filesystem.require("util/quadtree.lua")
module( 'TEST_QUADTREE', lunity )

function test_SimpleStore()
  local p1 = {x=0, y=0}
  local p2 = {x=10, y=10}
  local qt = QuadTree:create(1,p1,p2)
  local rect = {p1=p1, p2=p2}
  assertEqual( qt:overlaps(rect), true )

  qt:insert(rect)
  assertEqual( #qt.objects, 1 )

  local c = qt:collisions(rect)

  assertEqual( #c, 1 )
  -- Of course this doesn't prove anything... yet...
end


function test_SimpleOptimizer()
  local p1 = {x=0, y=0}
  local p2 = {x=2, y=2}
  local qt = QuadTree:create(1,p1,p2)
  local rect = geom.B(0,0,1,1)
  assertEqual( qt:has_children(), false )
  qt:insert(rect)
  assertEqual( qt:has_children(), true )

  local c_yes = qt:collisions(geom.B(0.5,0,1.5,1))
  local c_no  = qt:collisions(geom.B(1.5,0,2.5,1))
  assertEqual( #c_yes, 1 )
  assertEqual( #c_no, 0 )
end

