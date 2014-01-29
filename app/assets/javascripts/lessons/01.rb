require 'browser/webgl'
include Browser::WebGL

VERTEX_COUNTS = {
  triangle: 3,
  square: 4
}

VERTEX_SHADER = <<-glsl
  attribute vec3 vertex_position;

  uniform mat4 u_mv_matrix;
  uniform mat4 u_p_matrix;

  void main(void) {
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  }
glsl

FRAGMENT_SHADER = <<-glsl
  precision mediump float;

  void main(void) {
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
  }
glsl

def setup_shaders
  $shader_program = Program.new($gl)
  $shader_program.shaders << VERTEX_SHADER << FRAGMENT_SHADER

  $gl.link_program($shader_program)
  alert "Could not initialize shaders!" unless $shader_program.link_status
  $gl.use_program($shader_program)

  $vertex_postion = $shader_program.attrib_location(:vertex_position)
  $gl.enable_vertex_attrib_array($vertex_position)

  $p_matrix_uniform = $shader_program.uniform(:u_p_matrix)
  $mv_matrix_uniform = $shader_program.uniform(:u_mv_atrix)
end

def setup_buffers
  $triangle_vertex_pos_buffer = Buffer.new($gl)
  $gl.bind_buffer(:array, $triangle_vertex_pos_buffer)
  triangle_vertices = [
     0,  1,  0,
    -1, -1,  0,
     1, -1,  0
  ]
  $gl.buffer_data(:array, triangle_vertices, :static_draw)

  $square_vertex_pos_buffer = Buffer.new($gl)
  $gl.bind_buffer(:array, $square_vertex_pos_buffer)
  square_vertices = [
     0,  1,  0,
    -1, -1,  0,
     1, -1,  0,
    -1, -1,  0
  ]
  $gl.buffer_data(:array, vertices, :static_draw)
end

def set_matrix_uniforms
  $p_matrix_uniform.set_4fv($p_matrix, false)
  $mv_matrix_uniform.set_4fv($mv_matrix, false)
end

def draw_scene
  $gl.viewport(0, 0, $gl.width, $gl.height)
  $gl.clear_buffers(:color, :depth)

  $p_matrix.perspective(45, $gl.width / $gl.height, 0.1, 100)

  $mv_matrix.identity

  $mv_matrix.translate(-1.5, 0, -7)
  $gl.bind_buffer(:array, $triangle_vertex_pos_buffer)
  $gl.vertex_attrib_pointer($shader_program.vertex_pos, VERTEX_COUNTS[:triangle], :float, false, 0, 0)
  set_matrix_uniforms
  $gl.draw_arrays(:triangles, 0, 3)

  $mv_matrix.translate(-3, 0, 0)
  $gl.bind_buffer(:array, $square_vertex_pos_buffer)
  $gl.vertex_attrib_pointer($shader_program.vertex_pos, VERTEX_COUNTS[:square], :float, false, 0, 0)
  set_matrix_uniforms
  $gl.draw_arrays(:triangle_strip, 0, 3)
end

def start
  canvas = $document[:canvas]
  $gl = Context.new(canvas)

  $gl.clear_color = [0, 0, 0, 1]
  $gl.enable(:depth_test)

  setup_shaders
  setup_buffers

  $p_matrix = Matrix4.new
  $mv_matrix = Matrix4.new

  draw_scene
end

$document.on('dom:load', &:start)
