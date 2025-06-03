require 'gosu'
require_relative 'player'
require_relative 'platform'
require_relative 'collectible'
require_relative 'enemy'

class GameWindow < Gosu::Window
  MAX_LIVES = 3
  attr_reader :map_width, :map_height

  def initialize
    super 1280, 720
    self.caption = "Platformer with Textures"

    @font = Gosu::Font.new(20)

    @map_width = 2560
    @map_height = 900

    @background_image = Gosu::Image.new('assets/bg.png')

    reset_game
  end

  def reset_game
    @player = Player.new(self)

    @platforms = [
      Platform.new(0, 800, 500, 50),
      Platform.new(100, 720, 120, 30),
      Platform.new(300, 700, 90, 30),
      Platform.new(500, 640, 130, 30),
      Platform.new(700, 800, 600, 50),
      Platform.new(750, 640, 130, 30),
      Platform.new(950, 600, 100, 30),
      Platform.new(1200, 580, 100, 30),
    ]

    @collectibles = [
      Collectible.new(50, 770),
      Collectible.new(130, 690),
      Collectible.new(320, 670),
      Collectible.new(550, 610),
      Collectible.new(770, 610),
      Collectible.new(980, 570),
      Collectible.new(1220, 550),
      Collectible.new(1150, 760),
    ]

    @enemies = [
      Enemy.new(240, 760),
      Enemy.new(580, 600),
      Enemy.new(1050, 760),
      Enemy.new(1200, 760),
    ]

    @score = 0
    @lives = MAX_LIVES
    @game_over = false
    @game_won = false

    @camera_x = 0
    @camera_y = 0
  end

  def update
    return if @game_over || @game_won

    @player.update(@platforms)

    margin = 150
    if @player.x - @camera_x > width - margin
      @camera_x = 0
      @camera_y = 0
    elsif @player.x - @camera_x < margin
      @camera_x = [@player.x - margin, 0].max
    end

    @camera_y = @map_height - height

    @collectibles.each do |c|
      if !c.collected? && @player.collide_with?(c)
        c.collect
        @score += 1
        @game_won = true if @score == @collectibles.size
      end
    end

    lose_life if @player.y + @player.height >= @map_height

    @enemies.each do |enemy|
      next unless enemy.alive?

      if @player.collide_with?(enemy)
        player_bottom = @player.y + @player.height
        enemy_top = enemy.y
        if @player.velocity_y > 0 && (player_bottom <= enemy_top + 10)
          enemy.kill
          @player.instance_variable_set(:@velocity_y, Player::JUMP_STRENGTH / 2)
        else
          lose_life
        end
      end
    end
  end

  def lose_life
    @lives -= 1
    if @lives <= 0
      @game_over = true
    else
      @player.reset_position
    end
  end

  def draw
    scale_x = width.to_f / @background_image.width
    scale_y = height.to_f / @background_image.height
    @background_image.draw(0, 0, 0, scale_x, scale_y)

    @platforms.each { |p| p.draw(@camera_x, @camera_y) }
    @player.draw(@camera_x, @camera_y)
    @collectibles.each { |c| c.draw(@camera_x, @camera_y) }
    @enemies.each { |e| e.draw(@camera_x, @camera_y) }

    @font.draw_text("Score: #{@score}", 10, 10, 1, 1, 1, Gosu::Color::WHITE)
    @font.draw_text("Lives: #{@lives}", 10, 35, 1, 1, 1, Gosu::Color::WHITE)

    if @game_over
      @font.draw_text("GAME OVER! Press R to restart", 150, 200, 2, 1.5, 1.5, Gosu::Color::RED)
    end

    if @game_won
      @font.draw_text("CONGRATULATIONS! YOU WON! Press R to restart", 100, 200, 2, 1.5, 1.5, Gosu::Color::GREEN)
    end
  end

  def button_down(id)
    reset_game if (@game_over || @game_won) && id == Gosu::KB_R
  end
end

window = GameWindow.new
window.show
