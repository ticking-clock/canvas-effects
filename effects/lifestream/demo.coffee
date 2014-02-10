stage = new Kinetic.Stage
  container: 'main'
  width: 1600
  height: 900

layer = new Kinetic.Layer()

###
cursor = new Kinetic.Star
  x: 0
  y: 0
  numPoints: 5
  innerRadius: 6
  outerRadius: 12
  fill: 'yellow'
###

lifestream = new Lifestream
  stroke: '#2EF9C5'
  streamCount: 15
  origin: x:-40, y:-40
  interval: 800
  velocity: 120
  maxSegments: 8

  intervalVariance: 50
  originVariance: 80
  targetVariance: 60
  colorVariance: 40

layer.add lifestream
stage.add layer

lifestream.start()