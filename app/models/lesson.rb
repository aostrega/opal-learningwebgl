class Lesson
  class << self
    alias_method :find, :new

    def all
      lessons_path = Rails.root + "app/assets/javascripts/lessons"
      Dir.chdir(lessons_path)
      lesson_files = Dir['*']
      lesson_ids = lesson_files.map { |lf| lf[/\d+/] }
      lesson_ids.map { |id| Lesson.find(id) }
    end
  end

  def initialize(id)
    @id = id
  end

  attr_reader :id

  def script_path
    "lessons/#{id}.js"
  end
end
