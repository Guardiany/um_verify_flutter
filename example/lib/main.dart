import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:um_verify_flutter/um_verify_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _sdkVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initSdk();
    initLogin();
  }
  
  void initSdk() {
    UmVerifyFlutter.initWithAppKey(
      iosAppKey: '7ed710204f142e',
      androidAppKey: '102050a281',
    );
  }

  void initLogin() async {
    await UmVerifyFlutter.initLogin(
      iosSecret: 'yygmPl2NlDXf5yYgt8lH3NKlV0BaazlCRKnBQrK91aQs3BFs8HNkd3PuuWAgA+Vioan21r7tYegNMJaikb4ezuz2qyXtQoc3jb1FNETet3ADFOSDxDiF2mXMS2E0Di6yEC3mP2Nz7P36xFOl+JWt/cE/6J8jXkE8YzbqPI3p6Fg4wHJ7csio0LDbtwsYk1JukfqunlsoXIJWCMf9mLriOyyhB',
      androidSecret: 'JGEQwWd3g3xlrGvyyLDlpF4J37CrlwbjP3EAs7EOsCeu71eNVd0/ahpZyx8qdR+r7SMfgqyo2EiwpySf2D/Nz9+XZ2B9HqGd8kctQ4dEFvhrZE+7TOtc+9dVvFCEfMXPHbth7ppe+FFq7V7KuHMrf1fN9xe5ChsHI1diIps971WskJuhQVBXRJuSsiCg+pvIrW1dKfO/g95DaeLLhVnvYLSemLd7LoI5+HVH6NuyjQ5N3zMDqzVGd+V89xtNCKI00iBk=',
      onSuccess: () {
        setState(() {
          _secretText = '设置密钥成功';
          _envAvailableText = '检查认证环境成功';
        });
      },
      onError: (error) {
        print(error);
      }
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    String sdkVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await UmVerifyFlutter.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    try {
      sdkVersion =
          await UmVerifyFlutter.sdkVersion ?? 'Unknown sdk version';
    } on PlatformException {
      sdkVersion = 'Failed to get sdk version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _sdkVersion = sdkVersion;
    });
  }

  String _secretText = '设置SDK秘钥';
  String _envAvailableText = '检查认证环境';
  String _accelerateLoginText = 'accelerateLogin';
  String _getLoginTokenText = '获取一键登录token';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Running on: $_platformVersion\nSdk version: $_sdkVersion'),
              Padding(padding: EdgeInsets.only(top: 15)),
              TextButton(onPressed: () {
                _setVerifySDKInfo();
              }, child: Text('$_secretText', style: TextStyle(fontSize: 18),),),
              TextButton(onPressed: () {
                _checkEnvAvailableWithAuthType();
              }, child: Text('$_envAvailableText', style: TextStyle(fontSize: 18),),),
              TextButton(onPressed: () {
                _accelerateLogin();
              }, child: Text('$_accelerateLoginText', style: TextStyle(fontSize: 18),),),
              TextButton(onPressed: () {
                _getLoginToken();
              }, child: Text('$_getLoginTokenText', style: TextStyle(fontSize: 18),),),
            ],
          ),
        ),
      ),
    );
  }

  void _setVerifySDKInfo() async {
    final result = await UmVerifyFlutter.setVerifySDKInfo(
      iosSecret: '',
      androidSecret: 'androidSecret',
    );
    if (result != null) {
      if (result.resultCode == '600000') {
        setState(() {
          _secretText = '设置密钥成功';
        });
      } else {
        setState(() {
          _secretText = '设置密钥失败 $result';
        });
      }
    } else {
      setState(() {
        _secretText = '设置密钥失败';
      });
    }
    print(result);
  }

  void _checkEnvAvailableWithAuthType() async {
    final result = await UmVerifyFlutter.checkEnvAvailableWithAuthType();
    if (result != null) {
      if (result.resultCode == '600000') {
        setState(() {
          _envAvailableText = '检查认证环境成功';
        });
      } else {
        setState(() {
          _envAvailableText = '检查认证环境失败 $result';
        });
      }
    } else {
      setState(() {
        _envAvailableText = '检查认证环境失败';
      });
    }
    print(result);
  }

  void _accelerateLogin() async {
    final result = await UmVerifyFlutter.accelerateLogin();
    if (result != null) {
      if (result.resultCode == '600000') {
        setState(() {
          _accelerateLoginText = 'accelerateLogin success';
        });
      } else {
        setState(() {
          _accelerateLoginText = 'accelerateLogin error $result';
        });
      }
    } else {
      setState(() {
        _accelerateLoginText = 'accelerateLogin error';
      });
    }
    print(result);
  }

  void _getLoginToken() async {
    await UmVerifyFlutter.getLoginToken(
      navTitle: '一键登录',
      navColor: Colors.white,
      slogamText: '未注册图你好玩账号时将会自动注册',
      privacyOneName: '用户协议',
      privacyOneUrl: 'https://developer.umeng.com/docs/143070/detail/144768#h1-sdk-demo-88',
      privacyTwoName: '隐私政策',
      privacyTwoUrl: 'https://fanyi.baidu.com/',
      onSuccess: (token) {
        print('success: $token');
      },
      onError: (error) {
        print(error);
      },
      changeLogin: (type) {
        print('changeLogin');
      }
    );
  }
}
