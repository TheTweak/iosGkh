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

static AFHTTPClient* client;

+ (AFHTTPClient *) httpClient
{
    return client;
}

+ (void) authenticateWithLogin:(NSString *)login
                   andPassword:(NSString *)password {
    [self authenticateWithLogin:login andPassword:password byURL:@"http://localhost:8081/jersey"];
}

+ (void) authenticateWithLogin:(NSString *)login andPassword:(NSString *)password byURL:(NSString *)url {
    NSURL *nsUrl = [NSURL URLWithString:url];
    client = [AFHTTPClient clientWithBaseURL:nsUrl];
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
