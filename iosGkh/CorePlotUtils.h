//
//  CorePlotUtils.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 19.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface CorePlotUtils : NSObject

+ (CPTMutableTextStyle *) orangeHelvetica;
+ (CPTMutableTextStyle *) whiteHelvetica;
+ (CPTMutableTextStyle *) greenHelvetica;
+ (CGColorRef) blueColor;
+ (NSNumberFormatter *) thousandsSeparator;
+ (NSArray *) monthsArray;

@end
