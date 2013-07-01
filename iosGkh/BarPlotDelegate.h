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
#import "ReportViewController.h"

@interface BarPlotDelegate : NSObject <CPTBarPlotDelegate>
@property (nonatomic, weak) ReportViewController *reportViewController;
-(void) dismissPopupMenu;
@end
