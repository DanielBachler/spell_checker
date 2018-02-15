#Dan Bachler
#A program for spell-checking files in ruby

#CURRENT VERSION
#Creates internal lexicon using this data structure, Hash -> Hash -> Array
#Spell checks words from user input

#Global vars
#The lexicon, or dictionary
$lexicon = Hash.new
#The words to be corrected from text files
$words = Hash.new
#A data source for calculating probability of words
$language = Hash.new(0)

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
    file.close
    puts "Lexicon populated"
  rescue
    puts "Error in populating lexicon"
    exit 4
  end
end

#Fills the language hash
def initialize_language file_name
  file = File.open(file_name, 'r')
  until file.eof?
    file.each_line do |line|
      #checks for punctuation
      remove_punctuation = /[\?\¿\!\¡\.\;\&\@\%\#\|\,\*\(\)\#]/
      line.gsub!(remove_punctuation, '')
      line.downcase!
      #splits the line into words
      words = line.split(' ').to_a
      #for each word increments the count
      words.each do |word|
        $language[word] += 1
      end
      #puts "Line: #{line}\nWords: #{words}"
    end
  end
  file.close
  puts "Language initialized"
end

#Reads the file of words to check
def to_check file_to_check
  #Opens the file to check
  file = File.open(file_to_check, 'r')
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
    if word[0].length > 1
      first_char = word[0][0]
      second_char = word[0][1]
    elsif word[0].length == 1
      first_char = word[0][0]
      second_char = word[0][0]
    end
    #puts "First char: #{first_char}\nSecond char: #{second_char}\nWord: #{word[0]}, length = #{word[0].length}"
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

#Finds suggestions for misspelled words
def corrections

end

def main_loop
  #Checks that the user has specified the correct amount of files on startup, assumes they are correct
  if ARGV.length < 2
    puts "Need to specify lexicon source and language source"
    exit 4
  end
  #Creates the initial lexicon object
  initialize_lexicon
  #Populates the lexicon object with the words from the given file
  populate_lexicon ARGV[0]
  #creates and fills the language hash
  initialize_language ARGV[1]
  #User input loop
  puts "Please enter file name to be corrected, enter 'q' to quit"
  print '> '
  while user_input = STDIN.gets.chomp!
    if user_input == 'q'
      puts "Goodbye!"
      break;
    end
    if(File.exists?(user_input))
      to_check(user_input)
      spell_check
      feedback
      $words.clear
    else
      puts "Filename invalid, try again"
    end
    puts "Please enter file name to be corrected, enter 'q' to quit"
    print '> '
  end
end

if __FILE__==$0
  main_loop
end
