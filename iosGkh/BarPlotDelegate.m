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
#import "QBPopupMenu.h"
#import "PeriodDetailsViewController.h"

@interface BarPlotDelegate ()
@property (nonatomic, strong) CPTAnnotation *periodAnnotation;
@property (nonatomic, strong) CPTAnnotation *nachAnnotation;
@property (nonatomic, strong) CPTAnnotation *payAnnotation;
@property (nonatomic, strong) CPTAnnotation *rightSideBottomAnnotation;
@property (nonatomic, strong) CPTShadow *shadow;
@property (nonatomic, strong) NSString *period;
@property (nonatomic, strong) QBPopupMenu *popUpMenu;
@end

@implementation BarPlotDelegate

CGFloat const nach_label_height = 1.05;
CGFloat const nach_label_pos = 0.8;

CGFloat const pay_label_height = 1.05;
CGFloat const pay_label_pos = 0.2;

CGFloat const period_label_height = -0.07;
CGFloat const period_label_pos = 0.825;

@synthesize periodAnnotation = _periodAnnotation;
@synthesize nachAnnotation = _nachAnnotation;
@synthesize rightSideBottomAnnotation = _rightSideBottomAnnotation;
@synthesize payAnnotation = _payAnnotation;
@synthesize shadow = _shadow;

-(QBPopupMenu *)popUpMenu
{
    if (!_popUpMenu) {
        _popUpMenu = [[QBPopupMenu alloc] init];
    }
    return _popUpMenu;
}

- (CPTShadow *) shadow {
    if (!_shadow) {
        /*CPTMutableShadow *shadow = [CPTMutableShadow shadow];
        shadow.shadowColor = [CPTColor lightGrayColor];
        shadow.shadowOffset = CGSizeMake(1.0, 1.0);
        _shadow = shadow;*/
    }
    return _shadow;
}

- (void) barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx {
    // if plot == second bar plot, return!
    if (plot.isHidden) {
        return;
    }
    CPTPlotArea *plotArea = plot.graph.plotAreaFrame.plotArea;
    // get business values for selected bar
    id<ReportPlotDataSource> plotDataSource = (id<ReportPlotDataSource>) plot.dataSource;
        
    NSDictionary *businessVals = [plotDataSource getBusinessValues:idx];
    
    NSDecimalNumber *nachVal = [NSDecimalNumber decimalNumberWithString:[businessVals valueForKey:@"y"]];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *nachis = [formatter stringFromNumber:nachVal];

    NSDecimalNumber *payVal = [NSDecimalNumber decimalNumberWithString:[businessVals valueForKey:@"y2"]];
    NSString *pay = [formatter stringFromNumber:payVal];
    
    NSString *period = [businessVals valueForKey:@"period"];
    self.period = period;
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
    
    // percent label
    NSNumber *percent = [businessVals valueForKey:@"percent"];
    NSString *percentLabel = [[percent description] stringByAppendingString:@"%"];
    
    // Pop-up view
    QBPopupMenu *popupMenu = self.popUpMenu;
    
    // rotate 180 degrees along x axis
    popupMenu.layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0);
    QBPopupMenuItem *item = [QBPopupMenuItem itemWithTitle:percentLabel target:self action:@selector(popUpMenuClickHandler)];
    popupMenu.items = [NSArray arrayWithObjects:item, nil];
    // plot view area coords
    CPTPlotAreaFrame *plotAreaFrame = plot.graph.plotAreaFrame;
    // plot point in the plotAreaView
    CGPoint cgPlotPoint = [plot.plotSpace plotAreaViewPointForPlotPoint:plotPoint];
    cgPlotPoint = [plot.graph convertPoint:cgPlotPoint fromLayer:plotAreaFrame.plotArea];
    float bottomPopMenuBorder = 200.0; // if lower, draw at this point
    if (cgPlotPoint.y < bottomPopMenuBorder) {
        cgPlotPoint.y = bottomPopMenuBorder;
    }
    [popupMenu showInView:plot.graph.hostingView atPoint:cgPlotPoint];
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

#pragma mark Pop-up menu click handler
#define PERIOD_DETAIL_VIEW_CONTROLLER_ID @"PeriodDetailsViewController"
-(void) popUpMenuClickHandler
{
    NSLog(@"pop-up menu clicked");
    PeriodDetailsViewController *periodDetails = [self.reportViewController.storyboard instantiateViewControllerWithIdentifier:PERIOD_DETAIL_VIEW_CONTROLLER_ID];
    periodDetails.period = self.period;
    periodDetails.report = self.reportViewController.report;
    [self.reportViewController.navigationController pushViewController:periodDetails animated:YES];
}

-(void)dismissPopupMenu
{
    [self.popUpMenu dismiss];
}

@end
