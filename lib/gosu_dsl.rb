require 'gosu'

module GosuDsl
  module Media
    def sample name
      Gosu::Sample.new(window, media_path(name))
    end

    def image name, *args
      Gosu::Image.new(window, media_path(name), *args)
    end

    def media_path name
      File.join(media_dir, name)
    end

    def media_dir
      $media_dir
    end
  end

  module Keyboard
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
  end
end
