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

@interface Nach ()
@property (nonatomic, strong) NSArray *graphValues;
@property (atomic) BOOL isLoading;
@end

@implementation Nach

@synthesize graphValues = _graphValues;
@synthesize isLoading =   _isLoading;

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    axis.axisTitle = [[CPTAxisTitle alloc] initWithText:@"Период" textStyle:[CPTTextStyle textStyle]];
    return YES;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    // Todo : invoked 4 times for some reason
    NSUInteger numberOfRecords = 0;
    if (!self.isLoading) {
        self.isLoading = YES; // very bad
        AFHTTPClient *client = [BasicAuthModule httpClient];
        NSDictionary *requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:@"nach", @"type", nil];
        [client postPath:@"param/value" parameters:requestParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
            NSLog(@"success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.isLoading = NO;
            self.graphValues = [NSArray array];
            NSLog(@"failure");
        }];
    } else {
        numberOfRecords = [self.graphValues count];
    }
    NSLog(@"number of records=%d", numberOfRecords);
    return numberOfRecords;
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
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

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSDictionary *jsonObject = [self.graphValues objectAtIndex:idx];
    NSNumber *result;
    
    if (CPTBarPlotFieldBarLocation == fieldEnum) {
        result = [jsonObject objectForKey:@"x"];
    } else if (CPTBarPlotFieldBarTip == fieldEnum) {
        result = [jsonObject objectForKey:@"y"];
    }
    /*
    if (CPTBarPlotFieldBarLocation == fieldEnum) {
        float distance = 0.2f;
        switch (idx) {
            case 0:
                result = [NSNumber numberWithFloat:0.0f + distance];
                break;
            case 1:
                result = [NSNumber numberWithFloat:0.3f + distance];
                break;
            case 2:
                result = [NSNumber numberWithFloat:0.6f + distance];
                break;
            case 3:
                result = [NSNumber numberWithFloat:0.9f + distance];
                break;
            case 4:
                result = [NSNumber numberWithFloat:1.2f + distance];
                break;
            case 5:
                result = [NSNumber numberWithFloat:1.5f + distance];
                break;
            case 6:
                result = [NSNumber numberWithFloat:1.8f + distance];
                break;
            case 7:
                result = [NSNumber numberWithFloat:2.1f + distance];
                break;
            case 8:
                result = [NSNumber numberWithFloat:2.4f + distance];
                break;
            case 9:
                result = [NSNumber numberWithFloat:2.7f + distance];
                break;
            case 10:
                result = [NSNumber numberWithFloat:3.0f + distance];
                break;
            case 11:
                result = [NSNumber numberWithFloat:3.3f + distance];
                break;
            default:
                break;
        }
    } else if (CPTBarPlotFieldBarTip == fieldEnum) {
        int val;
        switch (idx) {
            case 0:
                val = 9;
                break;
            case 1:
                val = 15;
                break;
            case 2:
                val = 17;
                break;
            case 3:
                val = 8;
                break;
            case 4:
                val = 10;
                break;
            case 5:
                val = 16;
                break;
            case 6:
                val = 6;
                break;
            case 7:
                val = 1;
                break;
            case 8:
                val = 3;
                break;
            case 9:
                val = 19;
                break;
            case 10:
                val = 11;
                break;
            case 11:
                val = 14;
            default:
                break;
        }
        result = [NSNumber numberWithInt:val];
    }*/
    return result;
}

@end
