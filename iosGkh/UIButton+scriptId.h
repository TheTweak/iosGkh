//
//  UIButton+scriptId.h
//  iosGkh
//
//  Created by Evgeniy Sorokin on 13.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (scriptId)
- (void) setParameterScriptId: (NSString *) scriptId;
- (NSString *) getParameterScriptId;
@end
