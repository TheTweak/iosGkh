//
//  Utils.h
//  iosGkh
//
//  Created by Sorokin E on 04.08.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define THEME_HUE 1.0
#define THEME_SATURATION 0.73
#define THEME_BRIGHTNESS 0.44

@interface Utils : NSObject
CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius);
void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
+(UIColor *) themeColor;
@end
