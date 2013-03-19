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
static NSNumberFormatter *_thousandsSeparator;
static NSArray *_monthsArray;

+ (CPTMutableTextStyle *)orangeHelvetica {
    if (!_orangeHelvetica) {
        _orangeHelvetica = [CPTMutableTextStyle textStyle];
        _orangeHelvetica.color= [CPTColor orangeColor];
        _orangeHelvetica.fontSize = 13.0f;
        _orangeHelvetica.fontName = @"Helvetica-Bold";
    }
    return _orangeHelvetica;
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
