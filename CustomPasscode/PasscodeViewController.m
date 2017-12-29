//
//  PasscodeViewController.m
//  Apollo
//
//  Created by mickey on 2017/11/3.
//  Copyright © 2017年 Promise. All rights reserved.
//

#import "PasscodeViewController.h"
#import "SFHFKeychainUtils.h"

#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define NavigationBarHeight self.navigationController.navigationBar.frame.size.height

#define PASSCODE_COUNT 4
#define PASSCODE_USERNAME @"keychainPasscode"
#define PASSCODE_SERVICE @"keychainService"
#define PASSCODE_ALLOWBIO @"keychainAllowBio"

@interface PasscodeViewController ()
@end

@implementation PasscodeViewController
{
    UIView *bgView;
    CAGradientLayer *bgGradientLayer;
    NSString *titleString;
    NSString *subtitleString;
    UIView *emptyView;
}

# pragma mark - Public Class and Method
+ (BOOL)doesPasscodeExist {
    NSString *passcode = [SFHFKeychainUtils getPasswordForUsername:PASSCODE_USERNAME andServiceName:PASSCODE_SERVICE error:nil];
    return passcode.length != 0;
}

+ (BOOL)doesTouchIDEnabled {
    LAContext *laContext = [[LAContext alloc] init];
    return [laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
}

+ (BOOL)allowUnlockWithBiometrics {
    NSString *keychainValue = [SFHFKeychainUtils getPasswordForUsername:PASSCODE_ALLOWBIO andServiceName:PASSCODE_SERVICE error:nil];
    if (!keychainValue) return YES;
    return keychainValue.boolValue;
}

- (BOOL)showTouchIDUnlock {
    if ([PasscodeViewController doesPasscodeExist] == NO || [PasscodeViewController allowUnlockWithBiometrics] == NO) {
        return NO;
    }

    LAContext *context = [[LAContext alloc] init];
    if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        return NO;
    }

    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Unlock Screen" reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.dismissBlockValue) {
                    self.dismissBlockValue();
                }
            });
        }
    }];
    return YES;
}

# pragma mark - TouchIDButtonDelegate
- (void)touchIDButtonPressed {
    PasscodeViewController *vc = [[PasscodeViewController alloc] init];
    vc.passcodeStatus = PASSCODE_LAUNCHAPP;
    vc.isUsingBiometrics = [PasscodeViewController allowUnlockWithBiometrics];
    vc.dismissBlockValue = ^() {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [vc showTouchIDUnlock];
}

# pragma mark - ViewController Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgGradientLayer = [CAGradientLayer layer];
    bgGradientLayer.frame = bgView.frame;
    bgGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    bgGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    bgGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:194.0/255.0 green:229.0/255.0 blue:156.0/255.0 alpha:1.0].CGColor,
                               (__bridge id)[UIColor colorWithRed:4.0/255.0 green:185.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor,
                               (__bridge id)[UIColor colorWithRed:58.0/255.0 green:123.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor];
    [bgView.layer addSublayer:bgGradientLayer];
    [self.view addSubview:bgView];

    _digitTextFieldsArray = [NSMutableArray new];

    [self initNavigationBar];
    [self initUI];
    [self initLabel];
    [self setupDigitFields];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CustomNumberPad defaultNumberpad].passcodeStatus = _passcodeStatus;
    [_passcodeTextField becomeFirstResponder];
}

- (void)viewWillLayoutSubviews {
    bgView.frame = self.view.frame;
    bgGradientLayer.frame = bgView.frame;
}

- (void)viewDidUnload {
    _passcodeTextField = nil;
    [super viewDidUnload];
}

- (void)initNavigationBar {
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }

    if (_passcodeStatus == PASSCODE_LAUNCHAPP) {
        self.navigationController.navigationBarHidden = YES;
    } else {
        self.navigationController.navigationBarHidden = NO;
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    }
}

- (void)initUI {
    emptyView = [[UIView alloc] initWithFrame:_passcodeTextField.inputView.frame];
    emptyView.backgroundColor = [UIColor clearColor];

    _passcodeView = [[UIView alloc] initWithFrame:CGRectZero];
    _passcodeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_passcodeView];

    _passcodeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _passcodeTextField.borderStyle = UITextBorderStyleLine;
    _passcodeTextField.inputView = emptyView;
    _passcodeTextField.delegate = self;
    _passcodeTextField.hidden = YES;
    UITextInputAssistantItem *item = [_passcodeTextField inputAssistantItem];
    item.leadingBarButtonGroups = @[];
    item.trailingBarButtonGroups = @[];
    [self.view addSubview:_passcodeTextField];
}

