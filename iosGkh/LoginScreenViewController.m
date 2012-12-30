//
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 26.11.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "BasicAuthModule.h"

@interface LoginScreenViewController ()
- (void) registerForNotifications;
- (void) authenticationErrorOccured:(NSNotification *)notification;
- (void) authenticationSucceeded:(NSNotification *)notification;
@end

@implementation LoginScreenViewController

@synthesize userNameField = _userNameField;
@synthesize passwordField = _passwordField;
@synthesize errorLabel = _errorLabel;
@synthesize urlField = _urlField;

- (IBAction) authenticatePressed {
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    NSString *url = self.urlField.text;
    [self registerForNotifications];
    [[BasicAuthModule class] authenticateWithLogin:userName andPassword:password byURL:url];
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
    [self performSegueWithIdentifier: @"authDone" sender: self];
}

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

@end
