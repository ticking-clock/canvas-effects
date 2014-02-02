// Generated by CoffeeScript 1.6.3
(function() {
  Math.lerp = function(from, to, t) {
    return from + t * (to - from);
  };

  Math.degToRad = function(d) {
    return d * Math.PI / 180;
  };

  Math.radToDeg = function(r) {
    return r * 180 / Math.PI;
  };

  Math.angleDiff = function(a1, a2) {
    var d, twopi;
    twopi = 2 * Math.PI;
    d = a2 - a1;
    while (d < -Math.PI) {
      d += twopi;
    }
    while (d > Math.PI) {
      d -= twopi;
    }
    return d;
  };

  Math.angleQuadrant = function(a) {
    if (a >= 0 && a < Math.PI / 2) {
      return 1;
    }
    if (a >= Math.PI / 2 && a < Math.PI) {
      return 2;
    }
    if (a >= Math.PI && a < 3 * Math.PI / 2) {
      return 3;
    }
    return 4;
  };

  Math.sign = function(x) {
    if (x) {
      if (x < 0) {
        return -1;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  };

  Math.splitBezier = function(x1, y1, bx1, by1, bx2, by2, x2, y2, t0, t1) {
    var qxa, qxb, qxc, qxd, qya, qyb, qyc, qyd, u0, u1, xa, xb, xc, xd, ya, yb, yc, yd;
    u0 = 1.0 - t0;
    u1 = 1.0 - t1;
    qxa = x1 * u0 * u0 + bx1 * 2 * t0 * u0 + bx2 * t0 * t0;
    qxb = x1 * u1 * u1 + bx1 * 2 * t1 * u1 + bx2 * t1 * t1;
    qxc = bx1 * u0 * u0 + bx2 * 2 * t0 * u0 + x2 * t0 * t0;
    qxd = bx1 * u1 * u1 + bx2 * 2 * t1 * u1 + x2 * t1 * t1;
    qya = y1 * u0 * u0 + by1 * 2 * t0 * u0 + by2 * t0 * t0;
    qyb = y1 * u1 * u1 + by1 * 2 * t1 * u1 + by2 * t1 * t1;
    qyc = by1 * u0 * u0 + by2 * 2 * t0 * u0 + y2 * t0 * t0;
    qyd = by1 * u1 * u1 + by2 * 2 * t1 * u1 + y2 * t1 * t1;
    xa = qxa * u0 + qxc * t0;
    xb = qxa * u1 + qxc * t1;
    xc = qxb * u0 + qxd * t0;
    xd = qxb * u1 + qxd * t1;
    ya = qya * u0 + qyc * t0;
    yb = qya * u1 + qyc * t1;
    yc = qyb * u0 + qyd * t0;
    yd = qyb * u1 + qyd * t1;
    return [xa, ya, xb, yb, xc, yc, xd, yd];
  };

  this.util = {
    throttle: function(func, wait) {
      var previous;
      previous = 0;
      return function() {
        var remaining, result, time;
        time = arguments[0].time;
        if (!previous) {
          previous = time;
        }
        remaining = wait - (time - previous);
        if (remaining <= 0) {
          arguments[0].timeDiff = time - previous;
          previous = time;
          return result = func.apply(this, arguments);
        }
      };
    }
  };

}).call(this);

/*
//@ sourceMappingURL=helpers.map
*/
