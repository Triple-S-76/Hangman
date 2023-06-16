require 'yaml'

class Hangman
  attr_accessor :word,
                :word_array,
                :guessed_characters,
                :remaining_letters,
                :winner,
                :number_of_letters_guessed,
                :remaining_guesses,
                :game_loaded

  def initialize
    introduction
    game_type
    play_game
  end

  private

  def game_type
    puts
    if File.exist?('hangman_2_save.yaml')
      puts 'Would you like to load the previously saved game?'
      puts 'Press Y for yes or any other key for no'
      puts
      play_from_save = gets.chomp.downcase
      if play_from_save == 'y'
        @game_loaded = true
        load_save
      else
        setup_game(random_word)
      end
    else
      setup_game(random_word)
    end
  end

  def load_save
    game_data = YAML.load_file('hangman_2_save.yaml')

    self.word = game_data[:word]
    self.word_array = game_data[:word_array]
    self.guessed_characters = game_data[:guessed_characters]
    self.remaining_letters = game_data[:remaining_letters]
    self.winner = game_data[:winner]
    self.number_of_letters_guessed = game_data[:number_of_letters_guessed]
    self.remaining_guesses = game_data[:remaining_guesses]

    @game_loaded = true
    puts
    puts print_guessed_characters
    puts
  end

  def introduction
    puts 'Welcome to Hangman.'
    puts
    puts 'The computer will choose a word between 5 and 10 characters long.'
    puts 'You can then guess letters and see if you can figure out the word.'
    puts 'After each guess, the word will be shown to you with "_" for each letter you have not guessed.'
    puts 'You can also try to solve the puzzle at any time.'
    puts 'You can guess a wrong 8 times.'
    puts
  end

  def random_word
    line_count = 0
    File.open('google-10000-english-no-swears.txt', 'r') do |file|
      file.each_line do |line|
        line_count += 1
      end

      valid_word = false
      until valid_word == true
        random_line = rand(0..line_count)
        lines = File.readlines('google-10000-english-no-swears.txt')
        word = lines[random_line].chomp
        valid_word = true if word.length > 5 && word.length < 10
      end
      word
    end
  end

  def setup_game(word)
    @winner = false
    @number_of_letters_guessed = 0
    @remaining_guesses = 8
    @game_loaded = false
    create_remaining_letter_board
    @word = word
    @word_array = word.split('')
    @guessed_characters = Array.new(word.length, '_')
    first_round
  end

  def first_round
    puts "The computer has chosen a word with #{word.length} characters. Good Luck."
    puts
    print_guessed_characters
    puts
  end

  def play_game
    until @winner == true || @remaining_guesses.zero?
      player_guess = player_turn
      valid_guess = validate_guess(player_guess)

      invalid_guess(player_guess) if valid_guess == false
      redo if valid_guess == false

      check_the_guess(player_guess)

      print_guessed_characters
      puts

      won_game if @number_of_letters_guessed == @word.length
      lost_game if @remaining_guesses.zero?

    end
  end

  def save_game
    puts 'Would you like to save the game?'
    puts 'Press Y for yes or any other key to continue without saving.'
    answer = gets.chomp.downcase
    save_to_yaml if answer == 'y'
  end

  def save_to_yaml
    game_data = {
      word: word,
      word_array: word_array,
      guessed_characters: guessed_characters,
      remaining_letters: remaining_letters,
      winner: winner,
      number_of_letters_guessed: number_of_letters_guessed,
      remaining_guesses: remaining_guesses
    }
    File.open('hangman_2_save.yaml', 'w') do |file|
      file.write(YAML.dump(game_data))
    end
    puts
    puts 'Your game is now saved.'
    puts
    exit
  end

  def lost_game
    puts
    puts "You ran out of guesses. The secret word was #{@word.upcase}!"
    puts
    File.delete('hangman_2_save.yaml') if @game_loaded == true
  end


  def check_the_guess(player_guess)
    if player_guess.length > 1 # player is trying to solve the puzzle
      check_answer(player_guess)
    elsif @remaining_letters[player_guess] == true # player has guessed a letter that is available
      valid_single_letter(player_guess)
    else # player has guessed a letter that has already been guessed
      puts "Your guess of #{player_guess.upcase} has already been chosen. Try again."
    end
  end

  def valid_single_letter(player_guess)
    @remaining_letters[player_guess] = false
    match = false
    word_array.each_with_index do |letter, index|
      if player_guess == @word_array[index]
        @guessed_characters[index] = letter
        @number_of_letters_guessed += 1
        match = true
      end
    end
    @remaining_guesses -= 1 if match == false
  end

  def check_answer(player_guess)
    if player_guess == @word
      won_game
    else
      puts
      puts "Your guess of '#{player_guess.upcase}' is not correct. Too Bad!"
      puts
      @remaining_guesses -= 1
    end
  end

  def won_game
    puts
    puts 'Congratulations, You have won the game.'
    puts "The secret word was '#{@word.upcase}' and you guessed it!!"
    puts
    File.delete('hangman_2_save.yaml') if @game_loaded == true
    exit
  end

  def invalid_guess(player_guess)
    puts
    puts "Your guess of #{player_guess} is not valid."
    puts 'Please try again.'
    puts
  end

  def validate_guess(player_guess)
    if player_guess == 'savegame'
      save_game
      false
    elsif player_guess.length == 1
      return true if @remaining_letters.include?(player_guess)
    else
      array = player_guess.split('')
      array.each do |letter|
        valid = ('a'..'z').include?(letter)
        return false if valid == false
      end
    end
  end

  def create_remaining_letter_board
    @remaining_letters = {}
    ('a'..'z').each { |letter| @remaining_letters[letter] = true }
  end

  def player_turn
    puts "You have #{@remaining_guesses} remaining guesses left!"
    puts
    puts 'Take your guess or type "savegame" to save your game.'
    puts
    gets.chomp.downcase
  end

  def print_guessed_characters
    string = '   '
    @guessed_characters.each do |letter|
      string << letter
      string << ' '
    end
    puts string
  end

end

Hangman.new
