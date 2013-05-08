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

static AFHTTPClient *client;
// client with 'dweller' role
static AFHTTPClient *dwellerClient;
static NSString *role;

+ (AFHTTPClient *) httpClient
{
    return client;
}

+ (AFHTTPClient *) dwellerHttpClient {
    return dwellerClient;
}

+ (NSString *) role
{
    return role;
}

+ (void) authenticateWithLogin:(NSString *)login
                   andPassword:(NSString *)password {
    [self authenticateWithLogin:login andPassword:password byURL:@"http://localhost:8081/jersey"];
}

+ (void) authenticateWithLogin:(NSString *)login andPassword:(NSString *)password byURL:(NSString *)url {
    NSURL *nsUrl = [NSURL URLWithString:url];
    client = [AFHTTPClient clientWithBaseURL:nsUrl];
    [client setAuthorizationHeaderWithUsername:login password:password];
    [client getPath:@"auth" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *responseData = (NSData *)responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        role = responseString;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationSucceeded"
                                                            object:self
                                                            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:role, @"Role", nil]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorDescription = [error localizedDescription];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationError"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys: errorDescription, @"ErrorDescription", nil]];
    }];
}

// authorize as dweller and check FLS existence
+ (void) authenticateAsDweller:(NSString *)login
                      password:(NSString *)password
                      flsNomer:(NSString *)flsNomer
                       success:(void (^)(AFHTTPRequestOperation *, id))success
                       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSURL *nsUrl = [NSURL URLWithString:@"http://localhost:8081/jersey/dweller"];
    dwellerClient = [AFHTTPClient clientWithBaseURL:nsUrl];
    [dwellerClient setAuthorizationHeaderWithUsername:login password:password];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:flsNomer, @"flsNomer", nil];
    [dwellerClient postPath:@"fls" parameters:params success:success failure:failure];
}

@end
