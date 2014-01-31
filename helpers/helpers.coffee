# Math extensions
Math.lerp = (from, to, t) -> from + t * (to - from)
Math.degToRad = Kinetic.Util._degToRad
Math.radToDeg = Kinetic.Util._radToDeg
Math.angleDiff = (a1, a2) ->
  twopi = 2 * Math.PI
  d = a2 - a1
  d += twopi while d < -Math.PI
  d -= twopi while d > Math.PI
  return d

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
