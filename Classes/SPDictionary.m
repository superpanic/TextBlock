//
//  Dictionary.m
//  TouchSpell
//
//  Created by Fredrik Josefsson on 2008-12-14.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SPDictionary.h"
#import "stdio.h"
#import "SPCommon.h"

@implementation SPDictionary

@synthesize words;
@synthesize index;
@synthesize hi;
@synthesize lo;
@synthesize minWordLengt;
@synthesize maxWordLengt;
@synthesize gameLetterValueArray;
@synthesize gameLetterCharArray;
@synthesize gameLocale;
@synthesize counter;
@synthesize currentWord;
@synthesize randomCharWord;

// values used for calculating game score
//                              a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z
// int gameLetterValues[26] = { 1, 2, 2, 2, 1, 2, 2, 2, 1, 4, 4, 2, 2, 1, 1, 2, 4, 1, 1, 1, 2, 4, 2, 4, 1, 4 };
// char gameLetterChars[26] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

- (void)dealloc {
	[words release];
	[currentWord release];
	[gameLocale release];
	[gameLetterValueArray release];
	[gameLetterCharArray release];
	[super dealloc];
}

- (id)initWithLang:(NSString *)language {
	if( (self = [super init]) ) {
		
		// ### read the english.plist file containing the dictionary of words ###
		// find the path to dictionary
		NSBundle *thisBundle = [NSBundle bundleForClass:[self class]]; // object will be autoreleased
		NSString *path = [thisBundle pathForResource:language ofType:@"plist"]; // object will be autoreleased
		
		// temporaray dictionary object
		NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:path];
		
		// create an array with all the words
		// NSArray *w = [[NSArray alloc] initWithArray:[NSArray arrayWithContentsOfFile:path]];
		NSArray *tempWords = [[NSArray alloc] initWithArray:[d objectForKey:@"Dictionary"]];
		[self setWords:tempWords];
		[tempWords release];
		
		NSArray *tempGameLetterValueArray = [[NSArray alloc] initWithArray:[d objectForKey:@"Values"]];
		[self setGameLetterValueArray:tempGameLetterValueArray];
		[tempGameLetterValueArray release];
//		NSLog(@"values: %@", [gameLetterValueArray description]);
		
		NSArray *tempGameLetterCharArray = [[NSArray alloc] initWithArray:[d objectForKey:@"Charset"]];
		[self setGameLetterCharArray:tempGameLetterCharArray];
		[tempGameLetterCharArray release];
//		NSLog(@"charset: %@", [gameLetterCharArray description]);
		
		// a string used to compare words from dictionary
		NSMutableString *tempCurrentWord = [[NSMutableString alloc] initWithFormat:@""];
		[self setCurrentWord:tempCurrentWord];
		[tempCurrentWord release];
		
		// a string used to extract random chars from the dictionary
		NSMutableString *tempRandomCharWord = [[NSMutableString alloc] initWithFormat:@""];
		[self setRandomCharWord:tempRandomCharWord];
		[tempRandomCharWord release];

		NSLocale *temp_gameLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"];
		[self setGameLocale:temp_gameLocale];
		[temp_gameLocale release];
		
		// current search index
		[self setIndex:0];
		[self setLo:0];
		[self setHi:[words count]-1];
		
		[self setMinWordLengt:3];
		[self setMaxWordLengt:12];
		
		// check counter
		[self setCounter:0];
		
	}
	return self;
}

/*
- (int)getCharValue:(unichar)letter {
	// char *strchr(const char *string, int c) -- Find first occurrence of character c in string.
	char *charPos = strchr(gameLetterChars, letter);
	int i = 1;
	if(charPos) i = gameLetterValues[charPos - gameLetterChars];
	// return gameLetterValues[i];
	return i;
}
*/
 

- (int)getCharValue:(unichar)letter {
	// int charPos = [gameLetterChars indexOfObject:letter];
	NSString *s = [NSString stringWithFormat:@"%C", letter];
	int charPos = [gameLetterCharArray indexOfObject:s];
	// always return at least 1 as score value
	int i = 1;
	if (charPos) i = [[gameLetterValueArray objectAtIndex:charPos] intValue];	
	return i;
}

 
- (int)numberOfWordsInDictionary {
	return [words count];
}

/*
- (char)getRandomChar {
	if([randomCharWord length] == 0) {
		// extract a new random word from the dictionary
		int randomIndex = arc4random() % ( [words count]-1 );
		[randomCharWord setString:[words objectAtIndex:randomIndex]];
		// NSLog(@"%@", randomCharWord);
	}
	
	// create a random number with max value as file name arrays length
	int randomLetterIndex = ( arc4random() % [randomCharWord length] );
	// create the filename string
	char c = [randomCharWord characterAtIndex:randomLetterIndex];
	NSRange range = {randomLetterIndex, 1};
	[randomCharWord deleteCharactersInRange:range];
	
	// NSLog(@"%C", c);
	
	return c;
}
*/

- (unichar)getRandomChar {
	if([randomCharWord length] == 0) {
		// extract a new random word from the dictionary
		int randomIndex = arc4random() % ( [words count]-1 );
		[randomCharWord setString:[words objectAtIndex:randomIndex]];
		// NSLog(@"%@", randomCharWord);
	}
	
	// create a random number with max value as file name arrays length
	int randomLetterIndex = ( arc4random() % [randomCharWord length] );
	// create the filename string
	unichar c = [randomCharWord characterAtIndex:randomLetterIndex];
	NSRange range = {randomLetterIndex, 1};
	[randomCharWord deleteCharactersInRange:range];
	
	// NSLog(@"%C", c);
	
	return c;
}

- (BOOL)checkWord:(NSString *)word {

	if([word length] < minWordLengt) return NO;
	if([word length] > maxWordLengt) return NO;

	[self setLo:0];
	[self setHi:[words count]-1];
	[self setIndex:hi/2];

	
	searchRange.location = 0;
	searchRange.length = [word length];

	counter = 0;

	// while the search range is still more than 1
	while(hi - lo > 1) {

		// extract current word
		[currentWord setString:[words objectAtIndex:index]];

		// compare using swedish locale (works for english locale as well)
		NSComparisonResult result = [word compare:currentWord options:NSAnchoredSearch range:searchRange locale:gameLocale];

		if( result == 0 ) {
			NSLog(@"%@ found match!", word);
			NSLog(@"number of searches: %i", counter);
			return YES;
		}
		
		if ( result > 0 ) {
			// move lo up
			lo = index;
			index = hi-((hi-lo)/2);
			//NSLog(@"%@ is higher than %@\nindex: %i", word, currentWord, index);
		} else {
			// move hi down
			hi = index;
			index = hi-((hi-lo)/2);
			//NSLog(@"%@ is lower than %@ \nindex: %i", word, currentWord, index);
		}

		counter++;
	}

	// NSLog(@"%@ NOT found!", word);
	// NSLog(@"number of searches: %i", counter);
	return NO;
}

@end
