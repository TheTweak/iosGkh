//
//  BasicAuthModule.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 02.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "BasicAuthModule.h"
#import "ASIHTTPRequest.h"

@interface BasicAuthModule ()
+ (void) requestFinished:(ASIHTTPRequest *)request;
+ (void) requestFailed:(ASIHTTPRequest *)request;
@end

@implementation BasicAuthModule

+ (void) authenticateWithLogin:(NSString *)login
                   andPassword:(NSString *)password {
    [self authenticateWithLogin:login andPassword:password byURL:@"http://localhost:8080/gkh/jersey/hello"];
}

+ (void) authenticateWithLogin:(NSString *)login andPassword:(NSString *)password byURL:(NSString *)url {
    NSURL *nsUrl = [NSURL URLWithString:url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:nsUrl];
    [request setUsername:login];
    [request setPassword:password];
    [request setDelegate:self];
    [request startAsynchronous];
}

+ (void) requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSString *errorDescription = [error localizedDescription];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationError"
                                                         object:self
                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys: errorDescription, @"ErrorDescription", nil]];
}

+ (void) requestFinished:(ASIHTTPRequest *)request {
    int statusCode = [request responseStatusCode];
    if (statusCode == 404) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationError"
                                                            object:self
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"404: Not found.", @"ErrorDescription", nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationSucceeded" object:self];
    }
}

@end
