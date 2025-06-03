class Platform
  attr_reader :x, :y, :width, :height

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def draw(camera_x, camera_y)
    Gosu.draw_rect(@x - camera_x, @y - camera_y, @width, @height, Gosu::Color.argb(0xffa03a05))
  end
end
