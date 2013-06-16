//
//  ReportViewController.m
//  iosGkh
//
//  Created by Sorokin E on 16.06.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "ReportViewController.h"
#import "GkhReport.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "GkhReportPlotDataSource.h"

@interface ReportViewController ()
@property (nonatomic, strong) CPTGraphHostingView *graphHostingView;
@end

@implementation ReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = self.report.name;
}

-(void)viewWillAppear:(BOOL)animated
{
    CGRect graphHostingViewRect = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(graphHostingViewRect.size.width, 0);
    self.graphHostingView = [[CPTGraphHostingView alloc] initWithFrame:graphHostingViewRect];
    [self.scrollView addSubview:self.graphHostingView];
}

#define REPORT_REQUEST_TYPE_KEY @"type"

-(void)viewDidAppear:(BOOL)animated
{
    NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
    requestParameters[REPORT_REQUEST_TYPE_KEY] = self.report.id;
    for (GkhInputType *input in self.report.inputParamArray) {
        requestParameters[input.id] = input.value;
    }
//    [self showLoadingMask];
    AFHTTPClient *client = [BasicAuthModule httpClient];
    [client postPath:@"param/value" parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Getting report plot data succeeded!");
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *responseJson = [jsonParser objectWithString:responseString];
        NSArray *result = [responseJson objectForKey:@"values"];
        // создаем дата сорс для графика этого отчета
//        GkhReportPlotDataSource *plotDataSource = [[GkhReportPlotDataSource alloc] init];
//        plotDataSource.values = result;
        // draw graph
//        [self addPlot:self.report.id ofType:self.report.plotType dataSource:plotDataSource];
//        [self hideLoadingMask];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Getting report plot data failed!");
//        [self hideLoadingMask];
    }];
}

#pragma mark Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.report.inputParamArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportParamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GkhInputType *param = self.report.inputParamArray[indexPath.row];
    UILabel *paramName = (UILabel *) [cell viewWithTag:14];
    paramName.text = param.value;
    UILabel *paramDesc = (UILabel *) [cell viewWithTag:15];
    paramDesc.text = param.description;
    return cell;
}

@end
