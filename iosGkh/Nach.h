//
//  Nach.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 23.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface Nach : NSObject <CPTBarPlotDataSource, CPTAxisDelegate, CPTPieChartDataSource>
// Plot-specific data request params
@property (nonatomic, copy) NSArray *requestParams;
@property (nonatomic, strong) NSString *paramId;
@end
