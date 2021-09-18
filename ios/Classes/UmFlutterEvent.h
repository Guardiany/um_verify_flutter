//
//  UmFlutterEvent.h
//  um_verify_flutter
//
//  Created by 爱互动 on 2021/9/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface UmFlutterEvent : NSObject<FlutterStreamHandler>

- (instancetype)initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar;

- (void)sendEvent:(NSDictionary *)event;

@end
