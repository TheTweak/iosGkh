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

- (void) viewDidLoad {
    [super viewDidLoad];
    self.loginTable.dataSource = self;
}

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
#pragma mark Remove password
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
#pragma warning Remove login
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
#pragma mark Remove text
            self.fls.text = @"020101000050";
            self.fls.delegate = self;
            self.fls.keyboardType = UIKeyboardTypeDecimalPad;
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

- (IBAction) authenticatePressed {
    [self registerForNotifications];
    switch (self.segment) {
        case 0: { // auth uk
            NSString *userName = self.login.text;
            NSString *password = self.password.text;
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
    NSString *flsNomer = self.fls.text;
    [[BasicAuthModule class] authenticateAsDweller:@"user"
                                          password:@"1234"
                                          flsNomer:flsNomer
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               NSData *responseData = (NSData *)responseObject;
                                               NSString *responseString = [[NSString alloc] initWithData:responseData
                                                                                                encoding:NSUTF8StringEncoding];
                                               if (responseData) {
                                                   // fls id obtained, segue to counter table view
                                                   [[Dweller class] setFls:responseString];
                                                   [self performSegueWithIdentifier:@"authDweller" sender:self];
                                               } else {
                                                   UIAlertView *alert = [[UIAlertView alloc]
                                                                         initWithTitle:@"Не найден ФЛС"
                                                                         message:@"Введенный номер не существует"
                                                                         delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                                   [alert show];
                                               }
                                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Failure");
                                           }];
}

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
}

- (void) authenticationErrorOccured:(NSNotification *)notification {
    NSString *errorText = [[notification userInfo]
                        objectForKey:@"ErrorDescription"];
    [self.errorLabel setText:errorText];
}

- (void) authenticationSucceeded:(NSNotification *)notification {
    NSString *role = [[notification userInfo] objectForKey:@"Role"];
    NSString *segueId;
    if ([@"dweller" isEqualToString:role]) {
        segueId = @"authDweller";
    } else if ([@"glava" isEqualToString:role]) {
        segueId = @"authGlava";
    }
    [self performSegueWithIdentifier: segueId sender: self];
}

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

@end
