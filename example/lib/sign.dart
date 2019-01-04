import 'package:alipay_me/alipay_me.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

/// 计算签名
class Sign {
  Sign._();

  static Future<String> getSignFormMap(Map<String, String> map, String rsaKey, [bool rsa2]) async {
    var keys = map.keys.toList();
    // key排序
    keys.sort();

    StringBuffer sb = new StringBuffer();
    for (int i=0; i < keys.length - 1; i++) {
      var key = keys[i];
      var value = map[key];
      sb.write(buildKeyValue(key, value, false));
      sb.write('&');
    }

    String tailKey = keys[keys.length - 1];
    String tailValue = map[tailKey];
    sb.write(buildKeyValue(tailKey, tailValue, false));

    String oriSign = await getSign(sb.toString(), rsaKey, rsa2);
    String encodedSign = encodeData(oriSign);
    return "sign=$encodedSign";
  }

  static Future<String> getSign(String data, String rsaKey, [bool rsa2]) async {
    try {
      print(data);
      return await AlipayMe.sign(data, rsaKey, rsa2);
    } catch (e) {
      return null;
    }
  }

  static String buildKeyValue(String key, String value, bool isEncode) {
    return "$key=${isEncode ? encodeData(value) : value}";
  }

  static String encodeData(String value) {
    try {
      return Uri.encodeQueryComponent(value);
    } catch (e) {
      return value;
    }
  }
}