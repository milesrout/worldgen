_ = require 'underscore'
# _ctx = undefined
# ctx = () ->
#   if _ctx?
#     canvas = document.getElementById('can1')
#     _ctx = canvas.getContext('2d')
#   }
#   _ctx
# }

random_in_range = (min, max) ->
  return Math.random() * (max - min) + min

window.WorldGenerator = class WorldGenerator
  constructor: (@density, @width, @height) ->

  # POINTS
  generate_points: () ->
    total_px = @width * @height
    num_points = total_px * @density
    (@random_point() for i in [0...num_points])
	
  random_point: () ->
    return new Point2D (random_in_range 0, @width), (random_in_range 0, @height)

  draw_points: (ctx) ->
    @points = @generate_points()
    (@draw_point ctx, point for point in @points)

  draw_point: (ctx, point) ->
    ctx.fillRect(~~point.x, ~~point.y, 1, 1)

  # LINES
  draw_lines: (ctx) ->
    # select the point closest to the centre
    # order all other points by the gradient of the line from the selected point to that point.
    # for each point P[j], record the triangle ABC where A is the starting point, B is P[j] and C is P[j+1]

  # DRAW
  draw: (canvas_id) ->
    canvas = document.getElementById(canvas_id)
    ctx = canvas.getContext("2d")
    @draw_points ctx
    @draw_lines ctx

class Point2D
  constructor: (@x, @y) ->

