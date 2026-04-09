# 快速參考卡 - Flutter Auth App (SQLite 版本)

## 🚀 常用命令

### 安裝依賴
```bash
flutter pub get
```

### 運行應用
```bash
# Android 或 iOS（自動檢測）
flutter run

# 指定設備
flutter run -d <device-id>

# Release 模式
flutter run --release

# Debug 模式（默認）
flutter run --debug
```

### 構建應用
```bash
# Android APK
flutter build apk

# Android App Bundle（推薦）
flutter build appbundle

# iOS（僅 macOS）
flutter build ios

# Web
flutter build web
```

### 檢查設備
```bash
flutter devices
```

### 清理構建
```bash
flutter clean
```

### 升級依賴
```bash
flutter pub upgrade
```

## 🔧 檢查清單

### ✅ 開發環境設置
- [ ] Flutter SDK 已安裝
- [ ] Android Studio 已安裝（開發 Android）
- [ ] Xcode 已安裝（開發 iOS，僅 macOS）
- [ ] 設備或模擬器正在運行
- [ ] `flutter doctor` 無嚴重錯誤

### ✅ 專案設置
- [ ] 已運行 `flutter pub get`
- [ ] 依賴包安裝成功
- [ ] 數據庫會自動創建（無需手動配置）

## 📱 應用功能清單

### 用戶認證
- [x] 用戶註冊（email + password）
- [x] 用戶登入
- [x] 用戶登出
- [x] Email 驗證（本地模擬）
- [x] 忘記密碼（模擬發送）
- [x] 修改密碼
- [x] 刪除帳號

### UI 頁面
- [x] 登入頁面 (`login_screen.dart`)
- [x] 註冊頁面 (`register_screen.dart`)
- [x] 忘記密碼頁面 (`forgot_password_screen.dart`)
- [x] 主頁面 (`home_screen.dart`)

### 功能特性
- [x] 密碼顯示/隱藏
- [x] 表單驗證
- [x] 加載狀態
- [x] 錯誤提示（Toast）
- [x] 自動登入狀態管理
- [x] Email 驗證狀態檢查
- [x] 用戶統計信息
- [x] 應用信息展示

## 🐛 常見錯誤及解決方案

### 錯誤: Flutter SDK not found
```bash
# 解決方案：設置環境變量
export PATH="$PATH:/path/to/flutter/bin"
# 或添加到 ~/.bashrc 或 ~/.zshrc
```

### 錯誤: No devices found
```bash
# 解決方案：啟動模擬器或連接設備
# Android
flutter emulators
flutter emulators --launch <emulator_id>

# iOS（僅 macOS）
open -a Simulator
```

### 錯誤: CocoaPods not installed (iOS)
```bash
# 解決方案：安裝 CocoaPods
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### 錯誤: Gradle build failed
```bash
# 解決方案：清理並重建
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 錯誤: Database is locked
```bash
# 解決方案：重啟應用或設備
# 數據庫鎖定通常會自動解鎖
```

### 錯誤: No such table
```bash
# 解決方案：清除應用數據並重啟
# Android: 設置 → 應用 → 清除數據
# iOS: 刪除應用並重新安裝
```

## 📦 依賴包版本

```yaml
sqflite: ^2.3.0           # SQLite 數據庫
path: ^1.8.3              # 路徑操作
crypto: ^3.0.3            # 密碼加密（SHA-256）
provider: ^6.1.1          # 狀態管理
shared_preferences: ^2.2.2  # 會話存儲
fluttertoast: ^8.2.4      # 提示訊息
```

## 🔐 安全檢查清單

- [ ] 密碼使用 SHA-256 加密
- [ ] 密碼最小長度 6+
- [ ] Email 格式驗證已啟用
- [ ] Email 唯一性約束
- [ ] 敏感操作需要確認（登出）
- [ ] 數據庫不存儲明文密碼

## 📊 測試清單

### 功能測試
- [ ] 註冊新帳號
- [ ] 使用註冊帳號登入
- [ ] 測試錯誤的密碼
- [ ] 測試未註冊的 email
- [ ] 發送密碼重設連結
- [ ] 驗證 Email
- [ ] 修改密碼
- [ ] 查看用戶統計
- [ ] 登出功能
- [ ] 自動登入（重啟應用）

