//
//  SCCScanner.m
//  LToolUI
//
//  Created by William Woody on 4/24/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCCScanner.h"

@interface SCCScanner ()
{
	/*
	 *	String reader
	 */

	NSInteger start;
	NSInteger len;
	NSString *string;
	BOOL atSOL;

	/*
	 *	Reserved tokens
	 */

	NSSet<NSString *> *reserved;
	NSSet<NSString *> *preproc;

	/*
	 *	Scanned range
	 */
}
@end

/****************************************************************************/
/*																			*/
/*	Constants																*/
/*																			*/
/****************************************************************************/

#define COMMENT		-2

#define STRING		-3
#define NUMBER		-4
#define TOKEN		-5
#define RESTOKEN	-6
#define PREPROC		-7

@implementation SCCScanner

- (id)init
{
	if (nil != (self = [super init])) {
		NSMutableSet<NSString *> *set = [[NSMutableSet alloc] init];

		[set addObject:@"int"];
		[set addObject:@"signed"];
		[set addObject:@"typedef"];
		[set addObject:@"auto"];
		[set addObject:@"for"];
		[set addObject:@"const"];
		[set addObject:@"char"];
		[set addObject:@"unsigned"];
		[set addObject:@"enum"];
		[set addObject:@"extern"];
		[set addObject:@"while"];
		[set addObject:@"volatile"];
		[set addObject:@"float"];
		[set addObject:@"short"];
		[set addObject:@"register"];
		[set addObject:@"do"];
		[set addObject:@"sizeof"];
		[set addObject:@"double"];
		[set addObject:@"long"];
		[set addObject:@"static"];
		[set addObject:@"if"];
		[set addObject:@"goto"];
		[set addObject:@"struct"];
		[set addObject:@"void"];
		[set addObject:@"else"];
		[set addObject:@"continue"];
		[set addObject:@"union"];
		[set addObject:@"return"];
		[set addObject:@"switch"];
		[set addObject:@"break"];
		[set addObject:@"case"];
		[set addObject:@"default"];

		reserved = [NSSet setWithSet:set];

		set = [[NSMutableSet alloc] init];

		[set addObject:@"include"];
		[set addObject:@"define"];
		[set addObject:@"undef"];
		[set addObject:@"if"];
		[set addObject:@"ifdef"];
		[set addObject:@"ifndef"];
		[set addObject:@"elif"];
		[set addObject:@"else"];
		[set addObject:@"endif"];
		[set addObject:@"line"];
		[set addObject:@"error"];
		[set addObject:@"warning"];
		[set addObject:@"pragma"];

		preproc = [NSSet setWithSet:set];
	}
	return self;
}

/****************************************************************************/
/*																			*/
/*	Character Reader														*/
/*																			*/
/****************************************************************************/

- (NSInteger)readNextChar
{
	if (start >= len) return EOF;

	return [string characterAtIndex:start++];
}

- (void)pushBackChar
{
	--start;
}

/****************************************************************************/
/*																			*/
/*	Comment Scanner															*/
/*																			*/
/****************************************************************************/

- (NSInteger)nextChar
{
	NSInteger ch;

	ch = [self readNextChar];
	if (ch == EOF) return EOF;

	if (ch == '/') {
		ch = [self readNextChar];
		if (ch == '*') {
			// Read forward until reaching EOF or close comment

			for (;;) {
				ch = [self readNextChar];
				if (ch == '*') {
					ch = [self readNextChar];
					if (ch == '/') {
						return COMMENT;
					} else {
						if (ch != EOF) [self pushBackChar];
					}
				} else if (ch == EOF) {
					/* Entire range is comment. Next read will trip EOF */
					return COMMENT;
				}
			}
		} else if (ch == '/') {
			// Read until EOL
			for (;;) {
				ch = [self readNextChar];
				if ((ch == EOF) || (ch == '\n')) return COMMENT;
			}
		} else {
			if (ch != EOF) [self pushBackChar];
			return '/';
		}
	} else {
		return ch;
	}
}


/****************************************************************************/
/*																			*/
/*	Token Scanner															*/
/*																			*/
/****************************************************************************/

