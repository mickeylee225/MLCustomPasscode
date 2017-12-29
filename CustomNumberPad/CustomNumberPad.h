//
//  CustomNumberPad.h
//  Apollo
//
//  Created by mickey on 2017/11/15.
//  Copyright © 2017年 Promise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol TouchIDButtonDelegate <NSObject>
- (void)touchIDButtonPressed;
@end

@interface CustomNumberPad : UIView

@property (nonatomic,assign) UITextField *textField;
@property (nonatomic,assign) UITextView *textView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numberButtons;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *touchIDButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTrailingConstraint;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonLeadingConstraint;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonTrailingConstraint;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonTopConstraint;

@property (nonatomic, weak) id<TouchIDButtonDelegate> delegate;
@property (nonatomic,assign) NSUInteger passcodeStatus;

+ (CustomNumberPad *)defaultNumberpad;

@end
