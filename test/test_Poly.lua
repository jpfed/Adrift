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
  assertTableEquals( p:min_x_point(), {x=1,y=2} )
end

function test_BoundingBox()
  local p = Poly:create( {{x=1,y=2},{x=4,y=3},{x=2,y=5}} )
  assertTableEquals( p:bounding_box(), {{x=1,y=2},{x=4,y=5}} )
end

function test_IntersectSquare()
  local p = Poly:create( {{x=0,y=0},{x=4,y=0},{x=4,y=4},{x=0,y=4}} )
  local result = p:intersections_with( {x=-1,y=2}, {x=2,y=5} )
  assertEqual( #result, 2 )
  assertTableEquals( result, {{x=1,y=4}, {x=0,y=3}} )
end

function test_IntersectTriangle()
  local p = Poly:create( {{x=1,y=2},{x=4,y=3},{x=2,y=5}} )
  local result = p:intersections_with( {x=1,y=3.5}, {x=5,y=3.5} )
  assertEqual( #result, 2 )
  assertTableEquals( result, {{x=3.5,y=3.5}, {x=1.5,y=3.5}} )
end

runTests { useANSI = true }
