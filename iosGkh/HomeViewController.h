//
//  HomeViewController.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 08.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "MetricConsumerProtocol.h"
#import "CPTGraphHolderProtocol.h"
#import "TableViewController.h"

@interface HomeViewController : UIViewController <MetricConsumerProtocol, CPTBarPlotDelegate, UITableViewDelegate,
                                                  CPTPieChartDelegate, CPTGraphHolderProtocol>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end
