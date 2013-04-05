//
//  BarPlotDelegate.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 19.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "BarPlotDelegate.h"
#import "Nach.h"

@interface BarPlotDelegate ()
@property (nonatomic, strong) CPTAnnotation *leftSideAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideMiddleAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideBottomAnnotation;
@end

@implementation BarPlotDelegate
CGFloat const label_height = 1.4;
CGFloat const middle_label_height = 1.2;
CGFloat const bottom_label_height = 1.2;
CGFloat const left_label_pos = 0.2;
CGFloat const right_label_pos = 0.8;
@synthesize leftSideAnnotation = _leftSideAnnotation;
@synthesize rightSideAnnotation = _rightSideAnnotation;
@synthesize rightSideBottomAnnotation = _rightSideBottomAnnotation;
@synthesize rightSideMiddleAnnotation = _rightSideMiddleAnnotation;
@synthesize arrow = _arrow;

- (void) barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx {
    if (plot.isHidden) {
        return;
    }
    // get business values for selected bar
    Nach *nach = (Nach *) plot.dataSource;
    NSDictionary *businessVals = [nach getBusinessValues:idx];
    // get meta info
    NSDictionary *metaInfo = [self.homeVC selectedParameterMeta];
    
    NSDecimalNumber *nachVal = [NSDecimalNumber decimalNumberWithString:[businessVals valueForKey:@"y"]];
    NSString *nachis = [[CorePlotUtils thousandsSeparator] stringFromNumber:nachVal];
    nachis = [nachis stringByAppendingString:@" р."];
    
    NSDecimalNumber *payVal = [NSDecimalNumber decimalNumberWithString:[businessVals valueForKey:@"y2"]];
    NSString *pay = [[CorePlotUtils thousandsSeparator] stringFromNumber:payVal];
    pay = [pay stringByAppendingString:@" р."];
    
    NSNumber *percent = [businessVals valueForKey:@"percent"];
    NSString *period = [businessVals valueForKey:@"period"];

    // left annotation - bar position "value"
    if (!self.leftSideAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:left_label_pos];
        NSNumber *y = [NSNumber numberWithFloat:label_height];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.leftSideAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                   initWithPlotSpace:plot.plotSpace
                                   anchorPlotPoint:anchorPoint];
    }
    CPTTextLayer *textLayerLeft = [[CPTTextLayer alloc] initWithText:period
                                                               style:[CorePlotUtils whiteHelvetica]];
    CPTMutableShadow *shadow = [CPTMutableShadow shadow];
    shadow.shadowColor = [CPTColor grayColor];
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    textLayerLeft.shadow = shadow;
    self.leftSideAnnotation.contentLayer = textLayerLeft;
    // right annotation - bar height "value"
    if (!self.rightSideAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:right_label_pos];
        NSNumber *y = [NSNumber numberWithFloat:label_height];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.rightSideAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                    initWithPlotSpace:plot.plotSpace
                                    anchorPlotPoint:anchorPoint];
    }
    if (!self.rightSideMiddleAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:right_label_pos];
        NSNumber *y = [NSNumber numberWithFloat:middle_label_height];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.rightSideMiddleAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                    initWithPlotSpace:plot.plotSpace
                                    anchorPlotPoint:anchorPoint];
    }


    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:nachis
                                                           style:[CorePlotUtils orangeHelvetica]];
    textLayer.shadow = shadow;
    self.rightSideAnnotation.contentLayer = textLayer;
    
    CPTTextLayer *textLayerRMiddle = [[CPTTextLayer alloc] initWithText:pay
                                                           style:[CorePlotUtils greenHelvetica]];
    textLayerRMiddle.shadow = shadow;
    self.rightSideMiddleAnnotation.contentLayer = textLayerRMiddle;
    
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.leftSideAnnotation];
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.rightSideAnnotation];
    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.rightSideMiddleAnnotation];
    
    NSDecimal plotPoint[2]; // "plot" point coords
    NSNumber *barHeight = [plot.dataSource numberForPlot:plot
                                                   field:CPTBarPlotFieldBarTip
                                             recordIndex:idx];
    NSNumber *barPosition = [plot.dataSource numberForPlot:plot
                                                     field:CPTBarPlotFieldBarLocation
                                               recordIndex:idx];
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
