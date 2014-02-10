class @Stream extends Kinetic.Group
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
    initPoint = if config.origin? then config.origin else x:0, y:0
    @capturePoints = [ Coord2d.fromObject initPoint ]
    @currentTime = @interval

    # Gizmos
    @kAllSegmentsGizmo = new Kinetic.Line
      points: []
      stroke: 'red'
      strokeWidth: 1
    @kHeadSegmentGizmo = new Kinetic.Line
      points: []
      stroke: 'yellow'
      strokeWidth: 1
    @kTailSegmentGizmo = new Kinetic.Line
      points: []
      stroke: 'yellow'
      strokeWidth: 1
    @kBodySegmentsGizmo = new Kinetic.Line
      points: []
      stroke: 'lime'
      strokeWidth: 1

    @kBody = new Bezier
      points: []
      stroke: 'black'
      strokeWidth: 2
    @kHead = new Bezier
      points: []
      stroke: 'cyan'
      strokeWidth: 2
    @kTail = new Bezier
      points: []
      stroke: 'cyan'
      strokeWidth: 2

    @gizmos = new Kinetic.Group()
    @gizmos.add @kAllSegmentsGizmo
    #@gizmos.add @kHeadSegmentGizmo
    #@gizmos.add @kTailSegmentGizmo
    #@gizmos.add @kBodySegmentsGizmo
    @add @gizmos if @drawGizmos

    @add @kBody
    @add @kHead
    @add @kTail

  lastPoint: -> @capturePoints[@capturePoints.length - 1]
  pushPoint: (c) -> @capturePoints.push c
  segmentAngleAt: (i) ->
    # This gets called a lot. I should consider caching it.
    if i is 0
      p0 = @capturePoints[i]
      p1 = @capturePoints[i + 1]
      return Coord2d.angleFrom p0.x, p0.y, p1.x, p1.y
    else if i is @capturePoints.length - 1
      p0 = @capturePoints[i-1]
      p1 = @capturePoints[i]
      return Coord2d.angleFrom p0.x, p0.y, p1.x, p1.y
    p0 = @capturePoints[i-1]
    p1 = @capturePoints[i]
    p2 = @capturePoints[i+1]
    a0 = Coord2d.angleFrom p0.x, p0.y, p1.x, p1.y
    a1 = Coord2d.angleFrom p1.x, p1.y, p2.x, p2.y
    Coord2d.midAngleBetween a0, a1
  controlPointAt: (r, i) ->
    c = Coord2d.fromPolar r, @segmentAngleAt i
    c.add @capturePoints[i]
  captureSegment: (target) ->
    last = @lastPoint()
    newPoint = Coord2d.fromPolar @velocity, Coord2d.angleFrom(last.x, last.y, target.x, target.y)
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

    if isIntervalChange
      # Trim the tail point
      if pLen > @maxSegments + 4
        @capturePoints.shift()
        pLen = @capturePoints.length

    tHead = t - @headFadeLength
    tTail = t + @tailFadeLength
    iTail = if pLen < @maxSegments + 2 then -1 else pLen - @maxSegments - 2
    iHead = pLen - 3
    iBodyTail = if tTail < 1 then iTail-1 else iTail
    iBodyHead = if tHead > 0 then iHead else iHead-1
    iBody = Math.max iBodyTail+1, 0
    r = @tension * @velocity

    #console.log "pLen:#{pLen}, iTail:#{iTail}, iBodyTail:#{iBodyTail}, iBody:#{iBody}, iBodyHead:#{iBodyHead}, iHead:#{iHead}, t:#{t}, tTail:#{tTail}, tHead:#{tHead}"

    # Tail segment
    if pLen >= @maxSegments + 2
      tailPoints = []
      if tTail < 1
        if pLen >= @maxSegments + 3
          p0 = @capturePoints[iTail-1]
          p1 = @capturePoints[iTail]
          c1 = @controlPointAt r, iTail-1
          c2 = @controlPointAt -r, iTail
          tailPoints.push.apply tailPoints, Math.splitBezier p0.x, p0.y, c1.x, c1.y, c2.x, c2.y, p1.x, p1.y, t, tTail
      else
        # Tail is made up of two partial beziers
        # Go forward one more segment
        p1 = @capturePoints[iTail]
        p2 = @capturePoints[iTail+1]
        if pLen >= @maxSegments + 3
          p0 = @capturePoints[iTail-1]
          c1 = @controlPointAt r, iTail-1
          c2 = @controlPointAt -r, iTail
          tailPoints.push.apply tailPoints, Math.splitBezier p0.x, p0.y, c1.x, c1.y, c2.x, c2.y, p1.x, p1.y, t, 1
        c1 = @controlPointAt r, iTail
        c2 = @controlPointAt -r, iTail+1
        tailPoints.push.apply tailPoints, Math.splitBezier p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y, 0, tTail - 1

      tLen = tailPoints.length
      if tLen > 0
        if iTail > 0
          gradRad = Coord2d.distBetween tailPoints[0], tailPoints[1], tailPoints[tLen-2], tailPoints[tLen-1]
        else
          gradRad = @velocity * @tailFadeLength
        ctx = @getLayer().getContext()
        # This is grossly horribly inefficient, but ok for now
        grad = ctx.createRadialGradient tailPoints[tLen-2], tailPoints[tLen-1], 0, tailPoints[tLen-2], tailPoints[tLen-1], gradRad
        grad.addColorStop 0, chroma(@stroke).alpha(1).css()
        grad.addColorStop 1, chroma(@stroke).alpha(0).css()
        @kTail.setStroke grad

      @kTail.setStrokeWidth @strokeWidth
      @kTail.setOpacity @opacity
      @kTail.setPoints tailPoints

    # Body
    if pLen > 2
      bodyPoints = []

      # Body tail
      if pLen >= @maxSegments + 2 and iBodyTail >= 0
        # Doesn't work right if maxSegments === 1
        tBodyTail = if tTail > 1 then tTail-1 else tTail
        p1 = @capturePoints[iBodyTail]
        p2 = @capturePoints[iBodyTail+1]
        c1 = @controlPointAt r, iBodyTail
        c2 = @controlPointAt -r, iBodyTail+1
        bodyPoints.push.apply bodyPoints, Math.splitBezier p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y, tBodyTail, 1

      # Full interior body segments
      if pLen > 3 and iBody >= 0 and iBodyHead >= 1
        for i in [iBody..iBodyHead-1]
          p1 = @capturePoints[i]
          p2 = @capturePoints[i+1]
          c1 = @controlPointAt r, i
          c2 = @controlPointAt -r, i+1
          bodyPoints.push p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y

      # Body head
      if pLen >= 3 and iBodyHead >= 0
        tBodyHead = if tHead < 0 then tHead+1 else tHead
        p1 = @capturePoints[iBodyHead]
        p2 = @capturePoints[iBodyHead+1]
        c1 = @controlPointAt r, iBodyHead
        c2 = @controlPointAt -r, iBodyHead+1
        bodyPoints.push.apply bodyPoints, Math.splitBezier p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y, 0, tBodyHead

      @kBody.setStroke @stroke
      @kBody.setStrokeWidth @strokeWidth
      @kBody.setOpacity @opacity
      @kBody.setPoints bodyPoints

    # Head segment
    if pLen > 2
      headPoints = []
      p1 = @capturePoints[iHead]
      p2 = @capturePoints[iHead+1]
      if tHead > 0
        c1 = @controlPointAt r, iHead
        c2 = @controlPointAt -r, iHead+1
        headPoints.push.apply headPoints, Math.splitBezier p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y, tHead, t
      else
        # Head is made up of two partial beziers
        if pLen >= 4
          p0 = @capturePoints[iHead-1]
          c1 = @controlPointAt r, iHead-1
          c2 = @controlPointAt -r, iHead
          headPoints.push.apply headPoints, Math.splitBezier p0.x, p0.y, c1.x, c1.y, c2.x, c2.y, p1.x, p1.y, 1 + tHead, 1
        c1 = @controlPointAt r, iHead
        c2 = @controlPointAt -r, iHead+1
        headPoints.push.apply headPoints, Math.splitBezier p1.x, p1.y, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y, 0, t

      hLen = headPoints.length
      if iBodyHead >= 0
        gradRad = Coord2d.distBetween headPoints[0], headPoints[1], headPoints[hLen-2], headPoints[hLen-1]
      else
        gradRad = @velocity * @headFadeLength
      ctx = @getLayer().getContext()
      # This is grossly horribly inefficient, but ok for now
      grad = ctx.createRadialGradient headPoints[hLen-2], headPoints[hLen-1], 0, headPoints[hLen-2], headPoints[hLen-1], gradRad
      grad.addColorStop 0, chroma(@stroke).alpha(0).css()
      grad.addColorStop 1, chroma(@stroke).alpha(1).css()
      @kHead.setStroke grad

      @kHead.setStrokeWidth @strokeWidth
      @kHead.setOpacity @opacity
      @kHead.setPoints headPoints

    # Start gizmos
    if @drawGizmos
      # All segments
      newPoints = []
      for coord, i in @capturePoints
        newPoints.push coord.x, coord.y
      @kAllSegmentsGizmo.setPoints newPoints

      # Body segments
      if pLen >= 3
        newPoints = []

        # Body tail
        if pLen >= @maxSegments + 3
          i = if pLen < @maxSegments + 4 then 0 else 1
          p1 = @capturePoints[i]
          p2 = @capturePoints[i+1]
          tTailStart = t + @tailFadeLength
          if tTailStart < 1
            pStartx = Math.lerp p1.x, p2.x, tTailStart
            pStarty = Math.lerp p1.y, p2.y, tTailStart
            pEndx = p2.x
            pEndy = p2.y
          else
            p3 = @capturePoints[i+2]
            pStartx = Math.lerp p2.x, p3.x, tTailStart - 1
            pStarty = Math.lerp p2.y, p3.y, tTailStart - 1
            pEndx = p3.x
            pEndy = p3.y
          newPoints.push pStartx, pStarty, pEndx, pEndy

        # Body head
        p1 = @capturePoints[pLen - 3]
        p2 = @capturePoints[pLen - 2]
        tHeadStart = t - @headFadeLength
        if tHeadStart > 0
          pStartx = p1.x
          pStarty = p1.y
          pEndx = Math.lerp p1.x, p2.x, tHeadStart
          pEndy = Math.lerp p1.y, p2.y, tHeadStart
        else if pLen >= 4
          p0 = @capturePoints[pLen - 4]
          pStartx = p0.x
          pStarty = p0.y
          pEndx = Math.lerp p0.x, p1.x, 1 + tHeadStart
          pEndy = Math.lerp p0.y, p1.y, 1 + tHeadStart
        newPoints.push pStartx, pStarty, pEndx, pEndy

        #@kBodySegmentsGizmo.setPoints newPoints

      # Tail segment
      if pLen >= @maxSegments + 3
        newPoints = []
        i = if pLen < @maxSegments + 4 then 0 else 1
        p1 = @capturePoints[i]
        p2 = @capturePoints[i+1]
        pStartx = Math.lerp p1.x, p2.x, t
        pStarty = Math.lerp p1.y, p2.y, t
        tDiff = t + @tailFadeLength
        if tDiff < 1
          pEndx = Math.lerp p1.x, p2.x, tDiff
          pEndy = Math.lerp p1.y, p2.y, tDiff
          newPoints.push pStartx, pStarty, pEndx, pEndy
        else
          # Tail is made up of two partial beziers
          # Go forward one more segment
          p3 = @capturePoints[i+2]
          pEndx = Math.lerp p2.x, p3.x, tDiff - 1
          pEndy = Math.lerp p2.y, p3.y, tDiff - 1
          newPoints.push pStartx, pStarty, p2.x, p2.y, pEndx, pEndy

        @kTailSegmentGizmo.setPoints newPoints

      # Head segment
      if pLen >= 3
        newPoints = []
        p1 = @capturePoints[pLen - 3]
        p2 = @capturePoints[pLen - 2]
        pEndx = Math.lerp p1.x, p2.x, t
        pEndy = Math.lerp p1.y, p2.y, t
        tHeadStart = t - @headFadeLength
        if tHeadStart > 0
          pStartx = Math.lerp p1.x, p2.x, tHeadStart
          pStarty = Math.lerp p1.y, p2.y, tHeadStart
          newPoints.push pStartx, pStarty, pEndx, pEndy
        else
          # Head is made up of two partial beziers
          if pLen >= 4
            # Go back one more segment
            p0 = @capturePoints[pLen - 4]
            pStartx = Math.lerp p0.x, p1.x, 1 + tHeadStart
            pStarty = Math.lerp p0.y, p1.y, 1 + tHeadStart
            newPoints.push pStartx, pStarty, p1.x, p1.y, pEndx, pEndy
          else
            newPoints.push p1.x, p1.y, pEndx, pEndy
        @kHeadSegmentGizmo.setPoints newPoints
    # End gizmos

