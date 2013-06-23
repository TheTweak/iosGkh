//
//  ReportViewController.h
//  iosGkh
//
//  Created by Sorokin E on 16.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GkhReport.h"
#import "ReportPlotDataSource.h"

@interface ReportViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CPTPlotDataSource, CPTPlotDelegate, ReportPlotDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) GkhReport *report;
@end
