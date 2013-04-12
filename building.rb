$:.unshift File.expand_path('../', __FILE__)
require "curses"
require "brush"
require "shared"

module BuildingDefence
  class Building
    include Brush
    include Shared

    def initialize
      test_loading_game_setting
      init_window_for_drawing
      srand
      @max_height = PARAMS[:building_height]
      @building = []
      generate_building
    end

    def show
      @max_height.downto(1) do |i|
        draw_something @building[i-1], PARAMS[:battlefield_height] - i, 0
      end
    end

    def print
      puts @building
    end

    private

    def generate_building
      @max_height.times do
        @building << random_string
      end
    end

    def random_string
      str = ""
      PARAMS[:battlefield_width].times do
        if rand(10) >= 5
          str += "#"
        else
          str += " "
        end
      end
      str
    end
  end
end
