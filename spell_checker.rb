#Dan Bachler
#A program for spell-checking files in ruby

#CURRENT VERSION
#Creates internal lexicon using this data structure, Hash -> Hash -> Array
#Spell checks words from user input

#Global vars
$lexicon = Hash.new
$words = Hash.new

#Populates the lexicon from the given file.  Assumed that the given file
#is a list of english words
def populate_lexicon (file_name)
  begin
    #Opens given file for lexicon
    file = File.open(file_name, 'r')
    #Reads until the end of the file
    until file.eof?
      #For each line in the file compile into lexicon
      file.each_line do |line|
        line.chomp!
        first_char = ''
        second_char = ''
        #If word is longer than 1 character
        if(line.length > 1)
          first_char = line[0]
          second_char = line[1]
        #If the word is 1 character long
        elsif line.length == 1
          first_char = line[0]
          second_char = line[0]
        #If the word doesnt exist/error state
        else
          puts "Error in word, length is 0"
        end
        #puts "First char: #{first_char}\nSecond char: #{second_char}"
        #Processes word
        if first_char != '' && second_char != ''
          #puts "First option"
          $lexicon[first_char][second_char].push line
        elsif first_char != ''
          #puts "Second option"
          $lexicon[first_char][first_char].push line
        end
      end
    end
    puts "Lexicon populated"
  rescue
    puts "Error in populating lexicon"
    exit 4
  end
end

#initializes the blank lexicon
def initialize_lexicon
  #Outer refrence, for outermost hash
  'a'.upto 'z' do |char|
    $lexicon[char] = Hash.new
  end
  #Creates the internal hash that will hold array of words
  'a'.upto 'z' do |counter|
    'a'.upto 'z' do |internal|
      $lexicon[counter][internal] = Array.new
    end
  end
  puts "Lexicon initialized"
end

#Reads the file of words to check
def to_check to_check
  #Opens the file to check
  file = File.open(to_check, 'r')
  #Reads until the end of the file
  until file.eof?
    #Clears punctuation to make checking easier
    remove_punctuation = /[\?\¿\!\¡\.\;\&\@\%\#\|\,]/
    #For each line check the spelling of each word
    file.each_line do |line|
      line.chomp!.downcase!
      #cleans punctuation
      line.gsub!(remove_punctuation, "")
      line.split.each do |word|
        $words[word] = false
      end
    end
  end
end

#Checks the spelling of all words in array
def spell_check
  temp_hash = Hash.new
  $words.each do |word|
    first_char = ''
    second_char = ''
    if word.length > 1
      first_char = word[0][0]
      second_char = word[0][1]
    elsif word.length == 1
      first_char = word[0][0]
      second_char = word[0][0]
    end
    #puts "First char: #{first_char}\nSecond char: #{second_char}"
    #Searches lexicon for match
    match = false
    $lexicon[first_char][second_char].each do |check|
      if check == word[0]
        match = true
        break;
      end
    end
    temp_hash[word[0]] = match
  end
  temp_hash.each do |temp|
    $words[temp[0]] = temp[1]
  end
end

#Prints the words that are spelled wrong
def feedback
  puts "Spelling errors"
  errors = 0
  $words.each do |word|
    if word[1] == false
      puts "#{word[0]}"
      errors += 1
    end
  end
  if errors == 0
    puts "No errors found"
  end
end

def main_loop
  if ARGV.length < 2
    puts "Need to specify lexicon source and file to check"
    exit 4
  end
  #Creates the initial lexicon object
  initialize_lexicon
  #Populates the lexicon object with the words from the given file
  populate_lexicon ARGV[0]
  #Reads input file to words array
  to_check ARGV[1]
  #Checks the word hash
  spell_check
  feedback
end

if __FILE__==$0
  main_loop
end
