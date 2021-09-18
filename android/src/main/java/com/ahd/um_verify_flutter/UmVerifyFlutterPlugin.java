package com.ahd.um_verify_flutter;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.Log;

import androidx.annotation.NonNull;

import com.umeng.commonsdk.UMConfigure;
import com.umeng.umverify.UMResultCode;
import com.umeng.umverify.UMVerifyHelper;
import com.umeng.umverify.listener.UMAuthUIControlClickListener;
import com.umeng.umverify.listener.UMPreLoginResultListener;
import com.umeng.umverify.listener.UMTokenResultListener;
import com.umeng.umverify.model.UMTokenRet;
import com.umeng.umverify.view.UMAuthUIConfig;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** UmVerifyFlutterPlugin */
public class UmVerifyFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;
  private UMVerifyHelper verifyHelper;
  private Activity mActivity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "um_verify_flutter");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    UmFlutterEvent.getInstance().onAttachedToEngine(flutterPluginBinding);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Map<String, String> resultMap = new HashMap<>();
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "getSdkVersion":
        result.success(UMVerifyHelper.getUVerifyVersion());
        break;
      case "initWithAppkey":
        String appkey = call.argument("androidApKey");
        UMConfigure.init(context, appkey, "", UMConfigure.DEVICE_TYPE_PHONE, null);

        verifyHelper = UMVerifyHelper.getInstance(context, resultListener);
        verifyHelper.setUIClickListener(uiControlClickListener);
        result.success(null);
        break;
      case "setVerifySDKInfo":
        String secret = call.argument("androidSecret");
        verifyHelper.setAuthSDKInfo(secret);
        resultMap.put("resultCode", "600000");
        result.success(resultMap);
        break;
      case "checkEnvAvailableWithAuthType":
        verifyHelper.checkEnvAvailable(2);
        resultMap.put("resultCode", "600000");
        result.success(resultMap);
        break;
      case "accelerateLogin":
        verifyHelper.accelerateLoginPage(5000, new UMPreLoginResultListener() {
          @Override
          public void onTokenSuccess(String s) {
            System.out.println(s);
          }

          @Override
          public void onTokenFailed(String s, String s1) {
            System.out.println(s + "\n" + s1);
          }
        });
        resultMap.put("resultCode", "600000");
        result.success(resultMap);
        break;
      case "getLoginToken":
        verifyHelper = UMVerifyHelper.getInstance(context, resultListener);
        verifyHelper.setUIClickListener(uiControlClickListener);
        login(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  UMTokenResultListener resultListener = new UMTokenResultListener() {
    @Override
    public void onTokenSuccess(String s) {
      UMTokenRet tokenRet = UMTokenRet.fromJson(s);
      if (UMResultCode.CODE_START_AUTHPAGE_SUCCESS.equals(tokenRet.getCode())) {
        Log.i("TAG", "唤起授权页成功：" + s);
      }
      if (UMResultCode.CODE_SUCCESS.equals(tokenRet.getCode())) {
        Log.i("TAG", "获取token成功：" + s);
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("token", tokenRet.getToken());
        UmFlutterEvent.getInstance().sendEvent(resultMap);
        release();
        verifyHelper.hideLoginLoading();
        verifyHelper.quitLoginPage();
      }
    }

    @Override
    public void onTokenFailed(String s) {
      UMTokenRet tokenRet = UMTokenRet.fromJson(s);
      if (UMResultCode.CODE_ERROR_USER_SWITCH.equals(tokenRet.getCode())) {
        Log.i("TAG", "用户切换其他登录方式：" + s);
        return;
      }
      if (UMResultCode.CODE_ERROR_USER_CANCEL.equals(tokenRet.getCode())) {
        Log.i("TAG", "CODE_ERROR_USER_CANCEL：" + s);
        return;
      }
      Map<String, Object> resultMap = new HashMap<>();
      resultMap.put("error", s);
      UmFlutterEvent.getInstance().sendEvent(resultMap);
      release();
    }
  };

  UMAuthUIControlClickListener uiControlClickListener = new UMAuthUIControlClickListener() {
    @Override
    public void onClick(String s, Context context, String s1) {
      switch (s) {
        case "700000":
          Map<String, Object> backMap = new HashMap<>();
          backMap.put("loginType", "返回");
          UmFlutterEvent.getInstance().sendEvent(backMap);
          break;
        case "700001":
          Map<String, Object> loginMap = new HashMap<>();
          loginMap.put("loginType", "短信登录");
          UmFlutterEvent.getInstance().sendEvent(loginMap);
          verifyHelper.hideLoginLoading();
          verifyHelper.quitLoginPage();
          break;
        case "700002":
          break;
        case "700003":
          break;
        case "700004":
          break;
      }
    }
  };

  private void login(MethodCall call, Result result) {
    String title = call.argument("navTitle");
    String slogan = call.argument("slogamText");
    if (title == null) {
      title = "一键登录";
    }
    String privacyOneName = call.argument("privacyOneName");
    String privacyOneUrl = call.argument("privacyOneUrl");
    String privacyTwoName = call.argument("privacyTwoName");
    String privacyTwoUrl = call.argument("privacyTwoUrl");

    verifyHelper.removeAuthRegisterXmlConfig();
    verifyHelper.removeAuthRegisterViewConfig();

    UMAuthUIConfig uiConfig = new UMAuthUIConfig.Builder()
            .setNavColor(Color.WHITE)
            .setNavText(title)
            .setNavTextColor(Color.BLACK)
            .setSloganText(slogan)
            .setAppPrivacyOne(privacyOneName, privacyOneUrl)
            .setAppPrivacyTwo(privacyTwoName, privacyTwoUrl)
            .setPrivacyBefore("我已阅读并同意")
            .setSwitchAccText("切换到短信登录")
            .create();
    verifyHelper.setAuthUIConfig(uiConfig);

    verifyHelper.getLoginToken(mActivity, 5000);

    Map<String, String> resultMap = new HashMap<>();
    resultMap.put("resultCode", "600001");
    result.success(resultMap);
  }

  public void release() {
    verifyHelper.setAuthListener(null);
    verifyHelper.setUIClickListener(null);
    verifyHelper.removeAuthRegisterViewConfig();
    verifyHelper.removeAuthRegisterXmlConfig();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    mActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    mActivity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    mActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    mActivity = null;
  }
}
