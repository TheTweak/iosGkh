//
//  MetricSelectionViewController.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 16.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetricConsumerProtocol.h"

@interface MetricSelectionViewController : UIViewController
- (IBAction)addMetric:(UIButton *)sender;
@property (nonatomic, strong) id <MetricConsumerProtocol> metricConsumer;

@end
