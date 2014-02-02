###
  Coord2d is a library for creating and manipulating 2D coordinates in either cartesian or polar systems.
###
PI_OVER_2 = 1.57079632679
RAD_TO_DEG = 57.2957795131

class @Coord2d
  constructor: ->
    @x = 0
    @y = 0
  add: (c) ->
    @x += c.x
    @y += c.y
    @
  normalize: ->
    r = @constructor.radiusFromXY(@x, @y)
    @x /= r
    @y /= r
    @
  toDegrees: -> RAD_TO_DEG * @constructor.angleFromXY @x, @y
  fromObject: (o) ->
    @x = o.x
    @y = o.y
    @
  fromCartesian: (@x, @y) -> @
  fromPolar: (r, a) ->
    @x = @constructor.xFromPolar r, a
    @y = @constructor.yFromPolar r, a
    @
  clone: -> @constructor.fromCartesian @x, @y
  @radiusFromXY: (x, y) -> Math.sqrt x * x + y * y
  @angleFromXY: (x, y) -> Math.atan2 y, x
  @angleFrom: (x1, y1, x2, y2) -> @angleFromXY x2 - x1, y2 - y1
  @angleBetween: (x1, y1, x2, y2) ->
    a2 = @angleFromXY(x2, y2)
    a1 = @angleFromXY(x1, y1)
    diff = a2 - a1
    if diff < -Math.PI then diff += 2 * Math.PI
    if diff > Math.PI then diff -= 2 * Math.PI
    diff
  @midAngleBetween: (a1, a2) ->
    if a1 > a2
      temp = a1
      a1 = a2
      a2 = temp
    if a2 - a1 > Math.PI then a2 -= 2 * Math.PI
    final = 0.5 * (a1 + a2)
    if final < 0 then final += 2 * Math.PI
    final
  @angleToDegrees: (a) -> RAD_TO_DEG * a
  @xFromPolar: (r, a) -> r * Math.cos a
  @yFromPolar: (r, a) -> r * Math.sin a
  @fromObject: (o) ->
    c = new @()
    c.fromObject o
    c
  @fromCartesian: (x, y) ->
    c = new @()
    c.fromCartesian x, y
    c
  @fromXY: @fromCartesian
  @fromPolar: (r, a) ->
    c = new @()
    c.fromPolar r, a
    c
