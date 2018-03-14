//
//  SCSyntaxTextStorage.h
//  LToolUI
//
//  Created by William Woody on 4/20/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCSyntaxScanner;

@interface SCSyntaxTextStorage : NSTextStorage
@property (nonatomic, assign) id<SCSyntaxScanner> scanner;
@end
