//
//  MetricSelectionViewController.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 16.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "MetricSelectionViewController.h"

@interface MetricSelectionViewController ()

@end

@implementation MetricSelectionViewController
@synthesize metricConsumer = _metricConsumer;

- (IBAction)addMetric:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.metricConsumer addNewMetricByString:sender.currentTitle];
}
@end
