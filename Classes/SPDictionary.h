//
//  Dictionary.h
//  TouchSpell
//
//  Created by Fredrik Josefsson on 2008-12-14.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SPDictionary : NSObject {
	NSArray *words;
	int index;
	int hi;
	int lo;
	int counter;
	int minWordLengt;
	int maxWordLengt;
	
	NSArray *gameLetterValueArray;
	NSArray *gameLetterCharArray;
	
	NSLocale *gameLocale;
	
	NSRange searchRange;
	NSMutableString *currentWord;
	NSMutableString *randomCharWord;
}

- (id)initWithLang:(NSString *)language;
- (int)numberOfWordsInDictionary;
- (int)getCharValue:(unichar)letter;
// - (int)getCharValue:(NSString *)letter;
- (BOOL)checkWord:(NSString *)word;
- (unichar)getRandomChar;

@property int index;
@property int hi;
@property int lo;
@property int counter;
@property int minWordLengt;
@property int maxWordLengt;
@property (nonatomic, retain) NSArray *gameLetterValueArray;
@property (nonatomic, retain) NSArray *gameLetterCharArray;
@property (nonatomic, retain) NSLocale *gameLocale;
@property (nonatomic, retain) NSArray *words;
@property (nonatomic, retain) NSMutableString *currentWord;
@property (nonatomic, retain) NSMutableString *randomCharWord;

@end

