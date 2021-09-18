//
//  UmFlutterEvent.m
//  um_verify_flutter
//
//  Created by 爱互动 on 2021/9/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "UmFlutterEvent.h"

@implementation UmFlutterEvent {
    FlutterEventSink eventSink;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"com.ahd.um_verify/um_event" binaryMessenger:registrar.messenger];
    [eventChannel setStreamHandler:self];
    return self;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    eventSink = events;
    return nil;
}

- (void)sendEvent:(NSDictionary *)event {
    eventSink(event);
}

@end
