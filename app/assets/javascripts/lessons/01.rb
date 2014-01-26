require 'browser/webgl_canvas'

$document.on 'dom:load' do
  gl = Browser::WebGLCanvas.new($document[:canvas])

  gl.clearColor(0.0, 0.5, 1.0, 1.0)
  gl.clear(gl.COLOR_BUFFER_BIT)
end
