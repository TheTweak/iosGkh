//
//  Nach.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 23.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "Nach.h"
#import "CorePlot-CocoaTouch.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "HomeTableDataSource.h"
#import "CorePlotUtils.h"

@interface Nach ()
@property (nonatomic, strong) NSArray *graphValues;
@property (nonatomic, strong) NSArray *tableValues;
@property (atomic) BOOL isLoading;
@property (nonatomic, strong) NSDictionary *metaInfo;
@property NSDecimalNumber *maxHeight;
@end

@implementation Nach

@synthesize graphValues = _graphValues;
@synthesize tableValues = _tableValues;
@synthesize isLoading = _isLoading;
@synthesize metaInfo = _metaInfo;
@synthesize requestParams = _requestParams;
@synthesize paramId = _paramId;
@synthesize homeTableDS = _homeTableDS;
@synthesize tableNeedsReloading = _tableNeedsReloading;

- (BOOL) axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations {
    axis.axisTitle = [[CPTAxisTitle alloc] initWithText:@"Период" textStyle:[CPTTextStyle textStyle]];
    return YES;
}

- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([@"flsCount" isEqualToString:self.paramId]) {
        NSLog(@"flsCount numberOfRecords()");
        return 4; // todo remove this stub
    }        
    // Todo : invoked 4 times for some reason
    NSUInteger numberOfRecords = 0;
    numberOfRecords = [self.graphValues count];
    if (!self.isLoading) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoadingMask" object:self];
        self.isLoading = YES; // very bad
        AFHTTPClient *client = [BasicAuthModule httpClient];

        NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
        // necessary request param, unique identifier of requesting data
        [requestParameters setValue:self.paramId forKey:@"type"];
        
        // other, param-dependent parameters
        NSEnumerator *enumerator = [self.requestParams keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            NSDictionary *param = [self.requestParams valueForKey:key];
            NSString *paramValue = [param valueForKey:@"value"];
            [requestParameters setValue:paramValue forKey:key];
        }
                
        [client postPath:@"param/value" parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"post succeeded");
            
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *responseJson = [jsonParser objectWithString:responseString];
            if ([responseJson valueForKey:@"scope"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowScopeLabel" object:self userInfo:[NSDictionary dictionaryWithObject:[responseJson valueForKey:@"scope"] forKey:@"scopeLabel"]];
            }
            NSArray *params = [responseJson objectForKey:@"values"];
            self.graphValues = params;
            NSDecimalNumber *maxH = [NSDecimalNumber zero];
            NSDecimalNumber *maxH2 = [NSDecimalNumber zero];
            for (int i = 0, l = [params count]; i < l; i++) {
                NSDictionary *jsonObject = [params objectAtIndex:i];
                NSDecimalNumber *y = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y"]];
                NSComparisonResult compare = [maxH compare:y];
                if (compare == NSOrderedAscending) maxH = y;
                NSDecimalNumber *y2 = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y2"]];
                NSComparisonResult compare2 = [maxH2 compare:y2];
                if (compare2 == NSOrderedAscending) maxH2 = y2;
                NSLog(@"nach x : %@, y : %@", [jsonObject objectForKey:@"x"], y);
            }
            NSComparisonResult compare = [maxH compare:[NSDecimalNumber zero]];
            if (compare != NSOrderedSame) {
                self.maxHeight = maxH;
            } else {
                compare = [maxH2 compare:[NSDecimalNumber zero]];
                if (compare != NSOrderedSame) {
                    self.maxHeight = maxH2;
                }
            }

            if (!self.maxHeight) {
                self.maxHeight = [NSDecimalNumber decimalNumberWithString:@"1"];
            }
            [plot.graph reloadData];
            self.isLoading = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingMask" object:self];
            NSLog(@"success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.isLoading = NO;
            self.graphValues = [NSArray array];
            NSLog(@"failure");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingMask" object:self];
        }];
    } else {
        numberOfRecords = [self.graphValues count];
    }
    NSLog(@"number of records=%d", numberOfRecords);
    return numberOfRecords;
}

