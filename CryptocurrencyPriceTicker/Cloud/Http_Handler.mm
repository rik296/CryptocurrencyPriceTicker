//
//  Http_Handler.m
//  Http_Handler
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 GOLiFE. All rights reserved.
//

#import "Http_Handler.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"

#define HTTP_TIMEOUT 60

NSString *const kNetworkStatusChange = @"NetworkStatusChange";

@interface NSDictionary (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;
@end

@implementation NSDictionary (BVJSONString)

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@interface NSArray (BVJSONString)
- (NSString *)bv_jsonStringWithPrettyPrint:(BOOL)prettyPrint;
@end

@implementation NSArray (BVJSONString)
-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end

@interface Http_Handler ()
{
    Reachability *internetReachable;
    ASIFormDataRequest *httpRequest;
    
    NSMutableString *apiServer;
    NSDictionary *urlVersion;
}
@end

@implementation Http_Handler

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        
        apiServer = [[NSMutableString alloc] initWithString:@"https://api.coinmarketcap.com/"];
        
        urlVersion = [[NSDictionary alloc]
                      initWithObjectsAndKeys:
                      @"v1/",@"v1",
                      nil];
    }
    
    return self;
}

+ (Http_Handler*)singleton
{
    static dispatch_once_t onceToken;
    static Http_Handler* instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[Http_Handler alloc] init];
    });
    return instance;
}

- (void)checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"[Cloud_Handler] The internet is down.");
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"[Cloud_Handler] The internet is working via WIFI.");
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"[Cloud_Handler] The internet is working via WWAN.");
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkStatusChange object:nil userInfo:nil];
}

- (NetworkStatus)currentNetworkStatus
{
    return [internetReachable currentReachabilityStatus];
}

- (NSString*)destinationURL:(NSInteger)apiType andUserInfo:(NSDictionary*)userInfo
{
    switch (apiType)
    {
        case E_API_GET_TICKER:
        {
            //?start=0&limit=100
            NSString *parameterString = [NSString stringWithFormat:@"?start=%@&limit=%@", [userInfo objectForKey:@"start"], [userInfo objectForKey:@"limit"]];
            return [apiServer stringByAppendingString:[NSString stringWithFormat:@"%@ticker/%@", [urlVersion objectForKey:@"v1"], parameterString]];
        }
            break;
            
        case E_API_GET_TICKER_SPECIFIC:
        {
            NSString *coinID = [userInfo objectForKey:@"coinID"];
            if ([userInfo objectForKey:@"convert"] != nil)
            {
                NSString *parameterString = [NSString stringWithFormat:@"?convert=%@", [userInfo objectForKey:@"convert"]];
                return [apiServer stringByAppendingString:[NSString stringWithFormat:@"%@ticker/%@/%@", [urlVersion objectForKey:@"v1"], coinID, parameterString]];
            }
            else
            {
                return [apiServer stringByAppendingString:[NSString stringWithFormat:@"%@ticker/%@", [urlVersion objectForKey:@"v1"], coinID]];
            }
        }
            break;
            
        case E_API_GET_GLOBAL_DATA:
        {
            return [apiServer stringByAppendingString:[NSString stringWithFormat:@"%@global/", [urlVersion objectForKey:@"v1"]]];
        }
            break;
            
        default:
            return @"";
            break;
    }
}

#pragma mark -
#pragma mark Http Request & Response

