//
//  CounterValsViewController.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 13.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CounterValsViewController : UITableViewController <UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property NSArray *counterVals;
@property NSString *counterId;
@end
