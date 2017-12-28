//
//  PasscodeViewController.h
//  Apollo
//
//  Created by mickey on 2017/11/3.
//  Copyright © 2017年 Promise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "CustomNumberPad.h"

typedef NS_ENUM(NSUInteger, PasscodeStatus)
{
    PASSCODE_INIT = 0,
    PASSCODE_ENABLE,
    PASSCODE_CONFIRM,
    PASSCODE_CHANGE,
    PASSCODE_DISABLE,
    PASSCODE_LAUNCHAPP
};
typedef void(^DismissBlockValue)(void);

@interface PasscodeViewController : UIViewController <UITextFieldDelegate, TouchIDButtonDelegate>

@property (nonatomic, strong) UITextField *passcodeTextField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *keyboardView;
@property (nonatomic, strong) UIView *passcodeView;

@property (nonatomic, strong) NSMutableArray <UITextField *> *digitTextFieldsArray;
@property (nonatomic, strong) NSString *tempPasscode;
@property (nonatomic, assign) NSInteger failedAttempts;
@property (nonatomic, strong) NSString *passcodeCharacter;

@property (nonatomic, strong) LAContext *touchIDContext;

@property (nonatomic, assign) BOOL isUsingBiometrics;
@property (readwrite, assign) PasscodeStatus passcodeStatus;
@property (nonatomic, copy) DismissBlockValue dismissBlockValue;

+ (BOOL)doesPasscodeExist;
+ (BOOL)doesTouchIDEnabled;
+ (BOOL)allowUnlockWithBiometrics;
- (BOOL)showTouchIDUnlock;
@end
