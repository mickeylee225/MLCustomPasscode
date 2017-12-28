//
//  ViewController.h
//  CustomPasscode
//
//  Created by Mickey on 2017/12/22.
//  Copyright © 2017年 Mickey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <localAuthentication/LocalAuthentication.h>

typedef NS_ENUM(NSInteger, SWITCH_TYPE){
    SWITCH_PASSCODE = 100,
    SWITCH_TOUCHID
};

@protocol ViewControllerProtocol <NSObject>
- (void)cellSwitchChanged:(UISwitch *)sender;
@end

@interface myTableViewCell : UITableViewCell
@property (nonatomic, weak) id <ViewControllerProtocol> delegate;
- (void)setTitle:(NSString *)title;
- (void)setIsTapable:(BOOL)tapable;
- (void)setSwitchType:(SWITCH_TYPE)switchType switchOn:(BOOL)isSwitchOn;
- (void)setViewControllerProtocolDelegate:(id)delegate;

@end

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isEnablePasscode;
@property (nonatomic) BOOL isEnablePasscodeTouchID;

@property (strong, nonatomic) LAContext *laContext;

@end

