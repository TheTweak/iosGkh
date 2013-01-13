//
//  BasicAuthModule.h
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 02.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface BasicAuthModule : NSObject

+ (AFHTTPClient *) httpClient;

+ (void) authenticateWithLogin: (NSString *) login
                   andPassword: (NSString *) password;

+ (void) authenticateWithLogin:(NSString *) login
                   andPassword:(NSString *) password
                         byURL:(NSString *) url;

@end
