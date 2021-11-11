module GameStore
  require 'json'

  GAME_FILE = 'saved_games.txt'

  def dictionary_word
    word_list = File.readlines('dictionary.txt', chomp: true).select do |word|
      word.length.between?(5, 12)
    end
    word_list.sample
  end

  def load_game_data
    if File.exist?(GAME_FILE)
      File.readlines(GAME_FILE).map do |line|
        JSON.load(line)
      end.flatten
    else
      []
    end
  end

  def update(new_game)
    saved_games = load_game_data

    if saved_games.empty?
      updated = new_game
    else
      updated = saved_games.reject { |game| game['id'] == new_game[:id] }
      updated << new_game
      updated
    end
    write_to_file(updated)
  end

  def delete(word)
    saved_games = load_game_data
    updated = saved_games.reject { |game| game['secret'] == word }
    write_to_file(updated) unless updated.nil?
  end

  def write_to_file(updated)
    json = JSON.dump(updated)

    File.open(GAME_FILE, 'w') do |file|
      file.puts(json)
    end
  end
end
