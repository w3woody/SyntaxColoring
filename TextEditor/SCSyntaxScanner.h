//
//  SCSyntaxScanner.h
//  LToolUI
//
//  Created by William Woody on 4/24/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCSyntaxScanner <NSObject>

/*
 *	This is the primary entry point for our syntax scanner. This receives
 *	an attributed string, and scans the range specified (which is generally
 *	a subset of the string terminating in a newline). If this method returns
 *	false, that indicates that the scanner needs to rescan the entire
 *	string range and should be invoked with the range covering the entire
 *	string.
 */

- (void)scanString:(NSMutableAttributedString *)str hintRange:(NSRange)range;

@end
