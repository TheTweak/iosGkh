//
//  Nach.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 23.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "Nach.h"
#import "CorePlot-CocoaTouch.h"

@implementation Nach

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    axis.axisTitle = [[CPTAxisTitle alloc] initWithText:@"Период" textStyle:[CPTTextStyle textStyle]];
    return YES;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 12;
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    if (idx % 2 == 0) {
        return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:0.6167f blue:0.0f alpha:0.5f]];
    } else {
        return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:0.6167f blue:0.0f alpha:1.0f]];
    }
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSNumber *result;
    if (CPTBarPlotFieldBarLocation == fieldEnum) {
        float distance = 0.2f;
        switch (idx) {
            case 0:
                result = [NSNumber numberWithFloat:0.4f + distance];
                break;
            case 1:
                result = [NSNumber numberWithFloat:0.7f + distance];
                break;
            case 2:
                result = [NSNumber numberWithFloat:1.0f + distance];
                break;
            case 3:
                result = [NSNumber numberWithFloat:1.3f + distance];
                break;
            case 4:
                result = [NSNumber numberWithFloat:1.6f + distance];
                break;
            case 5:
                result = [NSNumber numberWithFloat:1.9f + distance];
                break;
            case 6:
                result = [NSNumber numberWithFloat:2.2f + distance];
                break;
            case 7:
                result = [NSNumber numberWithFloat:2.5f + distance];
                break;
            case 8:
                result = [NSNumber numberWithFloat:2.8f + distance];
                break;
            case 9:
                result = [NSNumber numberWithFloat:3.1f + distance];
                break;
            case 10:
                result = [NSNumber numberWithFloat:3.4f + distance];
                break;
            case 11:
                result = [NSNumber numberWithFloat:3.7f + distance];
                break;
            default:
                break;
        }
    } else if (CPTBarPlotFieldBarTip == fieldEnum) {
        int val;
        switch (idx) {
            case 0:
                val = 9;
                break;
            case 1:
                val = 15;
                break;
            case 2:
                val = 17;
                break;
            case 3:
                val = 8;
                break;
            case 4:
                val = 10;
                break;
            case 5:
                val = 16;
                break;
            case 6:
                val = 6;
                break;
            case 7:
                val = 1;
                break;
            case 8:
                val = 3;
                break;
            case 9:
                val = 19;
                break;
            case 10:
                val = 11;
                break;
            case 11:
                val = 14;
            default:
                break;
        }
        result = [NSNumber numberWithInt:val];
    }
    return result;
}

@end
