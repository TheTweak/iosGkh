//
//  MetricConsumerProtocol.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 16.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MetricConsumerProtocol <NSObject>

- (void)addNewMetricByString:(NSString *) identifier;

@end
