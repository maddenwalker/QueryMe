//
//  MWInputAccessoryView.h
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWKeyboardBarView.h"

@interface MWInputAccessoryView : UIView

@property (weak, nonatomic) id<MWKeyboardBarViewDelegate> keyboardDelegate;

@end
