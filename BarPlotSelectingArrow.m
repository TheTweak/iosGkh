//
//  BarPlotSelectingArrow.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 04.01.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "BarPlotSelectingArrow.h"

@implementation BarPlotSelectingArrow

- (void)drawInContext:(CGContextRef)theContext
{
    UIGraphicsPushContext(theContext);
    [[UIColor redColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(100, 100, 100, 100)] fill];
    [@"Vowel" drawAtPoint:CGPointMake(0, 0) withFont:[UIFont fontWithName:@"Chalkboard" size:14]];
    UIGraphicsPopContext();
}

@end
