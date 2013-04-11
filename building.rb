require "curses"
require "brush"

module BuildingDefence
  class Building
    include Brush

    def initialize
      test_loading_game_setting
      @max_height = 3
      @building = generate_building
    end

    def show
    end

    private

    def generate_building
    end

    def test_loading_game_setting
      PARAMS == nil 
    rescue NameError
      raise "not yet load game_setting!" 
    end

  end
end
