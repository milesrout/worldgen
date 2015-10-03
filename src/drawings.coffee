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
  distance_from: (p1, p2) ->
    Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2)

  angle_of: (p1, p2) ->
    Math.atan2(p2.y - p1.y, p2.x - p1.x)

  prepare_line: (ctx, {from, to}) ->
    ctx.moveTo(from.x, from.y)
    ctx.lineTo(to.x, to.y)

  generate_triangles: () ->
    centre = new Point2D @width/2, @height/2
    points_ordered_by_distance_from_centre = _.sortBy @points, (p) => @distance_from(p, centre)
    starting_point = _.first points_ordered_by_distance_from_centre
    ordered_points = _.sortBy _.rest(points_ordered_by_distance_from_centre), (p) => @angle_of(starting_point, p)
    outer_pairs = _.zip ordered_points, _.rest(ordered_points).concat [_.first(ordered_points)]
    return outer_pairs.map (pair) -> new Triangle(starting_point, pair[0], pair[1])
    
  draw_triangles: (ctx) ->
    @triangles = @generate_triangles()
    ctx.beginPath()
    for triangle in @triangles
      @prepare_line ctx, from: triangle.vertex_a, to: triangle.vertex_b
      @prepare_line ctx, from: triangle.vertex_b, to: triangle.vertex_c
    ctx.stroke()

  # DRAW
  draw: (canvas_id) ->
    canvas = document.getElementById(canvas_id)
    ctx = canvas.getContext("2d")
    @draw_points ctx
    @draw_triangles ctx

class Point2D
  constructor: (@x, @y) ->

class Triangle
  constructor: (@vertex_a, @vertex_b, @vertex_c) ->

console.log 'end'
