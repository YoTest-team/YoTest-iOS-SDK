## 友验 iOS SDK 文档

> 基于虚拟机保护、设备特征识别和操作行为识别的新一代智能验证码，具备智能评分、抗 Headless、模拟伪装、针对恶意设备自动提升验证难度等多项安全措施，帮助开发者减少恶意攻击导致的数字资产损失，强力护航业务安全。

### 目录
- [兼容性](#Compatibility)
- [安装](#Installation)
- [编译(自定义)](#Compile)
- [快速开始](#QuickStart)
- [API](#API)

#### <a name="Compatibility">兼容性</a>

- iOS >= 9.0
- swift(若需要使用OC，可以自行添加桥接代码)

#### <a name="Installation">安装</a>

- 使用 xcframework (推荐)
	
下载最新 tag，将 YoTest-iOS-SDK/Product 文件夹下的 YoTestSDK.xcframework 拖到您的工程目录里，并将动态库设置成 Embed&Sign。
	
操作如下：
	
<img src="./Res/install.gif" alt="show" />

- 使用 cocoapods

在 Podfile 中添加	 `pod 'YoTestSDK', '1.0.1'`

执行 `pod insall` 进行安装

#### <a name="Compile">编译(自定义)</a>

若有自定义更改 SDK 的需求，可将仓库克隆到本地，自行修改后，执行编译脚本打包 SDK


```
git clone https://github.com/YoTest-team/YoTest-iOS-SDK.git
cd YoTest-iOS-SDK
./build.sh
```


操作如下:

<img src="./Res/build.gif" alt="show" />

编译好后，可以按照[安装](#Installation)中的步骤，添加到工程项目中

#### <a name="QuickStart">快速开始</a>

* 第一步，克隆最新 tag 代码(不使用cocoapods)

```
git clone -b 1.0.1 --depth=1 https://github.com/YoTest-team/YoTest-iOS-SDK.git
```

下载好后按照[安装](#Installation)中的步骤，添加到工程项目中

若您使用的是 cocoapods，在 Podfile 中添加 `pod 'YoTestSDK', '1.0.1'`

执行 `pod insall` 进行安装

* 第二步，在项目中引用 SDK

在 Appdelegate 中添加注册 SDK 的代码

```
YoTest.registSDK(auth: .init(accessId: "在这里填写你的 accessId")) { success in
    print("regist success: \(success)")
}
```

<img src="./Res/import.gif" alt="show" />

* 第三步，设置代理

在给验证码页面添加 `YoTestDelegate` 并实现以下代理方法：

```
func onSuccess(args: [String : Any]) {
    print("onSuccess args: \(args)")
}
    
func onReady(args: [String : Any]) {
    print("onReady args: \(args)")
}
    
func onShow(args: [String : Any]) {
    print("onShow args: \(args)")
}
    
func onClose(args: [String : Any]) {
    print("onClose args: \(args)")
    captcha?.close()
}
    
func onError(args: [String : Any]) {
    print("onError args: \(args)")
}
```

* 第四步，在验证页面添加验证逻辑

声明属性 `var captcha: YoTest?`

在需要弹出验证的逻辑中加入以下代码

```
if captcha == nil {
    do {
        captcha = try YoTest(with: self)
    } catch {
        print("error: \(error)")
    }
}
captcha?.verify()
```

#### <a name="API">API</a>

--

类：

[YoTest](#YoTest)

- [public static func registSDK(auth:on:)](#registSDK)
- [public static func destroy()](#destroy)
- [public init(with:) throws](#YoTest.init)
- [public func verify()](#verify)
- [public func close()](#close)
- [public func cancel()](#cancel)
- [public weak var delegate: YoTestDelegate?](#delegate)
- [public var autoShowLoading: Bool](#autoShowLoading)
- [public var autoShowToast: Bool](#autoShowToast)

结构体：

[YoTest.Auth](#Auth)

- [public init(accessId:)](#Auth.init)

[YoTest.YTError](#YTError)

- [public let code: Code](#code)

枚举：

[YoTest.YTError.Code](#Error.Code)

- [case requesting](#Code.requesting)
- [case unavailable](#Code.unavailable)

协议：

[YoTestDelegate](#YoTestDelegate)

- [public func onReady(args:)](#onReady)
- [public func onSuccess(args:)](#onSuccess)
- [public func onShow(args:)](#onShow)
- [public func onError(args:)](#onError)
- [public func onClose(args:)](#onClose)

--

<a name="YoTest">YoTest</a>

- <a name="registSDK">public static func registSDK(auth: YoTest.Auth, on: @escaping (Bool) -> Void)</a>

注册 SDK，需要在使用 SDK 进行人机验证前调用。可以添加到 AppDelegate 中，启动 App 时注册。

参数 auth: [YoTest.Auth](#Auth)

参数 on: @escaping (Bool) -> Void。注册完成结果回调，成功返回 true，否则返回 false

***

- <a name="destroy">public static func destroy()</a>

销毁资源。不再使用SDK时，可以调用 YoTest.destroy() 方法来回收部分资源

***

- <a name="YoTest.init">public init(with: YoTestDelegate?) throws</a>

初始化 YoTest 实例对象。

参数 with: [YoTestDelegate?](#delegate)

throws: [YTError](#YTError)

***

- <a name="verify">public func verify()</a>

调起验证界面

***

- <a name="close">public func close()</a>

关闭验证界面

***

- <a name="cancel">public func cancel()</a>

取消验证

***

- <a name="delegate">public weak var delegate: YoTestDelegate?</a>

代理对象

***

- <a name="autoShowLoading">public var autoShowLoading: Bool</a>

是否显示 SDK 提供的 loading。默认为 true，可以设置为 false 来关闭。

***

- <a name="autoShowToast">public var autoShowToast: Bool</a>

是否显示 SDK 提供的 toast。默认为 true，可以设置为 false 来关闭。

--
<a name="Auth">YoTest.Auth</a>

- <a name="Auth.init">public init(accessId: String)</a>

初始化 Auth 对象。

参数 accessId：String 友验后台申请的 accessId

***
<a name="YTError">YoTest.YTError</a>

- <a name="code">public let code: Code</a>

[错误类型](#Error.Code)

--

<a name="Error.Code">YoTest.YTError.Code</a>

- <a name="Code.requesting">case requesting</a>

错误码：正在请求授权

- <a name="Code.unavailable">case unavailable</a>

错误码：SDK 不可用。请检查 accessId 是否正确。网络是否通畅。

--

<a name="YoTestDelegate">YoTestDelegate</a>

SDK 验证回调代理协议


- <a name="onReady">public func onReady(args: [String: Any])</a>

人机智能验证准备好时回调

- <a name="onSuccess">public func onSuccess(args: [String: Any])</a>

人机智能验证成功时回调

- <a name="onShow">public func onShow(args: [String: Any])</a>

显示人机验证界面时回调

- <a name="onError">public func onError(args: [String: Any])</a>

人机智能验证错误回调

- <a name="onClose">public func onClose(args: [String: Any])</a>

人机智能验证关闭时回调