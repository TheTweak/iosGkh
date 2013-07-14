//
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 26.11.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "BasicAuthModule.h"
#import "Dweller.h"
#import <AFNetworking.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <QuartzCore/QuartzCore.h>

@interface LoginScreenViewController ()
- (void) registerForNotifications;
- (void) authenticationErrorOccured:(NSNotification *)notification;
- (void) authenticationSucceeded:(NSNotification *)notification;
@property NSUInteger segment; // 0 - uk, 1 - dweller
@property UITextField *password;
@property UITextField *login;
@property UITextField *fls;
@end

@implementation LoginScreenViewController

@synthesize errorLabel = _errorLabel;
@synthesize segment = _segment;
@synthesize password = _password;
@synthesize login = _login;
@synthesize fls = _fls;

#pragma mark Accessors

- (void) viewDidLoad {
    [super viewDidLoad];
    self.loginTable.dataSource = self;
    [self registerForNotifications];
    // set default values for app settings
    [self registerDefaultSettingsValues];
    CALayer *layer = [self.enterButton layer];
    layer.cornerRadius = 5.0;
}

-(void) registerDefaultSettingsValues {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Credentials table delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    CGRect textFieldRect = CGRectMake(5, (cell.frame.size.height - 26) / 2, cell.frame.size.width, cell.frame.size.height);
    if (self.segment == 0) {
        if (indexPath.item == 1) {
            if (!self.password) {
                self.password = [[UITextField alloc] initWithFrame:textFieldRect];
                self.password.secureTextEntry = YES;
#warning Remove password
                self.password.text = @"1234";
                self.password.placeholder = @"Пароль";
                self.password.delegate = self;
                self.password.returnKeyType = UIReturnKeyDone;
                self.password.autocorrectionType = UITextAutocorrectionTypeNo;
            }
            [cell.contentView addSubview:self.password];
        } else if (indexPath.item == 0) {
            if (!self.login) {
                self.login = [[UITextField alloc] initWithFrame:textFieldRect];
                self.login.placeholder = @"Логин";
#warning Remove login
                self.login.text = @"glava";
                self.login.returnKeyType = UIReturnKeyDone;
                self.login.delegate = self;
                self.login.autocorrectionType = UITextAutocorrectionTypeNo;
            }
            [cell.contentView addSubview:self.login];
        }
    } else if (self.segment == 1) {
        if (!self.fls) {
            self.fls = [[UITextField alloc] initWithFrame:textFieldRect];
            self.fls.placeholder = @"Лицевой счет";
#warning Remove text
            self.fls.text = @"020101000050";
            self.fls.delegate = self;
            self.fls.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            self.fls.returnKeyType = UIReturnKeyDone;
            self.fls.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        [cell.contentView addSubview:self.fls];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows;
    if (self.segment == 0) {
        rows = 2;
    } else {
        rows = 1;
    }
    return rows;
}

#pragma mark Login button handlers

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (IBAction) authenticatePressed {
    if (![self connected]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:@"Отсутствует подключение к интернету"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    [self clearErrorText];
    switch (self.segment) {
        case 0: { // auth uk
            NSString *userName = self.login.text;
            NSString *password = self.password.text;
            [self showLoadingMask];
            [[BasicAuthModule class] authenticateWithLogin:userName andPassword:password];
            break;
        }
        case 1: { // auth dweller
            [self authenticateDweller];
            break;
        }
    }
}

- (void) authenticateDweller {
    [self showLoadingMask];
    NSString *flsNomer = self.fls.text;
    [[BasicAuthModule class] authenticateAsDweller:@"user" password:@"1234" flsNomer:flsNomer];
}

#pragma mark Segment control handlers

- (IBAction)segmentChanged:(UISegmentedControl *)sender forEvent:(UIEvent *)event {
    self.segment = sender.selectedSegmentIndex;
    [self.loginTable reloadData];
}

- (void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationErrorOccured:)
                                                 name:@"AuthenticationError"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationSucceeded:)
                                                 name:@"AuthenticationSucceeded"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadingMask)
                                                 name:@"ShowLoginLoadingMask"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingMask)
                                                 name:@"HideLoginLoadingMask"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAlertView)
                                                 name:@"ShowAlert"
                                               object:nil];
}

#pragma mark Notifications

- (void) showAlertView {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Не найден ФЛС"
                          message:@"Введенный номер не существует"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void) authenticationErrorOccured:(NSNotification *)notification {
    NSString *errorText = [[notification userInfo]
                        objectForKey:@"ErrorDescription"];
    [self.errorLabel setText:errorText];
}

#define HOME_VIEW_CONTROLLER_ID @"ReportTableViewController"
#define DWELLER_HOME_VIEW_CONTROLLER_ID @"DwellerTabBarController"

- (void) authenticationSucceeded:(NSNotification *)notification {
    NSString *role = [[notification userInfo] objectForKey:@"Role"];
    NSString *controllerId;
    if ([@"dweller" isEqualToString:role]) {
        controllerId = DWELLER_HOME_VIEW_CONTROLLER_ID;
    } else if ([@"glava" isEqualToString:role]) {
        controllerId = HOME_VIEW_CONTROLLER_ID;
    }
    UIViewController *controller = [[self.navigationController storyboard] instantiateViewControllerWithIdentifier:controllerId];
    if (controller) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void) showLoadingMask {
    self.loadingView.hidden = NO;
}

-(void) hideLoadingMask {
    self.loadingView.hidden = YES;
}

#pragma mark Other

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void) clearErrorText {
    self.errorLabel.text = @"";
}


@end
