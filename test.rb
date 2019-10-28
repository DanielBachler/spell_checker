require "yomu"
require "find"
require "docx"

def invertedIndex (folder)
    begin
    # Extend folder name to be used by dir
    folder += "\\"
    # Iterate over each file in folder
    Find.find(folder) do |filename|
        begin
        # Ignore just folder name
        if !filename.eql? folder
            # Read in each file
            # If .docx
            if filename.include? ".docx"
               d = Docx::Document.open(filename)
             else
             f = File.read(filename)
            end
            # Tokenize text
            puts "Read file"
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