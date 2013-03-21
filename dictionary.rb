module BuildingDefence
  class Dictionary
    def initialize
      @words = []
      @max_len = 0
      @number = 0
      load_words.each do |word|
        @words << word 
        @max_len = word.length if word.length > @max_len
        @number += 1
      end
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
      %w(
        apple like girl man jack tom light weight building
        Converts any arguments to arrays then merges elements 
        self with corresponding elements from each argument
        new array can be created by using the literal constructor 
        Arrays can contain different types of objects For example 
        the array below contains an Integer String and Float
      )
    end
  end
end
