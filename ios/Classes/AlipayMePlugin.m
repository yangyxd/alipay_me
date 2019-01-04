#import "AlipayMePlugin.h"
#import <AlipaySDK/AlipaySDK.h>

@implementation AlipayMePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"alipay_me"
            binaryMessenger:[registrar messenger]];
  AlipayMePlugin* instance = [[AlipayMePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

static NSString* appID = @"";
static NSString* rsa2PrivateKey = @"";
static NSString* rsaPrivateKey = @"";
static NSString* pid = @"";
static NSString* targetId = @"";

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        
    } else if ([@"init" isEqualToString:call.method]) {
        
        appID = [call.arguments objectForKey:@"APPID"];
        rsa2PrivateKey = [call.arguments objectForKey:@"RSA2_PRIVATE"];
        rsaPrivateKey = [call.arguments objectForKey:@"RSA_PRIVATE"];
        pid = [call.arguments objectForKey:@"PID"];
        targetId = [call.arguments objectForKey:@"TARGET_ID"];
        result(@"OK");
        
    } else if ([@"pay" isEqualToString:call.method]) {
        
        NSString* urlScheme = [call.arguments objectForKey:@"urlScheme"];
        NSString* payInfo = [call.arguments objectForKey:@"payInfo"];
        if ([self isEmptyString:urlScheme]) {
            NSLog(@"urlScheme不能为空");
            result(@"");
            return;
        }
        if ([self isEmptyString:payInfo]) {
            NSLog(@"payInfo不能为空");
            result(@"");
            return;
        }
        // 开始支付
        [[AlipaySDK defaultService] payOrder:payInfo
                                  fromScheme:urlScheme
                                    callback:^(NSDictionary *resultDic)
        {
            //NSLog(@"reslut = %@",resultDic);
            result(resultDic);
        }];
        
    } else if ([@"auth" isEqualToString:call.method]) {
        
        NSString* authInfo = [call.arguments objectForKey:@"authInfo"];
        NSString* urlScheme = [call.arguments objectForKey:@"urlScheme"];
        if ([self isEmptyString:urlScheme]) {
            NSLog(@"urlScheme不能为空");
            result(@"");
            return;
        }
        if ([self isEmptyString:authInfo]) {
            NSLog(@"authInfo不能为空");
            result(@"");
            return;
        }
        // start auth
        [[AlipaySDK defaultService] auth_V2WithInfo:authInfo
                                         fromScheme:urlScheme
                                           callback:^(NSDictionary *resultDic)
        {
            result(resultDic);
        }];
        
    } else if ([@"version" isEqualToString:call.method]) {
        
        result([[AlipaySDK defaultService] currentVersion]);
        
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (BOOL) isEmptyString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
