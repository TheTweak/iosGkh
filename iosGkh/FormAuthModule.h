//
//  FormAuthModule.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 02.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormAuthModule : NSObject
+ (void) authenticateWithLogin: (NSString *) login
                   andPassword: (NSString *) password;
@end
