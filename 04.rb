require 'webgl'
include WebGL

VERTEX_COUNTS = {
  triangle: 3,
  square: 4
}

VERTEX_SHADER = <<glsl
  attribute vec3 a_vertex_position;
  attribute vec4 a_vertex_color;

  uniform mat4 u_mv_matrix;
  uniform mat4 u_p_matrix;

  varying vec4 v_color;

  void main(void) {
    gl_Position = u_p_matrix * u_mv_matrix * vec4(a_vertex_position, 1.0);
    v_color = a_vertex_color;
  }
glsl

FRAGMENT_SHADER = <<glsl
  precision mediump float;

  varying vec4 v_color;

  void main(void) {
    gl_FragColor = v_color;
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

  $vertex_col_attribute = Attrib.new($shader_program, :a_vertex_color)
  $vertex_col_attribute.enable

  $p_matrix_uniform = Uniform.new($shader_program, :u_p_matrix, :matrix_4fv)
  $mv_matrix_uniform = Uniform.new($shader_program, :u_mv_atrix, :matrix_4fv)
end

def setup_buffers
  $pyramid_vertex_pos_buffer = Buffer.new($gl, :array)
  $gl.buffer = $pyramid_vertex_pos_buffer
  pyramid_vertices = [
    # Front
     0,  1,  0,
    -1, -1,  1,
     1, -1,  1,
    # Right
     0,  1,  0,
     1, -1,  1,
     1, -1, -1,
    # Back
     0,  1,  0,
     1, -1, -1,
    -1, -1, -1,
    # Left
     0,  1,  0,
    -1, -1, -1,
    -1, -1,  1
  ]
  $gl.buffer_data = pyramid_vertices, :static_draw

  $pyramid_vertex_col_buffer = Buffer.new($gl, :array)
  $gl.buffer = $pyramid_vertex_col_buffer
  pyramid_colors = [
    # Front
    1, 0, 0, 1,
    0, 1, 0, 1,
    0, 0, 1, 1,
    # Right
    1, 0, 0, 1,
    0, 0, 1, 1,
    0, 1, 0, 1,
    # Back
    1, 0, 0, 1,
    0, 1, 0, 1,
    0, 0, 1, 1,
    # Left
    1, 0, 0, 1,
    0, 0, 1, 1,
    0, 1, 0, 1
  ]
  $gl.buffer_data = pyramid_colors, :static_draw

  $cube_vertex_pos_buffer = Buffer.new($gl, :array)
  $gl.buffer = $cube_vertex_pos_buffer
  cube_vertices = [
    # Front
    -1, -1,  1,
     1, -1,  1,
     1,  1,  1,
    -1,  1,  1,

    # Back
    -1, -1, -1,
    -1,  1, -1,
     1,  1, -1,
     1, -1, -1,

    # Top
    -1,  1, -1,
    -1,  1,  1,
     1,  1,  1,
     1,  1, -1,

    # Bottom
    -1, -1, -1,
     1, -1, -1,
     1, -1,  1,
    -1, -1,  1,

    # Right
     1, -1, -1,
     1,  1, -1,
     1,  1,  1,
     1, -1,  1,

    # Left
    -1, -1, -1,
    -1, -1,  1,
    -1,  1,  1,
    -1,  1, -1,
  ]
  $gl.buffer_data = cube_vertices, :static_draw

  $cube_vertex_col_buffer = Buffer.new($gl, :array)
  $gl.buffer = $cube_vertex_col_buffer
  cube_colors = [
    [1, 0, 0, 1],     # Front
    [1, 1, 0, 1],     # Back
    [0, 1, 0, 1],     # Top
    [1, 0.5, 0.5, 1], # Bottom
    [1, 0, 1, 1],     # Right
    [0, 0, 1, 1],     # Left
  ].flat_map { |c| c * 4 }
  $gl.buffer_data = cube_colors, :static_draw

  $cube_vertex_ind_buffer = Buffer.new($gl, :element_array)
  $gl.buffer = $cube_vertex_ind_buffer
  cube_vertex_indices = [
    0, 1, 2,     0, 2, 3,    # Front
    4, 5, 6,     4, 6, 7,    # Back
    8, 9, 10,    8, 10, 11,  # Top
    12, 13, 14,  12, 14, 15, # Bottom
    16, 17, 18,  16, 18, 19, # Right
    20, 21, 22,  20, 22, 23  # Left
  ]
  $gl.buffer_data = cube_vertex_indices, :static_draw
end

def setup_other
  $p_matrix = Matrix4.new
  $mv_matrix = Matrix4.new
  $mv_matrices = []
  $pyramid_rot = Angle.new
  $cube_rot = Angle.new
  $last_time = 0
end

def push_mv_matrix
  $mv_matrices << $mv_matrix.dup
end

def pop_mv_matrix
  $mv_matrix = $mv_matrices.pop
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
  push_mv_matrix
  $mv_matrix.rotate_y($pyramid_rot)
  $gl.buffer = $pyramid_vertex_pos_buffer
  $gl.vertex_attrib_pointer($vertex_pos_attribute, VERTEX_COUNTS[:triangle])
  $gl.buffer = $pyramid_vertex_col_buffer
  $gl.vertex_attrib_pointer($vertex_col_attribute, 4)
  set_matrix_uniforms
  $gl.draw_arrays(:triangles, 0, 3)
  pop_mv_matrix

  $mv_matrix.translate(-3, 0, 0)
  push_mv_matrix
  $mv_matrix.rotate($cube_rot)
  $gl.buffer = $cube_vertex_pos_buffer
  $gl.vertex_attrib_pointer($vertex_pos_attribute, VERTEX_COUNTS[:square])
  $gl.buffer = $cube_vertex_col_buffer
  $gl.vertex_attrib_pointer($vertex_col_attribute, 4)
  $gl.buffer = $cube_vertex_ind_buffer
  set_matrix_uniforms
  $gl.draw_elements(:triangles, 36, :unsigned_short)
  pop_mv_matrix
end

def animate
  time = Time.now
  elapsed_time = time - $last_time
  $pyramid_rot.degrees += 90 * elapsed_time
  $cube_rot.degrees -= 75 * elapsed_time
  $last_time = time
end

def tick
  request_animation_frame(tick)
  draw_scene
  animate
end

def start
  setup_context
  setup_shaders
  setup_buffers
  setup_other

  tick
end

$document.on('dom:load', &:start)
