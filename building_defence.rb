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
      @score = 0
    end

    def start
      @building.show
      handle_input
      while !game_done?
        prepare_words
        go_words!
        break if game_done?
        sleep PARAMS[:wave_interval]
      end
      show_messages ["Game Over", "Your score: #{@score}"], COLORS[:info], (Curses.lines - 2) / 2, (Curses.cols - 20) / 2
      Curses.getch
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
        @words << Word.new(str, y, x, rand(10) + 1)
        x += str.length + PARAMS[:word_density]
      end 
    end

    def handle_input
      Thread.new do
        source = @words_on_screen
        while !game_done?
          char = Curses.getch
          find_all_match source, char
          targets = those_yet_lived source
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
          if word.kill_by_you?
            @score += calculate_score word
            show_messages [word.content + " is kia", "score: #{calculate_score word}"], COLORS[:success]
          end
        end
      end
    end

    def calculate_score(word)
      if word.length <= 5
        return word.length * 10 * word.speed
      elsif word.length <= 10
        return word.length * 20 * word.speed
      else
        return word.length * 30 * word.speed
      end
    end

    def game_over?
      Word.show_building.empty?
    end

    def victory?
      false
    end

    #for debug
    def show_messages msgs, color=COLORS[:info], top=0, left=Curses.cols-20
      raise "msgs must be array" if msgs.class != Array
      win = Curses::Window.new msgs.length + 2 , 20, top, left
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