#pragma mark <UITableViewDataSource> routine:

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRecords = [self.tableValues count];
    if (self.tableNeedsReloading) {
        if (!self.isLoading) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLoadingMask" object:self];
            self.isLoading = YES; // very bad
            AFHTTPClient *client = [BasicAuthModule httpClient];
            
            NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
            // necessary request param, unique identifier of requesting data
            [requestParameters setValue:self.paramId forKey:@"type"];
            
            [client postPath:@"param/value" parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"post succeeded");
                
                SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                NSData *responseData = (NSData *)responseObject;
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSDictionary *responseJson = [jsonParser objectWithString:responseString];
                NSArray *params = [responseJson objectForKey:@"values"];
                self.tableValues = params;
                [tableView reloadData];
                self.isLoading = NO;
                self.tableNeedsReloading = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingMask" object:self];
                NSLog(@"success");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                self.isLoading = NO;
                NSLog(@"failure");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoadingMask" object:self];
            }];
        }
    }
    return numberOfRecords;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    UILabel *accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 40)];
    accessoryLabel.textColor = [UIColor greenColor];
    accessoryLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    accessoryLabel.shadowColor = [UIColor darkGrayColor];
    accessoryLabel.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    NSDictionary *jsonObject = [self.tableValues objectAtIndex:indexPath.row];
    NSString *percent = [jsonObject valueForKey:@"percent"];
    accessoryLabel.text = [percent stringByAppendingString:@"%"];
    cell.accessoryView = accessoryLabel;
    
    NSString *kladr = [jsonObject objectForKey:@"scope"];
    NSNumberFormatter *formatter = [CorePlotUtils thousandsSeparator];
    NSDecimalNumber *pay = [NSDecimalNumber decimalNumberWithString:[jsonObject valueForKey:@"pay"]];
    NSString *payFormatted = [formatter stringFromNumber:pay];
    
    NSDecimalNumber *nach = [NSDecimalNumber decimalNumberWithString:[jsonObject valueForKey:@"nach"]];
    NSString *nachFormatted = [formatter stringFromNumber:nach];
    
    CGRect contentRect = CGRectMake(5, 7, cell.frame.size.width - 44, 15);
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:contentRect];
    contentLabel.text = kladr;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.shadowColor = [UIColor darkGrayColor];
    contentLabel.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    contentLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        
    CGRect bottomLeftRect = CGRectMake(5, 22, contentRect.size.width / 3, 15);
    UILabel *bottomLeft = [[UILabel alloc] initWithFrame:bottomLeftRect];
    NSMutableString *payed = [NSMutableString string];
    [payed appendString:payFormatted];
    [payed appendString:@" р."];
    bottomLeft.text = payed;
    bottomLeft.textColor = [UIColor greenColor];
    bottomLeft.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    bottomLeft.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    
    [cell.contentView addSubview:bottomLeft];
    
    CGRect bottomRightRect = CGRectMake(bottomLeftRect.size.width, 22,
                                        bottomLeftRect.size.width,
                                        bottomLeftRect.size.height);
    UILabel *bottomRight = [[UILabel alloc] initWithFrame:bottomRightRect];
    NSMutableString *nachis = [NSMutableString string];
    [nachis appendString:nachFormatted];
    [nachis appendString:@" р."];
    bottomRight.text = nachis;
    bottomRight.textColor = [UIColor colorWithRed:0 green:.3943 blue:.91 alpha:1];
    bottomRight.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    bottomRight.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    
    [cell.contentView addSubview:bottomRight];
    
    [cell.contentView addSubview:contentLabel];

    return cell;
}

#pragma mark <BarPlotDataSource> routine:

