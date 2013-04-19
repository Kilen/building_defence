module BuildingDefence
  class Dictionary
    def initialize
      @words = []
      @max_len = 0
      @number = 20
      load_words
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

    private

    def load_words
      dic = IO.readlines "dictionary/brit-a-z"
      @number.times do
        word  = dic[rand(dic.length)].chop
        @max_len = word.length if word.length > @max_len
        @words << word
      end
    end
  end
end

