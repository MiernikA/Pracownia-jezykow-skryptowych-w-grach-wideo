class Collectible
  attr_reader :x, :y, :width, :height

  def initialize(x, y)
    @x = x
    @y = y
    @image = Gosu::Image.new("assets/coin.png", tileable: true)
    @width = @image.width
    @height = @image.height
    @collected = false
  end

  def collected?
    @collected
  end

  def collect
    @collected = true
  end

  def draw(camera_x, camera_y)
    return if collected?
    @image.draw(@x - camera_x, @y - camera_y, 1)
  end
end
