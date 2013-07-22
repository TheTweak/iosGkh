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

@synthesize detailsArray = _detailsArray;

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
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    return self.detailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpdDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *epdDetail = [self.detailsArray objectAtIndex:indexPath.row];
    // Услуга
    UILabel *serv = (UILabel *) [cell viewWithTag:14];
    serv.text = [epdDetail objectForKey:@"serv"];
    
    // Поставщик
    UILabel *provider = (UILabel *) [cell viewWithTag:15];
    provider.text = [epdDetail objectForKey:@"provider"];
    
    // Сумма
    UILabel *summ = (UILabel *) [cell viewWithTag:16];
    NSString *summa = [NSString stringWithFormat:@"%@ руб.", epdDetail[@"val"]];
    summ.text = summa;
    
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
