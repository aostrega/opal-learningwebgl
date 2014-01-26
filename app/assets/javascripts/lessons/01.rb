$document.on :DOMContentLoaded do
  canvas = $document[:canvas]
  canvas.style.apply {
    background color: :black
  }

  puts 'done!'
end
