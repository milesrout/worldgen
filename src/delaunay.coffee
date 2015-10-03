_ = require 'underscore'

random_in_range = (min, max) ->
  return Math.random() * (max - min) + min

class Triangulator
  constructor: (@width, @height) ->
 
  inside_circumcircle: (point, triangle) ->
    # TODO: check that triangle is counterclockwise-aligned
    a = triangle.a
    b = triangle.b
    c = triangle.c
    d = point
    det3([
      [a.x - d.x, a.y - d.y, (a.x^2 - d.x^2) + (a.y^2 - d.y^2)],
      [b.x - d.x, b.y - d.y, (b.x^2 - d.x^2) + (b.y^2 - d.y^2)],
      [c.x - d.x, c.y - d.y, (c.x^2 - d.x^2) + (c.y^2 - d.y^2)]
    ]) > 0

  generate_triangulation: (points) ->
    triangulation = []
    super_tri = @calculate_supertriangle()
    triangulation.push super_tri
    for point in points
      bad_triangles = []
      for triangle in triangulation
        if @inside_circumcircle(point, triangle)
          bad_triangles.push triangle
      for triangle in bad_triangles
        for edge in triangle.edges()
          bad_edges = _.flatten bad_triangles.map((triangle) -> triangle.edges)
          if edge in bad_edges
            polygon.push edge
      for triangle in bad_triangles
        triangulation.splice(triangulation.indexOf(triangle), 1)
      for edge in polygon
        new_tri = new Triangle(edge.from, edge.to, point)
        triangulation.push new_tri
    new_triangulation = []
    for triangle in triangulation
      vertices = triangle.vertices()
      if not (super_tri.a in vertices or super_tri.b in vertices or super_tri.c in vertices)
        new_triangulation.push triangle
    return new_triangulation
            
  calculate_supertriangle: () ->
    tan60over2 = Math.tan(60 * Math.PI/180) / 2
    extra_width = @height / tan60over2
    extra_height = @width * tan60over2
    new Triangle(new Point2D(-extra_width, @height), new Point2D(width + extra_width, @height), new Point2D(width / 2, -extra_height))

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
    ctx.fillRect(~~point.x, ~~point.y, 3, 3)

  distance_from: (p1, p2) ->
    Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2)

  prepare_line: (ctx, {from, to}) ->
    ctx.moveTo(from.x, from.y)
    ctx.lineTo(to.x, to.y)

  draw_triangles: (ctx) ->
    ctx.beginPath()
    for triangle in @triangles
      @prepare_line ctx, from: triangle.vertex_a, to: triangle.vertex_b
      @prepare_line ctx, from: triangle.vertex_b, to: triangle.vertex_c
    ctx.stroke()

  draw: (canvas_id) ->
    canvas = document.getElementById(canvas_id)
    ctx = canvas.getContext("2d")
    @draw_points ctx

class Point2D
  constructor: (@x, @y) ->

class Triangle
  constructor: (@a, @b, @c) ->
