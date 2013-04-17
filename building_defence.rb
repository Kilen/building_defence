$:.unshift File.expand_path('../', __FILE__)
require "curses"
require "benchmark"

require "game_setting"
require "word"
require "building"
require "dictionary"
require "brush"
require "shared"

module BuildingDefence
  class GameControll
    include Shared

    def initialize
      test_loading_game_setting
      init_window_for_drawing
      init_parameters
      init_dictionary
      init_building

      srand
      @words_on_screen = []

    end

    def start
      @building.show
      handle_input
      while !game_done?
        prepare_words
        go_words!
        sleep PARAMS[:wave_interval]
      end
    end

    private

    def init_parameters
      #some game setting should be initialized here
      PARAMS[:battlefield_width] = Curses.cols - 20
      PARAMS[:battlefield_height] = Curses.lines
    end

    def init_dictionary
      @dictionary = Dictionary.new
    end

    def init_building
      @building = Building.new
      Word.load_building @building.coordinates_of_building
    end

    def prepare_words
      x, y = 0, 0
      @words = []
      while x + @dictionary.max_len < PARAMS[:battlefield_width]
        str = @dictionary.random_word
        @words << Word.new(str, y, x, PARAMS[:word_speed])
        x += str.length + PARAMS[:word_density]
      end 
    end

    def handle_input
      Thread.new do
        source = @words_on_screen
        while !game_done?
          char = Curses.getch
          targets = find_all_match source, char
          targets = those_yet_lived targets
          #show_messages ["targets:"] + targets.map {|w| w.content }, COLORS[:info]
          #show_messages ["targets num:", targets.length.to_s, "all words num:", source.length.to_s], COLORS[:info]

          if targets.empty?
            source = @words_on_screen
          else
            source = targets
          end
        end
      end
    end

    def find_all_match source, char
      source.select do |word|
        word.match_cur_letter?(char)
      end
    end

    def those_yet_lived source
      source.delete_if do |word|
        word.kia?
      end
    end

    def game_done?
      game_over? || victory?
    end

    def go_words!
      @words.each do |word|
        @words_on_screen << word
        Thread.new do 
          @words_on_screen.delete word.fall 
          #show_messages ["KIA:", word.content], COLORS[:success]
          show_messages ["building left:", Word.show_building.length.to_s]
        end
      end
    end

    def game_over?
      Word.show_building.empty?
    end

    def victory?
      false
    end

    #for debug
    def show_messages msgs, color=COLORS[:info]
      raise "msgs must be array" if msgs.class != Array
      win = Curses::Window.new msgs.length + 2 , 20, 0, Curses.cols - 20
      win.box(?|, ?-)
      msgs.each_with_index do |msg, index|
        win.setpos(index + 1, 3)
        win.attron(Curses.color_pair(color)) do
          win.addstr(msg)
        end
      end
      win.refresh
      sleep 0.3
    end

    public
    def test
      @building.show
      prepare_words
      go_words!
    end

  end

  #------------------> program entry
  game = GameControll.new
  game.start
end


