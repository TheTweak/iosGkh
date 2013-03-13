//
//  CustomView.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 11.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomView : UIView
- (void) buttonPressed:(id) button;
- (id) initWithFrame:(CGRect)frame
              inputs:(NSArray *)inputsArray;
@end
