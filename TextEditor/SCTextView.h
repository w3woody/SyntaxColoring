//
//  SCTextView.h
//  LToolUI
//
//  Created by William Woody on 4/20/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCSyntaxScanner;

@interface SCTextView : UIView

- (UITextView *)textView;
- (void)setSyntaxScanner:(id<SCSyntaxScanner>)scanner;

@end
