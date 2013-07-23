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
#import "CounterValsViewController.h"

@interface CounterTableViewController ()
@property BOOL isLoading;
@property NSArray *devices;
// <deviceId, viewController>
// todo : --->  <deviceId, dataArray>
@property NSMutableDictionary *viewControllerByCounter;
@end

@implementation CounterTableViewController

@synthesize isLoading = _isLoading;
@synthesize devices = _devices;
@synthesize viewControllerByCounter = _viewControllerByCounter;

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
    self.viewControllerByCounter = [[NSMutableDictionary alloc] init];
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

#define COUNTER_VALS_TABLE_VIEW_CONTROLLER_STORYBOARD_ID @"CounterValsTableView"

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *counters = [self.devices objectAtIndex:indexPath.section];
    NSDictionary *counter = [counters objectAtIndex:indexPath.row];
    NSString *counterId = [counter objectForKey:@"counterId"];
    UIViewController *counterViewController = [self.viewControllerByCounter objectForKey:counterId];
    if (counterViewController) {
        [self.navigationController pushViewController:counterViewController animated:YES];
    } else {
        AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
        [client postPath:@"counter" parameters:[NSDictionary dictionaryWithObjectsAndKeys:counterId, @"counter", nil]
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     CounterValsViewController *counterValsController = (CounterValsViewController *) [[self.navigationController storyboard] instantiateViewControllerWithIdentifier:COUNTER_VALS_TABLE_VIEW_CONTROLLER_STORYBOARD_ID];
                     // set counter id
                     counterValsController.counterId = counterId;
                     SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                     NSData *responseData = (NSData *) responseObject;
                     NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                     counterValsController.counterVals = [jsonParser objectWithString:responseString];
                     [self.viewControllerByCounter setObject:counterValsController forKey:counterId];
                     [self.navigationController pushViewController:counterValsController animated:YES];
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"fail to load counter vals");
                 }];
    }
}

@end
