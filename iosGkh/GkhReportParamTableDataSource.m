//
//  GkhReportParamTableDataSource.m
//  iosGkh
//
//  Created by Sorokin E on 26.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "GkhReportParamTableDataSource.h"
#import "GkhReport.h"
#import "BasicAuthModule.h"
#import "ActionSheetStringPicker.h"
#import "SBJsonParser.h"

@implementation GkhReportParamTableDataSource

@synthesize params = _params;

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.params.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ParamTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GkhInputType *param = [self.params objectAtIndex:indexPath.row];
    UILabel *description = (UILabel *) [cell viewWithTag:14];
    description.text = param.description;
    UILabel *value = (UILabel *) [cell viewWithTag:15];
    value.text = param.value;
    return cell;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GkhInputType *param = [self.params objectAtIndex:indexPath.row];
    AFHTTPClient *client = [BasicAuthModule httpClient];
        
#warning TODO : loading mask
    [client postPath:@"param/value/list" parameters:@{@"param": param.id} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSArray *responseJson = [jsonParser objectWithString:responseString];
        NSMutableArray *comboDataArray = [NSMutableArray array];
        for(int i = 0, l = [responseJson count]; i < l; i++) {
            NSDictionary *jsonObject = [responseJson objectAtIndex:i];
            NSString *name = [jsonObject valueForKey:@"name"];
            [comboDataArray insertObject:name atIndex:i];
        }
        [ActionSheetStringPicker showPickerWithTitle:param.description
                                                rows:comboDataArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSDictionary *selectedJson = [responseJson objectAtIndex:selectedIndex];
                                               NSString *value = [selectedJson objectForKey:@"name"];
                                               param.value = value;
                                               [tableView reloadData];
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {

                                         }
                                              origin:tableView.superview];
        NSLog(@"Gettin %@ param's value list succeeded", param.id);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Gettin %@ param's value list failed", param.id);
    }];

    
}

@end
