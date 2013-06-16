//
//  ReportViewController.m
//  iosGkh
//
//  Created by Sorokin E on 16.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "ReportViewController.h"
#import "GkhReport.h"

@interface ReportViewController ()
@end

@implementation ReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

#pragma mark Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.reportParams.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportParamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GkhInputType *param = self.reportParams[indexPath.row];
    UILabel *paramName = (UILabel *) [cell viewWithTag:14];
    paramName.text = param.value;
    UILabel *paramDesc = (UILabel *) [cell viewWithTag:15];
    paramDesc.text = param.description;
    return cell;
}

@end
