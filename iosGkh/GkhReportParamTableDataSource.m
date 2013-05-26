//
//  GkhReportParamTableDataSource.m
//  iosGkh
//
//  Created by Sorokin E on 26.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "GkhReportParamTableDataSource.h"
#import "GkhReport.h"

@implementation GkhReportParamTableDataSource

@synthesize params = _params;

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

@end
