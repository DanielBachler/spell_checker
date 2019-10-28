require "yomu"
require "find"

def invertedIndex (folder)
    begin
    # Extend folder name to be used by dir
    #folder = ""
    # Iterate over each file in folder
    Find.find(folder) do |filename|
      begin
      # Create yomu for each file
      data = File.read filename
      text = Yomu.read :text, data 
      # Tokenize text
      puts "Read file"
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
    #invertedIndex "corpus\\"
    # puts File.ftype "corpus\\langauge.txt"
    # puts File.ftype "corpus/"
    # puts File.ftype "/corpus/language.txt"
    # corpus\langauge.txt
    data = File.read("corpus\\Bachler5Questions.docx")
    text = Yomu.new data 
    puts text.text
end

if __FILE__==$0
    main_loop
end