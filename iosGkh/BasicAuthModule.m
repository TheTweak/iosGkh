//
//  BasicAuthModule.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 02.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "BasicAuthModule.h"
#import "Dweller.h"
#import <AFNetworking.h>

@implementation BasicAuthModule

static AFHTTPClient *client;
// client with 'dweller' role
static AFHTTPClient *dwellerClient;
static NSString *role;
static BOOL isLoading;

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    NSString *serverAddress = [[NSUserDefaults standardUserDefaults] valueForKey:@"server_address"];
    if (!serverAddress) {
        serverAddress = @"http://192.168.1.6";
    }
    [self authenticateWithLogin:login andPassword:password byURL:[serverAddress stringByAppendingString:@":8081/jersey"]];
}

+ (void) authenticateWithLogin:(NSString *)login andPassword:(NSString *)password byURL:(NSString *)url {
    if (!isLoading) {
        isLoading = YES;
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoginLoadingMask" object:self];
            isLoading = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *errorDescription = [error localizedDescription];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationError"
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys: errorDescription, @"ErrorDescription", nil]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoginLoadingMask" object:self];
            isLoading = NO;
        }];
    }
}

// authorize as dweller and check FLS existence
+ (void) authenticateAsDweller:(NSString *)login
                      password:(NSString *)password
                      flsNomer:(NSString *)flsNomer {
    if (!isLoading) {
        NSURL *nsUrl = [NSURL URLWithString:@"http://localhost:8081/jersey/dweller"];
        dwellerClient = [AFHTTPClient clientWithBaseURL:nsUrl];
        [dwellerClient setAuthorizationHeaderWithUsername:login password:password];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:flsNomer, @"flsNomer", nil];
        [dwellerClient postPath:@"fls" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSData *responseData = (NSData *)responseObject;
            NSString *responseString = [[NSString alloc] initWithData:responseData
                                                             encoding:NSUTF8StringEncoding];
            if (responseData) {
                // fls id obtained, segue to counter table view
                [[Dweller class] setFls:responseString];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationSucceeded"
                                                                    object:self
                                                                  userInfo:@{@"Role": @"dweller"}];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoginLoadingMask" object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *errorDescription = [error localizedDescription];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationError"
                                                                object:self
                                                              userInfo:@{@"ErrorDescription": errorDescription}];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideLoginLoadingMask" object:self];
        }];
    }
}

@end
