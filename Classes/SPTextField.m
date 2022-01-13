//
//  SPTextField.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 27 Nov 2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPTextField.h"


@implementation SPTextField


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)dealloc {
    [super dealloc];
}


@end
