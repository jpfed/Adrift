require 'lunity'
require 'love_test'
love.filesystem.require("util/poly.lua")
module( 'TEST_POLY', lunity )

function test_Create()
  local p = Poly:create( {{x=1,y=2},{x=4,y=3},{x=2,y=5}} )
  assertTableEquals( p.points, {{x=1,y=2},{x=4,y=3},{x=2,y=5}} )
end

function test_MaxMin()
  local p = Poly:create( {{x=1,y=2},{x=4,y=3},{x=2,y=5}} )
  assertEqual( p:max_x(), 4 )
  assertEqual( p:min_x(), 1 )
  assertEqual( p:max_y(), 5 )
  assertEqual( p:min_y(), 2 )
end

function test_BoundingBox()
  local p = Poly:create( {{x=1,y=2},{x=4,y=3},{x=2,y=5}} )
  assertTableEquals( p:bounding_box(), {{x=1,y=2},{x=4,y=5}} )
end

runTests { useANSI = true }
