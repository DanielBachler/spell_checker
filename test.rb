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


def main_loop
  
end

if __FILE__==$0
    main_loop
end