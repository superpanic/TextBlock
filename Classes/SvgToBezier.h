//
//  SvgToBezier.h
//
//  Created by Martin Haywood on 5/9/11.
//  Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0) license 2011 Ponderwell.
//

#import <Foundation/Foundation.h>

@interface SvgToBezier : NSObject {
	@private
	CGSize			viewBox;
	float			pathScale;
	UIBezierPath*		bezier;
	CGPoint			lastPoint;
	CGPoint			lastControlPoint;
	BOOL			validLastControlPoint;
	NSCharacterSet*		separatorSet;
	NSCharacterSet*		commandSet;
}

@property(nonatomic, readonly) UIBezierPath* bezier;

- (id) initFromSVGPathNodeDAttr: (NSString*) attr inViewBoxSize: (CGSize) size;

- (void) dealloc;

@end
