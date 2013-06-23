//
//  BarPlotDelegate.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 19.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "BarPlotDelegate.h"
#import "ReportPlotDataSource.h"
#import "CorePlotUtils.h"

@interface BarPlotDelegate ()
@property (nonatomic, strong) CPTAnnotation *periodAnnotation;
@property (nonatomic, strong) CPTAnnotation *nachAnnotation;
@property (nonatomic, strong) CPTAnnotation *payAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideBottomAnnotation;
@property (nonatomic, strong) CPTAnnotation *percentAnnotation;
@property (nonatomic, strong) CPTShadow *shadow;
@end

@implementation BarPlotDelegate

CGFloat const nach_label_height = 1.1;
CGFloat const nach_label_pos = 0.8;

CGFloat const pay_label_height = 1.1;
CGFloat const pay_label_pos = 0.2;

CGFloat const period_label_height = -0.1;
CGFloat const period_label_pos = 0.825;

@synthesize periodAnnotation = _periodAnnotation;
@synthesize nachAnnotation = _nachAnnotation;
@synthesize rightSideBottomAnnotation = _rightSideBottomAnnotation;
@synthesize payAnnotation = _payAnnotation;
@synthesize percentAnnotation = _percentAnnotation;
@synthesize shadow = _shadow;
@synthesize arrow = _arrow;

- (CPTShadow *) shadow {
    if (!_shadow) {
        CPTMutableShadow *shadow = [CPTMutableShadow shadow];
        shadow.shadowColor = [CPTColor lightGrayColor];
        shadow.shadowOffset = CGSizeMake(1.0, 1.0);
        _shadow = shadow;
    }
    return _shadow;
}

- (void) barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx {
    if (plot.isHidden) {
        return;
    }
    CPTPlotArea *plotArea = plot.graph.plotAreaFrame.plotArea;
    // get business values for selected bar
    id<ReportPlotDataSource> plotDataSource = (id<ReportPlotDataSource>) plot.dataSource;
        
    NSDictionary *businessVals = [plotDataSource getBusinessValues:idx];
    
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

    textLayerLeft.shadow = self.shadow;
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
    textLayer.shadow = self.shadow;
    self.nachAnnotation.contentLayer = textLayer;
    
    CPTTextLayer *textLayerRMiddle = [[CPTTextLayer alloc] initWithText:pay
                                                           style:[CorePlotUtils greenHelvetica]];
    textLayerRMiddle.shadow = self.shadow;
    self.payAnnotation.contentLayer = textLayerRMiddle;
        
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
        BOOL deleted = NO;
        for (int i = 0, l = [plotArea.annotations count]; i < l; i++) {
            CPTAnnotation *annotation = [plotArea.annotations objectAtIndex:i];
            if (annotation == self.percentAnnotation) {
                [plotArea removeAnnotation:self.percentAnnotation];
                deleted = YES;
            }
        }
        if (!deleted) {
            self.percentAnnotation = nil;
        }
    }
    NSArray *anchorPoint = [NSArray arrayWithObjects:barPosition, [NSNumber numberWithFloat:0.1], nil];
    self.percentAnnotation = [[CPTPlotSpaceAnnotation alloc]
                              initWithPlotSpace:plot.plotSpace
                              anchorPlotPoint:anchorPoint];
    CPTTextLayer *percentText = [[CPTTextLayer alloc] initWithText:percentLabel
                                                             style:[CorePlotUtils whiteHelvetica]];
    percentText.opacity = 0;
    percentText.shadow = self.shadow;
    self.percentAnnotation.contentLayer = percentText;
    [plotArea addAnnotation:self.percentAnnotation];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration = 0.5f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode = kCAFillModeForwards;
    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    [percentText addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
    // animation for arrow
    CABasicAnimation *animation = [CABasicAnimation animation];
    CGPoint newStrelkaPosition = CGPointMake(dataPoint.x, self.arrow.position.y);
    animation.toValue = [NSValue valueWithCGPoint:newStrelkaPosition];
    [animation setFillMode:kCAFillModeForwards];
    [animation setRemovedOnCompletion:NO];
    [self.arrow addAnimation:animation forKey:@"position"];
    [self.arrow setPosition:newStrelkaPosition];
}

-(void)didFinishDrawing:(CPTPlot *)plot {
    [CorePlotUtils setAnchorPoint:CGPointMake(0.0, 0.0) forPlot:plot];
    CABasicAnimation *scaling = [CABasicAnimation
                                 animationWithKeyPath:@"transform.scale.y"];
    scaling.fromValue = [NSNumber numberWithFloat:0.0];
    scaling.toValue = [NSNumber numberWithFloat:1.0];
    scaling.duration = 1.0f; // Duration
    scaling.removedOnCompletion = NO;
    scaling.fillMode = kCAFillModeForwards;
    [plot addAnimation:scaling forKey:@"scaling"];
}

@end
