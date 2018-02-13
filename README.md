# spell_checker
A spell checker written in ruby, utilizing the lexicon provided by dwyl\n
End goal is for user to be able to input files into cmd line and have file checked by program\n
with an output file of all errors \n
Future goals: \n
	In place text correction\n
	Larger lexicon\n
	Optimization\n
	
The lexicon is constructed in the following format: A hash of first letter -> A hash of second letter -> an array containing all words that fit in this category.\n
Once the lexicon is constructed the file to be corrected is read in and turned into a hash with the words being keys and the values being true/false\n
Spelling is then checked for errors and word hash is updated appropriatly\n
Currently only the errors are printed.\n
