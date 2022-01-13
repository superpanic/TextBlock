//
//  SPDropShadow.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SPDropShadowView : UIView {
	UIColor *shadowColor;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)c;

@property (nonatomic, retain) UIColor *shadowColor;

@end
