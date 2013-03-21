$:.unshift File.expand_path('../', __FILE__)
require "curses"
require "pry"

require "game_setting"
require "word"
require "dictionary"

module BuildingDefence

  class GameControll

    def initialize
      init_window
      init_dictionary

      @words_on_screen = []

      #some game setting should be initialized here
      PARAMS[:battlefield_width] = Curses.cols - 20
      PARAMS[:battlefield_height] = Curses.lines

    end

    def start
      handle_input
      while !game_done?
        prepare_words
        go_words!
        sleep PARAMS[:wave_interval]
      end
    end

    private

    def init_window
      Curses.init_screen
      Curses.start_color
      Curses.nl
      Curses.noecho
      Curses.cbreak
      srand

      Curses.use_default_colors
      Curses.init_pair(COLORS[:letter_typed], Curses::COLOR_BLUE, -1)
      Curses.init_pair(COLORS[:message], Curses::COLOR_RED, -1)
    end

    def init_dictionary
      @dictionary = Dictionary.new
    end

    def prepare_words
      x, y = 0, 0
      @words = []
      while x + @dictionary.max_len < PARAMS[:battlefield_width]
        str = @dictionary.random_word
        @words << Word.new(str, y, x, rand(5) + 1)
        x += str.length + PARAMS[:word_density]
      end 
    end

    def handle_input
      Thread.new do
        @match_words = []
        while !game_done?
          char = Curses.getch
          #find_all_match_words(char)
          #while !@match_words.empty?
          #  char = Curses.getch
          #  @match_words.each do |word|
          #    @match_words.delete(word) unless word.match_cur_letter?(char)
          #  end
          #end

          word = find_first_match_in_words_on_screen char
          if word
            #show_message "current typing: #{word.content}"
            while !word.done_typing?
              break unless word.match_cur_letter? Curses.getch
            end
            if word.done_typing?
              show_message "#{word.content} is KIA, #{@words_on_screen.length}"
            end
          end
        end
      end
    end

    def find_first_match_in_words_on_screen(char)
      @words_on_screen.each do |word|
        return word if word.match_cur_letter? char
      end
      return nil
    end

    def find_all_match_words(char)
      @words_on_screen.each do |word|
        @match_words << word if word.match_cur_letter?(char)
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
          #show_message "#{@words_on_screen.length} words on screen"
        end
      end
    end

    def game_over?
      false
    end

    def victory?
      false
    end

    #for debug
    def show_message msg
      width = msg.length + 6
      win = Curses::Window.new 5, width, 0, Curses.cols - width
      win.box(?|, ?-)
      win.setpos(2, 3)
      win.attron(Curses.color_pair(COLORS[:letter_typed])) do
        win.addstr(msg)
      end
      win.refresh
      sleep 0.3
    end
  end

  #------------------> program entry
  game = GameControll.new
  game.start
end

