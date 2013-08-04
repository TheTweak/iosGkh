//
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 26.11.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"

@interface LoginScreenViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *loginTable;
- (IBAction)authenticatePressed;
@property (weak, nonatomic) IBOutlet GradientButton *enterButton;
- (IBAction)segmentChanged:(UISegmentedControl *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@end
