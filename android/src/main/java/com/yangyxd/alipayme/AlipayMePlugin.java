package com.yangyxd.alipayme;

import android.app.Activity;
import android.text.TextUtils;

import com.alipay.sdk.app.EnvUtils;
import com.alipay.sdk.app.PayTask;
import com.alipay.sdk.app.AuthTask;

import org.w3c.dom.Text;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AlipayMePlugin */
public class AlipayMePlugin implements MethodCallHandler {

  private Registrar _reg;

  /**
   * 用于支付宝支付业务的入参 app_id。
   */
  private static String APPID = "";
  /**
   * 用于支付宝账户登录授权业务的入参 pid。
   */
  private static String PID = "";
  /**
   * 用于支付宝账户登录授权业务的入参 target_id。
   */
  private static String TARGET_ID = "";
  /**
   *  pkcs8 格式的商户私钥。
   *
   * 	如下私钥，RSA2_PRIVATE 或者 RSA_PRIVATE 只需要填入一个，如果两个都设置了，本 Demo 将优先
   * 	使用 RSA2_PRIVATE。RSA2_PRIVATE 可以保证商户交易在更加安全的环境下进行，建议商户使用
   * 	RSA2_PRIVATE。
   *
   * 	建议使用支付宝提供的公私钥生成工具生成和获取 RSA2_PRIVATE。
   * 	工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
   */
  private static String RSA2_PRIVATE = "";
  private static String RSA_PRIVATE = "";

  public AlipayMePlugin(Registrar registrar){
    _reg = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "alipay_me");
    channel.setMethodCallHandler(new AlipayMePlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    if ("pay".equals(method)) {
      String payInfo = call.argument("payInfo");
      boolean isSandbox = call.argument("isSandbox");
      pay(_reg.activity(), payInfo, isSandbox, result);
    } else if ("init".equals(method)) {
      APPID = call.argument("APPID");
      PID = call.argument("PID");
      RSA2_PRIVATE = call.argument("RSA2_PRIVATE");
      RSA_PRIVATE = call.argument("RSA_PRIVATE");
      TARGET_ID = call.argument("TARGET_ID");
      result.success("OK");
    } else if ("auth".equals(method)) {
      String authInfo = call.argument("authInfo");
      boolean isSandbox = call.argument("isSandbox");
      Oauth(_reg.activity(), authInfo, isSandbox, result);
    } else if ("version".equals(method)) {
      PayTask payTask = new PayTask(_reg.activity());
      result.success(payTask.getVersion());
    } else {
      result.notImplemented();
    }
  }

  // 支付
  public static void pay(final Activity currentActivity, String payInfo, boolean isSandbox, final Result callback){
    if (TextUtils.isEmpty(APPID) || (TextUtils.isEmpty(RSA2_PRIVATE) && TextUtils.isEmpty(RSA_PRIVATE))) {
      if (TextUtils.isEmpty(payInfo)) {
        callback.error("支付发生错误：无效的参数", null, null);
        return;
      }
    }

    /*
     * 如果payInfo为空，则在本地生成一个测试订单，正式运行时，由服务器生成
     */
    if (TextUtils.isEmpty(payInfo)) {
      boolean rsa2 = (RSA2_PRIVATE.length() > 0);
      Map<String, String> params = OrderInfoUtil2_0.buildOrderParamMap(APPID, rsa2);
      String orderParam = OrderInfoUtil2_0.buildOrderParam(params);

      String privateKey = rsa2 ? RSA2_PRIVATE : RSA_PRIVATE;
      String sign = OrderInfoUtil2_0.getSign(params, privateKey, rsa2);
      payInfo = orderParam + "&" + sign;
    }

    final String orderInfo = payInfo;

    //沙箱环境
    if(isSandbox){
      EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX);
    }

    Runnable payRunnable = new Runnable() {
      @Override
      public void run() {
        try {
          PayTask alipay = new PayTask(currentActivity);
          Map<String, String> result = alipay.payV2(orderInfo, true);
          callback.success(result);
        } catch (Exception e) {
          callback.error(e.getMessage(),"支付发生错误", e);
        }
      }
    };

    Thread payThread = new Thread(payRunnable);
    payThread.start();
  }

  // 登录
  public static void Oauth(final Activity currentActivity, String authInfo, boolean isSandbox, final Result callback) {
    if (TextUtils.isEmpty(PID) || TextUtils.isEmpty(APPID)
            || (TextUtils.isEmpty(RSA2_PRIVATE) && TextUtils.isEmpty(RSA_PRIVATE))
            || TextUtils.isEmpty(TARGET_ID)) {
      if (TextUtils.isEmpty(authInfo)) {
        callback.error("授权发生错误：无效的参数", null, null);
        return;
      }
    }

    /*
     * 如果authInfo为空，则在本地计算，正式运行时，建议由服务器生成
     */
    if (TextUtils.isEmpty(authInfo)) {
      boolean rsa2 = (RSA2_PRIVATE.length() > 0);
      Map<String, String> authInfoMap = OrderInfoUtil2_0.buildAuthInfoMap(PID, APPID, TARGET_ID, rsa2);
      String info = OrderInfoUtil2_0.buildOrderParam(authInfoMap);

      String privateKey = rsa2 ? RSA2_PRIVATE : RSA_PRIVATE;
      String sign = OrderInfoUtil2_0.getSign(authInfoMap, privateKey, rsa2);
      authInfo = info + "&" + sign;
    }

    final String _authInfo = authInfo;

    if(isSandbox){
      EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX);
    }

    Runnable authRunnable = new Runnable() {
      @Override
      public void run() {
        try {
          // 构造AuthTask 对象
          AuthTask authTask = new AuthTask(currentActivity);
          // 调用授权接口，获取授权结果
          Map<String, String> result = authTask.authV2(_authInfo, true);
          // 返回
          AuthResult ar = new AuthResult(result, true);

          Map map = new HashMap();
          map.put("openId", ar.getAlipayOpenId());
          map.put("authCode", ar.getAuthCode());
          map.put("memo", ar.getMemo());
          map.put("result", ar.getResult());
          map.put("resultCode", ar.getResultCode());
          map.put("status", ar.getResultStatus());
          callback.success(map);
        }  catch (Exception e) {
          callback.error(e.getMessage(),"授权发生错误", e);
        }
      }
    };

    // 必须异步调用
    Thread authThread = new Thread(authRunnable);
    authThread.start();
  }

}