- (void)initLabel {
    _titleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.numberOfLines = 0;
    _titleLabel.text = @"Set Passcode";
    _titleLabel.textColor = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
    _titleLabel.font = [UIFont fontWithName:@".SFUIText-Bold" size:24.0];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];

    _subtitleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _subtitleLabel.numberOfLines = 0;
    _subtitleLabel.text = @"Enter passcode to disable";
    _subtitleLabel.textColor = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
    _subtitleLabel.font = [UIFont fontWithName:@".SFUIText-Regular" size:12.0];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_subtitleLabel];

    switch (_passcodeStatus) {
        case PASSCODE_ENABLE:
            titleString = @"Set Passcode";
            subtitleString = @"Enter your passcode here";
            break;
        case PASSCODE_CHANGE:
            titleString = @"Change Passcode";
            subtitleString = @"Enter old passcode";
            break;
        case PASSCODE_DISABLE:
            titleString = @"Disable Passcode";
            subtitleString = @"Enter passcode to disable";
            break;
        case PASSCODE_LAUNCHAPP:
            titleString = @"Enter Passcode";
            subtitleString = nil;
            break;
        default:
            break;
    }
    [self updateTitleAndSubtitle];
}

- (void)updateTitleAndSubtitle {
    _titleLabel.text = titleString;
    _subtitleLabel.text = subtitleString;
}

- (void)setupDigitFields {
    [_digitTextFieldsArray enumerateObjectsUsingBlock:^(UITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        [textField removeFromSuperview];
    }];
    [_digitTextFieldsArray removeAllObjects];

    for (int i = 0; i < PASSCODE_COUNT; i++) {
        UITextField *digitTextField = [self makeDigitField];
        [_digitTextFieldsArray addObject:digitTextField];
        [_passcodeView addSubview:digitTextField];
    }

    [self passcodeDigitLayout];
}

- (UITextField *)makeDigitField {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectZero];
    field.rightViewMode = UITextFieldViewModeAlways;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white.png"]];
    field.rightView = imageView;
    field.delegate = self;
    field.secureTextEntry = NO;
    field.translatesAutoresizingMaskIntoConstraints = NO;
    [field setBorderStyle:UITextBorderStyleNone];
    return field;
}

- (void)passcodeDigitLayout {
    CGFloat titleLabelY = ([UIScreen mainScreen].bounds.size.width == 320) ? StatusBarHeight+NavigationBarHeight+22 : StatusBarHeight+NavigationBarHeight+37;
    NSLayoutConstraint *titleLabelConstraintCenterX = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.view
                                                                                   attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.0f
                                                                                    constant:0.0f];
    NSLayoutConstraint *titleLabelConstraintY = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0f
                                                                              constant:titleLabelY];
    [self.view addConstraint:titleLabelConstraintCenterX];
    [self.view addConstraint:titleLabelConstraintY];

    NSLayoutConstraint *subtitleLabelConstraintCenterX = [NSLayoutConstraint constraintWithItem:_subtitleLabel
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.view
                                                                                      attribute:NSLayoutAttributeCenterX
                                                                                     multiplier:1.0f
                                                                                       constant:0.0f];
    NSLayoutConstraint *subtitleLabelConstraintY = [NSLayoutConstraint constraintWithItem:_subtitleLabel
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:_titleLabel
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0f
                                                                                 constant:15];
    [self.view addConstraint:subtitleLabelConstraintCenterX];
    [self.view addConstraint:subtitleLabelConstraintY];

    [_digitTextFieldsArray enumerateObjectsUsingBlock:^(UITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat constant = idx == 0 ? 0 : 40;
        UIView *toItem = idx == 0 ? _passcodeView : _digitTextFieldsArray[idx - 1];

        NSLayoutConstraint *digitX = [NSLayoutConstraint constraintWithItem:textField
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:toItem
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0f
                                                                   constant:constant];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:textField
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_passcodeView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0f
                                                                constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:textField
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_passcodeView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:0];
        [self.view addConstraint:digitX];
        [self.view addConstraint:top];
        [self.view addConstraint:bottom];

        if (idx == _digitTextFieldsArray.count - 1) {
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:textField
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_passcodeView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.0f
                                                                         constant:0];
            [self.view addConstraint:trailing];
        }
    }];

    NSLayoutConstraint *passcodeViewX = [NSLayoutConstraint constraintWithItem:_passcodeView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0];
    NSLayoutConstraint *passcodeViewY = [NSLayoutConstraint constraintWithItem:_passcodeView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_titleLabel
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:65];
    [self.view addConstraint:passcodeViewX];
    [self.view addConstraint:passcodeViewY];
}

# pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGFloat keyboardViewY = ([UIScreen mainScreen].bounds.size.width == 320) ? StatusBarHeight+NavigationBarHeight+162 : StatusBarHeight+NavigationBarHeight+182;
    _keyboardView = [CustomNumberPad defaultNumberpad];
    _keyboardView.frame = CGRectMake(30, keyboardViewY, self.view.frame.size.width-60, self.view.frame.size.height-(keyboardViewY));
    [self.view addSubview:_keyboardView];
    [CustomNumberPad defaultNumberpad].delegate = self;

    if (textField == _passcodeTextField)
        return YES;
    [_passcodeTextField becomeFirstResponder];

    UITextPosition *end = _passcodeTextField.endOfDocument;
    UITextRange *range = [_passcodeTextField textRangeFromPosition:end toPosition:end];
    [_passcodeTextField setSelectedTextRange:range];

    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *typedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger location = range.location;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:([string isEqualToString:@""]) ? [UIImage imageNamed:@"white.png"] : [UIImage imageNamed:@"whiteAc.png"]];
    _digitTextFieldsArray[location].rightView = imageView;

    if (typedString.length == PASSCODE_COUNT) {
        [self performSelector:@selector(validatePasscode:) withObject:typedString afterDelay:0.15];
    }

    if (typedString.length > PASSCODE_COUNT)
        return NO;

    return YES;
}

