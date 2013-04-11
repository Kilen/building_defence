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
      @max_height = 3
      @building = generate_building
    end

    def show
      @max_height.downto(1) do |i|
        draw_something @building[i-1], PARAMS[:battlefield_height] - i
      end
    end

    private

    def generate_building
    end
  end
end
