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
             inputs:(NSDictionary *)inputs {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        NSEnumerator *enumerator = [inputs keyEnumerator];
        id key;
        int i = 0;
        while ((key = [enumerator nextObject])) {
            NSDictionary *inputMetaData = [inputs valueForKey:key];
            NSString *inputDescription = [inputMetaData valueForKey:@"description"];
            float width = self.frame.size.width
                 ,height = 44
                 ,padding = 25;
            CGRect rectangle = CGRectMake(padding, i * 55 + 10, width - 2 * padding, height);
            PickerField *textField = [[PickerField alloc] initWithFrame:rectangle];
            textField.inputId = (NSString *) key;
            textField.placeholder = inputDescription;
            textField.pickerDescription = inputDescription;
            [self addSubview:textField];
            i++;
        }        
    }
    return self;
}

@end
