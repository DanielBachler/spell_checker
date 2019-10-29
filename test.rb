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

def main_loop
  invertedIndex "corpus"
  puts "Init index"
  puts $index["i"]
  weightsCalc
  puts "\n\nConverted index"
  puts $index["i"]
end

if __FILE__==$0
    main_loop
end