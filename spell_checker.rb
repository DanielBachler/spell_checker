#Dan Bachler
#A program for spell-checking files in ruby

#CURRENT VERSION
#Creates internal lexicon using this data structure, Hash -> Hash -> Array
#Spell checks words from user input

# INIT: ruby spell_checker.rb words_alpha.txt language.txt

# Libs
require 'docx'
require 'find'

##Global vars
#The lexicon, or dictionary
$lexicon = Hash.new
#The words to be corrected from text files
$words = Hash.new
#The inverted index for term weighting
$index = Hash.new
#A data source for calculating probability of words
$language = Hash.new(0)
#Total words
$total_words = 0
#Global regex for removing punctuation
$remove_punctuation = /[\?\¿\!\¡\.\;\&\@\%\#\|\,\*\(\)\#\"\\\/]/
# Global regex for numbers
$numbers = /[0-9]/
#Hash to hold fixed words
$correction = Hash.new

# Lexicon functions

#initializes the blank lexicon
def initialize_lexicon
  #Outer reference, for outermost hash
  'a'.upto 'z' do |char|
    $lexicon[char] = Hash.new
  end
  puts "Lexicon initialized"
end

#Populates the lexicon from the from words_alpha
def populate_lexicon (file_name)
  begin
    #Opens given file for lexicon
    file = File.open(file_name, 'r')
    #Reads until the end of the file
    until file.eof?
      #For each line in the file compile into lexicon
      file.each_line do |line|
        line.chomp!
        #Gets first character of word
        first_char = line[0]
        #Processes word
        if first_char != ''
          # Get the length of the word
          len = line.length
          if $lexicon[first_char].has_key? len
            $lexicon[first_char][len][line] = 0
          else
            $lexicon[first_char][len] = Hash.new
            $lexicon[first_char][len][line] = 0
          end
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

# Inverted index functions

# Creates the inverted index from a given corpus (folder)
# format: $index[term] gives hash term[docNumber] = count
def invertedIndex (folder)
  begin
  # Set doc number
  docNumber = 1
  # Iterate over each file in folder
  Find.find(folder) do |filename|
    begin
      # Ignore just folder name
      if !filename.eql? folder
        # Read in each file
        # If .docx
        if filename.include? ".docx"
          file = Docx::Document.open(filename)
          file.each_paragraph do |line|
            processLine(docNumber, line)
          end
        # Assume text otherwise for now
        else
          file = File.open(filename)
          file_data = file.read
          # Read in file line by line
          file_data.each_line do |line|
            processLine(docNumber, line)
          end
          file.close
        end
        docNumber += 1
      end
      rescue
          puts "Error in file name"
          puts filename
          puts docNumber
          puts "\n\n"
      end
      
  end
  rescue
    puts "Error in folder name"
    exit 4
  end
  puts "Inverted index initialized and created"
end

# Helper function to process lines of text
def processLine (docNumber, line)
  line = line.to_s
  # Cleans line of white space
  line.chomp!
  #checks for punctuation and numbers
  line.gsub!($remove_punctuation, '')
  line.gsub!($numbers, "")
  line.gsub!(/-/, ' ')
  line.downcase!
  #splits the line into words
  words = line.split(' ').to_a
  # Handles each word
  words.each do |word|
    # Check if in hash
    if $index.has_key? word
      if $index[word].has_key? docNumber
        $index[word][docNumber] += 1
      else
        $index[word][docNumber] = 1
      end
    # Make new internal hash
    else
      $index[word] = Hash.new
      $index[word][docNumber] = 1
    end
  end
end

# Values into lexicon

# Calculated tf-idf weight for each term in index and stores in lexicon
# Not a true tf-idf weight, each term gets a cosine naturalized term-freq as weight
# Converts $index to format:
# format: $index[term] gives hash term[docNumber] = weight
# Then 
# format: $lexicon[first_char] gives hash first_char[len] gives len[term] = weight
def weightsCalc
  begin
    # For each term calculate the term-freq
    # Iterate over terms
    terms = $index.keys
    terms.each do |term|
      # Get all doc numbers for term
      docs = $index[term].keys
      # Iterate over doc numbers
      docs.each do |key|
        newVal = 1 + Math.log($index[term][key], 10)
        $index[term][key] = newVal
      end
    end
    puts "Weights calculated"
    
    # Now calculate cosine normalized score for each term
    terms.each do |term|
      sum = 0
      $index[term].each do |weight|
        #puts weight
        sum += weight[1]**2
      end
      # Cosine sum is calculated
      consineDiv = Math.sqrt(sum)
      
      # Sum of normalized values
      cosineSum = 0

      # Calculate cosine normalized weight for each doc
      $index[term].each do |weight|
        #puts weight
        cosineSum += weight[1] / consineDiv
      end
      $index[term] = cosineSum / $index[term].length
    end
  rescue
    puts "Error calculating weights"
  end
end

# OTHER

#Reads the file of words to check
def to_check file_to_check
  #Opens the file to check
  file = File.open(file_to_check, 'r')
  #Reads until the end of the file
  until file.eof?
    #For each line check the spelling of each word
    file.each_line do |line|
      line.chomp!.downcase!
      #cleans punctuation
      line.gsub!($remove_punctuation, "")
      #Removes numbers since they can't be spelled wrong
      line.gsub!(/\d/, "")
      line.split.each do |word|
        $words[word] = false
      end
    end
  end
end

#Checks the spelling of all words in array
def spell_check
  #Temp has to get around iterating blocking hash editing
  temp_hash = Hash.new
  #For each word hash pair
  $words.each do |word|
    #Sets default values
    first_char = ''
    second_char = ''
    #If the word is more than 1 character sets first and second characters appropriatly
    if word[0].length > 1
      first_char = word[0][0]
      second_char = word[0][1]
    #If the word length is 1 sets first and second char to word
    elsif word[0].length == 1
      first_char = word[0][0]
      second_char = word[0][0]
    end
    #puts "First char: #{first_char}\nSecond char: #{second_char}\nWord: #{word[0]}, length = #{word[0].length}"

    #Searches lexicon for match, default is false
    match = false
    #For each word in the lexicon with the same first and second characters checks for equality
    $lexicon[first_char][second_char].each do |check|
      #If the words are the same sets spelling to true, or correct and breaks out of loop
      if check == word[0]
        match = true
        break;
      end
    end
    #Sets temp hash to proper values, to be reassigned to word hash after full iterations
    temp_hash[word[0]] = match
  end
  #Sets words hash with proper values
  temp_hash.each do |temp|
    $words[temp[0]] = temp[1]
  end
end

#Prints the words that are spelled wrong
def feedback
  puts "Spelling errors"
  #Default errors is 0
  errors = 0
  #For each word in the word hash
  $words.each do |word|
    #If the word is spelled wrong prints the word and increments errors
    if word[1] == false
      puts "#{word[0]}"
      errors += 1
    end
  end
  #If there are no errors states as much
  if errors == 0
    puts "No errors found"
  end
end

#Finds suggestions for misspelled words
def corrections
  #For each word to be looked at
  $words.each do |word_array|
    #If the word is misspelled attempt corrections
    possible_matches = Array.new
    if word_array[1] == false
      #Sets word to the actual word, instead of array pair
      word = word_array[0]
      #Same logic as earlier char finders, perhaps turn into seperate method
      first_char, second_char = find_chars word
      ##Find words with similar letters
      #Saves the lenght of the word for eaiser access
      size = word.length
      #Iterates over words with matching starting letters
      $lexicon[first_char][second_char].each do |word_compare|
        #If the size is within one of word to check, adds to possible matches
        if word_compare.length == size - 1 || word_compare.length == size + 1 || word_compare.length == size
          possible_matches << word_compare
        end
      end
      #Iterates over lexicon again, except only uses first character, to make sure more words are found
      'a'.upto 'z' do |char|
        $lexicon[first_char][char].each do |word_compare|
          #If the size is within one of word to check, adds to possible matches
          if word_compare.length == size - 1 || word_compare.length == size + 1 || word_compare.length == size
            possible_matches << word_compare
          end
        end
      end
      #Iterate over the possible matches, taking the match with the highest percentage
      #Hash to hold similarity
      similarity = Hash.new(0.0)
      possible_matches.each do |word_to_compare|
        similarity[word_to_compare] = match_percentage word, word_to_compare
      end
      #Hash with the final chance, combining match_percentage and frequency
      match_chance = Hash.new(0.0)
      similarity.each do |match|
        match_chance[match[0]] = (3 * match[1].to_f + $language[match[0]]) / 4
      end
      best_match = ''
      match_chance.each do |match|
        if match[1] > match_chance[best_match]
          best_match = match[0]
        end
      end
      $correction[word] = best_match
    end
  end
end


#Calculates the percentage of matches betwee nthe two provided words
def match_percentage incorrect, possible
  #Creates character arrays for both words
  incorrect_array = incorrect.split("")
  possible_array = possible.split("")
  #Hashes to hold conut of each char
  incorrect_hash = Hash.new(0)
  possible_hash = Hash.new(0)
  #Counts the characters in each word
  incorrect_array.each do |char|
    incorrect_hash[char] += 1
  end
  possible_array.each do |char|
    possible_hash[char] += 1
  end
  ##Compares the two hashes and returns similarity as a decimal
  #The overall percentage and total characters, used to calculate final percentage
  overall_percentage = 0.to_f
  total_chars = [incorrect_hash.keys.length, possible_hash.keys.length].max
  #Iterates over the hash for the possible correction
  possible_hash.each do |chars|
    #Sets char to the actual character
    char = chars[0]
    #Sets value_possible to count in possible hash
    value_possible = chars[1]
    #Sets value_incorrect to count in incorrect hash
    value_incorrect = incorrect_hash[char]
    #If neither value is zero calcluates similarity and adds to overall_percentage, otherwise its 0
    if value_possible != 0 && value_incorrect != 0
      min = [value_possible, value_incorrect].min
      max = [value_possible, value_incorrect].max
      overall_percentage += (min.to_f / max.to_f)
    end
  end
  #Calculates similarity percentage and returns
  overall_percentage /= total_chars
  return overall_percentage
end

def main_loop
  #Checks that the user has specified the correct amount of files on startup, assumes they are correct
  if ARGV.length < 1
    puts "Need to specify lexicon source and language source"
    exit 4
  end
  #Creates the initial lexicon object
  initialize_lexicon
  #Populates the lexicon object with the words from the given file
  populate_lexicon ARGV[0]
  #User input loop
  puts "Please enter folder that contains the corpus, enter 'q' to quit"
  print '> '
  firstName = true
  while user_input = STDIN.gets.chomp!
    if user_input == 'q'
      puts "Goodbye!"
      break;
    end
    if !firstName
      if(File.exists?(user_input))
        to_check(user_input)
        spell_check
        corrections
        # Print correction and clear hashes for next document
        puts $correction
        $words.clear()
        $correction.clear()
      else
        puts "Filename invalid, try again"
      end
    else
      # Create inverted index and tell program it is done
      invertedIndex user_input
      firstName = false

      # Create weights for words in index and assign to lexicon
      weightsCalc
    end
    puts "Please enter file name to be corrected, enter 'q' to quit"
    print '> '
  end
end

if __FILE__==$0
  main_loop
end
