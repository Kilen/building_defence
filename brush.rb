module BuildingDefence
  module Brush
    def draw_something(str, y, x)
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

    def min x, y
      return x < y ? x : y
    end

    def max x, y
      return x > y ? x : y
    end
  end
end
