require "curses"

module BuildingDefence
  class Building
    def initialize
      @max_height = 3
      @building = generate_building
    end

    def show
    end

    private

    def generate_building
    end

    def draw_word(str, y, x)
      y, x = adjust_y_x y, x
      Curses.setpos y, x
      Curses.addstr str
      Curses.refresh
    end

    def adjust_y_x(y, x)
      y = 0 if y < 0
      y = PARAMS[:battlefield_height] - 1 if y >= PARAMS[:battlefield_height]
      x = 0 if x < 0
      x = PARAMS[:battlefield_width] - 1 if x >= PARAMS[:battlefield_width]
      return [y, x]
    end
  end
end
