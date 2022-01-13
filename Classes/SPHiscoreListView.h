//
//  SPHiscoreListView.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 16 Feb 2011.
//  Copyright 2011 Superpanic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPListView;

@interface SPHiscoreListView : UIView {
	CGRect gameScreenRect;
	SPListView *listView;
}

- (void) loadHiscoreList;
- (void) startScroll;
- (BOOL) isScrolling;	
- (BOOL) isEmpty;
- (void) reload;

@property (nonatomic, retain) SPListView *listView;

@end
