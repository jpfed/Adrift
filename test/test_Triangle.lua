require 'lunity'
require 'love_test'
love.filesystem.require("util/triangle.lua")
module( 'TEST_TRIANGLE', lunity )

function test_MakesTriangles()
  local t = Triangle:create(0,0,3,0,3,4)
  assertTableEquals( t, {0,0,3,0,3,4} )
end

function test_LengthsSimple()
  assertTableEquals( Triangle.lengths(Triangle:create(0,0,3,0,3,4)), {3,4,5} )
end

function test_LengthsComplex()
  local lengths = Triangle.lengths(Triangle:create(0,0,3,3,0,4))
  assertEqual( lengths[1], math.sqrt(18) )
end

function test_Area()
  -- Need an assertWithin for floats
  assertTrue( Triangle.area({0,0,3,0,3,4}), 6 )
end

function test_NotOverlapping()
  local t1 = Triangle:create(0,0,3,0,3,4)
  local t2 = Triangle:create(100,0,13,0,13,4)
  assertFalse( Triangle.has_overlap(t1, t2) )
end

function test_SharingEdge()
  local t1 = Triangle:create(0,0,3,0,3,4)
  local t2 = Triangle:create(0,0,3,4,0,4)
  assertFalse( Triangle.has_overlap(t1, t2) )
end

function test_OverlappingByContains()
  local t1 = Triangle:create(0,0,3,0,3,4)
  local t2 = Triangle:create(-10,-1,10,-1,10,10)
  assertTrue( Triangle.has_overlap(t1, t2) )
end

function test_Inside()
  local t1 = Triangle:create(-10,-1,10,-1,10,10)
  local t2 = Triangle:create(0,0,3,0,3,4)
  assertTrue( Triangle.has_inside(t1, t2) )
end

function test_InsideSame()
  local t2 = Triangle:create(0,0,3,0,3,4)
  local t2 = Triangle:create(0,0,3,0,3,4)
  assertTrue( Triangle.has_inside(t1, t2) )
end

function test_NotInside()
  local t1 = Triangle:create(0,0,2,0,2,1)
  local t2 = Triangle:create(0,0,3,0,3,4)
  assertFalse( Triangle.has_inside(t1, t2) )
end

runTests { useANSI = false }
