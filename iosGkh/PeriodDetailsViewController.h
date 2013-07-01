//
//  PeriodDetailsViewController.h
//  iosGkh
//
//  Created by Sorokin E on 30.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GkhReport.h"

@interface PeriodDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSString *period;
@property (nonatomic, weak) GkhReport *report;
@end
