//
//  CustomViewController.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 14.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomViewController : UIViewController
- (void) rightBarButtonHandler;
// row index, which input represented by CustomView
@property(nonatomic) NSNumber *tableRowIndex;
@end
