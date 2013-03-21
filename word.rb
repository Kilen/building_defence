require "curses"

module BuildingDefence
  class Word
    def initialize(str, beg_y, beg_x, speed = 2)
      @content = str
      @speed = speed
      @beg_x, @beg_y = beg_x, beg_y
      @cur_x, @cur_y = beg_x, beg_y
      @cur_i = 0 #pointer to current letter

      @done_typing = false #indicate whether this word was done typing
    end

    def fall
      sleep rand(5)
      while !(collided? || done_typing?)
        pause
        clear_word
        draw_word_at_next_line
      end
      clear_word
      self
    end

    def content
      @content
    end

    def match_cur_letter? char
      if @cur_i < @content.length && char == @content[@cur_i]
        if last_letter?
          @done_typing = true
          @cur_i = 0
        else
          @cur_i += 1
        end
        return true
      else
        @cur_i = 0
        return false
      end
    end

    def done_typing?
      @done_typing
    end

    private

    def clear_word
      draw_word word_length_space, @cur_y, @cur_x
    end

    def word_length_space
      " " * @content.length
    end

    def draw_word_at_next_line
      @cur_y += 1
      return if collided?
      draw_word @content, @cur_y, @cur_x
    end

    def draw_word(str, y, x)
      Curses.setpos y, x
      Curses.addstr str
      Curses.refresh
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
      @cur_i == @content.length - 1
    end

  end
end
