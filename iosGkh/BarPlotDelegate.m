//
//  BarPlotDelegate.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 19.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "BarPlotDelegate.h"

@interface BarPlotDelegate ()
@property (nonatomic, strong) CPTAnnotation *leftSideAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideAnnotation;
@end

@implementation BarPlotDelegate

@synthesize leftSideAnnotation = _leftSideAnnotation;
@synthesize rightSideAnnotation = _rightSideAnnotation;
@synthesize arrow = _arrow;

- (void) barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx {
    if (plot.isHidden) {
        return;
    }
    NSNumber *barHeight = [plot.dataSource numberForPlot:plot
                                                   field:CPTBarPlotFieldBarTip
                                             recordIndex:idx];
    NSNumber *barPosition = [plot.dataSource numberForPlot:plot
                                                     field:CPTBarPlotFieldBarLocation
                                               recordIndex:idx];
    CPTMutableTextStyle *style = [CorePlotUtils orangeHelvetica];
    // left annotation - bar position "value"
    if (!self.leftSideAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:0.25f];
        NSNumber *y = [NSNumber numberWithFloat:21.5f];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.leftSideAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                   initWithPlotSpace:plot.plotSpace
                                   anchorPlotPoint:anchorPoint];
    }
    NSArray *monthsArray = [CorePlotUtils monthsArray];
    NSString *monthValue = [monthsArray objectAtIndex:idx];
    CPTTextLayer *textLayerLeft = [[CPTTextLayer alloc] initWithText:monthValue
                                                               style:style];
    self.leftSideAnnotation.contentLayer = textLayerLeft;
    // right annotation - bar height "value"
    if (!self.rightSideAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:3.5f];
        NSNumber *y = [NSNumber numberWithFloat:21.5f];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.rightSideAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                    initWithPlotSpace:plot.plotSpace
                                    anchorPlotPoint:anchorPoint];
    }
    NSNumberFormatter *thousandSeparator = [CorePlotUtils thousandsSeparator];
    NSString *priceValue = [[thousandSeparator stringFromNumber:barHeight]
                            stringByAppendingString:@"р."];
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue
                                                           style:style];
    self.rightSideAnnotation.contentLayer = textLayer;
    
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.leftSideAnnotation];
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.rightSideAnnotation];
    
    NSDecimal plotPoint[2]; // "plot" point coords
    plotPoint[CPTCoordinateX] = barPosition.decimalValue;
    plotPoint[CPTCoordinateY] = barHeight.decimalValue;
    // plot view area coords
    CPTPlotAreaFrame *plotAreaFrame = plot.graph.plotAreaFrame;
    CGPoint cgPlotPoint = [plot.plotSpace plotAreaViewPointForPlotPoint:plotPoint];
    CGPoint dataPoint = [plotAreaFrame convertPoint:cgPlotPoint
                                          fromLayer:plotAreaFrame.plotArea];
    //animation for arrow
    CABasicAnimation *animation = [CABasicAnimation animation];
    CGPoint newStrelkaPosition = CGPointMake(dataPoint.x, self.arrow.position.y);
    animation.toValue = [NSValue valueWithCGPoint:newStrelkaPosition];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
        
    [self.arrow addAnimation:animation forKey:@"position"];
    [self.arrow setPosition:newStrelkaPosition];
}

@end
