//
//  CustomView.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 11.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CustomView.h"
#import "PickerField.h"

@implementation CustomView

- (id)initWithFrame:(CGRect)frame
             inputs:(NSArray *)inputsArray {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        for (int i = 0, l = [inputsArray count]; i < l; i++) {
            NSDictionary *inputMetaData = [inputsArray objectAtIndex:i];
            NSString *inputDescription = [inputMetaData valueForKey:@"description"];
            NSString *paramId = [inputMetaData valueForKey:@"id"];
            PickerField *textField = [[PickerField alloc] initWithFrame:CGRectMake(20, i * 50, 220, 44)];
            textField.inputId = paramId;
            textField.placeholder = inputDescription;
            textField.pickerDescription = inputDescription;
            [self addSubview:textField];
        }
    }
    return self;
}

@end
