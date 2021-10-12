## 友验 iOS SDK 文档

> 基于虚拟机保护、设备特征识别和操作行为识别的新一代智能验证码，具备智能评分、抗 Headless、模拟伪装、针对恶意设备自动提升验证难度等多项安全措施，帮助开发者减少恶意攻击导致的数字资产损失，强力护航业务安全。

### 目录
- [兼容性](#Compatibility)
- [安装](#Installation)
- [编译(自定义)](#Compile)
- [API](#API)

#### <a name="Compatibility">兼容性</a>

- iOS >= 9.0

#### <a name="Installation">安装</a>

- 使用 xcframework (推荐)
	
下载最新 tag，将 YoTest-iOS-SDK/Product 文件夹下的 YoTestSDK.xcframework 拖到您的工程目录里，并将动态库设置成 Embed&Sign。
	
操作如下：
	
<img src="./Res/install.gif" alt="show" />

#### <a name="Compile">编译(自定义)</a>

若有自定义更改 SDK 的需求，可将仓库克隆到本地，自行修改后，执行编译脚本打包 SDK


```
git clone https://github.com/YoTest-team/YoTest-iOS-SDK.git
cd YoTest-iOS-SDK
./build.sh
```


操作如下:

<img src="./Res/build.gif" alt="show" />

# 使用说明

[参考这里](./Capture/README.md)