### UI 測試
- [ ] 所有頁面顯示正常
- [ ] 按鈕點擊響應
- [ ] 輸入驗證訊息正確
- [ ] 加載動畫顯示
- [ ] 錯誤提示顯示
- [ ] 頁面導航流暢

### 平台測試
- [ ] Android 模擬器運行正常
- [ ] Android 真機運行正常
- [ ] iOS 模擬器運行正常（如果有 Mac）
- [ ] iOS 真機運行正常（如果有 Mac）

### 數據庫測試
- [ ] 數據庫正確創建
- [ ] 用戶數據正確存儲
- [ ] 密碼正確加密
- [ ] 會話正確管理
- [ ] 數據持久化（重啟應用）

## 🎨 自定義快速指南

### 修改應用名稱
```dart
// Android: android/app/src/main/AndroidManifest.xml
android:label="你的應用名稱"

// iOS: ios/Runner/Info.plist
<key>CFBundleDisplayName</key>
<string>你的應用名稱</string>
```

### 修改主題顏色
```dart
// lib/main.dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yourColor, // 修改這裡
  ),
  useMaterial3: true,
),
```

### 修改包名
```bash
# Android: 修改以下文件
# - android/app/build.gradle (applicationId)
# - android/app/src/main/AndroidManifest.xml (package)

# iOS: 修改 Bundle ID
# - ios/Runner.xcodeproj/project.pbxproj
# - ios/Runner/Info.plist
```

### 修改數據庫結構
```dart
// lib/services/auth_service.dart
// 在 _initDatabase() 方法中修改

await db.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    -- 添加新字段
    username TEXT,
    phone TEXT,
    emailVerified INTEGER DEFAULT 0,
    createdAt INTEGER NOT NULL,
    lastLoginAt INTEGER
  )
''');
```

## 📁 數據庫位置

### Android
```
/data/data/com.example.flutter_auth_app/databases/auth_app.db
```

### iOS
```
<App Container>/Documents/auth_app.db
```

### 查看數據庫（開發用）

**Android:**
```bash
adb shell
cd /data/data/com.example.flutter_auth_app/databases
sqlite3 auth_app.db
```

**iOS:**
使用 Xcode 的 Devices 工具或第三方工具。

## 📚 重要文件路徑

```
主程式入口         → lib/main.dart
認證服務           → lib/services/auth_service.dart
登入頁面           → lib/screens/login_screen.dart
註冊頁面           → lib/screens/register_screen.dart
忘記密碼頁面       → lib/screens/forgot_password_screen.dart
主頁面             → lib/screens/home_screen.dart
依賴配置           → pubspec.yaml
Android 權限       → android/app/src/main/AndroidManifest.xml
Android 構建       → android/app/build.gradle
本地數據庫         → 應用沙盒/databases/auth_app.db
```

## 🔧 數據庫操作速查

### 查詢用戶
```dart
final users = await db.query('users');
```

### 插入用戶
```dart
await db.insert('users', {
  'email': 'test@example.com',
  'password': hashedPassword,
  'emailVerified': 0,
  'createdAt': now,
});
```

### 更新用戶
```dart
await db.update(
  'users',
  {'emailVerified': 1},
  where: 'id = ?',
  whereArgs: [userId],
);
```

### 刪除用戶
```dart
await db.delete(
  'users',
  where: 'id = ?',
  whereArgs: [userId],
);
```

## 🔗 有用連結

- [Flutter 官方文檔](https://flutter.dev/docs)
- [SQLite 官方文檔](https://www.sqlite.org/docs.html)
- [sqflite Package](https://pub.dev/packages/sqflite)
- [Provider Package](https://pub.dev/packages/provider)
- [crypto Package](https://pub.dev/packages/crypto)

## 💡 開發技巧

### 調試數據庫
```dart
// 在 auth_service.dart 中添加
print('數據庫路徑: ${db.path}');
print('用戶數: ${(await db.query('users')).length}');
```

### 重置應用
```bash
# 清除所有數據並重新開始
flutter clean
flutter pub get
# 然後在設備上刪除應用並重新安裝
```

### 查看日誌
```bash
# 查看所有日誌
flutter logs

# 查看特定標籤的日誌
flutter logs | grep "數據庫"
```

---

**記住：SQLite 版本不需要 Firebase，完全離線運行！** 🚀
