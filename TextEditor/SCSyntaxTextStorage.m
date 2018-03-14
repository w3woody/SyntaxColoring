//
//  SCSyntaxTextStorage.m
//  LToolUI
//
//  Created by William Woody on 4/20/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//
//	Inspired from
//
//	https://www.objc.io/issues/5-ios7/getting-to-know-textkit/
//

#import "SCSyntaxTextStorage.h"
#import "SCSyntaxScanner.h"

@interface SCSyntaxTextStorage ()
@property (strong) NSMutableAttributedString *internal;
@end

@implementation SCSyntaxTextStorage

- (id)init
{
	if (nil != (self = [super init])) {
		self.internal = [[NSMutableAttributedString alloc] init];
	}
	return self;
}

/*
 *	Subclass
 */

- (NSString *)string
{
	return self.internal.string;
}

- (NSDictionary<NSString *,id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
	return [self.internal attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
	[self.internal replaceCharactersInRange:range withString:str];
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}

- (void)setAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range
{
	[self.internal setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)setScanner:(id<SCSyntaxScanner>)scanner
{
	_scanner = scanner;

	NSRange range = NSMakeRange(0, self.internal.string.length);
	[scanner scanString:self.internal hintRange:range];
}

- (void)processEditing 
{
    [super processEditing];

	if (self.scanner == nil) return;

	// Run the syntax scanner
    NSRange range = [self.string paragraphRangeForRange: self.editedRange];
	[self.scanner scanString:self.internal hintRange:range];
}

@end
