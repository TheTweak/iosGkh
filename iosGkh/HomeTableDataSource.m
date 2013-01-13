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

@interface HomeTableDataSource ()
@property (nonatomic, strong) NSArray* paramsArray;
@end

@implementation HomeTableDataSource

@synthesize paramsArray = _paramsArray;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor orangeColor];
    NSDictionary *paramJson = [self.paramsArray objectAtIndex:indexPath.row];
    
    NSString *graphType = [paramJson objectForKey:@"graph"];
    NSString *pngFileName;
    if ([@"BAR_PLOT" isEqualToString:graphType]) {
        pngFileName = @"coins48";
    } else if ([@"PIE_CHART" isEqualToString:graphType]) {
        pngFileName = @"fls48";
    } else if ([@"SCATTERED" isEqualToString:graphType]) {
        pngFileName = @"stocks48";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:pngFileName ofType:@"png"];
    cell.textLabel.text = [paramJson objectForKey:@"name"];
    cell.detailTextLabel.text = [paramJson objectForKey:@"description"];
    cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    /*
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Начисления";
            cell.detailTextLabel.text = @"начисления по периодам за год";
            NSString *path = [[NSBundle mainBundle] pathForResource:@"coins48" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"Количество ФЛС";
            cell.detailTextLabel.text = @"количество ФЛС по домам";
            NSString *path = [[NSBundle mainBundle] pathForResource:@"fls48" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
            break;
        }
        case 2:
        {
            cell.textLabel.text = @"Динамика показаний ДПУ";
            cell.detailTextLabel.text = @"изменение показаний ДПУ за период";
            NSString *path = [[NSBundle mainBundle] pathForResource:@"stocks48" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.image = theImage;
            break;
        }
    }*/
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.paramsArray) {
        AFHTTPClient *client = [BasicAuthModule httpClient];
        [client getPath:@"param/list" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSArray *params = [jsonParser objectWithString:responseString];
            self.paramsArray = params;
            [tableView reloadData];
            NSLog(@"success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure");
        }];
    }
    
    return [self.paramsArray count];
}

@end
