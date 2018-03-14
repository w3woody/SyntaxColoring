//
//  SCTextView.m
//  LToolUI
//
//  Created by William Woody on 4/20/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//

#import "SCTextView.h"
#import "SCSyntaxTextStorage.h"
#import "SCAltKeyboard.h"
#import "SCCScanner.h"

@interface SCTextView () <UITextViewDelegate>
@property (strong) SCSyntaxTextStorage *storage;
@property (strong) UITextView *textView;
@property (strong) IBOutlet UIScrollView *scrollView;
@property (strong) IBOutlet SCAltKeyboard *altKeyboard;
@property (strong) id<SCSyntaxScanner> scanner;
@end

@implementation SCTextView

- (id)initWithFrame:(CGRect)frame
{
	if (nil != (self = [super initWithFrame:frame])) {
		[self internalInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (nil != (self = [super initWithCoder:aDecoder])) {
		[self internalInit];
	}
	return self;
}

- (void)internalInit
{
	/* Set up storage */
	self.storage = [[SCSyntaxTextStorage alloc] init];

	NSLayoutManager *layout = [[NSLayoutManager alloc] init];
	[self.storage addLayoutManager:layout];

	NSTextContainer *container = [[NSTextContainer alloc] init];
	[layout addTextContainer:container];

	/* Set the syntax scanner */
	self.scanner = [[SCCScanner alloc] init];
	self.storage.scanner = self.scanner;

	/* Create contained text view */
	self.textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:container];
	self.textView.font = [UIFont fontWithName:@"Menlo-Regular" size:14];
	self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
	self.textView.spellCheckingType = UITextSpellCheckingTypeNo;
	self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.textView.delegate = self;

	/* Create input accessory view. This contains buttons for the common */
	/* syntax elements that are hard to type, such as { } [ ] ( ) and the like */
//	[[NSBundle mainBundle] loadNibNamed:@"SCAltKeyboard" owner:self options:nil];
	self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,768,44)];
	self.scrollView.backgroundColor = [UIColor colorWithRed:0.839 green:0.850 blue:0.880 alpha:1.0];
	self.altKeyboard = [[SCAltKeyboard alloc] initWithFrame:CGRectZero];
	self.altKeyboard.backgroundColor = [UIColor colorWithRed:0.839 green:0.850 blue:0.880 alpha:1.0];
	CGSize size = self.altKeyboard.intrinsicContentSize;
	self.altKeyboard.frame = CGRectMake(0,0,size.width,size.height);
	[self.scrollView addSubview:self.altKeyboard];

	self.scrollView.contentSize = self.altKeyboard.frame.size;

	self.altKeyboard.textField = self.textView;
	self.textView.inputAccessoryView = self.scrollView;

	[self addSubview:self.textView];
}

- (void)layoutSubviews
{
	self.textView.frame = self.bounds;
}

/*
 *	Convert NSRange to UITextRange in text view
 */

- (UITextRange *)textRangeForRange:(NSRange)range
{
	UITextPosition *beginning = self.textView.beginningOfDocument;
	UITextPosition *start = [self.textView positionFromPosition:beginning offset:range.location];
	UITextPosition *end = [self.textView positionFromPosition:start offset:range.length];
	UITextRange *textRange = [self.textView textRangeFromPosition:start toPosition:end];

	return textRange;
}

/*
 *	Perform insert text operation at the text range provided
 */

- (void)insertText:(NSString *)text atRange:(NSRange)range
{
	UITextRange *textRange = [self textRangeForRange:range];
	[self.textView replaceRange:textRange withText:text];

	NSRange cursor = NSMakeRange(range.location + text.length, 0);
	self.textView.selectedRange = cursor;
}

/*
 *	Autoindent support
 */

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	// ### STUPID TEST

	// TODO: Handle \t to 4 space conversion
	if ([text isEqualToString:@"\t"]) {
		// Autoindent test
		if (range.location == 0) {
			// Degenerate case: start of file. Simply insert 4 characters
			[self insertText:@"    " atRange:range];
			return NO;
		}

		// Get the text so we can scan
		NSString *text = textView.text;

		// Determine how many characters in from the start of the line we are at
		NSInteger ix = range.location;
		while (ix > 0) {
			unichar ch = [text characterAtIndex:--ix];
			if (ch == '\n') {
				++ix;
				break;
			}
		}

		// ix points to the first character of the line we are on. if at start
		// auto-indent. Otherwise fill to align with 4

		NSInteger pos = range.location - ix;
		if (pos == 0) {
			// Indent according to previous line
			if (ix == 0) {
				// No previous line. Inset 4
				[self insertText:@"    " atRange:range];
				return NO;
			}

			// Move to previous line
			--ix;
			while (ix > 0) {
				unichar ch = [text characterAtIndex:--ix];
				if (ch == '\n') {
					++ix;
					break;
				}
			}

			// Count spaces in previous line
			NSInteger ct = 0;
			while (ix < range.location) {
				unichar ch = [text characterAtIndex:ix++];
				if (ch != ' ') break;
				++ct;
			}

			// Insert
			if (ct == 0) {
				[self insertText:@"    " atRange:range];
			} else {
				unichar *c = (unichar *)malloc(sizeof(unichar) * ct);
				for (NSInteger i = 0; i < ct; ++i) {
					c[i] = (unichar)0x20;
				}
				NSString *s = [[NSString alloc] initWithCharactersNoCopy:c length:ct freeWhenDone:YES];
				[self insertText:s atRange:range];
			}
			return NO;

		} else {
			// Indent to 4
			NSInteger len = 4 - pos % 4;
			unichar ch[] = { (unichar)0x20, (unichar)0x20, (unichar)0x20, (unichar)0x20 };
			NSString *s = [[NSString alloc] initWithCharactersNoCopy:ch length:len freeWhenDone:NO];
			[self insertText:s atRange:range];
			return NO;
		}
	}

    // If the replacement text is "\n" thus indicating a newline...
    if ([text isEqualToString:@"\n"]) {

		// Degenerate case
		if (range.location == 0) return YES;

		// Get the text so we can scan
		NSString *text = textView.text;

		NSInteger off = 0;
		NSInteger ix = range.location;
		while (ix > 0) {
			unichar ch = [text characterAtIndex:--ix];
			if (!off) {
				if (ch == '{') off = 1;
				if (ch == '}') off = -1;
			}
			if (ch == '\n') {
				++ix;
				break;
			}
		}
		// Count spaces in previous line
		NSInteger ct = 0;
		while (ix < range.location) {
			unichar ch = [text characterAtIndex:ix++];
			if (ch != ' ') break;
			++ct;
		}

		if (off == 1) ct += 4;
		if (ct <= 0) {
			return true;				// just insert '\n'
		}

		// Insert proper spaces after newline
		unichar *c = (unichar *)malloc(sizeof(unichar) * (1 + ct));
		c[0] = (unichar)'\n';
		for (NSInteger i = 1; i <= ct; ++i) {
			c[i] = (unichar)0x20;
		}
		NSString *s = [[NSString alloc] initWithCharactersNoCopy:c length:ct+1 freeWhenDone:YES];
		[self insertText:s atRange:range];

		return NO;
	}

    // Else return yes
    return YES;
}

@end
