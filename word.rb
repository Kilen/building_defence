require "curses"

module BuildingDefence
  class Word
    def initialize(str, beg_y, beg_x, speed = 2)
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

    private

    def blast_effect
      explode
      sleep 0.5
      clear_explosion
    end

    def explode
      draw_word explosion_head, @cur_y - 1, @cur_x
      draw_word explosion_core, @cur_y, @cur_x 
    end

    def explosion_head
      #"\\" + ("|" * length) + "/"
      "v" * length
    end

    def explosion_core
      "*" * length
    end

    def clear_explosion
      draw_word space(length), @cur_y - 1, @cur_x
      clear_word
    end

    def clear_word
      draw_word space(length), @cur_y, @cur_x
    end

    def space len
      " " * len 
    end

    def draw_word_at_next_line
      @cur_y += 1
      return if collided?
      if typing?
        Curses.attron(Curses.color_pair(COLORS[:letter_typed])) do
          draw_word @content[0...@cur_i], @cur_y, @cur_x
        end
        draw_word @content[@cur_i...length], @cur_y, @cur_x + @cur_i
      else
        draw_word @content, @cur_y, @cur_x
      end
    end

    def draw_word_at_cur_line
      return if collided?
      Curses.attron(Curses.color_pair(COLORS[:letter_typed])) do
        draw_word @content[0...@cur_i], @cur_y, @cur_x
      end
      draw_word @content[@cur_i...length], @cur_y, @cur_x + @cur_i
    end

    public
    def draw_word(str, y, x)
      str = return_part_that_within_border str, y, x
      y, x = adjust_y_x y, x
      Curses.setpos y, x
      Curses.addstr str
      Curses.refresh
    end

    def return_part_that_within_border(str, y, x)
      if y < 0 || y >= PARAMS[:battlefield_height]
        return ""
      end

      if x < 0
        beg = -x
        len = str.length - beg
        len = min(len, PARAMS[:battlefield_width])
      else
        beg = 0
        over = max(x + str.length - PARAMS[:battlefield_width], 0)
        len = str.length - over
      end
      return str[beg, len]
    end

    def adjust_y_x(y, x)
      y = 0 if y < 0
      y = PARAMS[:battlefield_height] - 1 if y >= PARAMS[:battlefield_height]
      x = 0 if x < 0
      x = PARAMS[:battlefield_width] - 1 if x >= PARAMS[:battlefield_width]
      return [y, x]
    end

    def collided?
      @cur_y == Curses.lines || hit_building?
    end

    def hit_building?
      false
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

    def min x, y
      return x < y ? x : y
    end

    def max x, y
      return x > y ? x : y
    end


  end
end
