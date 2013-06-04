//
//  CorePlotUtils.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 19.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CorePlotUtils.h"

@implementation CorePlotUtils

static CPTMutableTextStyle *_orangeHelvetica;
static CPTMutableTextStyle *_greenHelvetica;
static CPTMutableTextStyle *_whiteHelvetica;
static CGColorRef _blueColor;
static NSNumberFormatter *_thousandsSeparator;
static NSArray *_monthsArray;

+(void)setAnchorPoint:(CGPoint)anchorPoint forPlot:(CALayer *)plot {
    CGPoint newPoint = CGPointMake(plot.bounds.size.width * anchorPoint.x, plot.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(plot.bounds.size.width * plot.anchorPoint.x, plot.bounds.size.height * plot.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, plot.affineTransform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, plot.affineTransform);
    
    CGPoint position = plot.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    plot.position = position;
    plot.anchorPoint = anchorPoint;
}

+ (CGColorRef) blueColor {
    if (!_blueColor) {
        _blueColor = [[CPTColor colorWithComponentRed:0 green:.3943 blue:.91 alpha:1] cgColor];
    }
    return _blueColor;
}

+ (CPTMutableTextStyle *)orangeHelvetica {
    if (!_orangeHelvetica) {
        _orangeHelvetica = [CPTMutableTextStyle textStyle];
        _orangeHelvetica.color= [CPTColor colorWithCGColor:[UIColor darkTextColor].CGColor];
        _orangeHelvetica.fontSize = 17.0f;
        _orangeHelvetica.fontName = @"Helvetica";
    }
    return _orangeHelvetica;
}

+ (CPTMutableTextStyle *)whiteHelvetica {
    if (!_whiteHelvetica) {
        _whiteHelvetica = [CPTMutableTextStyle textStyle];
        _whiteHelvetica.color = [CPTColor colorWithCGColor:[UIColor darkTextColor].CGColor];
        _whiteHelvetica.fontSize = 15.0f;
        _whiteHelvetica.fontName = @"Helvetica";
    }
    return _whiteHelvetica;
}

+ (CPTMutableTextStyle *)greenHelvetica {
    if (!_greenHelvetica) {
        _greenHelvetica = [CPTMutableTextStyle textStyle];
        _greenHelvetica.color= [CPTColor colorWithComponentRed:32.0/255.0 green:107.0/255.0 blue:164.0/255.0 alpha:1];
        _greenHelvetica.fontSize = 17.0f;
        _greenHelvetica.fontName = @"Helvetica";
    }
    return _greenHelvetica;
}

+ (NSNumberFormatter *)thousandsSeparator {
    if (!_thousandsSeparator) {
        _thousandsSeparator = [[NSNumberFormatter alloc] init];
        [_thousandsSeparator setMaximumFractionDigits:2];
        [_thousandsSeparator setUsesGroupingSeparator:YES];
        [_thousandsSeparator setGroupingSize:3];
        [_thousandsSeparator setGroupingSeparator:@" "];
    }
    return _thousandsSeparator;
}

+ (NSArray *)monthsArray {
    if (!_monthsArray) {
        _monthsArray = [NSArray arrayWithObjects:@"Январь", @"Февраль",
                                @"Март", @"Апрель", @"Май",
                                @"Июнь", @"Июль", @"Август",
                                @"Сентябрь", @"Октябрь", @"Ноябрь",
                                @"Декабрь", nil];
    }
    return _monthsArray;
}

@end
