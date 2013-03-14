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

@synthesize inputId = _inputId;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParamInputFieldTapped" object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.inputId, @"inputId",
                                                                self.pickerDescription, @"pickerDescription", nil]];
    return YES;
}

@end
