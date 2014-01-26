require 'browser/canvas'

$document.on :DOMContentLoaded do
  canvas = Browser::Canvas.new($document[:canvas])

  canvas.rect(20, 30, 40, 50)
  canvas.fill
end
