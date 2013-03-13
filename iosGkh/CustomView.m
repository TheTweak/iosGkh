//
//  CustomView.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 11.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CustomView.h"
#import "ActionSheetStringPicker.h"

@implementation CustomView

- (id)initWithFrame:(CGRect)frame
             inputs:(NSArray *)inputsArray {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        for (int i = 0, l = [inputsArray count]; i < l; i++) {
            NSDictionary *inputMetaData = [inputsArray objectAtIndex:i];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(0, 0, 220, 44);
            
            NSString *inputDescription = [inputMetaData valueForKey:@"description"];
            [button setTitle:inputDescription forState:UIControlStateNormal];
            [button addTarget:self
                       action:@selector(buttonPressed)
             forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
        }
    }
    return self;
}

- (void) buttonPressed {
    NSLog(@"pressed");
    NSArray *array = [NSArray arrayWithObjects:@"01.2012", @"02.2012", @"03.2012", @"04.2012", nil];
    [ActionSheetStringPicker showPickerWithTitle:@"Период"
                                            rows:array
                                initialSelection:nil
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"done");
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"cancel");
                                     }
                                          origin:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
