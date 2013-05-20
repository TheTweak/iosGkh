//
//  EpdTableViewController.m
//  iosGkh
//
//  Created by Sorokin E on 20.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "EpdTableViewController.h"
#import "EpdDetailTableViewController.h"

@interface EpdTableViewController ()
@end

@implementation EpdTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView *tableView = (UITableView *) self.view;
    tableView.dataSource = self;
    tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpdCell";
    static NSString *RedCellIdentifier = @"EpdCellRed";
    NSString *identifier;
    
    if (indexPath.row % 2 == 0) {
        identifier = CellIdentifier;
    } else {
        identifier = RedCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    UILabel *periodL = (UILabel *) [cell viewWithTag:14];
    periodL.text = @"05.2013";
    
    UILabel *createdL = (UILabel *) [cell viewWithTag:15];
    createdL.text = @"15.04.2013 11:35";
    
    UILabel *nachL = (UILabel *) [cell viewWithTag:16];
    nachL.text = @"10 421.23";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    EpdDetailTableViewController *detailViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]
                                                          instantiateViewControllerWithIdentifier:@"EpdDetailVC"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headerRect = CGRectMake(0, 0, tableView.frame.size.width, 32.0);
    UILabel *tableHeader = [[UILabel alloc] initWithFrame:headerRect];
    tableHeader.backgroundColor = [UIColor colorWithRed:0.6162 green:0.6872 blue:0.78 alpha:1.0];
    tableHeader.textColor = [UIColor whiteColor];
    tableHeader.shadowColor = [UIColor grayColor];
    tableHeader.text = @"    Период          Создано             Начислено      Оплачено";
    tableHeader.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    return tableHeader;
}

@end
