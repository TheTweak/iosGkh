//
//  CustomView.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 11.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "CustomView.h"
#import "ActionSheetStringPicker.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"
#import "UIButton+scriptId.h"

@implementation CustomView

- (id)initWithFrame:(CGRect)frame
             inputs:(NSArray *)inputsArray {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        for (int i = 0, l = [inputsArray count]; i < l; i++) {
            NSDictionary *inputMetaData = [inputsArray objectAtIndex:i];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            button.frame = CGRectMake(0, i * 50, 220, 44);
            
            NSString *inputDescription = [inputMetaData valueForKey:@"description"];
            NSString *paramId = [inputMetaData valueForKey:@"id"];
            [button setParameterScriptId:paramId];
            [button setTitle:inputDescription forState:UIControlStateNormal];
            [button addTarget:self
                       action:@selector(buttonPressed:)
             forControlEvents:UIControlEventTouchDown];
            [self addSubview:button];
        }
    }
    return self;
}

- (void) buttonPressed:(id) button {
    NSLog(@"pressed");
    AFHTTPClient *client = [BasicAuthModule httpClient];
    NSString *paramId = [button getParameterScriptId];
    NSDictionary *requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:paramId, @"type", nil];
    [client postPath:@"param/value" parameters:requestParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"post succeeded");
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSArray *responseJson = [jsonParser objectWithString:responseString];
        NSMutableArray *comboDataArray = [NSMutableArray array];
        for(int i = 0, l = [responseJson count]; i < l; i++) {
            NSDictionary *jsonObject = [responseJson objectAtIndex:i];
            NSString *name = [jsonObject valueForKey:@"name"];
            [comboDataArray insertObject:name atIndex:i];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@"Период"
                                                rows:comboDataArray
                                    initialSelection:nil
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSDictionary *selectedJson = [responseJson objectAtIndex:selectedIndex];
                                               NSLog(@"selected: %@", selectedJson);
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"cancel");
                                         }
                                              origin:self];
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
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
