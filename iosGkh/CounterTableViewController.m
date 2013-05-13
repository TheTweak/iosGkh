//
//  CounterTableViewController.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 08.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CounterTableViewController.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "Dweller.h"

@interface CounterTableViewController ()
@property BOOL isLoading;
@property NSArray *devices;
@end

@implementation CounterTableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.isLoading) {
        self.isLoading = YES;
        // dweller client
        AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
        NSString *flsId = [[Dweller class] fls];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:flsId, @"fls", nil];
        [client postPath:@"counters" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *) responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            self.devices = [jsonParser objectWithString:responseString];
            [tableView reloadData];
            self.isLoading = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.isLoading = NO;
            NSLog(@"Failed to load counters table: %@", error);
        }];
    }
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return self.devices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!tableView) return 0;
    NSArray *devices = [self.devices objectAtIndex:section];
    return devices.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!tableView) return nil;
    // if section exists so a device array, so no additional check here
    NSArray *counters = [self.devices objectAtIndex:section];
    NSDictionary *firstDevice = [counters objectAtIndex:0];
    NSString *deviceNum = [firstDevice objectForKey:@"deviceNum"];
    NSString *devieDesc = [firstDevice objectForKey:@"deviceDesc"];
    NSString *title = [NSString stringWithFormat:@"(%@) %@", deviceNum, devieDesc];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CounterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];        
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.shadowColor = [UIColor darkGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    NSArray *counters = [self.devices objectAtIndex:indexPath.section];
    NSDictionary *counter = [counters objectAtIndex:indexPath.row];
    cell.textLabel.text = [counter objectForKey:@"counterDesc"];
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
