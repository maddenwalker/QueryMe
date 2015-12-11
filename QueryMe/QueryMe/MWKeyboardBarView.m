    //
//  MWKeyboardBarView.m
//  QueryMe
//
//  Created by Ryan Walker on 12/10/15.
//  Copyright © 2015 Ryan Walker. All rights reserved.
//

#import "MWKeyboardBarView.h"

@interface MWKeyboardBarView()

@end

@implementation MWKeyboardBarView

-(instancetype)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(screen), 40);
    self = [self initWithFrame:frame];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        
        self.textView = [[SZTextView alloc] init];
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.placeholder = @"Answer this question here!";
        self.textView.layer.masksToBounds = YES;
        self.textView.layer.cornerRadius = 5;
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.submitButton setTitle:NSLocalizedString(@"Submit", @"Submit button") forState:UIControlStateNormal];
        [self.submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *views = @[self.textView, self.submitButton];
        
        for (UIView *view in views) {
            [self addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_textView, _submitButton);
        
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[_textView]-4-|" options:kNilOptions metrics:nil views:viewDictionary];
        
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_textView]-[_submitButton]-|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary];
        
        NSArray *allConstraints = @[verticalConstraints, horizontalConstraints];
        
        for (NSArray *constraints in allConstraints) {
            [self addConstraints:constraints];
        }
    }
    
    return self;
}

- (id)initWithDelegate:(id<MWKeyboardBarViewDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (void) submitButtonPressed:(UIButton *)sender {
    [self.delegate keyboardBar:self sendText:self.textView.text];
    self.textView.text = nil;
}

@end
