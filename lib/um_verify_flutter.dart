
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'um_verify_result_entity.dart';

class UmVerifyFlutter {
  static const MethodChannel _channel = const MethodChannel('um_verify_flutter');
  static const EventChannel _umEventChannel = const EventChannel('com.ahd.um_verify/um_event');

  static StreamSubscription? _eventStream;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  
  static Future<String?> get sdkVersion async {
    return await _channel.invokeMethod('getSdkVersion');
  }

  ///初始化sdk
  static void initWithAppKey({
    required String iosAppKey,
    required String androidAppKey,
    String? iosChannel,
    String? androidChannel,
  }) {
    _channel.invokeMethod('initWithAppkey', {
      'iosAppKey': iosAppKey,
      'androidApKey': androidAppKey,
      'iosChannel': iosChannel,
      'androidChannel': androidChannel,
    });
  }

  ///设置SDK秘钥
  static Future<UmVerifyResultEntity?> setVerifySDKInfo({
    required String iosSecret,
    required String androidSecret,
  }) async {
    final result = await _channel.invokeMethod('setVerifySDKInfo', {
      'iosSecret': iosSecret,
      'androidSecret': androidSecret,
    });
    return UmVerifyResultEntity.fromJson(result);
  }

  ///检查认证环境
  static Future<UmVerifyResultEntity?> checkEnvAvailableWithAuthType() async {
    final result = await _channel.invokeMethod('checkEnvAvailableWithAuthType');
    return UmVerifyResultEntity.fromJson(result);
  }

  ///加速一键登录授权页弹起
  static Future<UmVerifyResultEntity?> accelerateLogin() async {
    final result = await _channel.invokeMethod('accelerateLogin');
    return UmVerifyResultEntity.fromJson(result);
  }

  static Future initLogin({
    required String iosSecret,
    required String androidSecret,
    Function? onSuccess,
    Function? onError,
  }) async {
    _eventStream = _umEventChannel.receiveBroadcastStream().listen((data) {
      String? errorMsg = data['error'];
      if (errorMsg == null) {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) {
          onError(errorMsg);
        }
      }
      // if (_eventStream != null) {
      //   _eventStream?.cancel();
      // }
    });
    final result = await UmVerifyFlutter.setVerifySDKInfo(
      iosSecret: iosSecret,
      androidSecret: androidSecret,
    );
    if (result?.resultCode == '600000') {
      UmVerifyResultEntity? resultEntity = await checkEnvAvailableWithAuthType();
      if (resultEntity?.resultCode == '600000') {
        if (onSuccess != null) {
          onSuccess();
        }
      } else {
        if (onError != null) {
          onError(resultEntity?.toString());
        }
      }
    } else {
      if (onError != null) {
        onError(result?.toString());
      }
    }
  }

  ///一键登录获取token
  ///
  /// [navColor] 导航栏背景颜色
  ///
  /// [navTitle] 导航栏标题
  ///
  /// [slogamText] 自定义文字提示
  ///
  /// [privacyOneName] 协议1名称
  ///
  /// [privacyOneUrl] 协议1链接
  ///
  /// [privacyTwoName] 协议2名称
  ///
  /// [privacyTwoUrl] 协议2链接
  ///
  static Future<UmVerifyResultEntity?> getLoginToken({
    Color navColor = Colors.white,
    String navTitle = '一键登录',
    String slogamText = '',
    String? privacyOneName,
    String? privacyOneUrl,
    String? privacyTwoName,
    String? privacyTwoUrl,
    Function? onSuccess,
    Function? onError,
    Function? changeLogin,
  }) async {
    _eventStream = _umEventChannel.receiveBroadcastStream().listen((data) {
      String? token = data['token'];
      String? errorMsg = data['error'];
      if (token != null) {
        if (onSuccess != null) {
          onSuccess(token);
        }
      } else if (errorMsg != null) {
        if (onError != null) {
          onError(errorMsg);
        }
      } else if (data['loginType'] != null) {
        if (changeLogin != null) {
          changeLogin(data['loginType']);
        }
      }
      // if (_eventStream != null) {
      //   _eventStream?.cancel();
      // }
    });
    final result = await _channel.invokeMethod('getLoginToken', {
      'navTitle': navTitle,
      'navColor': {
        'red': navColor.red,
        'green': navColor.green,
        'blue': navColor.blue,
        'alpha': navColor.alpha
      },
      'slogamText': slogamText,
      'privacyOneName': privacyOneName,
      'privacyOneUrl': privacyOneUrl,
      'privacyTwoName': privacyTwoName,
      'privacyTwoUrl': privacyTwoUrl,
    });
    UmVerifyResultEntity resultEntity = UmVerifyResultEntity.fromJson(result);
    if (resultEntity.resultCode != '600001' && onError != null) {
      onError(resultEntity.toString());
    }
    return resultEntity;
  }

  static void releaseVerifyStream() {
    if (_eventStream != null) {
      _eventStream?.cancel();
    }
  }
}
