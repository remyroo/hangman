require_relative 'hangman.rb'
require_relative 'game_store.rb'

class Main
  include GameStore

  def initialize
    setup
  end

  def setup
    puts welcome_message
    choice = gets.chomp.downcase

    case choice
    when 'p'
      game = Hangman.new(rand(100))
      game.play
    when 'l'
      load_game
    when  'i'
      puts instructions
      setup
    else
      puts 'Exiting game...'
    end
  end

  def welcome_message
    <<-HEREDOC
      Welcome to Hangman!
      New game: "p"
      Resume game: "l"
      Instructions: "i"
      Exit: "quit"
    HEREDOC
  end

  def instructions
    "Guess the secret word. You are allowed 8 wrong guesses.\n"
  end

  def load_game
    game_data = load_game_data

    if game_data.empty?
      puts "No saved games on file."
      setup
      return
    else
      id = select_game_id(game_data)
      saved = game_data.find { |game| game["id"] == id }
      game = Hangman.new(saved["id"], saved)
    end

    game.play
  end

  def select_game_id(game_data)
    puts "Enter the ID of the game you'd like to play:"
    puts list_games(game_data)
    valid_ids = game_data.map { |game| game["id"] }
    validate_id(valid_ids)
  end

  def list_games(game_data)
    list = game_data.map { |game| "ID: #{game["id"]}: Lives: #{game["lives"]}" }
    list.join(",\n")
  end

  def validate_id(valid_ids)
    input = gets.chomp.to_i
    if valid_ids.include?(input)
      return input
    else
      puts 'Invalid input, try again:'
      validate_id(valid_ids)
    end
  end
end

Main.new
