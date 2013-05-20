//
//  EpdDetailTableViewController.m
//  iosGkh
//
//  Created by Sorokin E on 20.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "EpdDetailTableViewController.h"

@interface EpdDetailTableViewController ()

@end

@implementation EpdDetailTableViewController

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
    self.title = @"Детали";
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpdDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // Услуга
    UILabel *serv = (UILabel *) [cell viewWithTag:14];
    serv.text = @"Коллективная антенна";
    
    // Поставщик
    UILabel *provider = (UILabel *) [cell viewWithTag:15];
    provider.text = @"ООО \"Захват\"";
    
    // Сумма
    UILabel *summ = (UILabel *) [cell viewWithTag:16];
    summ.text = @"12 512.12";
    
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
}

@end
