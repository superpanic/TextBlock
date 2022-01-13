//
//  SvgToBezier.m
//
//  Created by Martin Haywood on 5/9/11.
//  Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0) license 2011 Ponderwell.
//
//  NB: Private methods here declared in a class extension, implemented in the class' main implementation block.

#import "SvgToBezier.h"

int const maxPathComplexity			= 1000;
int const maxParameters				= 64;
int const maxTokenLength			= 64;
NSString* const separatorCharString		= @"-,CcMmLlHhVvZzqQaAsS";
NSString* const commandCharString		= @"CcMmLlHhVvZzqQaAsS";
unichar const invalidCommand			= '*';



@interface Token : NSObject {
@private
	unichar			command;
	NSMutableArray *values;
}

@property(nonatomic, assign) unichar command;


- (id) init;
- (id) initWithCommand: (unichar) commandChar;
- (void) addValue: (float) value;
- (float) parameter: (int) index;
- (int) valence;
- (void) dealloc;

@end


@implementation Token

@synthesize command;

- (id) init {
	[super init];
	if (self) {
		command = invalidCommand;
		values = [[NSMutableArray alloc] initWithCapacity:maxParameters];
	}
	else {
		NSLog(@"Could not init token.");
	}
	return self;
}

- (id) initWithCommand:(unichar)commandChar {
	if ([self init]) {
		command = commandChar;
	}
	return self;
}

- (void) addValue: (float) value {
	[values addObject:[NSNumber numberWithFloat: value]];
}

- (float) parameter: (int)index {
	return [[values objectAtIndex:index] floatValue];
}

- (int) valence {
	return [values count];
}

- (void) dealloc {
	[values release];
	[super dealloc];
}

@end


@interface SvgToBezier ()

- (NSArray *) parsePath:(NSString *)attr;
- (UIBezierPath *) generateBezier:(NSArray *)tokens;

- (void) reset;
- (void) appendSVGMCommand: (Token *) token;
- (void) appendSVGLCommand: (Token *) token;
- (void) appendSVGCCommand: (Token *) token;
- (void) appendSVGSCommand: (Token *) token;
- (CGPoint) bezierPoint: (CGPoint) svgPoint;

@end


@implementation SvgToBezier

@synthesize bezier;

- (id) initFromSVGPathNodeDAttr:(NSString *)attr inViewBoxSize:(CGSize)size {
	[super init];
	if (self) {
		pathScale = 0;
		viewBox = size;
		[self reset];
		separatorSet = [NSCharacterSet characterSetWithCharactersInString:separatorCharString];
		commandSet = [NSCharacterSet characterSetWithCharactersInString:commandCharString];
		NSArray* tokens = [[self parsePath:attr] retain];
		bezier = [self generateBezier:tokens];
		for (Token *token in tokens) {
			[token release];
		}
		[tokens release];
	}
	return self;
}

- (void) dealloc {
	[bezier release];
	[super dealloc];
}

#pragma mark - Private methods

/*
 Tokenise pseudocode, used in parsePath below
 
 start a token
 eat a character
 while more characters to eat
 add character to token
 while in a token and more characters to eat
 eat character
 add character to token
 add completed token to store
 start a new token
 throw away empty token
 */

