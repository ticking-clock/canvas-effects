// Generated by CoffeeScript 1.6.3
(function() {
  var anim, cursor, i, layer, stage, stream, streamArray, streamCount, _i;

  stage = new Kinetic.Stage({
    container: 'main',
    width: 1600,
    height: 900
  });

  layer = new Kinetic.Layer();

  cursor = new Kinetic.Star({
    x: 0,
    y: 0,
    numPoints: 5,
    innerRadius: 6,
    outerRadius: 12,
    fill: 'yellow'
  });

  streamArray = [];

  streamCount = 1;

  for (i = _i = 0; 0 <= streamCount ? _i < streamCount : _i > streamCount; i = 0 <= streamCount ? ++_i : --_i) {
    stream = new Stream({
      interval: 1000 + (Math.random() * 50 - 25),
      maxSegments: 10,
      drawGizmos: true,
      velocity: 150,
      startPosition: {
        x: 800 + Math.random() * 0 * 60 - 30,
        y: 450 + Math.random() * 0 * 60 - 30
      }
    });
    streamArray.push(stream);
    layer.add(stream);
  }

  stage.add(layer);

  anim = new Kinetic.Animation(function(frame) {
    var adjusted, pos, _j, _len, _results;
    pos = stage.getPointerPosition();
    if (pos == null) {
      return;
    }
    adjusted = new Coord2d();
    _results = [];
    for (_j = 0, _len = streamArray.length; _j < _len; _j++) {
      stream = streamArray[_j];
      adjusted.fromObject(pos);
      _results.push(stream.update(frame.timeDiff, adjusted));
    }
    return _results;
  }, layer);

  anim.start();

}).call(this);

/*
//@ sourceMappingURL=lifestream.map
*/
