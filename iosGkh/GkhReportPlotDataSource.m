//
//  GkhReportPlotDataSource.m
//  iosGkh
//
//  Created by Sorokin E on 26.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "GkhReportPlotDataSource.h"
#import "CorePlotUtils.h"

@interface GkhReportPlotDataSource ()
@property NSDecimalNumber *maxHeight;
@property NSArray *animations;
/* Fill color for bar at given index */
@property(nonatomic, strong) NSMutableArray *barFillArray;
@end

@implementation GkhReportPlotDataSource

-(NSMutableArray *)barFillArray
{
    if (!_barFillArray) {
        _barFillArray = [NSMutableArray arrayWithCapacity:self.values.count];
    }
    return _barFillArray;
}

-(NSDictionary *)getBusinessValues:(NSInteger) idx {
    return [self.values objectAtIndex:idx];
}

-(void)setFill:(CPTFill *)fill forBarAtIndex:(NSInteger)idx
{
    self.barFillArray[idx] = fill;
}

#pragma mark CPTPlotDataSource

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {    
    // вычисление максимальной высоты графика
    self.maxHeight = nil;
    NSDecimalNumber *maxH = [NSDecimalNumber zero];
    NSDecimalNumber *maxH2 = [NSDecimalNumber zero];
    for (int i = 0, l = [self.values count]; i < l; i++) {
        NSDictionary *jsonObject = [self.values objectAtIndex:i];
        NSDecimalNumber *y = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y"]];
        NSComparisonResult compare = [maxH compare:y];
        if (compare == NSOrderedAscending) maxH = y;
        NSDecimalNumber *y2 = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y2"]];
        NSComparisonResult compare2 = [maxH2 compare:y2];
        if (compare2 == NSOrderedAscending) maxH2 = y2;
    }
    NSComparisonResult compare = [maxH compare:[NSDecimalNumber zero]];
    if (compare != NSOrderedSame) {
        self.maxHeight = maxH;
    } else {
        compare = [maxH2 compare:[NSDecimalNumber zero]];
        if (compare != NSOrderedSame) {
            self.maxHeight = maxH2;
        }
    }
    
    if (!self.maxHeight) {
        self.maxHeight = [NSDecimalNumber decimalNumberWithString:@"1"];
    }

    return self.values.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    // todo remove this stub (Pie Chart)
    if ([@"flsCount" isEqualToString:plot.title]) {
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
    
    NSDictionary *jsonObject = [self.values objectAtIndex:idx];
    NSNumber *result;
    
    if ([plot isKindOfClass:[CPTScatterPlot class]]) {
        if (CPTScatterPlotFieldX == fieldEnum) {
            result = [jsonObject objectForKey:@"x"];
        } else if (CPTScatterPlotFieldY == fieldEnum) {
            result = [jsonObject objectForKey:@"y"];
        }
    } else if ([plot isKindOfClass:[CPTBarPlot class]]) {
        NSNumber *width = [jsonObject objectForKey:@"width"];
        ((CPTBarPlot *)plot).barWidth = [width decimalValue];
        if (CPTBarPlotFieldBarLocation == fieldEnum) {
            result = [jsonObject objectForKey:@"x"];
            result = [NSNumber numberWithDouble:[result doubleValue]];
        } else if (CPTBarPlotFieldBarTip == fieldEnum) {
            NSDecimalNumber *y;
            if ([@"sec" isEqualToString:plot.title]) {
                y = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y2"]];
            } else {
                y = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y"]];
            }
            result = [y decimalNumberByDividingBy:self.maxHeight];
        }
    }
    
    return result;
}

- (CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx {
    CPTFill *barFill = self.barFillArray[idx];
    if (!barFill) {
        CPTGradient *gradient;
        CPTColor *begin = [CPTColor colorWithComponentRed:124.0/255.0 green:124.0/255.0 blue:124.0/255.0 alpha:1];
        CPTColor *end = [CPTColor colorWithComponentRed:124.0/255.0 green:124.0/255.0 blue:124.0/255.0 alpha:.5];
        if ([@"sec" isEqualToString:barPlot.title]) {
            CPTColor *begin = [CPTColor colorWithComponentRed:187.0/255.0 green:217.0/255.0 blue:238.0/255.0 alpha:1];
            CPTColor *end = [CPTColor colorWithComponentRed:187.0/255.0 green:217.0/255.0 blue:238.0/255.0 alpha:.5];
            gradient = [CPTGradient gradientWithBeginningColor:begin
                                                   endingColor:end];
        } else {
            gradient = [CPTGradient gradientWithBeginningColor:begin endingColor:end];
        }
        gradient.angle = 90.0f;
        barFill = [CPTFill fillWithGradient:gradient];
    }
    return barFill;
}

#pragma mark CPTPlotDelegate

-(void)didFinishDrawing:(CPTPlot *)plot {
    [CorePlotUtils setAnchorPoint:CGPointMake(0.0, 0.0) forPlot:plot];
    CABasicAnimation *scaling = [CABasicAnimation
                                 animationWithKeyPath:@"transform.scale.y"];
    scaling.fromValue = [NSNumber numberWithFloat:1.0];
    scaling.toValue = [NSNumber numberWithFloat:1.2];
    scaling.duration = 1.0f; // Duration
    scaling.removedOnCompletion = NO;
    scaling.fillMode = kCAFillModeForwards;
    [plot addAnimation:scaling forKey:@"scaling"];
}

@end
