require "curses"

module BuildingDefence
  class Word
    def initialize(str, beg_y, beg_x, speed = 2)
      @content = str
      @speed = speed
      @beg_x, @beg_y = beg_x, beg_y
      @cur_x, @cur_y = beg_x, beg_y
      @next_i = 0 #pointer to next letter to be typed

      @done_typing = false #indicate whether this unit was done typing
      @typing = false #indicate whether this unit was being typing
      @kia = false #indicate whether this unit kill in action
    end

    def fall
      sleep rand(5)
      while !(collided? || done_typing?)
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
      if @next_i < length && char == @content[@next_i]
        @typing = true
        if last_letter?
          @done_typing = true
          @next_i = 0
        else
          @next_i += 1
        end
        return true
      else
        @next_i = 0
        @typing = false
        return false
      end
    end

    def done_typing?
      @done_typing
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
      draw_word explosion_core, @cur_y, @cur_x if @cur_y < PARAMS[:battlefield_height]
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
          draw_word @content[0...@next_i], @cur_y, @cur_x
        end
        draw_word @content[@next_i...length], @cur_y, @cur_x + @next_i
      else
        draw_word @content, @cur_y, @cur_x
      end
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
      @next_i == length - 1
    end

  end
end
