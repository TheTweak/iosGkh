//
//  DateYearPicker.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 14.05.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "DateYearPicker.h"
#import "CorePlotUtils.h"

@interface DateYearPicker ()
@property (nonatomic) NSArray *years;
@end

@implementation DateYearPicker

@synthesize years = _years;

-(NSArray *)years {
    if (!_years) {
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps =
        [gregorian components:NSYearCalendarUnit fromDate:today];
        NSInteger currentYear = comps.year;
        NSInteger prevYear = currentYear - 1;
        NSInteger nextYear = currentYear + 1;
        NSString *current = [NSString stringWithFormat:@"%i", currentYear];
        NSString *prev = [NSString stringWithFormat:@"%i", prevYear];
        NSString *next = [NSString stringWithFormat:@"%i", nextYear];
        _years = [NSArray arrayWithObjects:prev, current, next, nil];
    }
    return _years;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.delegate = self;
    self.dataSource = self;
    return self;
}

#pragma mark <UIDatePickerDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self) {
        return 2;
    }
    return 0;
}

// 0 - month, 1 - year
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 12;
        case 1:
            return 3;
    }
    return 0;
}

#pragma mark <UIDatePickerDatasource>

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    // 0 - month, 1 - year
    if (pickerView == self) {
        switch (component) {
            case 0:
                return 120.0;
            case 1:
                return 80.0;
        }
    }
    return 0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44.0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component {
    NSString *result;
    if (pickerView == self) {
        switch (component) {
            // month
            case 0:
                result = [[[CorePlotUtils class] monthsArray] objectAtIndex:row];
                break;
            // year
            case 1:
                result = [self.years objectAtIndex:row];
                break;
            default:
                break;
        }
    }
    return result;
}

@end
