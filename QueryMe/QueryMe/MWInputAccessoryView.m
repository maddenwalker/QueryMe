//
//  MWInputAccessoryView.m
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWInputAccessoryView.h"

@interface MWInputAccessoryView()

@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;

@end

@implementation MWInputAccessoryView

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        _inputAccessoryView = [[MWKeyboardBarView alloc] initWithDelegate:self.keyboardDelegate];
    }
    
    return _inputAccessoryView;
}



@end
