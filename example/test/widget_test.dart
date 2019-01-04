// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alipay_me_example/main.dart';
import '../lib/sign.dart';

void main() {
  Sign.getSign("aaa", "aaa");

  Map<String, String> map = new Map<String, String>();
  map["appId"] = "2013081700024223";
  map["pid"] = "2088102123816631";
  map["apiname"] = "com.alipay.account.auth";
  map["app_name"] = "mc";
  map["product_id"] = "APP_FAST_LOGIN";
  map["auth_type"] = "AUTHACCOUNT";
  map["test"] = "中文fdsafdsafdas";

  Sign.getSignFormMap(map, "keyssalkffdjlskafjdslafldaslfdksafjdls", true).then((v) {
    print(v);
  });

//  testWidgets('Verify Platform version', (WidgetTester tester) async {
//    // Build our app and trigger a frame.
//    await tester.pumpWidget(MyApp());
//
//    // Verify that platform version is retrieved.
//    expect(
//      find.byWidgetPredicate(
//        (Widget widget) => widget is Text &&
//                           widget.data.startsWith('Running on:'),
//      ),
//      findsOneWidget,
//    );
//  });
}
