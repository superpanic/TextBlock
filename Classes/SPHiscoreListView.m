//
//  SPHiscoreListView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 16 Feb 2011.
//  Copyright 2011 Superpanic. All rights reserved.
//

#import "SPHiscoreListView.h"
#import "SPListView.h"
#import "SPCommon.h"

@implementation SPHiscoreListView

@synthesize listView;

- (void)dealloc {
	[listView release];
	[super dealloc];
}


- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code.

		// create a rect for whole screen
		gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
		
		// create the list view
		SPListView *temp_listView = [[SPListView alloc] 
					     initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame)) 
					     cellHeight:(CGRectGetHeight(gameScreenRect) * 0.2)
					     ];
		[self setListView:temp_listView];
		[temp_listView release];
		
		[self setBackgroundColor:[SPCommon SPGetRed]];
		
		[self loadHiscoreList];
		
	}
	return self;
}

- (void) loadHiscoreList {

	NSLog(@"Loading hiscore list!");

	// read saved hiscores from iphone
	NSArray *hiscoreArray = [SPCommon readHiscores];
	
	NSString *bestWordString;
	bestWordString = NSLocalizedString(@"HISCORE_BEST_WORD", @"Title text for best word info.");
	
	//NSString *lettersString;
	//lettersString = NSLocalizedString(@"HISCORE_LETTERS", @"Title text for points of best word.");
	
	NSString *emptyPlayerString;
	emptyPlayerString = NSLocalizedString(@"EMPTY_PLAYER", @"Name for default empty player in hiscore list.");
	
	// loop through all hiscores and create a list view cell
	int counter = 0;
	for(NSDictionary *aDict in hiscoreArray) {
		NSString *playerRankAndNameString = [NSString stringWithFormat:@"#%i - %@", counter+1, [aDict objectForKey:@"name"]];
		NSString *hiscoreString = [NSString stringWithFormat:@"%i", [[aDict objectForKey:@"score"] intValue] ];
		int letterCount = [[aDict objectForKey:@"bestWordScore"] intValue];
		if(letterCount <= 1) letterCount = 0;
		NSString *numberOfLettersInBestWordString = [NSString stringWithFormat:@"%@: %i", bestWordString, letterCount];
		[listView addCellWithTitle:playerRankAndNameString info:hiscoreString smallInfo:[aDict objectForKey:@"longword"] smallTitle:numberOfLettersInBestWordString];
		counter++;
	}
	
	// fill up with empty cells
	if([[listView cells] count] < 15) {
		for(int i = [[listView cells] count]; i<15; i++) {
			NSString *playerRankAndNameString = [NSString stringWithFormat:@"#%i - %@ %i", i+1, emptyPlayerString, i+1];
			NSString *numberOfLettersInBestWordString = [NSString stringWithFormat:@"%@: %i", bestWordString, 0];
			[listView addCellWithTitle:playerRankAndNameString info:@"0" smallInfo:@"N/A" smallTitle:numberOfLettersInBestWordString];				
		}
	}
	
	// add list view to main view
	[self addSubview:listView];
		
}

- (void) startScroll {
	if([[listView cells] count] == 0) return;
	[listView autoScrollToCell:MIN([[listView cells] count], 15)];
	// blink no 1 player!
	[listView blinkCell:0];
}

- (BOOL) isEmpty {
	if([[listView cells] count] == 0) return YES;
	return NO;
}

- (BOOL) isScrolling {
	return [listView isAutoScrolling];
}

- (void) reload {
	[listView removeCells];
	[self loadHiscoreList];
	//[listView setIsTouchedFlag:YES];	
}

@end
