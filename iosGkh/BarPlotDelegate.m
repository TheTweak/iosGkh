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
@property (nonatomic, strong) CPTAnnotation *periodAnnotation;
@property (nonatomic, strong) CPTAnnotation *nachAnnotation;
@property (nonatomic, strong) CPTAnnotation *payAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideBottomAnnotation;
@property (nonatomic, strong) CPTAnnotation *percentAnnotation;
@end

@implementation BarPlotDelegate

CGFloat const nach_label_height = 1.1;
CGFloat const nach_label_pos = 0.8;

CGFloat const pay_label_height = 1.1;
CGFloat const pay_label_pos = 0.2;

CGFloat const period_label_height = -0.1;
CGFloat const period_label_pos = 0.85;

@synthesize periodAnnotation = _periodAnnotation;
@synthesize nachAnnotation = _nachAnnotation;
@synthesize rightSideBottomAnnotation = _rightSideBottomAnnotation;
@synthesize payAnnotation = _payAnnotation;
@synthesize percentAnnotation = _percentAnnotation;
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
            
    NSString *period = [businessVals valueForKey:@"period"];

    // left annotation - bar position "value"
    if (!self.periodAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:period_label_pos];
        NSNumber *y = [NSNumber numberWithFloat:period_label_height];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.periodAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                   initWithPlotSpace:plot.plotSpace
                                   anchorPlotPoint:anchorPoint];
    }
    CPTTextLayer *textLayerLeft = [[CPTTextLayer alloc] initWithText:period
                                                               style:[CorePlotUtils whiteHelvetica]];
    CPTMutableShadow *shadow = [CPTMutableShadow shadow];
    shadow.shadowColor = [CPTColor grayColor];
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    textLayerLeft.shadow = shadow;
    self.periodAnnotation.contentLayer = textLayerLeft;
    // right annotation - bar height "value"
    if (!self.nachAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:nach_label_pos];
        NSNumber *y = [NSNumber numberWithFloat:nach_label_height];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.nachAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                    initWithPlotSpace:plot.plotSpace
                                    anchorPlotPoint:anchorPoint];
    }
    if (!self.payAnnotation) {
        NSNumber *x = [NSNumber numberWithFloat:pay_label_pos];
        NSNumber *y = [NSNumber numberWithFloat:pay_label_height];
        NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
        self.payAnnotation = [[CPTPlotSpaceAnnotation alloc]
                                    initWithPlotSpace:plot.plotSpace
                                    anchorPlotPoint:anchorPoint];
    }


    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:nachis
                                                           style:[CorePlotUtils orangeHelvetica]];
    textLayer.shadow = shadow;
    self.nachAnnotation.contentLayer = textLayer;
    
    CPTTextLayer *textLayerRMiddle = [[CPTTextLayer alloc] initWithText:pay
                                                           style:[CorePlotUtils greenHelvetica]];
    textLayerRMiddle.shadow = shadow;
    self.payAnnotation.contentLayer = textLayerRMiddle;
    
    CPTPlotArea *plotArea = plot.graph.plotAreaFrame.plotArea;
    
    [plotArea addAnnotation:self.periodAnnotation];
    [plotArea addAnnotation:self.nachAnnotation];
    [plotArea addAnnotation:self.payAnnotation];
    
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
    
    // percent label
    NSNumber *percent = [businessVals valueForKey:@"percent"];
    NSString *percentLabel = [[percent description] stringByAppendingString:@"%"];
    if (self.percentAnnotation) {
        [plotArea removeAnnotation:self.percentAnnotation];
    }
    NSArray *anchorPoint = [NSArray arrayWithObjects:barPosition, [NSNumber numberWithFloat:0.1], nil];
    self.percentAnnotation = [[CPTPlotSpaceAnnotation alloc]
                              initWithPlotSpace:plot.plotSpace
                              anchorPlotPoint:anchorPoint];
    CPTTextLayer *percentText = [[CPTTextLayer alloc] initWithText:percentLabel
                                                             style:[CorePlotUtils whiteHelvetica]];
    percentText.shadow = shadow;
    self.percentAnnotation.contentLayer = percentText;
    [plotArea addAnnotation:self.percentAnnotation];
    
    // animation for arrow
    CABasicAnimation *animation = [CABasicAnimation animation];
    CGPoint newStrelkaPosition = CGPointMake(dataPoint.x, self.arrow.position.y);
    animation.toValue = [NSValue valueWithCGPoint:newStrelkaPosition];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    [self.arrow addAnimation:animation forKey:@"position"];
    [self.arrow setPosition:newStrelkaPosition];
}

@end