static BOOL IsAlpha(NSInteger ch)
{
	return ((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z'));
}

static BOOL IsAlNum(NSInteger ch)
{
	return ((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) || ((ch >= '0') && (ch <= '9'));
}

static BOOL IsNumber(NSInteger ch)
{
	return ((ch >= '0') && (ch <= '9'));
}

- (NSInteger)nextToken
{
	NSInteger ch;

	ch = [self nextChar];
	if (ch == EOF) return EOF;

	/*
	 *	Pull preprocessor only if at start of line
	 */

	if (atSOL && (ch == '#')) {
		atSOL = NO;

		ch = [self readNextChar];
		while (isspace(ch)) {
			ch = [self readNextChar];
		}

		NSInteger pos = start - 1;
		while ((ch == '_') || IsAlNum(ch)) {
			ch = [self readNextChar];
		}
		if (ch != EOF) [self pushBackChar];

		NSString *str = [string substringWithRange:NSMakeRange(pos, start - pos)];
		if ([preproc containsObject:str]) return PREPROC;
		return TOKEN;
	}

	atSOL = NO;

	if ((ch == '"') || (ch == '\'')) {
		for (;;) {
			NSInteger d = [self readNextChar];
			if ((d == ch) || (d == EOF)) return STRING;
			if (d == '\\') {
				[self readNextChar];	/* Skip */
			}
		}
	}

	if ((ch == '_') || IsAlpha(ch)) {
		NSInteger pos = start - 1;
		while ((ch == '_') || IsAlNum(ch)) {
			ch = [self readNextChar];
		}
		if (ch != EOF) [self pushBackChar];

		/*
		 *	Determine if reserved token
		 */

		NSString *str = [string substringWithRange:NSMakeRange(pos, start - pos)];
		if ([reserved containsObject:str]) return RESTOKEN;
		return TOKEN;
	}

	if (ch == '.') {
		ch = [self readNextChar];
		if (!IsNumber(ch)) {
			if (ch != EOF) [self pushBackChar];
			return '.';
		}
	}

	if ((ch == '.') || IsNumber(ch)) {
		for (;;) {
			ch = [self readNextChar];
			if ((ch != '.') && !IsAlNum(ch)) {
				if (ch != EOF) [self pushBackChar];
				break;
			}
			if ((ch == 'e') || (ch == 'E')) {
				ch = [self readNextChar];
				if ((ch != '-') && (ch != '+')) {
					if (ch != EOF) [self pushBackChar];
				}
			}
		}
		return NUMBER;
	}

	if (ch == '\n') {
		atSOL = YES;
	}

	return ch;
}


- (void)removeAttributesForString:(NSMutableAttributedString *)str inRange:(NSRange)range
{
    [str removeAttribute:NSForegroundColorAttributeName range:range];
}

- (void)scanString:(NSMutableAttributedString *)str hintRange:(NSRange)range;
{
	UIColor *commentColor = [UIColor redColor];
	UIColor *strColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0];
	UIColor *tokenColor = [UIColor blueColor];
	UIColor *preprocColor = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1.0];

	/*
	 *	Step 1: grow range to encompass comment regions
	 */

	string = str.string;
	range.location = 0;
	range.length = string.length;	/* TODO */
	atSOL = YES;

	/*
	 *	Step 2: remove old attributes in range
	 */

    [str removeAttribute:NSForegroundColorAttributeName range:range];

	/*
	 *	Scan forward.
	 */

	start = range.location;
	len = range.length;

	NSInteger pos = 0;
	for (;;) {
		NSInteger t = [self nextToken];
		if (t == EOF) break;

		if (t == RESTOKEN) {
			[str addAttribute:NSForegroundColorAttributeName value:tokenColor range:NSMakeRange(pos,start-pos)];
		} else if ((t == STRING) || (t == NUMBER)) {
			[str addAttribute:NSForegroundColorAttributeName value:strColor range:NSMakeRange(pos,start-pos)];
		} else if (t == COMMENT) {
			[str addAttribute:NSForegroundColorAttributeName value:commentColor range:NSMakeRange(pos,start-pos)];
		} else if (t == PREPROC) {
			[str addAttribute:NSForegroundColorAttributeName value:preprocColor range:NSMakeRange(pos,start-pos)];
		}

		pos = start;
	}
}

@end
