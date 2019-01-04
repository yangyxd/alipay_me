import 'package:flutter/material.dart';
import 'dart:async';

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
      urlScheme: null,
      isSandbox: _isSandbox,
    );
    setState(() {
      msg = "$o";
    });
  }

  doOauth(BuildContext context) async {
    await initAlipay();
    var o = await AlipayMe.auth(
      isSandbox: _isSandbox,
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
MIIEpAIBAAKCAQEAx3FdShq3y9coefJoNcYw/1weZOigvd09AsSivZLw5uEAyiF2
DyknfoSAclOj2E9Dl8xgcL5uDQYjmX6hze3Pz51LMmIzZL7+8PTKmjIQfxDMcMi1
72Hu9eJaDrIdza4PvVR89IAlrRIA0VKd02PAmNCwq4tX+NhIeDpChIWazfolsTR2
KJyHKkMyYYh1Y7GiPXOoPdEJY+fq22D/gbt+F3N6g1wgEYaxVkt3QgL5XIAcA+If
74CDyTUCJEmS/tnpsWoV+BVe+h4269DcwD94j449QI9VKXzrXWUTcU4tWtgtqpHs
JNgL7qiCBI/k7Dk2d6NBzT2boTrhr1sgm7J61wIDAQABAoIBADjxzUkTR9cTn6Lx
638vD15Z1vPI19xeBsV7j1vBULcbFzafRy4c+gHNoz8BUo64UvxMhlyqgpGFZzS0
S06Yz/TfXFEOaM4jGneB7TcJhFxDV5v8MrYeqDPcZQo9IPVQ9X2BWgwVaqx3r3QU
uqtYl+0J6OeR6ZRLbKWnPMbJvuGAQXNiU4VVLbuIwolOerufbPDBiXx2cGSlgs2W
46+nVYL3ysJ0RiHAfXkD1qWon/0byffU+iVFwQqrzRC75N+ranM1ghtnKYu6/1Te
O9L0Fa4HI1KmWB9mseYTC7ZCZYfiiusDTTSi8dsgPYBLEOLkFpae9GmOS6QYQcP2
GgQjZgECgYEA72O3vZ0ghZSyYyI09sPJwFlpvyX+Wn+kpz5yGfGtNrU/K0IG+ve5
H8KiRucfF3frcqDjVeBZyxpZzYRkHlP5TVbyhYbt0bCbymqSomcgXkiK3shjV4Am
duRWdgnQEQAQ947ty+/GNknsHjSmZWFsgJm0ylWuQgDwyuLhPxVJZGECgYEA1UgS
kiITcOIzQevNlXh5jPTOHvgVfWD0B+vSiDkcw8uH2ZE+Qx3fF01ghQw06A2SfD6Q
OCIyWJTZyU2T8wgfn8Pd02l5yhnWVDWJvOdn4JGzV/zM85+A5zgWJHIij1qO6p84
+QaNUCSLBSHFlT2uC2snVqAg2HG4cUFCaxI2KjcCgYEAj0zzDZeEg1I64ur0J4+W
MwWTLrCQrR3hs5fG987bMHeY4803nn4yHFgHikgKLaNEly7GR37wYYtZnJQW1qzP
/MMClHnr3O1KpQXc10jCcI4eSzRLe3KkE+Gl/Cztl2+huH+fy8exsIfZx08fGGsU
Z3sbZU+a67niaqEb0wZsE6ECgYEAuAPXAf4kh+CiGN46Ihwvw030CQRChkqAQdVV
b/LWvpd8PlryPTYopRI9lI1TmGMdX9Ua2VOn3IWQ4f3tCGKZ5l43pY/7ZEOmiEEo
9bMyDK+o7OFQc2HK9bOOZyOSbdzUMdnube0ZP2xIBcV9k6YD5BYveq3tqNF1MUH8
7CRqV0ECgYAA5E+ZzeM2u7Gx2iplbvRjJjmJ0BHm9TZidPmiw5m00tJ97P2PkBCf
GXE9jOcmZDK7XQAabahXWVMeX7cjiohYx1BZLOjPo2UMcYNrnmUGPr7lIl6vM3iI
sMIgBV4Jw4Tm5MydXU3sZiaVk2tkdWGWNsl57mlPRakq8tqD1BiEAQ==      
      ''',
        targetId: tid
    );
  }
}