//
//  Dweller.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 08.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "Dweller.h"

@implementation Dweller
static NSString *flsId;

+ (NSString *) fls {
    return flsId;
}

+ (void)setFls:(NSString *)fls {
    flsId = fls;
}

@end
