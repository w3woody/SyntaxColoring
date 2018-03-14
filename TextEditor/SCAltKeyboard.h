//
//  SCAltKeyboard.h
//  LToolUI
//
//  Created by William Woody on 4/21/17.
//  Copyright © 2017 Glenview Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCAltKeyboard : UIView
@property (assign) id<UIKeyInput> textField;

- (NSInteger)desiredWidth;

@end
