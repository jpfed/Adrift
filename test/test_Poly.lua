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

function test_IntersectSquareSegment()
  local p = Poly:create( {{x=0,y=0},{x=4,y=0},{x=4,y=4},{x=0,y=4}} )
  local result = p:intersections_with( {x=-1,y=2}, {x=2,y=5} )
  assertEqual( #result, 2 )
  assertTableEquals( result, 
    {
      {{x=4,y=4},{x=0,y=4},{x=1,y=4}},
      {{x=0,y=4},{x=0,y=0},{x=0,y=3}}
    } )
end

function test_IntersectTriangleSegment()
  local p = Poly:create( {{x=1,y=2},{x=4,y=3},{x=2,y=5}} )
  local result = p:intersections_with( {x=1,y=3.5}, {x=5,y=3.5} )
  assertEqual( #result, 2 )
end

function test_UnionRectangleTriangle()
  local p = Poly:create( {{x=0,y=1},{x=4,y=1},{x=4,y=3},{x=0,y=3}} )
  local r = Poly:create( {{x=1,y=2},{x=3,y=2},{x=2,y=4}} )
  local result = p:union_with(r)
  assertEqual( #result.points, 7 )
  --assertTableEquals( result.points, {{x=0,y=1}...} )
end

function test_UnionRectangles()
  local p = Poly:create( {{x=0,y=1},{x=4,y=1},{x=4,y=3},{x=0,y=3}} )
  local r = Poly:create( {{x=1,y=0},{x=3,y=0},{x=3,y=4},{x=1,y=4}} )
  local result = p:union_with(r)
  assertEqual( #result.points, 12 )
  --assertTableEquals( result.points, {{x=0,y=1}...} )
end

function test_SubPolyLeaves()
  for numSubPolys=3,8 do
    local p = Poly:create({{x=0,y=0},{x=0,y=1},{x=1,y=1},{x=1,y=0}})
    p:subdivide(nil,numSubPolys)
    local l = p:subPolyLeaves()
    assertEqual( #l, numSubPolys)
  end
end

function test_SubPolyRecursion()
  for numSubPolys=3,8 do
    local p = Poly:create({{x=0,y=0},{x=0,y=1},{x=1,y=1},{x=1,y=0}})
    p:subdivide_r(3,nil,numSubPolys)
    local l = p:subPolyLeaves()
    assertEqual( #l, numSubPolys*numSubPolys*numSubPolys)
  end
end
