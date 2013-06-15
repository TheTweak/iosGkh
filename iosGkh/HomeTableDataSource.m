//
//  HomeTableDataSource.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 07.01.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "HomeTableDataSource.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "Constants.h"

@interface HomeTableDataSource ()
// Массив отчетов которые грузятся в таблицу
@property (nonatomic, strong) NSMutableArray* reportArray;
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation HomeTableDataSource

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (GkhReport *) gkhReportAt:(NSUInteger)index {
    GkhReport *report;
    if (self.reportArray) {
        report = [self.reportArray objectAtIndex:index];
    }
    return report;
}

-(void)setValue:(id)value forInputParam:(NSString *)paramId atIndex:(NSUInteger)index {
    GkhReport *report = [self.reportArray objectAtIndex:index];
    GkhInputType *inputParam = [report getInputParam:paramId];
    inputParam.value = [value copy];
}

#pragma mark UITableViewDataSource delegate

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ReportCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GkhReport *report = [self.reportArray objectAtIndex:indexPath.row];
    UILabel *reportName = (UILabel *)[cell viewWithTag:14];
    reportName.text = report.name;
    UILabel *reportDesc = (UILabel *) [cell viewWithTag:15];
    reportDesc.text = report.description;
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView = tableView;
    #warning Delete! only for dev purpose
    //[BasicAuthModule authenticateWithLogin:@"glava" andPassword:@"1234"];
    #warning end
    if (!self.reportArray) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTableLoadingMask" object:self];
        AFHTTPClient *client = [BasicAuthModule httpClient];
        [client getPath:@"param/list" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTableLoadingMask" object:self];
            NSLog(@"success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideTableLoadingMask" object:self];
            NSLog(@"failure");
        }];
    }
    
    return [self.reportArray count];
}

@end