- (NSArray *)parsePath:(NSString *)attr {
	NSMutableArray *stringTokens = [[NSMutableArray alloc] initWithCapacity: maxPathComplexity];
	
	int index = 0;
	while (index < [attr length]) {
		NSMutableString *stringToken = [[[NSMutableString alloc] initWithCapacity:maxTokenLength] autorelease];
		[stringToken setString:@""];
		unichar	charAtIndex = [attr characterAtIndex:index];
		if (charAtIndex != ',') {
			[stringToken appendString:[NSString stringWithFormat:@"%c", charAtIndex]];
		}
		if (![commandSet characterIsMember:charAtIndex] && charAtIndex != ',') {
			while ( (++index < [attr length]) && ![separatorSet characterIsMember:(charAtIndex = [attr characterAtIndex:index])] ) {
				[stringToken appendString:[NSString stringWithFormat:@"%c", charAtIndex]];
			}
		}
		else {
			index++;
		}
		if ([stringToken length]) {
			[stringTokens addObject:stringToken];
		}
	}
	
	if ([stringTokens count] == 0) {
		NSLog(@"Path string is empty of tokens");
		[stringTokens release];
		return nil;
	}
	
	// turn the stringTokens array into Tokens, checking validity of tokens as we go
	NSMutableArray* tokens = [[NSMutableArray alloc] initWithCapacity:maxPathComplexity];
	index = 0;
	NSString* stringToken = [stringTokens objectAtIndex:index];
	unichar command = [stringToken characterAtIndex:0];
	while (index < [stringTokens count]) {
		if (![commandSet characterIsMember:command]) {
			NSLog(@"Path string parse error: found float where expecting command at token %i in path %s.", 
			      index, [attr cStringUsingEncoding:NSUTF8StringEncoding]);
			[stringTokens release];
			return nil;
		}
		Token *token = [[Token alloc] initWithCommand:command];
		
		// There can be any number of floats after a command. Suck them in until the next command.
		while ((++index < [stringTokens count]) && ![commandSet characterIsMember:
							     (command = [(stringToken = [stringTokens objectAtIndex:index]) characterAtIndex:0])]) {
			
			NSScanner *floatScanner = [NSScanner scannerWithString:stringToken];
			float value;
			if (![floatScanner scanFloat:&value]) {
				NSLog(@"Path string parse error: expected float or command at token %i (but found %s) in path %s.", 
				      index, [stringToken cStringUsingEncoding:NSUTF8StringEncoding], [attr cStringUsingEncoding:NSUTF8StringEncoding]);
				[stringTokens release];
				return nil;
			}
			// Maintain scale.
			pathScale = (fabs(value) > pathScale) ? fabs(value) : pathScale;
			[token addValue:value];
		}
		
		// now we've reached a command or the end of the stringTokens array
		[tokens	addObject:token];
		[token release];
		token = nil;
	}
	[stringTokens release];
	return tokens;
}

- (UIBezierPath *) generateBezier: (NSArray *) tokens {
	bezier = [[UIBezierPath alloc] init];
	[self reset];
	for (Token *token in tokens) {
		unichar command = [token command];
		switch (command) {
			case 'M':
			case 'm':
				[self appendSVGMCommand: token];
				break;
			case 'L':
			case 'l':
			case 'H':
			case 'h':
			case 'V':
			case 'v':
				[self appendSVGLCommand: token];
				break;
			case 'C':
			case 'c':
				[self appendSVGCCommand: token];
				break;
			case 'S':
			case 's':
				[self appendSVGSCommand: token];
				break;
			case 'Z':
			case 'z':
				[bezier closePath];
				break;
			default:
				NSLog(@"Cannot process command : '%c'", command);
				break;
		}
	}
	return bezier;
}

- (void) reset {
	lastPoint = CGPointMake(0, 0);
	validLastControlPoint = NO;
}

- (CGPoint) bezierPoint: (CGPoint) svgPoint {
	/*
	 
	 this doesn't yet work.
	 
	 if (pathScale == 0.0) {
	 return CGPointMake(0,0);
	 }
	 float scaleX = viewBox.width / pathScale;
	 float scaleY = viewBox.height / pathScale;
	 CGPoint result = CGPointMake(svgPoint.x * scaleX, svgPoint.y * scaleY );
	 return result;
	 */
	
	return svgPoint;
}

