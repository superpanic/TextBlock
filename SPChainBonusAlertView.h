//
//  SPChainBonusAlertView.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2011-08-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPChainBonusAlertView : UIView {
	UIBezierPath *bezierPath;
}

- (void) addSvgPathIcon:(NSString *)svgString;

@property (nonatomic, retain) UIBezierPath *bezierPath;

@end
