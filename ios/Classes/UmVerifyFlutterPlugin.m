#import "UmVerifyFlutterPlugin.h"
#import <UMCommon/UMCommon.h>
#import <UMVerify/UMVerify.h>
#import "UmFlutterEvent.h"

UmFlutterEvent *umEvent;

@implementation UmVerifyFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"um_verify_flutter" binaryMessenger:[registrar messenger]];
    UmVerifyFlutterPlugin* instance = [[UmVerifyFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    umEvent = [[UmFlutterEvent alloc] initWithRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
    else if ([@"getSdkVersion" isEqualToString:call.method]) {
        result([UMCommonHandler getVersion]);
    }
    else if ([@"initWithAppkey" isEqualToString:call.method]) {
        NSDictionary *map = call.arguments;
        NSString *appKey = [map valueForKey:@"iosAppKey"];
        NSString *channel = [map valueForKey:@"iosChannel"];
        [UMConfigure initWithAppkey:appKey channel:channel];
        result(nil);
    }
    else if ([@"setVerifySDKInfo" isEqualToString:call.method]) {
        NSDictionary *map = call.arguments;
        NSString *secret = [map valueForKey:@"iosSecret"];
        [UMCommonHandler setVerifySDKInfo:secret complete:^(NSDictionary*_Nonnull resultDic){
            result(resultDic);
        }];
    }
    else if ([@"checkEnvAvailableWithAuthType" isEqualToString:call.method]) {
        [UMCommonHandler checkEnvAvailableWithAuthType:UMPNSAuthTypeLoginToken complete:^(NSDictionary*_Nonnull resultDic){
            result(resultDic);
        }];
    }
    else if ([@"accelerateLogin" isEqualToString:call.method]) {
        NSTimeInterval timeOut = 10.0;
        [UMCommonHandler accelerateLoginPageWithTimeout:timeOut complete:^(NSDictionary*_Nonnull resultDic){
            result(resultDic);
        }];
    }
    else if ([@"getLoginToken" isEqualToString:call.method]) {
        [self getLoginToken:result call:call];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)getLoginToken:(FlutterResult)result call:(FlutterMethodCall*)call {
    
    NSDictionary *map = call.arguments;
    NSDictionary *navColor = [map valueForKey:@"navColor"];
    CGFloat red = [[navColor valueForKey:@"red"] floatValue];
    CGFloat green = [[navColor valueForKey:@"green"] floatValue];
    CGFloat blue = [[navColor valueForKey:@"blue"] floatValue];
    CGFloat alpha = [[navColor valueForKey:@"alpha"] floatValue];
    
    NSString *navTitle = [map valueForKey:@"navTitle"];
    NSString *slogamText = [map valueForKey:@"slogamText"];
    
    UMCustomModel *model =[[UMCustomModel alloc] init];
    //标题栏颜色
    model.navColor = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    model.navTitle = [[NSAttributedString alloc] initWithString:navTitle attributes:@{NSForegroundColorAttributeName:UIColor.blackColor,NSFontAttributeName:[UIFont systemFontOfSize:18.0]}];
    model.changeBtnTitle = [[NSAttributedString alloc] initWithString:@"切换到短信登录"];
    
    if (slogamText != nil) {
        model.sloganText = [[NSAttributedString alloc] initWithString:slogamText attributes:@{NSForegroundColorAttributeName:UIColor.grayColor,NSFontAttributeName:[UIFont systemFontOfSize:15.0]}];
    }
    
    NSString *privacyOneName = [map valueForKey:@"privacyOneName"];
    NSString *privacyOneUrl = [map valueForKey:@"privacyOneUrl"];
    NSString *privacyTwoName = [map valueForKey:@"privacyTwoName"];
    NSString *privacyTwoUrl = [map valueForKey:@"privacyTwoUrl"];
    
    model.checkBoxIsChecked = YES;
    model.privacyPreText = @"我已阅读并同意";
    if (privacyOneName != nil && privacyOneUrl != nil) {
        model.privacyOne = [NSArray arrayWithObjects:privacyOneName,privacyOneUrl, nil];
    }
    if (privacyTwoName != nil && privacyTwoUrl != nil) {
        model.privacyTwo = [NSArray arrayWithObjects:privacyTwoName,privacyTwoUrl, nil];
    }
    model.privacyAlignment = NSTextAlignmentCenter;
    
    NSTimeInterval timeOut = 10.0;
    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [UMCommonHandler getLoginTokenWithTimeout:timeOut controller:rootViewController model:model complete:^(NSDictionary*_Nonnull resultDic){
        NSString *code = [resultDic objectForKey:@"resultCode"];
        if([PNSCodeLoginControllerPresentSuccess isEqualToString:code]){
            NSLog(@"%@", @"弹起授权页成功");
        } else if([PNSCodeLoginControllerClickCancel isEqualToString:code]){
            NSLog(@"%@", @"点击了授权页的返回");
            NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"返回", @"loginType", nil];
            [umEvent sendEvent:resultDic];
        } else if([PNSCodeLoginControllerClickChangeBtn isEqualToString:code]){
            NSLog(@"%@", @"点击切换其他登录方式按钮");
            NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"短信登录", @"loginType", nil];
            [umEvent sendEvent:resultDic];
            [UMCommonHandler cancelLoginVCAnimated:YES complete:^() {
                
            }];
        } else if([PNSCodeLoginControllerClickLoginBtn isEqualToString:code]){
            if([[resultDic objectForKey:@"isChecked"] boolValue] == YES){
                NSLog(@"%@", @"点击了登录按钮，check box选中，SDK内部接着会去获取登陆Token");
            }else{
                NSLog(@"%@", @"点击了登录按钮，check box选中，SDK内部不会去获取登陆Token");
            }
        } else if([PNSCodeLoginControllerClickCheckBoxBtn isEqualToString:code]){
            NSLog(@"%@", @"点击check box");
        } else if([PNSCodeLoginControllerClickProtocol isEqualToString:code]){
            NSLog(@"%@", @"点击了协议富文本");
        } else if([PNSCodeSuccess isEqualToString:code]){
            //点击登录按钮获取登录Token成功回调
            NSString *token = [resultDic objectForKey:@"token"];
            NSString *verifyId = [UMCommonHandler getVerifyId];
            //返回token
            NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:token, @"token", verifyId, @"verifyId", nil];
            [umEvent sendEvent:resultDic];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [UMCommonHandler cancelLoginVCAnimated:YES complete:nil];
            });
        }
        result(resultDic);
    }];
}

@end
