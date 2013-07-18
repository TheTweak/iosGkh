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
@property BOOL showAllEpd;
@property NSArray *epdArray;
@property UITableViewController *settingsController;
@end

@implementation EpdTableViewController

@synthesize isLoading = _isLoading;
@synthesize epdArray = _epdArray;
@synthesize showAllEpd = _showAllEpd;
@synthesize settingsController = _settingsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.showAllEpd] forKey:@"show_all_epd"];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView *tableView = (UITableView *) self.view;
    tableView.dataSource = self;
    tableView.delegate = self;
    BOOL showAllEpd = [[[NSUserDefaults standardUserDefaults] valueForKey:@"show_all_epd"] boolValue];
    self.showAllEpd = showAllEpd;
    /*self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Настройки" style:UIBarButtonItemStyleBordered
                                                                             target:self action:@selector(naviRightButtonHandler)];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation right bar button handler

-(void)naviRightButtonHandler {
    if (!self.settingsController) {
        UITableViewController *settingsTableViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EpdSettings"];
        settingsTableViewController.tableView.delegate = self;
        settingsTableViewController.tableView.dataSource = self;
        self.settingsController = settingsTableViewController;
    }
    [self.navigationController pushViewController:self.settingsController animated:YES];
}

#pragma mark - Epd Settings table delegates

-(void)showAllEpdSwitchToggled:(id)sender {
    self.showAllEpd = ((UISwitch *)sender).on;
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.settingsController.tableView) {
        return @"Общие";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.settingsController.tableView) {
        return 1;
    } else {
        if (!self.isLoading) {
            self.isLoading = YES;
            // dweller client
            AFHTTPClient *client = [BasicAuthModule dwellerHttpClient];
            NSString *flsId = [[Dweller class] fls];
            NSNumber *showAll = [NSNumber numberWithBool:self.showAllEpd];
            [client getPath:@"epdlist" parameters:@{@"fls" : flsId, @"allEpd" : showAll} success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
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
        periodL.text = epd[@"period"];
        
        UILabel *createdL = (UILabel *) [cell viewWithTag:15];
        createdL.text = [epd objectForKey:@"created"];
        
        UILabel *nachL = (UILabel *) [cell viewWithTag:16];
        nachL.text = [epd objectForKey:@"nach"];
        
        return cell;
    } else if (tableView == self.settingsController.tableView) {
        static NSString *SettingsCellIdentifier = @"EpdSettingsSwitchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier forIndexPath:indexPath];
        UILabel *settingName = (UILabel *) [cell viewWithTag:14];
        UISwitch *allEpdSwitch = (UISwitch *) [cell viewWithTag:15];
        allEpdSwitch.on = self.showAllEpd;
        [allEpdSwitch addTarget:self action:@selector(showAllEpdSwitchToggled:) forControlEvents:UIControlEventValueChanged];
        settingName.text = @"Отображать все ЕПД";        
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
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
}

@end
