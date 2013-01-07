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

@interface HomeViewController : UIViewController <MetricConsumerProtocol, CPTBarPlotDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)testPlot:(UIBarButtonItem *)sender;

@end
