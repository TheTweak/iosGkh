//
//  CPTGraphHolderProtocol.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPTGraphHolderProtocol <NSObject>

- (void) addPlot:(NSString *)title ofType:(NSString *)type;

@end
