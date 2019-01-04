import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:alipay_me/alipay_me.dart';

import 'sign.dart';

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
          OutlineButton(child: Text("测试Sign"), onPressed: () {
            testSign();
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
      urlScheme: "alisdkdemo",  // 这里的URL Schemes中输入的alisdkdemo，为测试demo，实际商户的app中要填写独立的scheme
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
      urlScheme: "alisdkdemo", // 这里的URL Schemes中输入的alisdkdemo，为测试demo，实际商户的app中要填写独立的scheme
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
        rsa2Private: RSAPrivate,
        targetId: tid
    );
  }

  void testSign() async {
    Map<String, String> map = new Map<String, String>();
    map["appId"] = "2013081700024223";
    map["pid"] = "2088102123816631";
    map["apiname"] = "com.alipay.account.auth";
    map["app_name"] = "mc";
    map["product_id"] = "APP_FAST_LOGIN";
    map["auth_type"] = "AUTHACCOUNT";
    map["test"] = "中文fdsafdsafdas";

    Sign.getSignFormMap(map, RSAPrivate, true).then((v) {
      setState(() {
        msg = v;
      });
      print(v);
    });
  }

  final String RSAPrivate = '''
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC1GnINzLscYTX6
LRMXMDTbuLSBtzxE69s2Acv2WdbKiIf8dSzt3wXy/Kev7FXhHNxCOuF6aSTR/RrO
q2/FQ96tWh/99a9WoIoIpyHbODxlOslxg8tsiuoqs2bIrktq2wrOrb9D+RoeOlZ/
hAGKwRDGo+0LNbxrsaygeShZpCffjFqQpZnjdZPEB+XggxxoQ2MnZoIg7qu0krN8
SqCpLrpx206vd1WIqrGbzpG5WQWXOocwGxzMlADxL5dbeGEdHhSKBV2U5gjjCSXV
0acCo42mjXNryc/u+vIrdh31yxeh4YDBwmbsc8lg0Bl25uiLBSxP61z1p4L/RzZv
bE5O5uHXAgMBAAECggEBAKYbQW0i0KOxDd8OpKnqDzFQck9fjynv4jng4ABuWjGd
lIybtL/ghQZfcjZLYGF/JQ6iDtlFwv3PVl0kpPmbzIvXU+yNAWtFCBXzpXv6UnrO
tqElLtm5eBn+PlHme0ng6kKy3fEscyYyf8+pdficKBTpmatkeBOW/Syas8W0aNYB
y8/8NKIypZSqvsWtqfKJFL/dsEyBTcU4bNxf+QEyEMXtfDpmw26YZk6PyTLU32Hz
B9rsCdk3M0ZP1hDLQS4/0LQBW5PZdexHwwRqw5pCQfPZtwQbFTTHWtzCR0cetwsF
zZXHcS82ZwdldZ7V7+nV8SAny5L2LxCYMqy+uDXmoDECgYEA5oStUbVs0Ad11ho9
xtzToBqyp67xOtK0BbV6PQTNjhy81U9t8VF471SgcEWQ/vw7/Te8GHOV0Sw72Ifx
MJPaEoE6JKKs+/T41fB/qqhnrXmHfCduCY4va2FpHuSCBTpwWH0+VdiqPo6MmVWV
1RNmC+k2j4wzzi/AAa7iwfMVLWsCgYEAyR9mEG39Ata6IaA2Oa6v4LioB66akOx5
O4IOMkkVBmCo0XdCoZjVbEmf19112r6FGkk9I4Ri31jdt4yp37SF3OXamUSVst1c
oBSwLuAObJtltblU9rMf+QLpAkOkaBxHMBsQdcvoc7jeyoxVzwdD1o1bEcNs9/pi
SO0ywda57EUCgYEAxA0vQwDkDIFrzK4AwHLrYY2TSF3XOEofZYOU9PRyxlzWlSy6
urSqABKfaR0hVlu7wX53cOxNDNtsApqLnN8CZx6VDrd0G82bHIkwazpTAw0LF6KJ
SYMt/UuZlfaORlgPWJMcQvLEx/OAzKAnkFKxRYwRJUD+hmvCByxwGrfc2QUCgYB/
tCUtd3k4rTlgkob711SrvvRKdG6GaPCNfYYgHdFwzD1FS5GOZCnX6WPKQD9OFr0T
NL/SZoQVRyr5GiLe/ZQl7/j+atMW0IG4z4oTKYdfJMjPO4+cWZ6KkXN8UZD53kLB
Y93uvfuqRw+H0tXFb9p+SCE0RT9SsbRok9wvwnUpdQKBgQCld532s35rJi5QF8Oc
CLdtkLoW72sRuzXWgs3VKw9sBpG/lKI5IlQXKR1e2HWaKKkD/ot+3cI3c6HOJPqh
zACH2P5FLDFLJPxfjA8RG58mnF9LjM3pRn5ZAj92Osls8lCRHIMB4B5NsyOq5oXV
JPmyqVL8mnAJW8X/J6mpiCkivQ==''';

}