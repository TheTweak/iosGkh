//
//  ReportPlotDataSource.h
//  iosGkh
//
//  Created by Sorokin E on 23.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReportPlotDataSource <NSObject>
-(NSDictionary *)getBusinessValues:(NSInteger) idx;
-(void) setFill:(CPTFill *) fill forBarAtIndex:(NSInteger) idx;
@end
