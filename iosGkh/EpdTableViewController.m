//
//  EpdTableViewController.m
//  iosGkh
//
//  Created by Sorokin E on 20.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "EpdTableViewController.h"
#import "EpdDetailTableViewController.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "Dweller.h"

@interface EpdTableViewController ()
@property BOOL isLoading;
@property NSArray *epdArray;
@end

@implementation EpdTableViewController

@synthesize isLoading = _isLoading;
@synthesize epdArray = _epdArray;

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
    if (!self.isLoading) {
        self.isLoading = YES;
        // dweller client
        AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
        NSString *flsId = [[Dweller class] fls];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:flsId, @"fls", nil];
        [client getPath:@"epdlist" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *) responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            self.epdArray = [jsonParser objectWithString:responseString];
            [tableView reloadData];
            self.isLoading = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.isLoading = NO;
            NSLog(@"Failed to load counters table: %@", error);
        }];
    }
    return self.epdArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpdCell";
    static NSString *RedCellIdentifier = @"EpdCellRed";
    NSString *identifier;
    NSDictionary *epd = [self.epdArray objectAtIndex:indexPath.row];
    NSString *isOpl = [epd objectForKey:@"isOpl"];
    if ([@"YES" isEqualToString:isOpl]) {
        identifier = CellIdentifier;
    } else {
        identifier = RedCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    UILabel *periodL = (UILabel *) [cell viewWithTag:14];
    periodL.text = [epd objectForKey:@"period"];
    
    UILabel *createdL = (UILabel *) [cell viewWithTag:15];
    createdL.text = [epd objectForKey:@"created"];
    
    UILabel *nachL = (UILabel *) [cell viewWithTag:16];
    nachL.text = [epd objectForKey:@"nach"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *epd = [self.epdArray objectAtIndex:indexPath.row];
    NSString *epdId = [epd objectForKey:@"id"];
    NSString *flsId = [[Dweller class] fls];
    AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
    [client getPath:@"epdetails" parameters:[NSDictionary dictionaryWithObjectsAndKeys:epdId, @"epd", flsId, @"fls", nil]
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                 NSData *responseData = (NSData *) responseObject;
                 NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                 NSArray *epdDetails = [jsonParser objectWithString:responseString];
                 EpdDetailTableViewController *detailViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]
                                                                       instantiateViewControllerWithIdentifier:@"EpdDetailVC"];
                 detailViewController.detailsArray = epdDetails;
                 [self.navigationController pushViewController:detailViewController animated:YES];
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"fail to load counter vals");
             }];
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
