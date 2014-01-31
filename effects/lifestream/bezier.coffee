
class @Bezier extends Kinetic.Shape
  constructor: (config) ->
    @___init config
  ___init: (config) ->
    Kinetic.Shape.call @, config
    @className = 'Bezier'
    @sceneFunc @_sceneFunc
  _sceneFunc: (context) ->
    p = @getPoints()
    # Number of points should be a multiple of 8
    unless p.length % 8 is 0
      throw new Error "Bezier points.length needs to be a multiple of 8, was '#{p.length}'"

    for p0x, i in p by 8
      context.beginPath()
      context.moveTo p[i], p[i+1]
      context.bezierCurveTo p[i+2], p[i+3], p[i+4], p[i+5], p[i+6], p[i+7]
      context.fillStrokeShape(@)

Kinetic.Factory.addGetterSetter(Bezier, 'points');