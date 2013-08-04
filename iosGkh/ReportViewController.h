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
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (weak, nonatomic) GkhReport *report;
@property (weak, nonatomic) IBOutlet UIView *loadMask;
@property (weak, nonatomic) IBOutlet UIView *loadMaskView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceBetweenTableViewAndHostingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphHostingViewTopSpaceToSuper;
@end