- (void) appendSVGMCommand: (Token *) token {
	validLastControlPoint = NO;
	int index = 0;
	BOOL first = YES;
	while (index < [token valence]) {
		float x = [token parameter:index] + ([token command] == 'm' ? lastPoint.x : 0);
		if (++index == [token valence]) {
			NSLog(@"Invalid parameter count in M style token");
			return;
		}
		float y = [token parameter:index] + ([token command] == 'm' ? lastPoint.y : 0);
		lastPoint = CGPointMake(x, y);
		if (first) {
			[bezier moveToPoint:[self bezierPoint:lastPoint]];
			first = NO;
		}
		else {
			[bezier addLineToPoint:[self bezierPoint:lastPoint]];
		}
		index++;
	}
}

- (void) appendSVGLCommand: (Token *) token {
	validLastControlPoint = NO;
	int index = 0;
	while (index < [token valence]) {
		float x = 0;
		float y = 0;
		switch ( [token command] ) {
			case 'l':
				x = lastPoint.x;
				y = lastPoint.y;
			case 'L':
				x += [token parameter:index];
				if (++index == [token valence]) {
					NSLog(@"Invalid parameter count in L style token");
					return;
				}
				y += [token parameter:index];
				break;
			case 'h' :
				x = lastPoint.x;				
			case 'H' :
				x += [token parameter:index];
				y = lastPoint.y;
				break;
			case 'v' :
				y = lastPoint.y;
			case 'V' :
				y += [token parameter:index];
				x = lastPoint.x;
				break;
			default:
				NSLog(@"Unrecognised L style command.");
				return;
		}
		lastPoint = CGPointMake(x, y);
		[bezier addLineToPoint: [self bezierPoint: lastPoint]];
		index++;
	}
}

- (void) appendSVGCCommand: (Token *) token {
	int index = 0;
	while ((index + 5) < [token valence]) {  // we must have 6 floats here (x1, y1, x2, y2, x, y).
		float x1 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.x : 0);
		float y1 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.y : 0);
		float x2 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.x : 0);
		float y2 = [token parameter:index++] + ([token command] == 'c' ? lastPoint.y : 0);
		float x  = [token parameter:index++] + ([token command] == 'c' ? lastPoint.x : 0);
		float y  = [token parameter:index++] + ([token command] == 'c' ? lastPoint.y : 0);
		lastPoint = CGPointMake(x, y);
		[bezier addCurveToPoint:[self bezierPoint:lastPoint] 
			  controlPoint1:[self bezierPoint:CGPointMake(x1,y1)] 
			  controlPoint2:[self bezierPoint:CGPointMake(x2, y2)]];
		lastControlPoint = CGPointMake(x2, y2);
		validLastControlPoint = YES;
	}
	if (index == 0) {
		NSLog(@"Insufficient parameters for C command");
	}
}

- (void) appendSVGSCommand: (Token *) token {
	if (!validLastControlPoint) {
		NSLog(@"Invalid last control point in S command");
	}
	int index = 0;
	while ((index + 3) < [token valence]) {  // we must have 4 floats here (x2, y2, x, y).
		float x1 = lastControlPoint.x; // + ([token command] == 's' ? lastPoint.x : 0);
		float y1 = lastControlPoint.y; // + ([token command] == 's' ? lastPoint.y : 0);
		float x2 = [token parameter:index++] + ([token command] == 's' ? lastPoint.x : 0);
		float y2 = [token parameter:index++] + ([token command] == 's' ? lastPoint.y : 0);
		float x  = [token parameter:index++] + ([token command] == 's' ? lastPoint.x : 0);
		float y  = [token parameter:index++] + ([token command] == 's' ? lastPoint.y : 0);
		lastPoint = CGPointMake(x, y);
		[bezier addCurveToPoint:[self bezierPoint:lastPoint] 
			  controlPoint1:[self bezierPoint:CGPointMake(x1,y1)] 
			  controlPoint2:[self bezierPoint:CGPointMake(x2, y2)]];
		lastControlPoint = CGPointMake(x2, y2);
		validLastControlPoint = YES;
	}
	if (index == 0) {
		NSLog(@"Insufficient parameters for S command");
	}
}




@end
