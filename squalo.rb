require 'gosu'

module ZOrder
  Background, Fish, Shark, UI = *0..3
end

Width = 800
Height = 480
class GameWindow < Gosu::Window
  def initialize
    super Width, Height, false
    self.caption = '🐟'
    @background_image = Gosu::Image.new(self, "underwater.jpg", true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @player = Shark.new(self)
    @player.warp(320, 240)
    @player.go_right
  end

  def fishes
    @fishes ||= []
  end
  attr_writer :fishes

  def update
    @player.go_left  if left?
    @player.go_right if right?
    @player.go_up    if up?
    @player.go_down  if down?

    unless fishes.any?
      self.fishes += [
        Fish.new(self),
        Fish.new(self),
        Fish.new(self),
        Fish.new(self),
      ]
    end
    fishes.each(&:move)

    @player.move
    @player.eats_fish(fishes)
  end

  def left?
    button_down? Gosu::KbLeft or button_down? Gosu::GpLeft
  end
  def right?
    button_down? Gosu::KbRight or button_down? Gosu::GpRight
  end
  def up?
    button_down? Gosu::KbUp or button_down? Gosu::GpButton0
  end
  def down?
    button_down? Gosu::KbDown
  end

  def draw
    @player.draw
    fishes.each(&:draw)
    @background_image.draw(0, 0, ZOrder::Background)
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

class Shark
  def initialize(window)
    @window = window
    setup
  end
  attr_reader :window, :x, :y, :score

  def setup
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
    @direction = :r

    @splash = Gosu::Sample.new(window, 'water.wav')
    @chomp = Gosu::Sample.new(window, 'chomp.wav')
  end

  def eats_fish(fishes)
    if fishes.reject! {|fish| Gosu::distance(mouth_x, @y, fish.x, fish.y) < 60 }
      @score += 1
      @eat = Time.now
      chomp!
    end
  end

  def just_eat?
    @eat and Time.now.to_f - @eat.to_f < 0.2
  end

  def mouth_x
    right? ? @x + 100 : @x - 100
  end

  def splash!
    unless splashing?
      @played = Time.now
      @splash.play
    end
  end

  def chomp!
    @chomp.play
  end

  def splashing?
    @played and (Time.now.to_f - @played.to_f) < 1.0
  end

  def image= file
    @image = self.class.image file, @window
  end

  def self.image file, window
    @images ||= Hash.new
    @images[file] = Gosu::Image.new(window, file, false)
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= Width
    @y %= Height
    decelerate
  end

  def decelerate
    @vel_x *= 0.95
    @vel_y *= 0.95
  end

  def draw
    update_image
    @image.draw_rot(@x, @y, 1, @angle)
  end

  def go_left
    splash!
    @vel_x = -10
  end

  def go_right
    splash!
    @vel_x = 10
  end

  def update_image
    path = name
    path << '-open' if just_eat?
    path << "-#{right? ? :r : :l}"
    path << ".#{ext}"
    self.image = path
  end

  def name
    'shark'
  end

  def ext
    'png'
  end

  def right?
    @vel_x > 0
  end

  def go_up
    @vel_y = -3
    splash!
  end

  def go_down
    @vel_y = 3
    splash!
  end
end


class Fish < Shark
  def setup
    super
    @vel_x = 5 * (rand - 0.5)
    @vel_y = 1 * (rand - 0.5)
    @y = 40 + rand(Height)/2
  end

  def name
    @n ||= rand(4)+1
    "fish/fish-#{@n}"
  end

  def ext
    'png'
  end

  def decelerate
    # noop
  end

  def splash!
    # noop
  end
end

window = GameWindow.new
window.show
