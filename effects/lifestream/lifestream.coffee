class @Lifestream extends Kinetic.Group
  streamCount: 1
  origin: x:0, y:0
  intervalVariance: 0
  originVariance: 100
  targetVariance: 100
  colorVariance: 40

  drawGizmos: false
  velocity: 150
  interval: 1000
  tension: 0.35
  maxSegments: 5
  headFadeLength: 0.5
  tailFadeLength: 0.5
  opacity: 0.5
  strokeWidth: 2
  stroke: '#000000'

  constructor: (config) ->
    Kinetic.Group.call @, config
    @setup config
  setup: (config) ->
    @[setting] = value for own setting, value of config
    @streamArray = []
    for i in [0...@streamCount]
      color = chroma(@stroke).darken(Math.random() * @colorVariance - 0.5 * @colorVariance)
      stream = new Stream
        interval: @interval + (Math.random() * @intervalVariance - 0.5 * @intervalVariance)
        maxSegments: @maxSegments
        drawGizmos: @drawGizmos
        velocity: @velocity
        strokeWidth: @strokeWidth
        headFadeLength: @headFadeLength
        tailFadeLength: @tailFadeLength
        stroke: color.hex()
        origin:
          x: @origin.x + Math.random() * @originVariance - 0.5 * @originVariance
          y: @origin.y + Math.random() * @originVariance - 0.5 * @originVariance
      @streamArray.push stream
      @add stream

  start: ->
    unless @anim
      layer = @getLayer()
      @anim = new Kinetic.Animation (frame) =>
        stage = @getStage()
        pos = stage.getPointerPosition()
        return if not pos?    # TODO: separately track if the cursor leaves the stage and stop() the animation
        adjusted = new Coord2d()
        for stream in @streamArray
          adjusted.fromObject pos
          adjusted.x += Math.random() * @targetVariance - 0.5 * @targetVariance
          adjusted.y += Math.random() * @targetVariance - 0.5 * @targetVariance
          stream.update frame.timeDiff, adjusted
      , layer
    @anim.start()