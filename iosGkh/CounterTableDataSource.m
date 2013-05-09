//
//  CounterTableDataSource.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CounterTableDataSource.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "Dweller.h"

@interface CounterTableDataSource ()
// счетчики
@property NSArray *counters;
@end

@implementation CounterTableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.counters) {
        // dweller client
        AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
        NSString *flsId = [[Dweller class] fls];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:flsId, @"fls", nil];
        [client postPath:@"counters" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSArray *responseArray = [jsonParser objectWithString:responseString];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to load counters table: %@", error);
        }];
    }
    return [self.counters count];
}

@end
