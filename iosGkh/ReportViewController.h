//
//  ReportViewController.h
//  iosGkh
//
//  Created by Sorokin E on 16.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *reportParams;
@end
