//
//  BasicAuthModule.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 02.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "BasicAuthModule.h"
#import <AFNetworking.h>

@implementation BasicAuthModule

+ (void) authenticateWithLogin:(NSString *)login
                   andPassword:(NSString *)password {
    [self authenticateWithLogin:login andPassword:password byURL:@"http://localhost:8081/gkh/jersey"];
}

+ (void) authenticateWithLogin:(NSString *)login andPassword:(NSString *)password byURL:(NSString *)url {
    NSURL *nsUrl = [NSURL URLWithString:url];
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:nsUrl];
    [client setAuthorizationHeaderWithUsername:login password:password];
    [client getPath:@"hello" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationSucceeded" object:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorDescription = [error localizedDescription];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationError"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys: errorDescription, @"ErrorDescription", nil]];
    }];
}

@end
