
# stream needs to be updated on a regular basis
# stream needs to be given a target point in its updates
# or, stream needs a callback that will give it the target point

class @Stream extends Kinetic.Group
  drawGizmos: false
  velocity: 150
  interval: 1000
  tension: 0.40
  maxSegments: 5
  constructor: (config) ->
    Kinetic.Group.call @, config
    @setup config
  setup: (config) ->
    if config.drawGizmos? then @drawGizmos = config.drawGizmos
    if config.interval? then @interval = config.interval
    if config.maxSegments? then @maxSegments = config.maxSegments
    initPoint = if config.startPosition? then config.startPosition  else x:0, y:0
    @capturePoints = [ Coord2d.fromObject initPoint ]
    @currentTime = @interval

    # Gizmos
    @kAllSegmentsGizmo = new Kinetic.Line
      points: []
      stroke: 'red'
      strokeWidth: 1
    @kActiveSegmentsGizmo = new Kinetic.Line
      points: []
      stroke: 'yellow'
      strokeWidth: 1

    @kBody = new Bezier
      points: []
      stroke: 'white'
      opacity: 0.5
      strokeWidth: 2
    @kHead = new Bezier
      points: []
      stroke: 'white'
      opacity: 0.5
      strokeWidth: 2
    @kTail = new Bezier
      points: []
      stroke: 'white'
      opacity: 0.5
      strokeWidth: 2

    @gizmos = new Kinetic.Group()
    @gizmos.add @kAllSegmentsGizmo
    #@gizmos.add @kActiveSegmentsGizmo
    @add @gizmos if @drawGizmos

    @add @kBody
    @add @kHead
    @add @kTail

  lastPoint: -> @capturePoints[@capturePoints.length - 1]
  pushPoint: (c) -> @capturePoints.push c
  segmentAngleAt: (i) ->
    if i is 0
      p0 = @capturePoints[i]
      p1 = @capturePoints[i + 1]
      return Coord2d.angleFromDiff p0.x, p0.y, p1.x, p1.y
    else if i is @capturePoints.length - 1
      p0 = @capturePoints[i-1]
      p1 = @capturePoints[i]
      return Coord2d.angleFromDiff p0.x, p0.y, p1.x, p1.y
    p0 = @capturePoints[i-1]
    p1 = @capturePoints[i]
    p2 = @capturePoints[i+1]
    a0 = Coord2d.angleFromDiff p0.x, p0.y, p1.x, p1.y
    a1 = Coord2d.angleFromDiff p1.x, p1.y, p2.x, p2.y
    a0 + 0.5 * (a1 - a0)

  captureSegment: (target) ->
    last = @lastPoint()
    newPoint = Coord2d.fromPolar @velocity, Coord2d.angleFromDiff(last.x, last.y, target.x, target.y)
    newPoint.add last
    @pushPoint newPoint

  update: (dt, target) ->
    isIntervalChange = false
    target = Coord2d.fromObject target
    @currentTime += dt
    if @currentTime >= @interval
      @currentTime -= @interval
      @captureSegment target
      isIntervalChange = true

    t = @currentTime / @interval

    pLen = @capturePoints.length
    body = @kBody.getPoints()
    head = @kHead.getPoints()
    tail = @kTail.getPoints()

    # Start gizmos
    if @drawGizmos
      # All segments
      newPoints = []
      for coord, i in @capturePoints
        newPoints.push coord.x
        newPoints.push coord.y
      @kAllSegmentsGizmo.setPoints newPoints

      # Active segments
      newPoints = []
      if pLen >= 4
        # Loop over the previously active segments
        for i in [0..pLen - 4]
          newPoints.push @capturePoints[i].x
          newPoints.push @capturePoints[i].y
          newPoints.push @capturePoints[i+1].x
          newPoints.push @capturePoints[i+1].y

      if pLen >= 3
        # Loop over the active segment
        activeStart = @capturePoints[pLen - 3]
        activeEnd = @capturePoints[pLen - 2]
        newPoints.push activeStart.x
        newPoints.push activeStart.y
        newPoints.push Math.lerp activeStart.x, activeEnd.x, t
        newPoints.push Math.lerp activeStart.y, activeEnd.y, t

        @kActiveSegmentsGizmo.setPoints newPoints
    # End gizmos

    # Draw the spline segments if enough points have been captured
    return if pLen < 3

    c1 = new Coord2d()
    c2 = new Coord2d()
    r = @tension * @velocity

    # Body segments
    if isIntervalChange

      # Trim the tail point
      if pLen > @maxSegments + 4
        @capturePoints.shift()
        pLen = @capturePoints.length
        body.splice 0, 8

      # Don't draw the body over the tail
      if @maxSegments >= 2
        while body.length > (@maxSegments - 2) * 8
          body.splice 0, 8

        if pLen >= 4
          # Add the new body segment
          p1 = @capturePoints[pLen - 4]
          p2 = @capturePoints[pLen - 3]
          c1.fromPolar r, @segmentAngleAt pLen - 4
          c1.add p1
          c2.fromPolar -r, @segmentAngleAt pLen - 3
          c2.add p2
          body.push p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y

    # Head segment
    if pLen >= 3
      p1 = @capturePoints[pLen - 3]
      p2 = @capturePoints[pLen - 2]
      c1.fromPolar r, @segmentAngleAt pLen - 3
      c1.add p1
      c2.fromPolar -r, @segmentAngleAt pLen - 2
      c2.add p2
      headPoints = Math.splitBezier p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y, 0, t

      if head.length is 0
        head.push.apply head, headPoints
      else
        head[i] = headPoints[i] for i in [0..7]

      #ctx = @getLayer().getContext()
      #grad = ctx.createLinearGradient p1.x, p1.y, p2.x, p2.y
      #grad.addColorStop 0, '#ffffff'
      #grad.addColorStop 1, '#000000'
      #@kHead.setStroke grad
      #@kHead.setStroke 'cyan'

    # Tail segment
    if pLen >= @maxSegments + 3
      i = if pLen < @maxSegments + 4 then 0 else 1
      p1 = @capturePoints[i]
      p2 = @capturePoints[i+1]
      c1.fromPolar r, @segmentAngleAt i
      c1.add p1
      c2.fromPolar -r, @segmentAngleAt i+1
      c2.add p2
      tailPoints = Math.splitBezier p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y, t, 1

      if tail.length is 0
        tail.push.apply tail, tailPoints
      else
        tail[i] = tailPoints[i] for i in [0..7]