- (void)sendCloudHttpRequest:(HttpCompletionHandler)completionHandler andJSON:(id)json andUserInfo:(NSDictionary*)userInfo
{
    self.completionHandler = completionHandler;
    
    if ([self currentNetworkStatus] == NotReachable)
    {
        self.completionHandler(E_HTTP_RESULT_NETWORK_NOT_ENABLE, @"Network is not enable");
        return;
    }
    
    NSInteger apiType = [[userInfo objectForKey:@"apiType"] integerValue];
    NSString *method = [userInfo objectForKey:@"method"];
    NSString *strURL = [self destinationURL:apiType andUserInfo:userInfo];
    NSLog(@"URL : %@", strURL);
        
    [httpRequest clearDelegatesAndCancel];
    httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:strURL]];
    [httpRequest setValidatesSecureCertificate:NO];
    [httpRequest setUseCookiePersistence:NO];
    [httpRequest setTimeOutSeconds:HTTP_TIMEOUT];
    [httpRequest setDelegate:self];
    [httpRequest setDidFailSelector:@selector(sendCloudHttpRequestFailed:)];
    [httpRequest setDidFinishSelector:@selector(sendCloudHttpRequestFinished:)];
    [httpRequest addRequestHeader:@"Content-Type" value:@"text/json"];
    
    if ([method isEqualToString:@"GET"])
    {
        [httpRequest setRequestMethod:@"GET"];
    }
    else if ([method isEqualToString:@"POST"])
    {
        [httpRequest setRequestMethod:@"POST"];
    }
    else if ([method isEqualToString:@"PUT"])
    {
        [httpRequest setRequestMethod:@"PUT"];
    }
    else if ([method isEqualToString:@"DELETE"])
    {
        [httpRequest setRequestMethod:@"DELETE"];
        [httpRequest buildPostBody];
    }
    
    if (json != nil)
    {
        NSData *payloadData = [[json bv_jsonStringWithPrettyPrint:NO] dataUsingEncoding:NSUTF8StringEncoding];
        [httpRequest appendPostData:payloadData];
        NSLog(@"JSON : %@", [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding]);
    }
    
    [httpRequest startAsynchronous];
}

- (void)sendCloudHttpRequestFailed:(ASIHTTPRequest *)theRequest
{
    NSInteger statusCode = [httpRequest responseStatusCode];
    self.completionHandler((E_HTTP_RESULT)statusCode, [self showStatusLog]);
}

- (void)sendCloudHttpRequestFinished:(ASIHTTPRequest *)theRequest
{
    NSInteger statusCode = [httpRequest responseStatusCode];
    NSString *receiveMessage = [httpRequest responseString];
    
    NSData *jsonData = [receiveMessage dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id responseJSON = nil;
    if (jsonData)
    {
        responseJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    }
    else
    {
        self.completionHandler(E_HTTP_RESULT_CONNECTION_ERROR, @"JSON 解析錯誤");
    }
    
    if (responseJSON == nil)
    {
        responseJSON = receiveMessage;
    }
    [self showStatusLog];
    NSLog(@"result:%@", responseJSON);
    
    self.completionHandler((E_HTTP_RESULT)statusCode, responseJSON);
}

#pragma mark -
#pragma mark Log

- (NSDictionary*)showStatusLog
{
    NSString *strURL = [[httpRequest url] absoluteString];
    NSString *receivedString = [httpRequest responseString];
    NSInteger statusCode = [httpRequest responseStatusCode];
    NSString *statusMessage = [httpRequest responseStatusMessage];
    NSString *strRequestMethod = [httpRequest requestMethod];
    NSDictionary *headerDict = [httpRequest responseHeaders];
    NSString *error = [[httpRequest error] localizedDescription];
    
    NSMutableDictionary *reasonDict = [NSMutableDictionary dictionary];
    [reasonDict setValue:strURL forKey:@"URL"];
    [reasonDict setValue:@(statusCode) forKey:@"statusCode"];
    [reasonDict setValue:statusMessage forKey:@"statusMessage"];
    [reasonDict setValue:strRequestMethod forKey:@"method"];
    [reasonDict setValue:receivedString forKey:@"receivedString"];
    [reasonDict setValue:headerDict forKey:@"responseHeader"];
    [reasonDict setValue:error forKey:@"error"];
    
    NSLog(@"[Http_Handler] {");
    NSLog(@"URL = %@", strURL);
    NSLog(@"statusCode = %ld", (long)statusCode);
    NSLog(@"statusMessage = %@", statusMessage);
    NSLog(@"method = %@", strRequestMethod);
    
    if (statusCode != 200)
    {
        NSLog(@"receivedString = %@", receivedString);
        NSLog(@"header = %@", headerDict);
        NSLog(@"error = %@", error);
    }
    NSLog(@"}");
    
    return reasonDict;
}

@end
