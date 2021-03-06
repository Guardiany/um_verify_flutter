#import "UmVerifyFlutterPlugin.h"
#import <UMCommon/UMCommon.h>
#import <UMVerify/UMVerify.h>
#import <UMCommon/MobClick.h>
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
    else if ([@"onEventObject" isEqualToString:call.method]) {
        [self onEventObject:result call:call];
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)onEventObject:(FlutterResult)result call:(FlutterMethodCall*)call {
    NSDictionary *map = call.arguments;
    NSString *eventID = [map valueForKey:@"eventID"];
    NSDictionary *dic = [map valueForKey:@"map"];
    [MobClick event:eventID attributes:dic];
    result(nil);
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
    //???????????????
    model.navColor = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
    model.navTitle = [[NSAttributedString alloc] initWithString:navTitle attributes:@{NSForegroundColorAttributeName:UIColor.blackColor,NSFontAttributeName:[UIFont systemFontOfSize:18.0]}];
    model.changeBtnTitle = [[NSAttributedString alloc] initWithString:@"?????????????????????"];
    
    if (slogamText != nil) {
        model.sloganText = [[NSAttributedString alloc] initWithString:slogamText attributes:@{NSForegroundColorAttributeName:UIColor.grayColor,NSFontAttributeName:[UIFont systemFontOfSize:15.0]}];
    }
    
    NSString *privacyOneName = [map valueForKey:@"privacyOneName"];
    NSString *privacyOneUrl = [map valueForKey:@"privacyOneUrl"];
    NSString *privacyTwoName = [map valueForKey:@"privacyTwoName"];
    NSString *privacyTwoUrl = [map valueForKey:@"privacyTwoUrl"];
    
    model.checkBoxIsChecked = YES;
    model.privacyPreText = @"?????????????????????";
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
            NSLog(@"%@", @"?????????????????????");
        } else if([PNSCodeLoginControllerClickCancel isEqualToString:code]){
            NSLog(@"%@", @"???????????????????????????");
            NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"??????", @"loginType", nil];
            [umEvent sendEvent:resultDic];
        } else if([PNSCodeLoginControllerClickChangeBtn isEqualToString:code]){
            NSLog(@"%@", @"????????????????????????????????????");
            NSDictionary *resultDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"????????????", @"loginType", nil];
            [umEvent sendEvent:resultDic];
            [UMCommonHandler cancelLoginVCAnimated:YES complete:^() {
                
            }];
        } else if([PNSCodeLoginControllerClickLoginBtn isEqualToString:code]){
            if([[resultDic objectForKey:@"isChecked"] boolValue] == YES){
                NSLog(@"%@", @"????????????????????????check box?????????SDK??????????????????????????????Token");
            }else{
                NSLog(@"%@", @"????????????????????????check box?????????SDK???????????????????????????Token");
            }
        } else if([PNSCodeLoginControllerClickCheckBoxBtn isEqualToString:code]){
            NSLog(@"%@", @"??????check box");
        } else if([PNSCodeLoginControllerClickProtocol isEqualToString:code]){
            NSLog(@"%@", @"????????????????????????");
        } else if([PNSCodeSuccess isEqualToString:code]){
            //??????????????????????????????Token????????????
            NSString *token = [resultDic objectForKey:@"token"];
            NSString *verifyId = [UMCommonHandler getVerifyId];
            //??????token
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
