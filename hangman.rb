random_word = ''

until random_word.chomp.length >= 5 && random_word.chomp.length <= 12
  File.foreach('google-10000-english-no-swears.txt').each_with_index do |line, number|
    # p line
    random_word = line if rand < 1.0 / (number + 1)

    temp = random_word
    temp if temp != random_word
  end
end

random_word = random_word.chomp
# puts "\n#{random_word}" ####################################

random_word_array = random_word.scan /\w/

players_guess_array = Array.new(random_word.length, '_')
players_guess = ''

number_of_guesses = 0
incorrect_guesses_number = 0
incorrect_guesses_letters = ''

puts "\nLet's play Hangman.\n
A random word that is 5-12 letters will be chosen.
You can guess one letter each round.
If you think you know the secret word, enter it in the console.\n\n"

puts 'How many incorrect guesses would you like to have?'
until number_of_guesses != 0
  number_of_guesses = gets.chomp.to_i
  puts 'You have to choose a number to play. Please try again' if number_of_guesses.zero?
end

winner_message = "You are a winner! The secret word was: #{random_word.upcase}\n\n"

until players_guess == random_word || players_guess_array.join == random_word

  puts "========================================\n\n"

  if incorrect_guesses_number == 0
    puts 'You have not chosen an incorrect letter yet.'
  else
    puts "Your incorrect letter choices are: #{incorrect_guesses_letters.upcase}"
  end
  puts "You have #{number_of_guesses - incorrect_guesses_number} incorrect guesses left.\n\n"
  puts "The secret word has #{random_word.length} letters in it."
  puts "Here is the secret word with your correct choices: #{players_guess_array.join(' ')}\n\n"

  puts "Guess a single letter or try to solve the puzzle.\n\n"
  players_guess = gets.chomp.downcase
  puts

  correct_guess = 'no'

  if players_guess.length == 1

    random_word_array.each_with_index do |letter, index|
      if players_guess == letter
        correct_guess = "yes"
        players_guess_array.delete_at(index)
        players_guess_array.insert(index, letter)

        if players_guess_array.join == random_word
          puts winner_message
          exit
        end

      end
    end

    if correct_guess == 'yes'
      puts "The letter you guessed is in the secret word!\n\n"
    else
      incorrect_guesses_letters << "#{players_guess} "
      incorrect_guesses_number += 1
      puts "That letter is not in the secret word.\n\n"
    end

  end

  if players_guess.length != 1

    if players_guess == random_word
      puts winner_message
      exit
    else
      puts "That is not the secret word.\n\n"
      incorrect_guesses_number += 1
    end

  end

  if (number_of_guesses - incorrect_guesses_number).zero?
    puts "You have run out of chances. The secret word was #{random_word.upcase}.\n\nGame Over.\n\n"
    exit
  end

end
