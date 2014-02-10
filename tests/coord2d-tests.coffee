module "Coord2d"

epsilon = 0.00001

bound = (a) ->
  a -= 2 * Math.PI while a > Math.PI
  a += 2 * Math.PI while a < -Math.PI
  a

test "angleFromXY returns correct results", ->
  tests = [
    { a: 0, x: 1, y: 0, e: 0 }
    { a: 30, x: 0.86602540378, y: 0.5, e: Math.PI / 6 }
    { a: 45, x: 1, y: 1, e: Math.PI / 4 }
    { a: 60, x: 0.5, y: 0.86602540378, e: Math.PI / 3 }
    { a: 90, x: 0, y: 1, e: Math.PI / 2 }
    { a: 120, x: -0.5, y: 0.86602540378, e: Math.PI * 2 / 3 }
    { a: 135, x: -1, y: 1, e: Math.PI * 3 / 4 }
    { a: 150, x: -0.86602540378, y: 0.5, e: Math.PI * 5 / 6 }
    { a: 180, x: -1, y: 0, e: Math.PI }
    { a: 210, x: -0.86602540378, y: -0.5, e: Math.PI * 7 / 6 }
    { a: 225, x: -1, y: -1, e: Math.PI * 5 / 4 }
    { a: 240, x: -0.5, y: -0.86602540378, e: Math.PI * 4 / 3 }
    { a: 270, x: 0, y: -1, e: Math.PI * 3 / 2 }
    { a: 300, x: 0.5, y: -0.86602540378, e: Math.PI * 5 / 3 }
    { a: 315, x: 1, y: -1, e: Math.PI * 7 / 4 }
    { a: 330, x: 0.86602540378, y: -0.5, e: Math.PI * 11 / 6 }
  ]

  for test in tests
    p = Coord2d.fromCartesian test.x, test.y
    r = Coord2d.angleFromXY p.x, p.y
    ok Math.abs(bound(test.e) - r) <= epsilon, "angle of #{test.a} degrees expected #{bound(test.e)}, got #{r} (#{Math.radToDeg r})"


test "angleBetween in Q1 (45 deg) returns correct results", ->
  p1 = Coord2d.fromCartesian 1, 1

  tests = [
    { a: 0, x: 1, y: 0, e: -45 }
    { a: 30, x: 0.86602540378, y: 0.5, e: -15 }
    { a: 45, x: 1, y: 1, e: 0 }
    { a: 60, x: 0.5, y: 0.86602540378, e: 15 }
    { a: 90, x: 0, y: 1, e: 45 }
    { a: 120, x: -0.5, y: 0.86602540378, e: 75 }
    { a: 135, x: -1, y: 1, e: 90 }
    { a: 150, x: -0.86602540378, y: 0.5, e: 105 }
    { a: 180, x: -1, y: 0, e: 135 }
    { a: 210, x: -0.86602540378, y: -0.5, e: 165 }
    { a: 225, x: -1, y: -1, e: -180 }
    { a: 240, x: -0.5, y: -0.86602540378, e: -165 }
    { a: 270, x: 0, y: -1, e: -135 }
    { a: 300, x: 0.5, y: -0.86602540378, e: -105 }
    { a: 315, x: 1, y: -1, e: -90 }
    { a: 330, x: 0.86602540378, y: -0.5, e: -75 }
  ]

  for test in tests
    p2 = Coord2d.fromCartesian test.x, test.y
    r = Coord2d.angleBetween p1.x, p1.y, p2.x, p2.y
    e = Math.degToRad test.e
    ok Math.abs(bound(e) - r) <= epsilon, "angle between 45 deg quad 1 and #{test.a} degrees expected #{bound(e)}, got #{r} (#{Math.radToDeg r})"


test "angleBetween in Q2 (135 deg) returns correct results", ->
  p1 = Coord2d.fromCartesian -1, 1

  tests = [
    { a: 0, x: 1, y: 0, e: -135 }
    { a: 30, x: 0.86602540378, y: 0.5, e: -105 }
    { a: 45, x: 1, y: 1, e: -90 }
    { a: 60, x: 0.5, y: 0.86602540378, e: -75 }
    { a: 90, x: 0, y: 1, e: -45 }
    { a: 120, x: -0.5, y: 0.86602540378, e: -15 }
    { a: 135, x: -1, y: 1, e: 0 }
    { a: 150, x: -0.86602540378, y: 0.5, e: 15 }
    { a: 180, x: -1, y: 0, e: 45 }
    { a: 210, x: -0.86602540378, y: -0.5, e: 75 }
    { a: 225, x: -1, y: -1, e: 90 }
    { a: 240, x: -0.5, y: -0.86602540378, e: 105 }
    { a: 270, x: 0, y: -1, e: 135 }
    { a: 300, x: 0.5, y: -0.86602540378, e: 165 }
    { a: 315, x: 1, y: -1, e: -180 }
    { a: 330, x: 0.86602540378, y: -0.5, e: -165 }
  ]

  for test in tests
    p2 = Coord2d.fromCartesian test.x, test.y
    r = Coord2d.angleBetween p1.x, p1.y, p2.x, p2.y
    e = Math.degToRad test.e
    ok Math.abs(bound(e) - r) <= epsilon, "angle between 45 deg quad 1 and #{test.a} degrees expected #{bound(e)}, got #{r} (#{Math.radToDeg r})"






