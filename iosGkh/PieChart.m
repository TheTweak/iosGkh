//
//  PieChart.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 23.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "PieChart.h"
#import "CorePlot-CocoaTouch.h"

@implementation PieChart

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    CPTLayer *result;
    int sum = 15;
    int price = 0;
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor whiteColor];
        labelText.fontSize = 13.0f;
    }
    price = [[self numberForPlot:plot field:CPTPieChartFieldSliceWidth recordIndex:idx] intValue];
    float percent = ((float)price / (float)sum);
    // 4 - Set up display label
    NSString *labelValue = [NSString stringWithFormat:@"%0.0f %%", percent * 100.0f];
    // 5 - Create and return layer with label text
    result = [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
    return result;
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    CPTColor *color;
    switch (idx) {
        case 0:
        {
            color = [CPTColor colorWithComponentRed:0.0f green:0.6917f blue:0.83f alpha:1.0f]; //sky
            break;
        }
        case 1:
        {
            color = [CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.2167f alpha:1.0f]; //red
            break;
        }
        case 2:
        {
            color = [CPTColor colorWithComponentRed:0.0f green:0.83f blue:0.2075f alpha:1.0f]; //green
            break;
        }
        case 3:
        {
            color = [CPTColor colorWithComponentRed:1.0f green:0.5833f blue:0.0f alpha:1.0f]; //orange
            break;
        }
        default:
            color = [CPTColor whiteColor];
            break;
    }
    return [CPTFill fillWithColor:color];
}

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
