# 🇨🇳 EWOCPPSDK 接入说明文档
## 1. 简介
EWOCPPSDK 是一套专为 iOS 平台设计的充电桩本地化管理与控制协议库。它提供了从低功耗蓝牙 (BLE) 连接、网络配置、RFID 卡片管理、充电控制到 OTA 升级的全套功能。

## 2. 安装指南 (Installation)
EWOCPPSDK 推荐采用 CocoaPods 进行私有化接入。由于 SDK 包含底层闭源二进制框架，请**务必严格按照以下步骤**配置主工程的 `Podfile`，以避免编译崩溃或底层依赖冲突。

### 2.1 环境要求
- iOS 12.0 及以上
- Swift 5.0 及以上

### 2.2 配置 Podfile
```ruby
platform :ios, '15.0'

use_frameworks!

target 'YourAppTargetName' do
  pod 'EWOCPPSDK'
  # 请将 tag 替换为 SDK 最新发布的版本号
  pod 'EWOCPPSDK', :git => '[https://github.com/kelijun/EWOCPPSDK.git](https://github.com/kelijun/EWOCPPSDK.git)', :tag => '1.0.0'
end

# 🌟 必须配置：开启所有底层依赖的模块稳定性，防止因 Xcode 版本不同导致 Signal 6 崩溃
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end

## 2. 初始化与配置

#### 2.1 获取单例与日志配置
SDK 的所有核心功能均通过`EWOCPPManager` 的单例调用。在开发阶段，建议调整日志级别以方便调试。

```swift
// 设置日志级别（推荐 release 环境设置为 .error、.info、.none）
EWOCPPManager.logLevel = .info

let manager = EWOCPPManager.shared
```

#### 2.2 蓝牙配置
请先通过 `EWCentralManager` 扫描获取目标设备（`EWPeripheral`）。
```swift
// 配置线程，如果是子线程，务必切换主线程刷新 UI / Configure threads, if it is a child thread, be sure to switch to the main thread to refresh the UI
let queue = DispatchQueue(label: "com.ocpp", attributes: .concurrent)

// 过滤名字 / Filter names
let filterInfo = EWBluetoothFilterInfo()
filterInfo.matchName = "OCPP"
filterInfo.matchNameWay = .prefixIgnoreCase
EWCentralManager.share().clearConfigure()
EWCentralManager.share().configureManagerQueue()(queue)

// 遵守代理 / Implement the delegate
EWCentralManager.share().configureManagerDelegate()(self)
EWCentralManager.share().configureManagerFilterInfos()([filterInfo])
```

### 2.3 扫描蓝牙
扫描蓝牙和停止扫描蓝牙。
```swift
// 开始扫描 / Start scanning
EWCentralManager.share().scanForPeripherals()

// 停止扫描 / Stop scanning
EWCentralManager.share().stopScan()
```

### 2.4 实现代理
请务必遵守 `EWCentralManagerDelegate` 协议，并实现其中的方法。  
- **发现设备:** `ewCentralManager(_:didDiscover:)`

- **连接成功:** `ewCentralManager(_:didConnect:)`

- **连接失败:** `ewCentralManager(_:didFailToConnect:)`

- **断开连接:** `ewCentralManager(_:didDisconnectPeripheral:)`

### 2.5 建立连接
```swift
// 注意：ewOCPPStart() 已被废弃，请使用 establishOcppConnection
manager.establishOcppConnection(peripheral: targetPeripheral)
```

## 3. 核心功能模块

### 3.1 充电控制 (Charging Control)
控制充电桩的启停、电流调节及实时状态获取。

- **开始充电:** `startCharging(ampere:completion:)` (注：指令间隔需大于 5 秒)

- **停止充电:** `stopCharging(completion:)`

- **调节电流:** `adjustCurrent(ampere:completion:)`

- **获取实时数据:** `getChargeInfo(completion:)`

- **最大电流限制:**
  - **读取:** `readCurrentLimitValue(completion:)`
  - **设置:** `setCurrentLimit(_:echo:completion:)`

### 3.2 网络与设备信息 (Network & Device)
获取设备软硬件版本及配置配网信息。

- **读取设备信息:** `readDeviceInfo(completion:)` (返回 `DeviceInfo`，包含软硬件版本、Wi-Fi/4G 状态等)

- **配置网络:** `ewOCPPConfigNet(ch:ssid:psw:completion:)` (支持 WIFI, ETHERNET, LTE, OFFLINE)

- **查询网络状态:** `ewOCPPNetworkState(reset:completion:)`

### 3.3 OCPP 基础配置 (OCPP Configuration)
读取与修改桩端的 OCPP 标准参数。

- **读取配置:** `readBaseConfiguration(completion:)

- **写入配置:** `setBaseConfiguration(configuration:completion:) (传入修改后的 `BaseConfiguration` 模型)

### 3.4 RFID 卡片管理 (RFID Management)
管理本地白名单/鉴权卡片。

- **读取所有卡片:** `readRFIDCards(completion:)`

- **写入卡片:** `writeRFIDCards(cards:completion:)` (支持批量写入)

- **清空卡片:** `clearAllRFIDCards(completion:)`

### 3.5 订单与异常记录 (Records & Alerts)
- **订单读取:** `readCachedOrderCount(completion:)` / `readAllCachedOrders(completion:)`

- **异常记录读取:** `readErrorReportCount(completion:)` / `readErrorRecords(completion:)`

- **告警参数配置:** `setErrorConfig(type:errorIndices:warningIndices:completion:)`
> 💡 **附注：** 详细的错误码对应关系及说明，请参考随附的 `Fault_Error_Code_Comparison_Table.md` 文件。

### 3.6 OTA 升级 (OTA Upgrade)
支持蓝牙与局域网两种固件升级方式。

- **蓝牙 OTA:** `startOTAUpgrade(fileURL:type:progress:completion:)`

- **局域网 OTA:** `startLANOTAUpgrade(ipAddress:fileURL:progress:completion:)`

### 3.7 设备基础控制 (Device Control)
- **重启设备:** `restartDevice(completion:)`

- **恢复出厂设置:** `resetDevice(completion:)`