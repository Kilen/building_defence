module BuildingDefence
  module Shared
    def init_window_for_drawing
      Curses.init_screen
      Curses.start_color
      Curses.noecho
      Curses.use_default_colors

      Curses.init_pair(COLORS[:letter_typed], Curses::COLOR_BLUE, -1)
      Curses.init_pair(COLORS[:error], Curses::COLOR_RED, -1)
      Curses.init_pair(COLORS[:info], Curses::COLOR_WHITE, -1)
      Curses.init_pair(COLORS[:success], Curses::COLOR_GREEN, -1)
    end

    def test_loading_game_setting
      PARAMS == nil 
    rescue NameError
      raise "not yet load game_setting!" 
    end
  end
end
