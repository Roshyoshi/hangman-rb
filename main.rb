require 'yaml'
$current_save = nil

def random_word(arr)
  word = "XXXXXXXXXXXXXXXXXXX"
  until word.length >= 5 && word.length <= 12 do
    word = arr.sample
  end
  word
end

class Letters
  attr_reader :winning_letters, :correct_guesses, :incorrect_guesses
  def initialize(winning_word)
    @winning_letters = winning_word.chomp.chars.uniq
    @correct_guesses = []
    @incorrect_guesses = []
  end

  def all_guessed
    all = @correct_guesses + @incorrect_guesses
    all.uniq
  end

  def winning?(guess)
    if @winning_letters.include?(guess)
      @correct_guesses.append(guess)
      true
    else
      @incorrect_guesses.append(guess)
      false
    end
  end 
end

class Game
  attr_accessor :guess_count, :state, :word
  def initialize(word)
    @word = word
    @state = Letters.new(word)
    @guess_count = 0
  end
  def print_correct
    @word.chars do |char| 
      if @state.correct_guesses.include?(char) 
        print "#{char} "    
      else
        print '_ '
      end
    end
  end

  def show_guessed
    puts "Here's what you've guessed so far"
    counter = 0
    @state.all_guessed.each do |letter|
      print "#{letter} "
      counter += 1
      if counter == 4
        puts ''
        counter = 0
      end
    end
    puts "\n"
  end

  def guess
    @guess_count += 1
    puts "Guess #{@guess_count} / 12 \n"
    puts "Enter a letter that you haven't guessed or '!' to save and quit."
    invalid = true
    while invalid 
      guess = gets.chomp.downcase
      if guess.length == 1 && guess.match(/^[[:alpha:]]$/) || guess == "!"
        invalid = false
      else
        puts "Please enter a valid guess!"
      end
    end
    if guess == '!'
      puts "saving..."
      save(self)
    elsif @state.winning?(guess)
      puts "Correct!"
    else
      puts "Dead wrong!\n"
    end
  end
end

def start_game
  dictionary = File.open("dict.txt", "r").readlines
  Game.new(random_word(dictionary))
end

def load_save
  saves = Dir.entries("./saves")
  puts "\nHere are your saves so far"
  saves.each_with_index do |name, index|
    if name == '.' || name == '..' 
      saves.delete_at(index)
    end
  end

  saves.each_with_index do |name, index|
    puts "#{index + 1}. #{name}"
  end

  begin
    puts "Enter the number of the save you want to load."
    index = gets.chomp.to_i - 1
    save_name = saves[index]
  rescue
    puts "Invalid number! Exiting..."
    exit 1
  end

  $current_save = save_name

  YAML.load_file( 
  "./saves/#{save_name}", 
    permitted_classes: [Game, Letters, Symbol, Array]
  )
end

def save(game)
  if $current_save.nil?
    save_dir = Dir.entries("./saves")
    i = 0
    file_name = "save#{i}.yaml"
    while save_dir.include?(file_name)
      i += 1
      file_name = "save#{i}.yaml"
    end
  else
    file_name = $current_save
  end 
  delete(file_name) if File.exist?(file_name.to_s)

  File.open("./saves/#{file_name}", "w") do |save|
    save.puts YAML.dump game
    save.puts ''
  end 

  puts "Thanks for playing!"

  exit 0
end

puts "Welcome to Hangman!"
if Dir.entries("./saves").length == 2 
  game = start_game()
else
  puts "Press 1 to load a save, and 2 to start a new game."
  num = gets.chomp
  if num == '1'
    game = load_save()
    game.guess_count -= 1
  elsif num == '2'
    game = start_game()
  else
    puts "Invalid option! Quitting..."
    exit 1
  end
end

while game.guess_count < 12
  game.guess
  game.print_correct
  puts ""
  game.show_guessed
end

puts "You lose! The correct word was #{game.word}."

delete("./saves/#{$current_save}") unless $current_save.nil?


