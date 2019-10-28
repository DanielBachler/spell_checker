# Features to Add
Proposed:
- upgraded dictionary creation
- larger corpus for term weighting
- use tf-idf weighting for terms
- improved hash structure


# Dictionary creation

Currently the lexicon is created from the words_alpha.txt file and those words are then given a term-frequency using language.txt.  

The new system will create an inverted index that will be populated by reading in the provided corpus.  This inverted index will be a hash with words as the keys and a set of tuples for the values.  

These tuples will be the document number for the first term, and a count of the word for the second term, 0 values will not be present.

To turn this into a dictionary with the more powerful lookup structure the entire inverted index will be iterated over upon completion and terms scored and sorted into the new hash.

## Future upgrade

Store the created dictionary so that runtime is faster and have flag in program init to specify whether to use pre-genned dictionary of generate new from corpus

# Improved Corpus

The new system will use a larger corpus, that for my testing purposes, will compose of a folder containing as many essays and papers as I can find that I have written.  For other users who wish to use the spell checker to its full extent they should provide their own corpus of their own writings for best results.

# Weighting and similarity scoring

Along with overhauling the dictionary and its creation, the way terms are scored for comparison and weighting also need to be changed.  

For term weight, instead of relying solely on document-frequency the new system will implement tf-idf scoring for terms.  For all documents the tf-idf variant used will be ltc (logarithmic, idf, cosine) to ensure that all words are given an appropriate weight.

For comparing similarity, the new system will use two scores in a weighted average.  First is the tf-idf score calculated for various terms, the second is the "matching" of the terms.  For example, given `thrre` as the term and comparing to `there` for similarity, the number of matching letters as a ratio to total letters is calculated.  So in this case, 4/5 match, meaning `there` gets a similarity score of `0.8 * tf-idf(there)`.  

All non-zero scoring terms will be put into a temporary hash, and the highest scoring term will be selected.  If there is a tie between terms, the term with the higher tf-idf score will be chose.  If there is another tie between both similarity score and tf-idf weight then one term will be chosen at random.

## Future improvement

Return top 10 words based on similarity score.

# New Hash Structure (dictionary)

The new hash will consist of a similar layered approach as the current solution, but with major changes.  

The outermost hash will be for alphabetical ordering, with keys of a-z and values being an internal hash.

This internal hash will be for the length of the words, with dynamic size determined upon creation and throughout run time.  This will in turn, point to another hash with words of a similar length.

This final hash will contain words of a given length `i` as the keys, and the values will be the tf-idf weight of the words for the given corpus.