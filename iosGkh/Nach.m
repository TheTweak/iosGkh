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

@interface Nach ()
@property (nonatomic, strong) NSArray *graphValues;
@property (atomic) BOOL isLoading;
@property (nonatomic, strong) NSDictionary *dataToType;
@end

@implementation Nach

@synthesize graphValues = _graphValues;
@synthesize isLoading = _isLoading;
@synthesize dataToType = _dataToType;
@synthesize requestParams = _requestParams;
@synthesize paramId = _paramId;

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
        for (int i = 0, l = self.requestParams.count; i < l; i++) {
            NSDictionary *param = [self.requestParams objectAtIndex:i];
            NSString *paramName = [param valueForKey:@"id"];
            NSString *paramValue = [param valueForKey:@"value"];
            
            [requestParameters setValue:paramValue forKey:paramName];
        }
                
        [client postPath:@"param/value" parameters:requestParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"post succeeded");
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSDictionary *responseJson = [jsonParser objectWithString:responseString];
            NSArray *params = [responseJson objectForKey:@"values"];
            self.graphValues = params;
            for (int i = 0, l = [params count]; i < l; i++) {
                NSDictionary *jsonObject = [params objectAtIndex:i];
                NSLog(@"nach x : %@, y : %@", [jsonObject objectForKey:@"x"], [jsonObject objectForKey:@"y"]);
            }
            [plot reloadData];
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

- (CPTFill *) barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx {
//    if (idx % 2 == 0) {
        CPTColor *begin = [CPTColor colorWithComponentRed:0.74f green:0.259f blue:0.0f alpha:1.0f];
        CPTColor *end = [CPTColor colorWithComponentRed:1.0f green:0.5833f blue:0.0f alpha:1.0f];
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:begin endingColor:end];
    gradient.angle = 90.0f;
        return [CPTFill fillWithGradient:gradient];
//    } else {
//        return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:0.5667f blue:1.0f alpha:1.0f]];
//    }
}

- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
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
    
    if (CPTBarPlotFieldBarLocation == fieldEnum) {
        result = [jsonObject objectForKey:@"x"];
    } else if (CPTBarPlotFieldBarTip == fieldEnum) {
        result = [jsonObject objectForKey:@"y"];
    }
    return result;
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

@end
