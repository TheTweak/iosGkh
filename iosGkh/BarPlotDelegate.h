//
//  BarPlotDelegate.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 19.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "CorePlotUtils.h"
#import "HomeViewController.h"

@interface BarPlotDelegate : NSObject <CPTBarPlotDelegate>
// arrow, pointing on clicked bar
@property (nonatomic, strong) CALayer *arrow;
@end