- (CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx {
    CPTGradient *gradient;
    CPTColor *begin = [CPTColor colorWithComponentRed:0 green:.3943 blue:.91 alpha:1];
    CPTColor *end = [CPTColor colorWithComponentRed:0 green:.3943 blue:.91 alpha:.34];
    if ([@"sec" isEqualToString:barPlot.title]) {
        CPTColor *begin = [CPTColor colorWithComponentRed:0.4023 green:0.71 blue:0 alpha:1];
        CPTColor *end = [CPTColor colorWithComponentRed:0.6793 green:1.0 blue:0.26 alpha:1];
        gradient = [CPTGradient gradientWithBeginningColor:begin
                                               endingColor:end];
    } else {
        gradient = [CPTGradient gradientWithBeginningColor:begin endingColor:end];
    }
    gradient.angle = 90.0f;
    return [CPTFill fillWithGradient:gradient];
}

- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    // load meta-info once
    if (!self.metaInfo) {
        self.metaInfo = [self.homeTableDS customPropertiesAtRowIndex:idx];
    }
    
    // todo remove this stub (Pie Chart)
    if ([@"flsCount" isEqualToString:plot.title]) {
        int result = 0;
        if (CPTPieChartFieldSliceWidth == fieldEnum) {
            switch (idx) {
                case 0:
                    result = 2;
                    break;
                case 1:
                    result = 4;
                    break;
                case 2:
                    result = 3;
                    break;
                case 3:
                    result = 6;
                default:
                    break;
            }
        }
        return [NSNumber numberWithInt:result];
    }
        
    NSDictionary *jsonObject = [self.graphValues objectAtIndex:idx];
    NSNumber *result;
    
    if ([plot isKindOfClass:[CPTScatterPlot class]]) {
        if (CPTScatterPlotFieldX == fieldEnum) {            
            result = [jsonObject objectForKey:@"x"];
        } else if (CPTScatterPlotFieldY == fieldEnum) {
            result = [jsonObject objectForKey:@"y"];
        }
    } else if ([plot isKindOfClass:[CPTBarPlot class]]) {
        // get key for X, Y values
        /*NSString *xKey = [self.metaInfo valueForKey:@"x"];
        NSString *yKey = [self.metaInfo valueForKey:@"y"];
        NSString *y2Key = [self.metaInfo valueForKey:@"y2"];*/
        NSNumber *width = [jsonObject objectForKey:@"width"];
        ((CPTBarPlot *)plot).barWidth = [width decimalValue];
        if (CPTBarPlotFieldBarLocation == fieldEnum) {
            result = [jsonObject objectForKey:@"x"];
            /*double offset = width / 2;
            offset = offset + [result doubleValue] + 0.2;
            result = [NSNumber numberWithDouble:offset];*/
            result = [NSNumber numberWithDouble:[result doubleValue]];
        } else if (CPTBarPlotFieldBarTip == fieldEnum) {
            NSDecimalNumber *y;
            if ([@"sec" isEqualToString:plot.title]) {
                y = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y2"]];
            } else {
                y = [NSDecimalNumber decimalNumberWithString:[jsonObject objectForKey:@"y"]];
            }
            result = [y decimalNumberByDividingBy:self.maxHeight];
        }
    }
    
    return result;
}

- (NSDictionary *)getBusinessValues:(NSUInteger)idx {
    if (self.graphValues) {
        return (NSDictionary *) [self.graphValues objectAtIndex:idx];
    }
    return nil;
}

#pragma mark Pie chart

- (CPTFill *) sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx {
    CPTColor *color;
    switch (idx) {
        case 0:
        {
            color = [CPTColor colorWithComponentRed:0.0f green:0.6917f blue:0.83f alpha:1.0f]; //sky
            break;
        }
        case 1:
        {
            color = [CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.2167f alpha:1.0f]; //red
            break;
        }
        case 2:
        {
            color = [CPTColor colorWithComponentRed:0.0f green:0.83f blue:0.2075f alpha:1.0f]; //green
            break;
        }
        case 3:
        {
            color = [CPTColor colorWithComponentRed:1.0f green:0.5833f blue:0.0f alpha:1.0f]; //orange
            break;
        }
        default:
            color = [CPTColor whiteColor];
            break;
    }
    return [CPTFill fillWithColor:color];
}

- (NSString *) legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx {
    NSString *result;
    switch (idx) {
        case 0:
            result = @"д.1";
            break;
        case 1:
            result = @"д.2";
            break;
        case 2:
            result = @"д.3";
            break;
        case 3:
            result = @"д.4";
            break;
        default:
            break;
    }
    return result;
}

- (CPTLayer *) dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx {
    if ([plot isKindOfClass:[CPTScatterPlot class]]) return nil;
    if ([plot isKindOfClass:[CPTBarPlot class]]) return nil;
    if ([@"nach" isEqualToString:plot.title]) return nil;
    CPTLayer *result;
    //int sum = 15;
    int price = 0;
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor whiteColor];
        labelText.fontSize = 13.0f;
    }
    price = [[self numberForPlot:plot field:CPTPieChartFieldSliceWidth recordIndex:idx] intValue];
    //float percent = ((float)price / (float)sum);
    // 4 - Set up display label
    //    NSString *labelValue = [NSString stringWithFormat:@"%0.0f %%", percent * 100.0f];
    NSString *labelValue = [NSString stringWithFormat:@"%d", price];
    // 5 - Create and return layer with label text
    result = [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
    return result;
}

#pragma mark XY plot

- (CPTPlotSymbol *) symbolForScatterPlot:(CPTScatterPlot *)plot
                             recordIndex:(NSUInteger)idx {
    return nil;
}

@end
