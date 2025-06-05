class Enemy
  attr_reader :x, :y, :width, :height

  def initialize(x, y)
    @x = x
    @y = y
    @width = 50
    @height = 40
    @image = Gosu::Image.new('assets/enemy.png')
    @scale_x = @width.to_f / @image.width
    @scale_y = @height.to_f / @image.height
    @alive = true
  end

  def alive?
    @alive
  end

  def kill
    @alive = false
  end

  def draw(camera_x, camera_y)
    return unless alive?
    @image.draw(@x - camera_x, @y - camera_y, 1, @scale_x, @scale_y)
  end
end
