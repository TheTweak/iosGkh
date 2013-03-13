//
//  HomeTableDataSource.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.01.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeTableDataSource : NSObject <UITableViewDataSource>
-(NSDictionary *) customPropertiesAtRowIndex:(NSUInteger) index;
@end
