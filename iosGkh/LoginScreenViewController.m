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
@end

@implementation LoginScreenViewController

@synthesize userNameField = _userNameField;
@synthesize passwordField = _passwordField;
@synthesize errorLabel = _errorLabel;
@synthesize segment = _segment;

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (IBAction) authenticatePressed {
    [self registerForNotifications];
    switch (self.segment) {
        case 0: { // auth uk
            NSString *userName = self.userNameField.text;
            NSString *password = self.passwordField.text;
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
    NSString *flsNomer = self.flsNomer.text;
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
    switch (sender.selectedSegmentIndex) {
        case 0: { // uk
            [UIView animateWithDuration:0.3 animations:^{
                self.passwordField.alpha = 1.0;
                self.userNameField.alpha = 1.0;
                self.flsNomer.alpha = 0.0;
            }];
            break;
        }
        case 1: { // dweller
            [UIView animateWithDuration:0.3 animations:^{
                self.passwordField.alpha = 0.0;
                self.userNameField.alpha = 0.0;
                self.flsNomer.alpha = 1.0;
            }];
            break;
        }
        default:
            break;
    }
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
