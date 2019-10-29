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
$remove_punctuation = /[\?\¿\!\¡\.\;\&\@\%\#\|\,\*\(\)\#\"\\\/]/
# Global regex for numbers
$numbers = /[0-9]/
#Hash to hold fixed words
$correction = Hash.new

def invertedIndex (folder)
    begin
    # Extend folder name to be used by dir
    folder += "\\"
    # Iterate over each file in folder
    Find.find(folder) do |filename|
      begin
        # Ignore just folder name
        if !filename.eql? folder
          begin 
          # Set doc number
          docNumber = 1
          # Read in each file
          # If .docx
          file = ""
          # Create file item based on if .txt or .docx
          if filename.include? ".docx"
            file = Docx::Document.open(filename)
          else
            file = File.read(filename)
          end
          # Read in file line by line
          file.each_line do |line|
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
              if $index.include?(word)
                $index[word][docNumber] += 1
              # Make new internal hash
              else
                $index[word] = Hash.new
                $index[word][docNumber] = 1
              end
              rescue
                puts "Meh"
              end
            end
          end
          # Tokenize text
          puts "Read file"
          docNumber += 1
        end
        rescue
            puts "Error in file name"
            puts filename + "\n"
        end
    end
    rescue
      puts "Error in folder name"
      exit 4
    end
    puts "Inverted index initialized and created"
end

def main_loop
    invertedIndex "corpus"
    # d = Docx::Document.open("corpus\\Bachler5Questions.docx")
    # d.each_paragraph do |p|
    #     puts p
    # end
end

if __FILE__==$0
    main_loop
end