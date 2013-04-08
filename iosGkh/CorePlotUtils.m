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

+ (CGColorRef) blueColor {
    if (!_blueColor) {
        _blueColor = [[CPTColor colorWithComponentRed:0 green:.3943 blue:.91 alpha:1] cgColor];
    }
    return _blueColor;
}

+ (CPTMutableTextStyle *)orangeHelvetica {
    if (!_orangeHelvetica) {
        _orangeHelvetica = [CPTMutableTextStyle textStyle];
        _orangeHelvetica.color= [CPTColor colorWithComponentRed:0 green:.3943 blue:.91 alpha:1];
        _orangeHelvetica.fontSize = 17.0f;
        _orangeHelvetica.fontName = @"Helvetica-Bold";
    }
    return _orangeHelvetica;
}

+ (CPTMutableTextStyle *)whiteHelvetica {
    if (!_whiteHelvetica) {
        _whiteHelvetica = [CPTMutableTextStyle textStyle];
        _whiteHelvetica.color= [CPTColor whiteColor];
        _whiteHelvetica.fontSize = 15.0f;
        _whiteHelvetica.fontName = @"Helvetica-Bold";
    }
    return _whiteHelvetica;
}

+ (CPTMutableTextStyle *)greenHelvetica {
    if (!_greenHelvetica) {
        _greenHelvetica = [CPTMutableTextStyle textStyle];
        _greenHelvetica.color= [CPTColor colorWithComponentRed:0.6793 green:1.0 blue:0.26 alpha:1];
        _greenHelvetica.fontSize = 17.0f;
        _greenHelvetica.fontName = @"Helvetica-Bold";
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
