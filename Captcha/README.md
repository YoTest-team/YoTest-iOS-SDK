#  友验 SDK 使用说明

1. 调用 YoTest.registSDK(auth:on) 进行 SDK 注册。
2. 注册 SDK 成功回调后初始化 YoTest 对象。let x = YoTest.init(with:)。
3. 调用验证方法 x.verify()。
4. 验证完成后，调用 x.close() 关闭验证码页面

完整使用逻辑可以参照以下代码：

AppDelegate

application(_:didFinishLaunchingWithOptions:)->Bool

```
YoTest.RegistSDK(auth: Auth(accessId: "Your accessId")) { success in
    // TODO: 如果成功了，可以初始化 YoTest 实例对象
}
```

验证页面

```
var x: YoTest?
```

点击验证时


```
if x == nil {
    do {
    x = try YoTest(with: delegate)
    } catch {
        print("\(error)")
        return
    }
}
x?.verify()
```


具体实例，可以参照 Demo。
