//
//  HomeTableDataSource.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.01.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeTableDataSource : NSObject <UITableViewDataSource>

// Get custom properties of a parameter (id, ... etc) from the home screen table
- (NSDictionary *) customPropertiesAtRowIndex:(NSUInteger) index;

// set custom info
- (void) setCustomProperties:(NSDictionary *) props
                     atIndex:(NSUInteger) index;

// set custom Input info
- (void) setCustomInputProperties:(NSDictionary *) props
                          atIndex:(NSUInteger) index;
@end
