YoTest-iOS-SDK 文档
----

> 基于虚拟机保护、设备特征识别和操作行为识别的新一代智能验证码，具备智能评分、抗 Headless、模拟伪装、针对恶意设备自动提升验证难度等多项安全措施，帮助开发者减少恶意攻击导致的数字资产损失，强力护航业务安全。

* [兼容性](https://github.com/YoTest-team/YoTest-iOS-SDK#%E5%85%BC%E5%AE%B9%E6%80%A7)
* [安装](https://github.com/YoTest-team/YoTest-iOS-SDK#%E5%AE%89%E8%A3%85)
* [编译(自定义)](https://github.com/YoTest-team/YoTest-iOS-SDK#%E7%BC%96%E8%AF%91%E8%87%AA%E5%AE%9A%E4%B9%89)
* [快速开始](https://github.com/YoTest-team/YoTest-iOS-SDK#%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
* [API](#API)

### 兼容性

* iOS >= 9.0
* Swift（若需要使用OC，可以自行添加桥接代码）

### 安装

* 使用[xcframework](https://github.com/bielikb/xcframeworks)（推荐）
	
下载最新[Tag](https://github.com/bielikb/xcframeworks/releases)，将[YoTest-iOS-SDK/Product](https://github.com/YoTest-team/YoTest-iOS-SDK/tree/main/Product/YoTestSDK.xcframework)文件夹下的YoTestSDK.xcframework拖到您的工程目录里，并将动态库设置成 Embed&Sign，操作如下所示：
	
<img src="./Res/install.gif" alt="show" />

* 使用[CocoaPods](https://cocoapods.org/)

在 Podfile 中添加`pod 'YoTestSDK', '1.0.1'`并执行 `pod insall` 进行安装。

### 编译(自定义)

若有自定义更改SDK的需求，你可将仓库克隆到本地，自行修改后执行编译脚本打包，操作如下：

```shell
➜  git clone https://github.com/YoTest-team/YoTest-iOS-SDK.git
➜  cd YoTest-iOS-SDK
➜  ./build.sh
```

<img src="./Res/build.gif" alt="show" />

编译好后，可以按照[安装](https://github.com/YoTest-team/YoTest-iOS-SDK#%E5%AE%89%E8%A3%85)中的步骤，添加到工程项目中

### 快速开始

第一步，克隆最新Tag代码（不使用[CocoaPods](https://cocoapods.org/)）

```shell
➜ git clone -b 1.0.1 --depth=1 https://github.com/YoTest-team/YoTest-iOS-SDK.git
```

下载好后按照[安装](https://github.com/YoTest-team/YoTest-iOS-SDK#%E5%AE%89%E8%A3%85)中的步骤添加到工程项目中（若您使用的是[CocoaPods](https://cocoapods.org/)，在Podfile中添加 `pod 'YoTestSDK', '1.0.1'`并执行 `pod insall` 进行安装）。

第二步，在 Appdelegate 中添加注册 SDK 的代码，如图所示：

```swift
YoTest.registSDK(auth: .init(accessId: "在这里填写你的 accessId")) { success in
    print("regist success: \(success)")
}
```

<img src="./Res/import.gif" alt="show" />

第三步，在给验证码页面添加 `YoTestDelegate` 并实现以下代理方法：

```swift
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

第四步，在需要弹出验证的逻辑中加入声明属性 `var captcha: YoTest?` 代码：

```swift
if captcha == nil {
    do {
        captcha = try YoTest(with: self)
    } catch {
        print("error: \(error)")
    }
}
captcha?.verify()
```

### API

YoTest类：

* [public static func registSDK(auth\:on\:)](#registSDK)
* [public static func destroy()](#destroy)
* [public init(with:) throws](#YoTest.init)
* [public func verify()](#verify)
* [public func close()](#close)
* [public func cancel()](#cancel)
* [public weak var delegate: YoTestDelegate?](#delegate)
* [public var autoShowLoading: Bool](#autoShowLoading)
* [public var autoShowToast: Bool](#autoShowToast)

YoTest.Auth结构体：

* [public init(accessId:)](#Auth.init)

[YoTest.YTError](#YTError)

* [public let code: Code](#code)

YoTest.YTError.Code枚举：

* [case requesting](#Code.requesting)
* [case unavailable](#Code.unavailable)

YoTestDelegate协议：

* [public func onReady(args:)](#onReady)
* [public func onSuccess(args:)](#onSuccess)
* [public func onShow(args:)](#onShow)
* [public func onError(args:)](#onError)
* [public func onClose(args:)](#onClose)

#### public static func registSDK(auth: YoTest.Auth, on: @escaping (Bool) -> Void)
- auth \<YoTest.Auth\>
- on \<@escaping (Bool) -> Void\> 注册完成结果回调，成功返回true，否则返回false

注册SDK，需要在使用SDK进行人机验证前调用。可以添加到AppDelegate中，启动 App 时注册

#### public static func destroy()

销毁资源。不再使用SDK时，可以调用 YoTest.destroy() 方法来回收部分资源

#### public init(with: YoTestDelegate?) throws

- with \<YoTestDelegate\>
- throws \<YTError\>

初始化 YoTest 实例对象。

#### public func verify()

调起验证界面

#### public func close()

关闭验证界面

#### public func cancel()

取消验证

#### public weak var delegate: YoTestDelegate?

代理对象

#### public var autoShowLoading: Bool

是否显示 SDK 提供的 loading，默认为true，可以设置为false来关闭

#### public var autoShowToast: Bool

是否显示SDK提供的Toast，默认为true，可以设置为false来关闭

#### public init(accessId: String)

- accessId \<String\> 友验后台申请的accessId

初始化 Auth 对象。

#### public let code: Code

错误码类型请参考如下表格：

|      错误码         |    描述   |
| ------------- | ---------- |
|    case requesting   |  正在请求授权 |
|    case unavailable  |  SDK不可用，请检查accessId是否正确，网络是否通畅 |


#### public func onReady(args: [String: Any])

验证已准备就绪的回调

#### public func onSuccess(args: [String: Any])

验证成功时的回调

#### public func onShow(args: [String: Any])

验证弹框即将显示的回调

#### public func onError(args: [String: Any])

验证错误回调

#### public func onClose(args: [String: Any])

验证关闭时回调