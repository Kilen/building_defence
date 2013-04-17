$:.unshift File.expand_path('../', __FILE__)
require "curses"
require "brush"
require "shared"

module BuildingDefence
  class Word
    include Brush
    include Shared

    def initialize(str, beg_y, beg_x, speed = 2)
      test_loading_game_setting
      init_window_for_drawing
      @content = str
      @speed = speed
      @beg_x, @beg_y = beg_x, beg_y
      @cur_x, @cur_y = beg_x, beg_y
      @cur_i = 0 #pointer to the first letter untyped

      @typing = false #indicate whether this unit was being typing
      @kia = false #indicate whether this unit kill in action
    end

    def fall
      sleep rand(5)
      while !(collided? || kia?)
        pause
        clear_word
        draw_word_at_next_line
      end
      @kia = true
      blast_effect
      self
    end

    def content
      @content
    end

    def length
      @content.length
    end

    def match_cur_letter? char

      if @cur_i < length && char == @content[@cur_i]
        @typing = true
        @kia = true if last_letter?
        @cur_i += 1
        draw_word_at_cur_line
        return true
      else
        @cur_i = 0
        @typing = false
        return false
      end
    end

    def typing?
      @typing
    end

    def kia?
      @kia
    end

    def self.load_building(building)
      @@building = building
      #@@buiding = [[x1, y1], [x2, y2], [x3, y3] ...]
    end

    def self.show_building
      @@building
    end

    private

    def blast_effect
      explode
      sleep 0.5
      clear_explosion
    end

    def explode
      draw_something explosion_head, @cur_y - 1, @cur_x
      draw_something explosion_core, @cur_y, @cur_x 
    end

    def explosion_head
      #"\\" + ("|" * length) + "/"
      "v" * length
    end

    def explosion_core
      "*" * length
    end

    def clear_explosion
      draw_something space(length), @cur_y - 1, @cur_x
      clear_word
    end

    def clear_word
      draw_something space(length), @cur_y, @cur_x
    end

    def space len
      " " * len 
    end

    def draw_word_at_next_line
      @cur_y += 1
      return if collided?
      if typing?
        Curses.attron(Curses.color_pair(COLORS[:letter_typed])) do
          draw_something @content[0...@cur_i], @cur_y, @cur_x
        end
        draw_something @content[@cur_i...length], @cur_y, @cur_x + @cur_i
      else
        draw_something @content, @cur_y, @cur_x
      end
    end

    def draw_word_at_cur_line
      return if collided?
      Curses.attron(Curses.color_pair(COLORS[:letter_typed])) do
        draw_something @content[0...@cur_i], @cur_y, @cur_x
      end
      draw_something @content[@cur_i...length], @cur_y, @cur_x + @cur_i
    end


    def collided?
      @kia = true if @cur_y == Curses.lines || hit_building?
      @kia
    end

    def hit_building?
      top_floor_of_building = @@building[0][1]
      flag = false
      if @cur_y >= top_floor_of_building
        flag = check_collide
      end
      flag
    end

    def check_collide
      collide_flag = false
      word_x = word_x_coordinate_to_array
      word_index, building_index = 0, find_right_floor
      while word_index < self.length && building_index < @@building.length && @@building[building_index][1] == @cur_y
        if word_x[word_index] > @@building[building_index][0]
          building_index += 1
        elsif word_x[word_index] == @@building[building_index][0]
          collide_flag = true
          @@building.delete_at building_index
          word_index += 1
          building_index += 1
        else
          word_index += 1
        end
      end
      collide_flag
    end

    def word_x_coordinate_to_array
      arr = []
      self.length.times {|i| arr << @cur_x + i}
      arr
    end
    
    def find_right_floor
      building_index = 0
      while building_index < @@building.length && @@building[building_index][1] < @cur_y
        building_index += 1
      end
      return building_index
    end

    def pause
      sleep pause_duration
    end

    def pause_duration
      (1.0 / @speed).abs
    end

    def last_letter?
      @cur_i == length - 1
    end

  end
end
