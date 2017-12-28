//
//  ViewController.m
//  CustomPasscode
//
//  Created by Mickey on 2017/12/22.
//  Copyright © 2017年 Mickey. All rights reserved.
//

#import "ViewController.h"
#import "PasscodeViewController.h"
#import "SFHFKeychainUtils.h"

static NSString *cellIdentifier = @"cell";

enum MORE_MENU_LIST {
    MENU_PASSCODE_LOCK,
    MENU_PASSCODE_TOUCHID,
    MENU_PASSCODE_CHANGE
};

@implementation myTableViewCell
{
    UILabel *titleLabel;
    BOOL isTapable;
    SWITCH_TYPE mySwitchType;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    self.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake((self.bounds.size.width-titleLabel.frame.size.width)/2, (self.bounds.size.height-titleLabel.frame.size.height)/2, titleLabel.frame.size.width, titleLabel.frame.size.height);
}

- (void)setTitle:(NSString *)title {
    titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 0);
    titleLabel.textColor = [UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:1.0];
    titleLabel.font = [UIFont fontWithName:@".SFUIText-Regular" size:12.0];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake((self.bounds.size.width-titleLabel.frame.size.width)/2, (self.bounds.size.height-titleLabel.frame.size.height)/2, titleLabel.frame.size.width, titleLabel.frame.size.height);
}

- (void)setIsTapable:(BOOL)tapable {
    isTapable = tapable;
    if (tapable) {
        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }
    [self layoutSubviews];
}

- (void)setSwitchType:(SWITCH_TYPE)switchType switchOn:(BOOL)isSwitchOn {
    mySwitchType = switchType;
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    switchView.tag = mySwitchType;
    switchView.on = isSwitchOn;
    self.accessoryView = switchView;
    [switchView addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)switchChange:(UISwitch *)switchBut {
    [_delegate cellSwitchChanged:switchBut];
}

- (void)setViewControllerProtocolDelegate:(id)delegate {
    _delegate = delegate;
}
@end

@interface ViewController ()

@end

@implementation ViewController
{
    UITableView *tableView;
    NSMutableArray *menuList;
    BOOL isTouchIDInserted;
    BOOL isChangeInserted;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.navigationItem.title = @"Passcode";

    _laContext = [[LAContext alloc] init];
    _isEnablePasscodeTouchID = NO;

    CAGradientLayer *bgGradientLayer = [CAGradientLayer layer];
    bgGradientLayer.frame = self.view.bounds;
    bgGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    bgGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    bgGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:194.0/255.0 green:229.0/255.0 blue:156.0/255.0 alpha:1.0].CGColor,
                               (__bridge id)[UIColor colorWithRed:4.0/255.0 green:185.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor,
                               (__bridge id)[UIColor colorWithRed:58.0/255.0 green:123.0/255.0 blue:213.0/255.0 alpha:1.0].CGColor];
    [self.view.layer addSublayer:bgGradientLayer];

    [self initMenuList];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[myTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initMenuList];
    [tableView reloadData];
}

- (void)initMenuList {
    if (menuList == nil) {
        menuList = [[NSMutableArray alloc] init];
    }
    [menuList removeAllObjects];
    [menuList addObject:[NSString stringWithFormat:@"%d", MENU_PASSCODE_LOCK]];
    _isEnablePasscode = [PasscodeViewController doesPasscodeExist];
    if (_isEnablePasscode && [_laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        _isEnablePasscodeTouchID = [PasscodeViewController allowUnlockWithBiometrics];
        [menuList addObject:[NSString stringWithFormat:@"%d", MENU_PASSCODE_TOUCHID]];
    }
    if (_isEnablePasscode) {
        [menuList addObject:[NSString stringWithFormat:@"%d", MENU_PASSCODE_CHANGE]];
    }
}

# pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.7;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16,1)];
    footerView.backgroundColor = tableView.separatorColor;
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *menuIdxStr = [menuList objectAtIndex:indexPath.row];
    NSInteger idx = [menuIdxStr integerValue];

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (idx == MENU_PASSCODE_LOCK) {
        [(myTableViewCell *)cell setIsTapable:NO];
        [(myTableViewCell *)cell setTitle:@"Enable Passcode"];
        [(myTableViewCell *)cell setSwitchType:SWITCH_PASSCODE switchOn:_isEnablePasscode];
        [(myTableViewCell *)cell setViewControllerProtocolDelegate:self];
    } else if (idx == MENU_PASSCODE_TOUCHID) {
        NSString *itemName = @"Touch ID";
        if (@available(iOS 11_0, *)) {
            if (_laContext.biometryType == LABiometryTypeFaceID) {
                itemName = @"Face ID";
            }
        }
        [(myTableViewCell *)cell setIsTapable:NO];
        [(myTableViewCell *)cell setTitle:itemName];
        [(myTableViewCell *)cell setSwitchType:SWITCH_TOUCHID switchOn:_isEnablePasscodeTouchID];
        [(myTableViewCell *)cell setViewControllerProtocolDelegate:self];
    } else if (idx == MENU_PASSCODE_CHANGE) {
        [(myTableViewCell *)cell setIsTapable:YES];
        [(myTableViewCell *)cell setTitle:@"Change Passcode"];
    }

    return cell;
}

# pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *menuIdxStr = [menuList objectAtIndex:indexPath.row];
    NSInteger idx = [menuIdxStr integerValue];
    if (idx == MENU_PASSCODE_CHANGE) {
        PasscodeViewController *vc = [[PasscodeViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.passcodeStatus = PASSCODE_CHANGE;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

# pragma mark - Handle UISwitch
- (void)cellSwitchChanged:(UISwitch *)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if (mySwitch.tag == SWITCH_PASSCODE) {
        [self setPasscodeLock:mySwitch];
    } else if (mySwitch.tag == SWITCH_TOUCHID) {
        [self setPasscodeTouchID:mySwitch];
    }
}

- (void)setPasscodeLock:(UISwitch *)passcodeLockSwitch {
    BOOL needDisplayTouchID = [_laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    NSInteger updateRow1 = (needDisplayTouchID) ? MENU_PASSCODE_LOCK +1 : 0;
    NSInteger updateRow2 = updateRow1 +1;

    NSIndexPath *touchIDIndexPath = [NSIndexPath indexPathForRow:updateRow1 inSection:0];
    NSIndexPath *changeIndexPath = [NSIndexPath indexPathForRow:updateRow1 inSection:0];
    myTableViewCell *touchIDCell = [tableView cellForRowAtIndexPath:touchIDIndexPath];
    myTableViewCell *changeCell = [tableView cellForRowAtIndexPath:changeIndexPath];
    if (passcodeLockSwitch.on) {
        if ((touchIDCell == nil || touchIDCell.tag != MENU_PASSCODE_TOUCHID) && !isTouchIDInserted && needDisplayTouchID) {
            isTouchIDInserted = YES;
            [menuList insertObject:[NSString stringWithFormat:@"%d", MENU_PASSCODE_TOUCHID] atIndex:updateRow1];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:updateRow1 inSection:0];
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        if ((changeCell == nil || changeCell.tag != PASSCODE_CHANGE) && !isChangeInserted) {
            isChangeInserted = YES;
            [menuList insertObject:[NSString stringWithFormat:@"%d", MENU_PASSCODE_CHANGE] atIndex:updateRow2];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:updateRow2 inSection:0];
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        PasscodeViewController *vc = [[PasscodeViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.passcodeStatus = PASSCODE_ENABLE;
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        if ((touchIDCell.tag == MENU_PASSCODE_TOUCHID) && isTouchIDInserted) {
            isTouchIDInserted = NO;
            [menuList removeObjectAtIndex:updateRow1];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:updateRow1 inSection:0];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        if ((changeCell.tag == MENU_PASSCODE_CHANGE) && isChangeInserted) {
            isChangeInserted = NO;
            [menuList removeObjectAtIndex:updateRow2];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:updateRow2 inSection:0];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        PasscodeViewController *vc = [[PasscodeViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.passcodeStatus = PASSCODE_DISABLE;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)setPasscodeTouchID:(UISwitch *)passcodeTouchIDSwitch {
    _isEnablePasscodeTouchID = passcodeTouchIDSwitch.on;
    PasscodeViewController *vc = [[PasscodeViewController alloc] init];
    vc.isUsingBiometrics = _isEnablePasscodeTouchID;

    [SFHFKeychainUtils storeUsername:@"keychainAllowBio" andPassword:[NSString stringWithFormat: @"%d", _isEnablePasscodeTouchID] forServiceName:@"keychainService" updateExisting:YES error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
