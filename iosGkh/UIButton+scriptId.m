//
//  UIButton+scriptId.m
//  iosGkh
//
//  Created by Evgeniy Sorokin on 13.03.13.
//  Copyright (c) 2013 Prosoftlab. All rights reserved.
//

#import "UIButton+scriptId.h"
#import "Constants.h"
#import <objc/runtime.h>

@implementation UIButton (scriptId)
- (void) setParameterScriptId:(NSString *)scriptId {
    objc_setAssociatedObject(self, &ButtonToScriptMappingKey, scriptId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *) getParameterScriptId {
    NSString *result = objc_getAssociatedObject(self, &ButtonToScriptMappingKey);
    return result;
}

@end
