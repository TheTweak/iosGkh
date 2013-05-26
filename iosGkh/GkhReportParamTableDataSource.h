//
//  GkhReportParamTableDataSource.h
//  iosGkh
//
//  Created by Sorokin E on 26.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GkhReportParamTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>
@property NSArray *params;
@end
