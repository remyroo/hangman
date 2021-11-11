require_relative 'game_store.rb'

class Hangman
  include GameStore

  def initialize(game_id, opts = {})
    @game_id = game_id
    @secret_word = opts['secret'] || dictionary_word
    @lives = opts['lives'] || 8
    @correct_guesses = opts['correct_guesses'] || ''
    @wrong_guesses = opts['wrong_guesses'] || []
  end

  def play
    puts "The secret word is #{@secret_word.size} letters long."
    puts "You can save the game before each turn by entering '!'"
    print_teaser
    make_guess
  end

  def print_teaser(last_guess=nil)
    if last_guess == nil && @correct_guesses == ''
      @secret_word.size.times do
        @correct_guesses += "_ "
      end
    else
      update_teaser(last_guess)
    end

    puts @correct_guesses
  end

  def update_teaser(last_guess)
    new_teaser = @correct_guesses.split

    new_teaser.each_with_index do |letter, index|
      if letter == '_' && @secret_word[index] == last_guess
        new_teaser[index] = last_guess
      end
    end

    @correct_guesses = new_teaser.join(' ')
  end

  def make_guess
    if @secret_word == @correct_guesses.split.join
      puts "** Congrats! You've won this round. **"
      delete(@secret_word)
      return
    end

    if @lives > 0
      puts "Enter a letter:"
      input = sanitize_input
      return if quit_game?(input)

      analyze_guess(input)
    else
      delete(@secret_word)
      puts '*' * 20
      puts "Ouch, your man is hung.\nThe word was: #{@secret_word}\nBetter luck next time!"
      puts '*' * 20
    end
  end

  def sanitize_input
    input = gets.chomp.downcase
    unless input.match?(/\A[a-z!]\z|\Aquit\z/i)
      puts 'One letter at a time!'
      sanitize_input
    end
    input
  end

  def quit_game?(input)
    if input == 'quit'
      puts 'Thanks for playing :)'
      true
    elsif input == '!'
      save_game
      puts "Game saved with id: #{@game_id}. Thanks for playing :)"
      true
    else
      false
    end
  end

  def analyze_guess(guess)
    if @correct_guesses.include?(guess) || @wrong_guesses.include?(guess)
      puts 'You already tried that letter'
    elsif @secret_word.include?(guess)
      print_teaser(guess)
    else
      @lives -= 1
      print_wrong_guesses(guess) if @lives > 0
    end

    make_guess
  end

  def print_wrong_guesses(guess)
    @wrong_guesses << guess
    puts "Nope, try again! Wrong guesses so far: #{@wrong_guesses.join(', ')}"
  end

  def save_game
    game_data = {
      'id': @game_id,
      'secret': @secret_word,
      'lives': @lives,
      'correct_guesses': @correct_guesses,
      'wrong_guesses': @wrong_guesses
    }

    update(game_data)
  end
end
