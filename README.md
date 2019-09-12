# spell_checker
A spell checker written in ruby, utilizing the lexicon provided by dwyl

End goal is for user to be able to input files into cmd line and have file checked by program
with an output file of all errors

Future goals:

	In place text correction

	Larger lexicon

	Optimization

The lexicon is constructed in the following format: A hash of first letter -> A hash of second letter -> an array containing all words that fit in this category.

Once the lexicon is constructed the file to be corrected is read in and turned into a hash with the words being keys and the values being true/false

Spelling is then checked for errors and word hash is updated appropriately.

Currently only the errors are printed.
