//
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 26.11.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginScreenViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITableView *loginTable;
- (IBAction)authenticatePressed;
- (IBAction)segmentChanged:(UISegmentedControl *)sender forEvent:(UIEvent *)event;

@end
