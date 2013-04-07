require 'gosu_dsl'

module Collector
  include GosuDsl::Media
  def collect(items)
    collected = items.reject! do |item|
      Gosu.distance(collector_x, collector_y, item.x, item.y) < collector_range
    end

    if collected
      @collected_at = Time.now
      on_collect(collected)
    end
  end

  def on_collect(collected)
  end

  def collector_x
    raise NotImplementedError
  end

  def collector_y
    raise NotImplementedError
  end

  def collector_range
    60
  end
  def just_collected?
    @collected_at and Time.now.to_f - @collected_at.to_f < 0.2
  end
end


class Fish
  include GosuDsl::Media
  extend GosuDsl::Media

  def initialize(window)
    @window = window
    setup
  end
  attr_reader :window, :x, :y


  def self.image_cache file, window
    @images ||= Hash.new
    @window = window
    @images[file] ||= image(file, false)
  end

  def self.window
    @window
  end

  def setup
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @direction = :r
  end

  def mouth_x
    right? ? @x + 100 : @x - 100
  end

  def image= file
    @image = self.class.image_cache file, @window
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= window.width
    @y %= window.height
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

  def update_image
    self.image = path
  end

  def path
    path = name
    path << "-#{right? ? :r : :l}"
    path << ".#{ext}"
  end

  def name
    raise NotImplementedError
  end

  def ext
    raise NotImplementedError
  end

  def right?
    @vel_x > 0
  end
end


class Game < Gosu::Window
  include GosuDsl::Media
  include GosuDsl::Keyboard

  def width
    800
  end

  def height
    480
  end

  def initialize
    super width, height, false
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    setup
  end

  attr_accessor :player, :background
  attr_reader :font

  def window
    self
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end

  def self.play
    new.show
  end
end
