class Player
  attr_reader :x, :y, :width, :height, :velocity_y

  GRAVITY = 0.5
  JUMP_STRENGTH = -10
  START_X = 50
  START_Y = 500

  def initialize(window)
    @window = window
    @image = Gosu::Image.new('assets/player.png')
    @width = @image.width
    @height = @image.height
    reset_position
    @velocity_y = 0
    @on_ground = false
  end

  def reset_position
    @x = START_X
    @y = START_Y
    @velocity_y = 0
  end

  def update(platforms)
    @velocity_y += GRAVITY
    @y += @velocity_y

    @on_ground = false
    platforms.each do |platform|
      if collide_with?(platform)
        if @velocity_y >= 0 && (@y + @height) - platform.y < 20
          @y = platform.y - @height
          @velocity_y = 0
          @on_ground = true
        elsif @velocity_y < 0 && (platform.y + platform.height) - @y < 20
          @y = platform.y + platform.height
          @velocity_y = 0
        end
      end
    end

    if @window.button_down?(Gosu::KB_LEFT)
      @x -= 5
      platforms.each do |platform|
        if collide_with?(platform)
          @x = platform.x + platform.width
        end
      end
    end

    if @window.button_down?(Gosu::KB_RIGHT)
      @x += 5
      platforms.each do |platform|
        if collide_with?(platform)
          @x = platform.x - @width
        end
      end
    end

    @x = 0 if @x < 0
    @x = @window.map_width - @width if @x + @width > @window.map_width
    @y = 0 if @y < 0
    @y = @window.map_height - @height if @y + @height > @window.map_height

    if @window.button_down?(Gosu::KB_SPACE) && @on_ground
      @velocity_y = JUMP_STRENGTH
    end
  end

  def collide_with?(object)
    @x < object.x + object.width &&
      @x + @width > object.x &&
      @y < object.y + object.height &&
      @y + @height > object.y
  end

  def draw(camera_x, camera_y)
    @image.draw(@x - camera_x, @y - camera_y, 1)
  end
end
