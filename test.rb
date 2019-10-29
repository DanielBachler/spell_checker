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

# Creates and fills the inverted index from the given corpus
def invertedIndex (folder)
  begin
  # Extend folder name to be used by dir
  #folder += "\\"
  # Iterate over each file in folder
  # Set doc number
  docNumber = 1
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
    begin
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
    rescue
      puts word
      exit 4
    end
  end
end

def main_loop
    # testLine = "This reading struck a chord with me, as arguing is one of my hobbies.  While reading through the piece, I saw things that I did subconsciously while making an argument.  In high school I noticed that a lot of people would not properly create their argument, rather resorting to simply telling others they were wrong without having any evidence to support their claims.  Due to my very different views I quickly learned to create a proper argument, so that my classmates would have a much harder time refuting my claims.  The idea of researching past arguments and framing my own within that perspective was something I already knew was important, but the idea of creating a question that you can answer with your evidence to further cement my argument was a hit or miss.  I did not do it every time, but now after reading this piece, looking back I can see that the times I did create that question my argument was much stronger.  Instead of just telling people what you want them to think, asking them a question makes them think for themselves.  Once you get them thinking, and you provide evidence to support your side, while showing that the opposing views argument is flimsy, most people will be more willing to accept what you say.  Another important thing I must say after reading this, is the idea we have of an argument just being people screaming at each other that the other is wrong, is wrong.  That is not an argument that is just two people fighting without making progress on the other.  Whoever yells the loudest will usually win, as the other person simply does not want to continue.  By showing that this idea of argument is wrong, hopefully the negative connotation of the word will be removed, and we can focus on the positives of argument.  If you never argue with people over things—whether big or small—you will not be able to gain more perspective.  Even though I disagree with most of what the liberal party has to say, I will still listen to them and respect their views, because I want them to do the same for me.  If, however I just shut my ears and eyes and sang “lalalalalala” I would be showing that I do not respect them enough to at least listen to what they have to say, even when I disagree.  It is my hope that going forward into the future, people will be more willing to listen and have actual debate and arguments, instead of sticking their heads into the sand."
    # processLine(1, testLine)
    # processLine(2, testLine)
    # d = Docx::Document.open("corpus/Bachler5Questions.docx")
    # d.each_paragraph do |p|
    #     processLine(1, p)
    # end
    invertedIndex "corpus"
    puts $index["i"]
end

if __FILE__==$0
    main_loop
end