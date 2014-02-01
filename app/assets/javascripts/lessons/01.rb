require 'webgl'
include WebGL

VERTEX_COUNTS = {
  triangle: 3,
  square: 4
}

VERTEX_SHADER = <<glsl
  attribute vec3 a_vertex_position;

  uniform mat4 u_mv_matrix;
  uniform mat4 u_p_matrix;

  void main(void) {
    gl_Position = u_p_matrix * u_mv_matrix * vec4(a_vertex_position, 1.0);
  }
glsl

FRAGMENT_SHADER = <<glsl
  precision mediump float;

  void main(void) {
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
  }
glsl

def setup_context
  canvas = $document[:canvas]
  $gl = Context.new(canvas)

  $gl.clear_color = [0, 0, 0, 1]
  $gl.enable(:depth_test)
end

def setup_shaders
  $shader_program = Program.new($gl)
  $shader_program.shaders << VERTEX_SHADER << FRAGMENT_SHADER

  $gl.link_program($shader_program)
  alert "Could not initialize shaders!" unless $shader_program.link_status
  $gl.use_program($shader_program)

  $vertex_pos_attribute = Attrib.new($shader_program, :a_vertex_position)
  $vertex_pos_attribute.enable

  $p_matrix_uniform = Uniform.new($shader_program, :u_p_matrix, :matrix_4fv)
  $mv_matrix_uniform = Uniform.new($shader_program, :u_mv_atrix, :matrix_4fv)
end

def setup_buffers
  $triangle_vertex_pos_buffer = Buffer.new($gl, :array)
  $gl.buffer = $triangle_vertex_pos_buffer
  triangle_vertices = [
     0,  1,  0,
    -1, -1,  0,
     1, -1,  0
  ]
  $gl.buffer_data = triangle_vertices, :static_draw

  $square_vertex_pos_buffer = Buffer.new($gl, :array)
  $gl.buffer = $square_vertex_pos_buffer
  square_vertices = [
     0,  1,  0,
    -1, -1,  0,
     1, -1,  0,
    -1, -1,  0
  ]
  $gl.buffer_data = square_vertices, :static_draw
end

def setup_matrices
  $p_matrix = Matrix4.new
  $mv_matrix = Matrix4.new
end

def set_matrix_uniforms
  $p_matrix_uniform.value = $p_matrix
  $mv_matrix_uniform.value = $mv_matrix
end

def draw_scene
  $gl.viewport = [0, 0, $gl.width, $gl.height]
  $gl.clear_buffers(:color, :depth)

  $p_matrix.perspective(45, $gl.width / $gl.height, 0.1, 100)

  $mv_matrix.identity

  $mv_matrix.translate(-1.5, 0, -7)
  $gl.buffer = $triangle_vertex_pos_buffer
  $gl.vertex_attrib_pointer($vertex_pos_attribute, VERTEX_COUNTS[:triangle])
  set_matrix_uniforms
  $gl.draw_arrays(:triangles, 0, 3)

  $mv_matrix.translate(-3, 0, 0)
  $gl.buffer = $square_vertex_pos_buffer
  $gl.vertex_attrib_pointer($vertex_pos_attribute, VERTEX_COUNTS[:square])
  set_matrix_uniforms
  $gl.draw_arrays(:triangle_strip, 0, 3)
end

def start
  setup_context
  setup_shaders
  setup_buffers
  setup_matrices

  draw_scene
end

$document.on('dom:load', &:start)
