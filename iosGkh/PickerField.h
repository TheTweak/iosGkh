//
//  PickerField.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 13.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerField : UITextField
@property(nonatomic, strong) NSString *inputId;
@property(nonatomic, strong) NSString *pickerDescription;
// selected value's identity
@property(nonatomic, strong) NSString *pickedValueId;
@end
