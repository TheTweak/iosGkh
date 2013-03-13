//
//  HomeTableDataSource.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.01.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "HomeTableDataSource.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "Constants.h"

@interface HomeTableDataSource ()
@property (nonatomic, strong) NSArray* paramsArray;
@end

@implementation HomeTableDataSource

@synthesize paramsArray = _paramsArray;

// Get custom properties of a parameter (id, ... etc) from the home screen table
- (NSDictionary *) customPropertiesAtRowIndex:(NSUInteger)index {
    NSDictionary *properties;
    if (self.paramsArray) {
        properties = [self.paramsArray objectAtIndex:index];
    }
    return properties;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor orangeColor];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    NSDictionary *paramJson = [self.paramsArray objectAtIndex:indexPath.row];
    
    NSString *graphType = [paramJson objectForKey:@"graph"];
    NSString *pngFileName;
    if ([BarPlot isEqualToString:graphType]) {
        pngFileName = @"coins48";
    } else if ([PieChart isEqualToString:graphType]) {
        pngFileName = @"fls48";
    } else if ([@"SCATTERED" isEqualToString:graphType]) {
        pngFileName = @"stocks48";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:pngFileName ofType:@"png"];
    cell.textLabel.text = [paramJson objectForKey:@"name"];
    cell.detailTextLabel.text = [paramJson objectForKey:@"description"];
    cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Delete! only for dev purpose
    [BasicAuthModule authenticateWithLogin:@"glava" andPassword:@"1234"];
#warning end
    if (!self.paramsArray) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTableLoadingMask" object:self];
        AFHTTPClient *client = [BasicAuthModule httpClient];
        [client getPath:@"param/list" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSArray *params = [jsonParser objectWithString:responseString];
            self.paramsArray = params;
            [tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTableLoadingMask" object:self];
            NSLog(@"success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTableLoadingMask" object:self];
            NSLog(@"failure");
        }];
    }
    
    return [self.paramsArray count];
}

@end
