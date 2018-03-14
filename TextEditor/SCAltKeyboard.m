//
//  SCAltKeyboard.m
//  LToolUI
//
//  Created by William Woody on 4/21/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//

#import "SCAltKeyboard.h"

#define LT_HBORDERWIDTH		8
#define LT_VBORDERHEIGHT	4
#define LT_SEPARATOR		16
#define LT_BTNWIDTH			64
#define LT_PHONEWIDTH		44

@interface SCAltKeyboard ()
@property (strong) NSArray<NSString *> *keys;
@property (assign) NSInteger selIndex;
@end

@implementation SCAltKeyboard

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (nil != (self = [super initWithCoder:aDecoder])) {
		[self internalInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if (nil != (self = [super initWithFrame:frame])) {
		[self internalInit];
	}
	return self;
}

- (void)internalInit
{
	self.selIndex = -1;
	self.contentMode = UIViewContentModeRedraw;
	self.keys = @[ @"{", @"}", @"[", @"]", @"(", @")", @"<", @">",
				   @"+", @"-", @"*", @"/", @"%", @"=", @"&", @"|" ];

}

/*
 *	Automatically generated code from PaintCode
 */

- (void)drawKeyButtonWithArea: (CGRect)area label: (NSString*)label isPressed: (BOOL)isPressed
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* btnBGColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* btnBorderColor = [UIColor colorWithRed: 0.54 green: 0.56 blue: 0.57 alpha: 1];
    UIColor* btnPressColor = [UIColor colorWithRed: 0.72 green: 0.75 blue: 0.79 alpha: 1];

    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = btnBorderColor;
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowBlurRadius = 0;

    //// Variable Declarations
    UIColor* btnBgColor = isPressed ? btnPressColor : btnBGColor;

    //// Rectangle Drawing
    CGRect rectangleRect = CGRectMake(area.origin.x, area.origin.y, area.size.width, area.size.height);
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: rectangleRect cornerRadius: 6];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    [btnBgColor setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);

    NSMutableParagraphStyle* rectangleStyle = [[NSMutableParagraphStyle alloc] init];
    rectangleStyle.alignment = NSTextAlignmentCenter;
    NSDictionary* rectangleFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: rectangleStyle};

    CGFloat rectangleTextHeight = [label boundingRectWithSize: CGSizeMake(rectangleRect.size.width, INFINITY) options: NSStringDrawingUsesLineFragmentOrigin attributes: rectangleFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, rectangleRect);
    [label drawInRect: CGRectMake(CGRectGetMinX(rectangleRect), CGRectGetMinY(rectangleRect) + (rectangleRect.size.height - rectangleTextHeight) / 2, rectangleRect.size.width, rectangleTextHeight) withAttributes: rectangleFontAttributes];
    CGContextRestoreGState(context);
}

/*
 *	Calculate the button location. Takes into account width of the view and
 *	evenly spreads the buttons across. (Assumption: there are enough
 *	buttons to make this work)
 */

- (CGRect)calcButton:(NSInteger)button
{
	CGRect r = self.bounds;
	NSInteger width;
	width = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? LT_BTNWIDTH : LT_PHONEWIDTH;

	r.origin.y += LT_VBORDERHEIGHT;
	r.size.height -= LT_VBORDERHEIGHT * 2;
	r.origin.x += LT_HBORDERWIDTH + button * width;
	if (button >= 8) r.origin.x += LT_SEPARATOR;
	r.size.width = width - LT_HBORDERWIDTH;

	return r;
}

- (CGSize)intrinsicContentSize
{
	return CGSizeMake([self desiredWidth], 44);
}

- (NSInteger)desiredWidth
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return (self.keys.count * LT_BTNWIDTH) + LT_HBORDERWIDTH + LT_SEPARATOR;
	} else {
		return (self.keys.count * LT_PHONEWIDTH) + LT_HBORDERWIDTH + LT_SEPARATOR;
	}
}

- (void)drawRect:(CGRect)rect
{
	/*
	 *	Draw buttons
	 */

	NSInteger index = 0;
	for (NSString *str in self.keys) {
		[self drawKeyButtonWithArea:[self calcButton:index] label:str isPressed:(self.selIndex == index)];
		++index;
	}
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	CGPoint pt = [[touches anyObject] locationInView:self];

	NSInteger index,len = self.keys.count;
	for (index = 0; index < len; ++index) {
		CGRect r = CGRectInset([self calcButton:index], -LT_HBORDERWIDTH, -LT_VBORDERHEIGHT);
		if (CGRectContainsPoint(r, pt)) {
			self.selIndex = index;
			[self setNeedsDisplay];
			return;
		}
	}
	self.selIndex = -1;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	// ### TODO: Send keyboard event
	if (self.selIndex != -1) {
		[self.textField insertText:self.keys[self.selIndex]];

		self.selIndex = -1;
		[self setNeedsDisplay];
	}
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	self.selIndex = -1;
	[self setNeedsDisplay];
}

@end
