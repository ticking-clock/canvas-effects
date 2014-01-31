stage = new Kinetic.Stage
  container: 'main'
  width: 1600
  height: 900

layer = new Kinetic.Layer()

cursor = new Kinetic.Star
  x: 0
  y: 0
  numPoints: 5
  innerRadius: 6
  outerRadius: 12
  fill: 'yellow'

streamArray = []
streamCount = 15

for i in [0...streamCount]
  stream = new Stream
    interval: 1000 + (Math.random() * 50 - 25)
    maxSegments: 10
    drawGizmos: false
    startPosition:
      x: Math.random() * 60 - 30
      y: Math.random() * 60 - 30
  streamArray.push stream
  layer.add stream

#layer.add cursor
stage.add layer

anim = new Kinetic.Animation (frame) ->
  pos = stage.getPointerPosition()
  return if not pos?    # TODO: separately track if the cursor leaves the stage and stop() the animation
  #cursor.setPosition pos
  adjusted = new Coord2d()
  for stream in streamArray
    adjusted.fromObject pos
    adjusted.x += Math.random() * 60 - 30
    adjusted.y += Math.random() * 60 - 30
    stream.update frame.timeDiff, adjusted
, layer

anim.start()