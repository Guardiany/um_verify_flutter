# 友盟一键登录sdk Flutter版本

## 简介
  um_verify_flutter是一款集成了友盟一键登录sdk的Flutter插件

## 官方文档
* [Android](https://developer.umeng.com/docs/143070/detail/144780)
* [IOS](https://developer.umeng.com/docs/143070/detail/144766)

## 集成步骤
#### 1、pubspec.yaml
```Dart
um_verify_flutter:
  git: https://github.com/Guardiany/um_verify_flutter.git
```

#### 2、IOS
SDK最新版本已配置插件中，无需多余配置

#### 3、Android
SDK最新版本已配置插件中，配置Android9.0对http协议的支持方式，AndroidManifest.xml里面添加
```
<application
    android:usesCleartextTraffic="true">
```

## 使用

#### 1、SDK初始化
```Dart
UmVerifyFlutter.initWithAppKey(
      iosAppKey: 'iosAppKey',
      androidAppKey: 'androidAppKey',
    );
```
#### 2、获取SDK版本
```Dart
await UmVerifyFlutter.sdkVersion;
```
#### 3、获取登录token
```Dart
///初始化登录环境
await UmVerifyFlutter.initLogin(
      iosSecret: 'iosSecret',
      androidSecret: 'androidSecret',
      onSuccess: () {
        ///登录环境检查成功
      },
      onError: (error) {
        print(error);
      }
    );

///弹出授权页，获取登录token
await UmVerifyFlutter.getLoginToken(
      navTitle: '一键登录',
      slogamText: '未注册账号时将会自动注册',
      privacyOneName: '用户协议',
      privacyOneUrl: 'https://www.baidu.com/',
      privacyTwoName: '隐私政策',
      privacyTwoUrl: 'https://fanyi.baidu.com/',
      onSuccess: (token) {
        print('success: $token');
      },
      onError: (error) {
        print(error);
      },
      changeLogin: (type) {
        ///切换登录方式
      },
    );

///登录成功后释放sdk资源
UmVerifyFlutter.releaseVerifyStream();
```

## 联系方式
* Email: 1204493146@qq.com
