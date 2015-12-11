//
//  MWKeyboardBarView.h
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SZTextView/SZTextView.h>

@class MWKeyboardBarView;

@protocol MWKeyboardBarViewDelegate <NSObject>

- (void)keyboardBar:(MWKeyboardBarView *)keyboardBar sendText:(NSString *)text;

@end

@interface MWKeyboardBarView : UIView

- (id)initWithDelegate:(id<MWKeyboardBarViewDelegate>)delegate;
@property (strong, nonatomic) SZTextView *textView;
@property (strong ,nonatomic) UIButton *submitButton;
@property (weak, nonatomic) id<MWKeyboardBarViewDelegate> delegate;

@end
