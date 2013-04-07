$:.unshift "#{__dir__}/lib"

require 'fish'
require 'gosu_dsl'
# require 'profile'

$media_dir = "#{__dir__}/squalo"

module ZOrder
  Background, LittleFish, Shark, UI = *0..3
end

Width = 800
Height = 480


class GameWindow < Gosu::Window
  include GosuDsl::Media
  include GosuDsl::Keyboard

  def initialize
    super Width, Height, false
    self.caption = '🐟'
    @background_image = image('underwater.jpg', true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @player = Shark.new(self)
    @player.warp(320, 240)
    @player.go_right
  end

  def window
    self
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
        LittleFish.new(self),
        LittleFish.new(self),
        LittleFish.new(self),
        LittleFish.new(self),
        LittleFish.new(self),
        LittleFish.new(self),
        LittleFish.new(self),
        LittleFish.new(self),
      ]
    end
    fishes.each(&:move)

    @player.move
    @player.eats_fish(fishes)
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

class Shark < Fish
  prepend Collector

  def name
    base_name = 'shark'
    base_name += '-open' if just_eat?
    base_name
  end


  def ext
    'png'
  end

  attr_reader :score

  def chomp!
    chomp.play
  end

  def chomp
    @chomp ||= sample('chomp.wav')
  end

  def setup
    super
    @score = 0
    @splash = sample('water.wav')
    @chomp = sample('chomp.wav')
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

  def splashing?
    @played and (Time.now.to_f - @played.to_f) < 1.0
  end

  def go_left
    splash!
    @vel_x = -10
  end

  def go_right
    splash!
    @vel_x = 10
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


class LittleFish < Fish
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
