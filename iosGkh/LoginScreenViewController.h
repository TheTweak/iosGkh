//
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 26.11.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginScreenViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *flsNomer;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)authenticatePressed;
- (IBAction)segmentChanged:(UISegmentedControl *)sender forEvent:(UIEvent *)event;

@end
