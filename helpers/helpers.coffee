# Math extensions
Math.lerp = (from, to, t) -> from + t * (to - from)
Math.degToRad = (d) -> d * Math.PI / 180
Math.radToDeg = (r) -> r * 180 / Math.PI

Math.angleDiff = (a1, a2) ->
  twopi = 2 * Math.PI
  d = a2 - a1
  d += twopi while d < -Math.PI
  d -= twopi while d > Math.PI
  return d

Math.angleQuadrant = (a) ->
  if a >= 0 and a < Math.PI/2 then return 1
  if a >= Math.PI/2 and a < Math.PI then return 2
  if a >= Math.PI and a < 3*Math.PI/2 then return 3
  return 4

Math.bezier = (x1, y1, c1x, c1y, c2x, c2y, x2, y2, t) ->
  u = 1 - t
  u0 = u * u * u
  u1 = 3 * t * u * u
  u2 = 3 * t * t * u
  u3 = t * t * t
  x: u0*x1 + u1*c1x + u2*c2x + u3*x2
  y: u0*y1 + u1*c1y + u2*c2y + u3*y2

Math.splitBezier = (x1, y1, bx1, by1, bx2, by2, x2, y2, t0, t1) ->
  # De Casteljau algorithm
  u0 = 1.0 - t0
  u1 = 1.0 - t1

  qxa =  x1*u0*u0 + bx1*2*t0*u0 + bx2*t0*t0
  qxb =  x1*u1*u1 + bx1*2*t1*u1 + bx2*t1*t1
  qxc = bx1*u0*u0 + bx2*2*t0*u0 +  x2*t0*t0
  qxd = bx1*u1*u1 + bx2*2*t1*u1 +  x2*t1*t1

  qya =  y1*u0*u0 + by1*2*t0*u0 + by2*t0*t0
  qyb =  y1*u1*u1 + by1*2*t1*u1 + by2*t1*t1
  qyc = by1*u0*u0 + by2*2*t0*u0 +  y2*t0*t0
  qyd = by1*u1*u1 + by2*2*t1*u1 +  y2*t1*t1

  xa = qxa*u0 + qxc*t0
  xb = qxa*u1 + qxc*t1
  xc = qxb*u0 + qxd*t0
  xd = qxb*u1 + qxd*t1

  ya = qya*u0 + qyc*t0
  yb = qya*u1 + qyc*t1
  yc = qyb*u0 + qyd*t0
  yd = qyb*u1 + qyd*t1

  [xa, ya, xb, yb, xc, yc, xd, yd]

# Utilities
@util =
  # Timing for Kineticjs
  throttle: (func, wait) ->
    previous = 0
    ->
      time = arguments[0].time
      previous = time if not previous
      remaining = wait - (time - previous)
      if remaining <= 0
        arguments[0].timeDiff = time - previous
        previous = time
        result = func.apply @, arguments
