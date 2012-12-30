//
//  PieChart.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 23.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "PieChart.h"

@implementation PieChart

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 4;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    int result = 0;
    if (CPTPieChartFieldSliceWidth == fieldEnum) {
        switch (idx) {
            case 0:
                result = 2;
                break;
            case 1:
                result = 4;
                break;
            case 2:
                result = 3;
                break;
            case 3:
                result = 6;
            default:
                break;
        }
    }
    return [NSNumber numberWithInt:result];
}

@end
