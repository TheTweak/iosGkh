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
@property NSUInteger sections;
@property BOOL isLoaded;
// counters post request error (if failed)
@property NSError *error;
@end
@implementation CounterTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.isLoaded && !self.error) {
        // dweller client
        AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
        NSString *flsId = [[Dweller class] fls];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:flsId, @"fls", nil];
        [client postPath:@"counters" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *responseJson = [jsonParser objectWithString:responseString];
            self.counters = [responseJson objectForKey:@"counters"];
            self.sections = [responseJson objectForKey:@"sections"];
            self.isLoaded = YES;
            self.error = nil;
            [tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.error = error;
            self.isLoaded = NO;
            NSLog(@"Failed to load counters table: %@", error);
        }];
    }
    return self.sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.counters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.shadowColor = [UIColor darkGrayColor];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    NSDictionary *counter = [self.counters objectAtIndex:indexPath.item];
    return nil;
//    cell.textLabel.text = [counter]
}

@end