# pragma mark - Validation and Action
- (BOOL)validatePasscode:(NSString *)typedString {
    NSString *savedPasscode = [SFHFKeychainUtils getPasswordForUsername:PASSCODE_USERNAME andServiceName:PASSCODE_SERVICE error:nil];
    switch (_passcodeStatus) {
        case PASSCODE_ENABLE:
            _tempPasscode = typedString;
            [self performSelector:@selector(confirmPasscode) withObject:nil afterDelay:0.15f];
            break;
        case PASSCODE_CONFIRM:
            if ([typedString isEqualToString:_tempPasscode]) {
                [self savePasscode:typedString];
            } else {
                [self performSelector:@selector(reAskForNewPasscode) withObject:nil afterDelay:0.15f];
            }
            break;
        case PASSCODE_CHANGE:
            if ([typedString isEqualToString:savedPasscode]) {
                [self performSelector:@selector(changeToNewPasscode) withObject:nil afterDelay:0.15f];
            } else {
                [self performSelector:@selector(denyAccess) withObject:nil afterDelay:0.15f];
            }
            break;
        case PASSCODE_DISABLE:
            if ([typedString isEqualToString:savedPasscode]) {
                [self performSelector:@selector(disablePasscode) withObject:nil afterDelay:0.15f];
            } else {
                [self performSelector:@selector(denyAccess) withObject:nil afterDelay:0.15f];
            }
            break;
        case PASSCODE_LAUNCHAPP:
            if ([typedString isEqualToString:savedPasscode]) {
                [self performSelector:@selector(allowAccess) withObject:nil afterDelay:0.15f];
            } else {
                [self performSelector:@selector(denyAccess) withObject:nil afterDelay:0.15f];
            }
            break;
        default:
            break;
    }
    return YES;
}

- (void)confirmPasscode {
    _passcodeStatus = PASSCODE_CONFIRM;
    titleString = @"Confirm Passcode";
    subtitleString = @"Enter your passcode again";
    [self updateTitleAndSubtitle];
    [self resetUI];
    [self swipeAnimation];
}

- (void)reAskForNewPasscode {
    _tempPasscode = @"";
    titleString = @"Enter Passcode";
    subtitleString = @"Your passcodes don't match. Please try again.";
    _passcodeStatus = PASSCODE_ENABLE;
    [self updateTitleAndSubtitle];
    [self resetUI];
    [self swipeAnimation];
}

- (void)changeToNewPasscode {
    titleString = @"Enter New Password";
    subtitleString = @"Enter a new passcode here";
    _passcodeStatus = PASSCODE_ENABLE;
    [self updateTitleAndSubtitle];
    [self resetUI];
    [self swipeAnimation];
}

- (void)savePasscode:(NSString *)passcode {
    BOOL isSuccess = [SFHFKeychainUtils storeUsername:PASSCODE_USERNAME andPassword:passcode forServiceName:PASSCODE_SERVICE updateExisting:YES error:nil];
    if (isSuccess) {
        [self cancelAction];
    }
}

- (void)disablePasscode {
    [SFHFKeychainUtils deleteItemForUsername:PASSCODE_USERNAME andServiceName:PASSCODE_SERVICE error:nil];
    [self cancelAction];
}

- (void)allowAccess {
    [self cancelAction];
}

- (void)denyAccess {
    if (_passcodeStatus == PASSCODE_DISABLE) {
        titleString = @"Disable Passcode";
    } else if (_passcodeStatus == PASSCODE_CHANGE) {
        titleString = @"Change Passcode";
    } else {
        titleString = @"Enter Passcode";
    }
    subtitleString = @"Incorrect passcode";
    [self updateTitleAndSubtitle];
    [self resetUI];
    [self shakeAnimation];
}

- (void)resetUI {
    _passcodeTextField.text = @"";

    if (![_passcodeTextField isFirstResponder]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_passcodeTextField becomeFirstResponder];
        });
    }

    [_digitTextFieldsArray enumerateObjectsUsingBlock:^(UITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white.png"]];
        textField.rightView = imageView;
    }];
}

# pragma mark - PasscodeView Animation
- (void)swipeAnimation {
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromRight];
    [transition setDuration:0.15];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[_passcodeView layer] addAnimation:transition forKey:@"swipe"];
}

- (void)shakeAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.duration = 0.6;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    animation.values = @[@-12, @12, @-12, @12, @-6, @6, @-3, @3, @0];
    [_digitTextFieldsArray enumerateObjectsUsingBlock:^(UITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        [textField.layer addAnimation:animation forKey:@"shake"];
    }];
}

# pragma mark - Bar Button Action
- (void)cancelAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
