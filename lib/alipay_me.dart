import 'dart:async';

import 'package:flutter/services.dart';

class AlipayMe {
  static const MethodChannel _channel =
      const MethodChannel('alipay_me');

  /// payInfo 服务端返回的支付请求字符串
  /// urlScheme iOS 支付需要用到，用Xcode打开项目ios部分，点击项目名称，点击“Info”选项卡，
  /// 在“URL Types”选项中，点击“+”，在“URL Schemes”中输你的urlScheme，该参数涉及到支付完成能否正确跳回商户app
  /// isSandbox android支付需要，是否是沙箱环境，默认非沙箱
  ///
  /// 返回结果参考 https://docs.open.alipay.com/204/105301/
  static Future<dynamic> pay(String payInfo,
      {String urlScheme, bool isSandbox = false}) async {
    var result;
    try {
      result = await _channel.invokeMethod('pay', <String, dynamic>{
        'payInfo': payInfo,
        'isSandbox': isSandbox,
        'urlScheme': urlScheme
      });
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
    return result;
  }

  /// 初始化。需要从本地计算用于授权登录信息时需要先调用此方法
  ///  - appId 支付宝分配给开发者的应用ID
  ///  - pid 签约的支付宝账号对应的支付宝唯一用户号，以2088开头的16位纯数字组成
  ///  - rsa2Private 商户私钥, RSA2_PRIVATE 或者 RSA_PRIVATE 只需要填入一个, 优先使用rsa2Private
  ///  - targetId  商户标识该次用户授权请求的ID，该值在商户端应保持唯一
  ///
  /// 参考：https://docs.open.alipay.com/218/105327
  static Future<bool> init({String appId, String pid, String rsa2Private, String rsaPrivate, String targetId}) async {
    await _channel.invokeMethod('init', <String, dynamic>{
    'APPID': appId,
    'PID': pid,
    'RSA2_PRIVATE': rsa2Private,
    'RSA_PRIVATE': rsaPrivate,
    'TARGET_ID': targetId
    });
    return true;
  }

  /// 授权登录
  ///  - authInfo 用于发起请求的授权登录信息，如果为空，则使用init传入的参数在本地生成
  ///  - isSandbox 沙盒模式(iOS无限)
  ///  - urlScheme iOS需要用到
  static Future<dynamic> auth({String authInfo, String urlScheme, bool isSandbox = false}) async {
    var result;
    try {
      result = await _channel.invokeMethod('auth', <String, dynamic>{
        'authInfo': authInfo,
        'isSandbox': isSandbox,
        'urlScheme': urlScheme
      });
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
    return result;
  }

  /// 获取支付宝当前开发包版本号
  static Future<String> getVersion({String appId, String pid, String rsa2Private, String rsaPrivate, String targetId}) async {
    return await _channel.invokeMethod('version');
  }
}
