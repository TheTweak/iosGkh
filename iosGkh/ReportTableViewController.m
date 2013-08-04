//
//  ReportTableViewController.m
//  iosGkh
//
//  Created by Sorokin E on 16.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "ReportTableViewController.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "Constants.h"
#import "GkhReport.h"
#import "ReportViewController.h"

@interface ReportTableViewController ()
// Массив отчетов которые грузятся в таблицу
@property (nonatomic, strong) NSMutableArray* reportArray;
@end

@implementation ReportTableViewController

#define TITLE @"Отчеты"
#define TITLE_FONT_SIZE 16.0

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = TITLE;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:TITLE_FONT_SIZE];
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeFont: font}];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Table view data source

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GkhReport *report = [self.reportArray objectAtIndex:indexPath.row];
    UILabel *reportName = (UILabel *) [cell viewWithTag:14];
    reportName.text = report.name;
    UILabel *reportDesc = (UILabel *) [cell viewWithTag:15];
    reportDesc.text = report.description;
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.reportArray) {
        [self.activityIndicator startAnimating];
        AFHTTPClient *client = [BasicAuthModule httpClient];
        [client getPath:@"param/list" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.activityIndicator stopAnimating];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSArray *params = [jsonParser objectWithString:responseString];
            NSMutableArray *reportArray = [NSMutableArray array];
            for (NSDictionary *param in params) {
                NSString *reportId = [param objectForKey:@"id"];
                NSString *reportName = [param objectForKey:@"name"];
                NSString *reportDesc = [param objectForKey:@"description"];
                NSString *stringPlotType = [param objectForKey:@"graph"];
                // доп. представления
                NSArray *additionalReps = [param objectForKey:@"additionalRep"];
                NSMutableArray *addReps = [NSMutableArray array];
                for (NSDictionary *rep in additionalReps) {
                    NSString *stringType = [rep objectForKey:@"type"];
                    GkhRepresentation *representation = [GkhRepresentation representation:[rep objectForKey:@"id"]
                                                                                   ofType:[GkhRepresentation representationTypeOf:stringType]];
                    [addReps addObject:representation];
                }
                // вход. параметры
                NSArray *inputParams = [param objectForKey:@"input"];
                NSMutableArray *inputArr = [NSMutableArray array];
                for (NSDictionary *input in inputParams) {
                    NSString *stringRepType = [input objectForKey:@"representation"];
                    GkhInputType *inputType = [GkhInputType inputParam:[input objectForKey:@"id"]
                                                           description:[input objectForKey:@"description"]
                                                        representation:[GkhInputType representationTypeOf:stringRepType]
                                                                 value:[input objectForKey:@"value"]];
                    [inputArr addObject:inputType];
                }
                GkhReport *report = [GkhReport report:reportId
                                             withName:reportName
                                          description:reportDesc
                            additionalRepresentations:addReps
                                               inputs:inputArr
                                             plotType:[GkhReport plotTypeOf:stringPlotType]];
                [reportArray addObject:report];
            }
            self.reportArray = [reportArray copy];
            [tableView reloadData];
            NSLog(@"success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.activityIndicator stopAnimating];
            NSLog(@"failure");
        }];
    }
    
    return [self.reportArray count];
}

#pragma mark - Table view delegate

#define REPORT_VIEW_CONTROLLER_ID @"ReportViewController"

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ReportViewController *reportViewController = [self.storyboard instantiateViewControllerWithIdentifier:REPORT_VIEW_CONTROLLER_ID];
    GkhReport *report = self.reportArray[indexPath.row];
    reportViewController.report = report;
    [self.navigationController pushViewController:reportViewController animated:YES];
}

@end
