//
//  Http_Handler.h
//  Http_Handler
//
//  Created by Rik Tsai on 2018/4/14.
//  Copyright © 2018年 Rik Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"

extern NSString *const kNetworkStatusChange;

typedef NS_ENUM(NSUInteger, E_API) {
    E_API_GET_TICKER = 0,
    E_API_GET_TICKER_SPECIFIC,
    E_API_GET_GLOBAL_DATA
};

typedef NS_ENUM(NSUInteger, E_HTTP_RESULT)
{
    E_HTTP_RESULT_NO_STATUS_CODE = 0,
    E_HTTP_RESULT_OK = 200,
    E_HTTP_RESULT_BAD_REQUEST = 400,
    E_HTTP_RESULT_UNAUTHORIZED = 401,
    E_HTTP_RESULT_FORBIDDEN = 403,
    E_HTTP_RESULT_NOT_FOUND = 404,
    E_HTTP_RESULT_CONFLICT = 409,
    E_HTTP_RESULT_SERVER_ERROR = 500,
    E_HTTP_RESULT_CONNECTION_ERROR = 520,
    E_HTTP_RESULT_NETWORK_NOT_ENABLE = 601
};

typedef void (^HttpCompletionHandler)(E_HTTP_RESULT, id);

@interface Http_Handler : NSObject

@property (nonatomic, copy) HttpCompletionHandler completionHandler;

#pragma mark -

+ (Http_Handler*)singleton;
- (NetworkStatus)currentNetworkStatus;
- (void)sendCloudHttpRequest:(HttpCompletionHandler)completionHandler andJSON:(id)json andUserInfo:(NSDictionary*)userInfo;

@end
