import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:alipay_me/alipay_me.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Page(),
    );
  }


}

class Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}

class _PageState extends State<Page> {
  String msg = "";
  bool _isSandbox = false;
  String version;

  @override
  void initState() {
    super.initState();
    AlipayMe.getVersion().then((v) {
      setState(() {
        version = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('支付宝插件示例'),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: ListView(
        primary: true,
        children: <Widget>[
          Text("开发包版本号：${version ?? ""}"),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Checkbox(value: _isSandbox, onChanged: (v) {
                setState(() {
                  _isSandbox = v;
                });
              }),
              Text("沙盒模式")
            ],
          ),
          SizedBox(height: 32.0),
          OutlineButton(child: Text("支付"), onPressed: () {
            doPay(context);
          }),
          OutlineButton(child: Text("授权登录"), onPressed: () {
            doOauth(context);
          }),
          SizedBox(height: 32.0),
          Text(msg ?? "", style: TextStyle(fontSize: 10.0, color: Colors.blue)),
        ],
      )),
    );
  }

  doPay(BuildContext context) async {
    showDialog<void>(context: context, builder: (context) {
      TextEditingController edtPayInfo = new TextEditingController();
      return AlertDialog(
        title: Text("支付宝付款"),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("请输入服务器返回的payInfo："),
              TextField(
                controller: edtPayInfo,
                maxLines: 2,
              )
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("确定"),
            onPressed: () {
              Navigator.pop(context);
              doPayExec(edtPayInfo.text);
            },
          )
        ],
      );
    });
  }

  doPayExec(String apyInfo) async {
    print("apyInfo: $apyInfo");
    await initAlipay();

    var o = await AlipayMe.pay(apyInfo,
      urlScheme: "https://www.baidu.com",
      isSandbox: _isSandbox,
    );
    setState(() {
      msg = "$o";
    });
  }

  doOauth(BuildContext context) async {
    await initAlipay();
    String data;
    if (Platform.isIOS) {
      data = "Server AuthInfo";  // ioS平台只支持服务器返回
    }
    var o = await AlipayMe.auth(
      urlScheme: "https://www.baidu.com",
      isSandbox: _isSandbox,
      authInfo: data,
    );
    setState(() {
      msg = "$o";
    });
  }

  initAlipay() async {
    final String tid = "tid_${DateTime.now().millisecondsSinceEpoch}";
    await AlipayMe.init(
        appId: "2019010362782013",
        pid: "2088012716890635",
        rsa2Private: '''
MIIEpQIBAAKCAQEAtRpyDcy7HGE1+i0TFzA027i0gbc8ROvbNgHL9lnWyoiH/HUs
7d8F8vynr+xV4RzcQjrhemkk0f0azqtvxUPerVof/fWvVqCKCKch2zg8ZTrJcYPL
bIrqKrNmyK5LatsKzq2/Q/kaHjpWf4QBisEQxqPtCzW8a7GsoHkoWaQn34xakKWZ
43WTxAfl4IMcaENjJ2aCIO6rtJKzfEqgqS66cdtOr3dViKqxm86RuVkFlzqHMBsc
zJQA8S+XW3hhHR4UigVdlOYI4wkl1dGnAqONpo1za8nP7vryK3Yd9csXoeGAwcJm
7HPJYNAZduboiwUsT+tc9aeC/0c2b2xOTubh1wIDAQABAoIBAQCmG0FtItCjsQ3f
DqSp6g8xUHJPX48p7+I54OAAbloxnZSMm7S/4IUGX3I2S2BhfyUOog7ZRcL9z1Zd
JKT5m8yL11PsjQFrRQgV86V7+lJ6zrahJS7ZuXgZ/j5R5ntJ4OpCst3xLHMmMn/P
qXX4nCgU6ZmrZHgTlv0smrPFtGjWAcvP/DSiMqWUqr7FranyiRS/3bBMgU3FOGzc
X/kBMhDF7Xw6ZsNumGZOj8ky1N9h8wfa7AnZNzNGT9YQy0EuP9C0AVuT2XXsR8ME
asOaQkHz2bcEGxU0x1rcwkdHHrcLBc2Vx3EvNmcHZXWe1e/p1fEgJ8uS9i8QmDKs
vrg15qAxAoGBAOaErVG1bNAHddYaPcbc06Aasqeu8TrStAW1ej0EzY4cvNVPbfFR
eO9UoHBFkP78O/03vBhzldEsO9iH8TCT2hKBOiSirPv0+NXwf6qoZ615h3wnbgmO
L2thaR7kggU6cFh9PlXYqj6OjJlVldUTZgvpNo+MM84vwAGu4sHzFS1rAoGBAMkf
ZhBt/QLWuiGgNjmur+C4qAeumpDseTuCDjJJFQZgqNF3QqGY1WxJn9fdddq+hRpJ
PSOEYt9Y3beMqd+0hdzl2plElbLdXKAUsC7gDmybZbW5VPazH/kC6QJDpGgcRzAb
EHXL6HO43sqMVc8HQ9aNWxHDbPf6YkjtMsHWuexFAoGBAMQNL0MA5AyBa8yuAMBy
62GNk0hd1zhKH2WDlPT0csZc1pUsurq0qgASn2kdIVZbu8F+d3DsTQzbbAKai5zf
AmcelQ63dBvNmxyJMGs6UwMNCxeiiUmDLf1LmZX2jkZYD1iTHELyxMfzgMygJ5BS
sUWMESVA/oZrwgcscBq33NkFAoGAf7QlLXd5OK05YJKG+9dUq770SnRuhmjwjX2G
IB3RcMw9RUuRjmQp1+ljykA/Tha9EzS/0maEFUcq+Roi3v2UJe/4/mrTFtCBuM+K
EymHXyTIzzuPnFmeipFzfFGQ+d5CwWPd7r37qkcPh9LVxW/afkghNEU/UrG0aJPc
L8J1KXUCgYEApXed9rN+ayYuUBfDnAi3bZC6Fu9rEbs11oLN1SsPbAaRv5SiOSJU
FykdXth1miipA/6Lft3CN3OhziT6ocwAh9j+RSwxSyT8X4wPERufJpxfS4zN6UZ+
WQI/djrJbPJQkRyDAeAeTbMjquaF1ST5sqlS/JpwCVvF/yepqYgpIr0=''',
        targetId: tid
    );
  }
}