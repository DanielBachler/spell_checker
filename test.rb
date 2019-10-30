require "find"
require "docx"

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
$remove_punctuation = /[\?\¿\!\¡\.\;\&\@\%\#\|\,\*\(\)\#\"\\\/\“\…\–]/
# Global regex for numbers
$numbers = /[0-9]/
#Hash to hold fixed words
$correction = Hash.new

# Lexicon functions
def match_percentage incorrect, possible
  #Creates character arrays for both words
  incorrect_array = incorrect.split("")
  possible_array = possible.split("")

  #Hashes to hold count of each char
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
  return overall_percentage * $index[possible]
end

def main_loop
  $index['test'] = 0.6
  puts match_percentage 'test', 'test'
  puts match_percentage 'tett', 'test'
  puts match_percentage 'this', 'test'
end

if __FILE__==$0
    main_loop
end