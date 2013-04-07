$:.unshift "#{__dir__}/lib"
require 'fish'
$media_dir = "#{__dir__}/sirenetta"

module ZOrder
  Background, LittleFish, Shark, UI = *0..3
end

class SirenettaGame < Game
  include GosuDsl::Media
  include GosuDsl::Keyboard

  def setup
    self.caption = '🐬'
    self.background = image('underwater.jpg', true)
    self.player = Mermaid.new(self)
    player.warp(320, 240)
    player.go_right
    self.fishes = []
  end

  def window
    self
  end

  attr_accessor :fishes

  def update
    player.go_left  if left?
    player.go_right if right?
    player.go_up    if up?
    player.go_down  if down?

    unless fishes.any?
      self.fishes += [
        HumanThing.new(self),
        HumanThing.new(self),
        HumanThing.new(self),
        HumanThing.new(self),
        HumanThing.new(self),
        HumanThing.new(self),
        HumanThing.new(self),
        HumanThing.new(self),
      ]
    end
    fishes.each(&:move)

    player.move
    player.collect(fishes)
  end

  def draw
    player.draw
    fishes.each(&:draw)
    background.draw(0, 0, ZOrder::Background)
    font.draw("Score: #{player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
end

class Mermaid < Fish
  include Collector

  attr_accessor :score

  def setup
    super
    @score = 0
  end

  def name
    'mermaid'
  end

  def ext
    'png'
  end

  def on_collect(stuff)
    self.score += 1
  end

  def collector_x
    right? ? @x + 100 : @x - 100
  end

  def collector_y
    @y + 20
  end

  def collector_range
    80
  end

  def go_left
    @vel_x = -10
  end

  def go_right
    @vel_x = 10
  end

  def go_up
    @vel_y = -6
  end

  def go_down
    @vel_y = 6
  end
end


class HumanThing < Fish
  def setup
    super
    @vel_x = 5 * (rand - 0.5)
    @vel_y = 1 * (rand - 0.5)
    @y = 40 + rand(window.height)/2
  end

  def name
    @n ||= rand(3)+1
    "stuff/thing-#{@n}"
  end

  def path
    "#{name}.#{ext}"
  end

  def ext
    'png'
  end

  def decelerate
    # noop
  end
end

SirenettaGame.play
