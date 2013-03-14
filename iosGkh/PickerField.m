//
//  PickerField.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 13.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "PickerField.h"
#import "ActionSheetStringPicker.h"
#import "BasicAuthModule.h"
#import "SBJsonParser.h"

@implementation PickerField

@synthesize scriptId = _scriptId;
@synthesize pickerDescription = _pickerDescription;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.font = [UIFont systemFontOfSize:15];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeyDone;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL) becomeFirstResponder {
    NSLog(@"tapped text field");
    AFHTTPClient *client = [BasicAuthModule httpClient];
    NSString *paramId = self.scriptId;
    if (!paramId) return NO;
    #warning TODO : loading mask
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
        
        [ActionSheetStringPicker showPickerWithTitle:self.pickerDescription
                                                rows:comboDataArray
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               NSDictionary *selectedJson = [responseJson objectAtIndex:selectedIndex];
                                               self.text = [selectedJson valueForKey:@"name"];
                                               NSLog(@"selected: %@", selectedJson);
                                           }
                                         cancelBlock:^(ActionSheetStringPicker *picker) {
                                             NSLog(@"cancel");
                                         }
                                              origin:self.superview];
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
    return YES;
}

@end
