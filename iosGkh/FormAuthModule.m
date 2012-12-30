//
//  FormAuthModule.m
//  Pocket Gkh Portal
//
//  Created by Evgeniy Sorokin on 02.12.12.
//  Copyright (c) 2012 Prosoftlab. All rights reserved.
//

#import "FormAuthModule.h"
#import "ASIFormDataRequest.h"

@implementation FormAuthModule

+ (void) authenticateWithLogin:(NSString *)login andPassword:(NSString *)password {
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/gkh/jersey/j_security_check"];
    ASIFormDataRequest *formRequest = [ASIFormDataRequest requestWithURL:url];
    [formRequest setPostValue:login forKey:@"j_username"];
    [formRequest setPostValue:password forKey:@"j_password"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"no-cache,no-store,must-revalidate"
             forKey:@"Cache-Control"];
    [dict setObject:@"no-cache"
             forKey:@"Pragma"];
    [formRequest setRequestHeaders:dict];
    
    [formRequest startSynchronous];
    
    url = [NSURL URLWithString:@"http://localhost:8080/gkh/jersey/hello"];
    ASIHTTPRequest *newRequest = [ASIHTTPRequest requestWithURL:url];
    [newRequest startSynchronous];
    
    NSArray *cookies = [newRequest responseCookies];
    for (id cookie in cookies) {
        NSLog(@"cookie: %@", cookie);
    }
    
}

+ (void) requestFailed:(ASIFormDataRequest *) request {
    
}

+ (void) requestFinished:(ASIFormDataRequest *) request {
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/gkh/jersey/j_security_check"];
    ASIFormDataRequest *formRequest = [ASIFormDataRequest requestWithURL:url];
    [formRequest setPostValue:@"glava" forKey:@"j_username"];
    [formRequest setPostValue:@"123" forKey:@"j_password"];
    [formRequest setDelegate:self];
    [formRequest startAsynchronous];
    
    NSArray *cookies = [request responseCookies];
    for (id cookie in cookies) {
        NSLog(@"cookie: %@", cookie);
    }
    /*
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/gkh/jersey/hello"];
    ASIHTTPRequest *newRequest = [ASIHTTPRequest requestWithURL:url];
    [newRequest setDelegate:self];
    [newRequest startAsynchronous];
     */
}

@end
