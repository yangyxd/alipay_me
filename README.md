# alipay_me

[![pub package](https://img.shields.io/pub/v/alipay_me.svg)](https://pub.dartlang.org/packages/alipay_me)
![GitHub](https://img.shields.io/github/license/yangyxd/alipay_me.svg)
[![GitHub stars](https://img.shields.io/github/stars/yangyxd/alipay_me.svg?style=social&label=Stars)](https://github.com/yangyxd/alipay_me)

Alipay plug-in. Support payment and authorized login. Support Android and iOS. Android supports local computational signatures.

## Usage
To use this plugin, add `alipay_me` as a dependency in your `pubspec.yaml` file.

## ROADMAP

* [x] 发起支付
* [x] 授权登录
* [x] 本地计算签名(仅Android)
* [x] 沙盒模式（仅Android）

> Supported  Platforms
> * Android
> * IOS

## Examples

  * [Examples App](https://github.com/yangyxd/alipay_me/tree/master/example) - Demonstrates how to use the alipay_me plugin.
  
```dart
import 'package:alipay_me/alipay_me.dart';

  // 初始化
  initAlipay() async {
    final String tid = "tid_${DateTime.now().millisecondsSinceEpoch}";
    await AlipayMe.init(
        appId: "2019010362782013",
        pid: "2088012716890635",
        rsa2Private: RSAPrivate,
        targetId: tid
    );
  }
  
  // 发起支付
  var o = await AlipayMe.pay(apyInfo,
      urlScheme: "alisdkdemo",  // 这里的URL Schemes中输入的alisdkdemo，为测试demo，实际商户的app中要填写独立的scheme
      isSandbox: _isSandbox,
   );

  //授权申请
  await AlipayMe.auth(
        urlScheme: "alisdkdemo", // 这里的URL Schemes中输入的alisdkdemo，为测试demo，实际商户的app中要填写独立的scheme
        isSandbox: _isSandbox,
        authInfo: data,
      );
  
```

## License MIT

Copyright (c) 2019
