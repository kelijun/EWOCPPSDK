# 🇬🇧 EWOCPPSDK Integration Guide
## 1. Introduction
EWOCPPSDK is a comprehensive protocol library designed for iOS to manage and control charging stations locally. It provides a full suite of features including BLE connection, network configuration, RFID card management, charging control, and OTA upgrades.

**Requirements:**
- iOS 15.0+
- Swift 5.0+

## 2. Initialization & Setup

#### 2.1 Singleton & Logging
All core functionalities are accessed via the `EWOCPPManager` singleton. It is recommended to adjust the log level during the development phase.

```swift
// Set log level (Recommend .error or .none for release, .debug for development)
EWOCPPManager.logLevel = .debug

let manager = EWOCPPManager.shared
```
#### 2.2 Bluetooth Configuration
Please first scan for and obtain the target device (`EWPeripheral`) using `EWCentralManager`.
```swift
//  Configure threads, if it is a child thread, be sure to switch to the main thread to refresh the UI
let queue = DispatchQueue(label: "com.ocpp", attributes: .concurrent)

// Filter names
let filterInfo = EWBluetoothFilterInfo()
filterInfo.matchName = "OCPP"
filterInfo.matchNameWay = .prefixIgnoreCase
EWCentralManager.share().clearConfigure()
EWCentralManager.share().configureManagerQueue()(queue)

// Implement the delegate
EWCentralManager.share().configureManagerDelegate()(self)
EWCentralManager.share().configureManagerFilterInfos()([filterInfo])
```
### 2.3 Bluetooth Scanning
Start and stop scanning for Bluetooth devices.
```swift
// Start scanning
EWCentralManager.share().scanForPeripherals()

// Stop scanning
EWCentralManager.share().stopScan()
```
### 2.4 Implementing the Delegate
Ensure your class conforms to the `EWCentralManagerDelegate` protocol and implements the required callback methods to handle connection states.  
- **Device Discovered:** `ewCentralManager(_:didDiscover:)`

- **Connection Successful:** `ewCentralManager(_:didConnect:)`

- **Connection Failed::** `ewCentralManager(_:didFailToConnect:)`

- **Disconnected:** `ewCentralManager(_:didDisconnectPeripheral:)`

### 2.5 Establishing Connection
Once successfully connected to the peripheral via the delegate, pass the peripheral to the OCPP Manager to establish the protocol connection.
```swift
// Note: ewOCPPStart() is deprecated. Please use establishOcppConnection.
manager.establishOcppConnection(peripheral: targetPeripheral)
```

## 3. Core Modules

### 3.1 Charging Control
Control the start/stop of charging, adjust current, and fetch real-time status.

- **Start Charging:** `startCharging(ampere:completion:)` (Note: Minimum 5s interval required between commands)

- **Stop Charging:** `stopCharging(completion:)`

- **Adjust Current:** `adjustCurrent(ampere:completion:)`

- **Get Real-time Info:** `getChargeInfo(completion:)`

- **Max Current Limit:**
  - **Read:** `readCurrentLimitValue(completion:)`
  - **Write:** `setCurrentLimit(_:echo:completion:)`

### 3.2 Network & Device Info
Retrieve hardware/software versions and configure network settings.

- **Read Device Info:** `readDeviceInfo(completion:)` (Returns `DeviceInfo` including HW/SW versions, Wi-Fi/4G status, etc.)

- **Configure Network:** `ewOCPPConfigNet(ch:ssid:psw:completion:)` (Supports WIFI, ETHERNET, LTE, OFFLINE)

- **Check Network State:** `ewOCPPNetworkState(reset:completion:)`

### 3.3 OCPP Configuration
Read and modify standard OCPP parameters on the charging station.

- **Read Config:** `readBaseConfiguration(completion:)

- **Write Config:** `setBaseConfiguration(configuration:completion:) (Pass the modified `BaseConfiguration` model)

### 3.4 RFID Card Management
Manage the local authorization whitelist.

- **Read All Cards:** `readRFIDCards(completion:)`

- **Write Cards:** `writeRFIDCards(cards:completion:)` (Supports batch writing)

- **Clear All Cards:** `clearAllRFIDCards(completion:)`

### 3.5 Records & Alerts
- **Read Cached Orders:** `readCachedOrderCount(completion:)` / `readAllCachedOrders(completion:)`

- **Read Error Records::** `readErrorReportCount(completion:)` / `readErrorRecords(completion:)`

- **Configure Alerts:** `setErrorConfig(type:errorIndices:warningIndices:completion:)`
>💡 Note: For the detailed error code correspondence and descriptions, please refer to the attached `Fault_Error_Code_Comparison_Table.md` file.

### 3.6 OTA Upgrades
Supports both Bluetooth and Local Area Network (LAN) firmware upgrades.

- **Bluetooth OTA:** `startOTAUpgrade(fileURL:type:progress:completion:)`

- **LAN OTA:** `startLANOTAUpgrade(ipAddress:fileURL:progress:completion:)`

### 3.7 Device Control
- **Restart Device:** `restartDevice(completion:)`

- **Factory Reset:** `resetDevice(completion:)`