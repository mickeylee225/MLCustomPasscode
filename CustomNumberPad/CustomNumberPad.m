//
//  CustomNumberPad.m
//  Apollo
//
//  Created by mickey on 2017/11/15.
//  Copyright © 2017年 Promise. All rights reserved.
//

#import "CustomNumberPad.h"
#import "PasscodeViewController.h"

@interface CustomNumberPad ()
@property (weak, nonatomic) UIResponder <UITextInput> *textInput;
@end

@implementation CustomNumberPad
{
    BOOL layoutModified;
}
@synthesize textInput;

#pragma mark - Shared CustomNumberPad method
+ (CustomNumberPad *)defaultNumberpad {
    static CustomNumberPad *defaultNumberpad = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultNumberpad = [[[NSBundle mainBundle] loadNibNamed:@"CustomNumberPad" owner:self options:nil] objectAtIndex:0];
    });

    return defaultNumberpad;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addObservers];
        self.backgroundColor = [UIColor clearColor];
        layoutModified = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addObservers];
        self.backgroundColor = [UIColor clearColor];
        layoutModified = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [self initButtons];

    [_deleteButton setTitle:@"C" forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_deleteButton.titleLabel setFont:[UIFont fontWithName:@".SFUIText-Semibold" size:28.0]];
    [_deleteButton bringSubviewToFront:_deleteButton.titleLabel];

    _touchIDButton.layer.cornerRadius = _touchIDButton.frame.size.height/2;
    _touchIDButton.clipsToBounds = YES;
    _touchIDButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    [_touchIDButton setImage:[UIImage imageNamed:@"touchId.png"] forState:UIControlStateNormal];
    [_touchIDButton setTitle:@"" forState:UIControlStateNormal];
    [_touchIDButton bringSubviewToFront:_touchIDButton.imageView];
    _touchIDButton.hidden = ![PasscodeViewController doesTouchIDEnabled] | ![PasscodeViewController allowUnlockWithBiometrics];
}

- (void)initButtons {
    for (UIButton *button in _numberButtons) {
        button.layer.cornerRadius = button.frame.size.height/2;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];

        [button setTitle:[NSString stringWithFormat:@"%ld", (long)button.tag] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:@".SFUIText-Semibold" size:28.0]];
        [button bringSubviewToFront:button.titleLabel];
    }
    [self buttonLayout];
}

- (void)buttonLayout {
    if (layoutModified) return;
    if ([UIScreen mainScreen].bounds.size.width <= 375) {
        layoutModified = YES;
        for (NSLayoutConstraint *leadingConstraint in _buttonLeadingConstraint) {
            leadingConstraint.constant = ([UIScreen mainScreen].bounds.size.width == 320) ? leadingConstraint.constant-20 : leadingConstraint.constant-5;
        }
        for (NSLayoutConstraint *trailingConstraint in _buttonTrailingConstraint) {
            trailingConstraint.constant = ([UIScreen mainScreen].bounds.size.width == 320) ? trailingConstraint.constant-20 : trailingConstraint.constant-5;
        }
        for (NSLayoutConstraint *topConstraint in _buttonTopConstraint) {
            topConstraint.constant = ([UIScreen mainScreen].bounds.size.width == 320) ? topConstraint.constant-20 : topConstraint.constant-5;
        }
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidBeginEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidBeginEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidEndEditingNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidEndEditingNotification
                                                  object:nil];
    self.textInput = nil;
}

#pragma mark - editingDidBegin/End
- (void)editingDidBegin:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[UIResponder class]]) {
        if ([notification.object conformsToProtocol:@protocol(UITextInput)]) {
            self.textInput = notification.object;
            return;
        }
    }

    self.textInput = nil;
}

- (void)editingDidEnd:(NSNotification *)notification {
    self.textInput = nil;
}

# pragma mark - Button Action
- (IBAction)numberPressed:(UIButton *)sender {
    if (self.textInput) {
        NSString *numberPressed  = sender.titleLabel.text;
        if ([numberPressed length] > 0) {
            UITextRange *selectedTextRange = self.textInput.selectedTextRange;
            if (selectedTextRange) {
                [self textInput:self.textInput replaceTextAtTextRange:selectedTextRange withString:numberPressed];
            }
        }
    }
}

- (IBAction)deletePressed:(UIButton *)sender {
    if (self.textInput) {
        UITextRange *selectedTextRange = self.textInput.selectedTextRange;
        if (selectedTextRange) {
            // Calculate the selected text to delete
            UITextPosition *startPosition = [self.textInput positionFromPosition:selectedTextRange.start offset:-1];
            if (!startPosition) {
                return;
            }
            UITextPosition *endPosition = selectedTextRange.end;
            if (!endPosition) {
                return;
            }
            UITextRange *rangeToDelete = [self.textInput textRangeFromPosition:startPosition toPosition:endPosition];
            [self textInput:self.textInput replaceTextAtTextRange:rangeToDelete withString:@""];
        }
    }
}

- (IBAction)touchIDPressed:(UIButton *)sender {
    [self touchIDButtonPressed];
}

- (void)touchIDButtonPressed {
    if ([_delegate respondsToSelector:@selector(touchIDButtonPressed)]) {
        [_delegate touchIDButtonPressed];
    }
}

# pragma mark - TextInput
// Check delegate methods to see if we should change the characters in range
- (BOOL)textInput:(id <UITextInput>)textInput shouldChangeCharactersInRange:(NSRange)range withString:(NSString *)string {
    if (textInput) {
        if ([textInput isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)textInput;
            if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                if ([textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        } else if ([textInput isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)textInput;
            if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                if ([textView.delegate textView:textView shouldChangeTextInRange:range replacementText:string]) {
                    return YES;
                }
            } else {
                // Delegate does not respond, so default to YES
                return YES;
            }
        }
    }
    return NO;
}

// Replace the text of the textInput in textRange with string if the delegate approves
- (void)textInput:(id <UITextInput>)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string {
    if (textInput) {
        if (textRange) {
            // Calculate the NSRange for the textInput text in the UITextRange textRange:
            NSInteger startPos = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRange.start];
            NSInteger length = [textInput offsetFromPosition:textRange.start toPosition:textRange.end];
            NSRange selectedRange  = NSMakeRange(startPos, length);
            
            if ([self textInput:textInput shouldChangeCharactersInRange:selectedRange withString:string]) {
                // Make the replacement:
                [textInput replaceRange:textRange withText:string];
            }
        }
    }
}

@end
