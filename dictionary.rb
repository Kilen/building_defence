module BuildingDefence
  class Dictionary
    def initialize
      @words = []
      @max_len = 0
      @number = 20
      @dic = IO.readlines "dictionary/brit-a-z"
      srand
      reload_words
    end

    def max_len
      @max_len
    end

    def number
      @number
    end

    def random_word
      srand
      @words[rand(@number)]
    end

    def reload_words
      @words.clear
      @number.times do
        word  = @dic[rand(@dic.length)].chomp.chomp #for words like "abc\n\r"
        @max_len = word.length if word.length > @max_len
        @words << word
      end
    end
  end
end

