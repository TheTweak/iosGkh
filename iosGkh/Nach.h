//
//  Nach.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 23.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "HomeTableDataSource.h"

@interface Nach : NSObject <CPTBarPlotDataSource, CPTAxisDelegate, CPTPieChartDataSource, CPTScatterPlotDataSource, UITableViewDataSource>
- (NSDictionary *) getBusinessValues: (NSUInteger) idx;
// Plot-specific data request params
@property (nonatomic, copy) NSDictionary *requestParams;
@property (nonatomic, strong) NSString *paramId;
@property (nonatomic, weak) HomeTableDataSource *homeTableDS;
@property (nonatomic, strong) NSString *scope;
@property BOOL tableNeedsReloading;
// период за который загружаются данные в табличках для отчета Платежи в проценте от начислений
@property NSString *period;
@end
