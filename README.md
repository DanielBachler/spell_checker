# spell_checker
A spell checker written in ruby, utilizing the lexicon provided by dwyl

End goal is for user to be able to input files into cmd line and have file checked by program
with an output file of all errors

Future goals

-	In place text correction

-	Larger lexicon

-	Optimization

The lexicon is constructed in the following format: A hash containing the letters of the alphabet, which each map to a hash of word lengths, which finally maps to a hash of weighted scores for each word of that length.

Once the lexicon is constructed the file to be corrected is read in and turned into a hash with the words being keys and the values being true/false

Spelling is then checked for errors and word hash is updated appropriately.

Currently only the errors are printed.

# INIT

To run the program, first Ruby must be installed.  

`ruby spell_checker.rb words_alpha.txt`

The order of files is the program, the list of words to use for lexicon, and a large example of the language to give words weight (corpus folder).
