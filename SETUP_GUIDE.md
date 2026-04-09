# 快速設置指南 - SQLite 版本

## 🎉 好消息！

**不需要設置 Firebase！** 這個版本使用本地 SQLite 數據庫，完全離線運行，設置超級簡單！

## 第一步：安裝 Flutter

### Linux (Ubuntu/Debian)
```bash
# 下載 Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# 設置環境變量
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# 驗證安裝
flutter doctor
```

### macOS
```bash
# 使用 Homebrew 安裝
brew install --cask flutter

# 驗證安裝
flutter doctor
```

### Windows
1. 下載 Flutter SDK：https://flutter.dev/docs/get-started/install/windows
2. 解壓縮到 C:\flutter
3. 將 C:\flutter\bin 添加到系統 PATH
4. 運行 `flutter doctor`

## 第二步：安裝依賴並運行

```bash
# 進入專案目錄
cd flutter-auth-app

# 安裝依賴
flutter pub get

# 檢查設備
flutter devices

# 運行應用
flutter run
```

## 第三步：測試功能

### 1. 註冊測試帳號
- 點擊「立即註冊」
- 輸入測試 email：test@example.com
- 設置密碼：123456
- 完成註冊 ✅

### 2. 登入測試
- 輸入剛才註冊的 email
- 輸入密碼：123456
- 點擊「登入」
- 成功進入主頁 ✅

### 3. 驗證 Email
- 在主頁點擊「驗證信箱」按鈕
- 狀態變為「信箱已驗證」✅

### 4. 修改密碼
- 點擊「修改密碼」
- 輸入舊密碼：123456
- 輸入新密碼：newpass
- 確認新密碼：newpass
- 點擊「確認修改」✅

### 5. 查看統計
- 點擊「用戶統計」
- 查看總用戶數和驗證狀態 ✅

### 6. 登出測試
- 點擊右上角的登出圖標
- 確認登出
- 返回登入頁面 ✅

## 常見問題

### Q: flutter doctor 顯示錯誤怎麼辦？
A: 根據錯誤提示安裝相應的工具（Android Studio、Xcode 等）

### Q: 數據存儲在哪裡？
A: 
- **Android**: `/data/data/com.example.flutter_auth_app/databases/auth_app.db`
- **iOS**: 應用沙盒的 Documents 目錄

### Q: 如何清除數據庫？
A: 
- 刪除應用並重新安裝
- 或在設備設置中清除應用數據

### Q: iOS 編譯失敗？
A: 確保：
1. 在 macOS 上運行
2. 已安裝 Xcode 和 Command Line Tools
3. 運行 `sudo xcode-select --switch /Applications/Xcode.app`
4. 運行 `pod install` 在 ios/ 目錄中

### Q: Android 編譯失敗？
A: 確保：
1. 已安裝 Android Studio
2. 已接受 Android SDK 條款：`flutter doctor --android-licenses`
3. 設備或模擬器正在運行

### Q: 可以在多個設備上使用同一個帳號嗎？
A: 不可以。這是本地數據庫，每個設備的數據是獨立的。如果需要跨設備同步，需要整合雲端服務（如 Firebase）。

### Q: 密碼安全嗎？
A: 是的！密碼使用 SHA-256 哈希加密存儲，不會以明文保存。

### Q: 應用需要網絡連接嗎？
A: 不需要！這個版本完全離線運行。

## 下一步

✅ 完成基本設置後，你可以：

1. **自定義 UI** - 修改顏色、主題、字體
2. **添加功能** - 用戶資料、設定頁面等
3. **擴展數據庫** - 添加更多表和字段
4. **發布應用** - 打包並發布到 App Store 和 Google Play
5. **添加雲端同步** - 整合 Firebase 或自建後端

## 數據庫管理

### 查看數據庫內容（開發用）

**Android:**
```bash
# 使用 adb 進入設備
adb shell

# 導航到數據庫目錄
cd /data/data/com.example.flutter_auth_app/databases

# 使用 sqlite3 查看
sqlite3 auth_app.db
.tables
SELECT * FROM users;
```

**iOS:**
使用 Xcode 的 Devices 工具或第三方工具查看應用容器。

### 備份數據庫

**Android:**
```bash
# 從設備複製數據庫到電腦
adb pull /data/data/com.example.flutter_auth_app/databases/auth_app.db ~/Desktop/
```

**iOS:**
使用 Xcode 的 Devices 工具下載應用容器。

## 專案結構說明

```
lib/
├── main.dart              # 應用入口，無需特殊配置
├── screens/
│   ├── login_screen.dart         # 登入頁面
│   ├── register_screen.dart      # 註冊頁面
│   ├── forgot_password_screen.dart  # 忘記密碼
│   └── home_screen.dart          # 主頁面
└── services/
    └── auth_service.dart         # 核心邏輯
        ├── _initDatabase()       # 數據庫初始化
        ├── register()            # 註冊
        ├── login()               # 登入
        ├── logout()              # 登出
        └── ...                   # 其他功能
```

## 修改數據庫結構

如果要添加新字段或表，編輯 `lib/services/auth_service.dart`：

```dart
// 在 _initDatabase 中添加新表
await db.execute('''
  CREATE TABLE new_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    value TEXT
  )
''');
```

**注意：** 修改數據庫結構後需要增加版本號並實現遷移邏輯。

## 需要幫助？

- Flutter 文檔：https://flutter.dev/docs
- SQLite 文檔：https://www.sqlite.org/docs.html
- Provider 文檔：https://pub.dev/packages/provider
- 提交 Issue：在專案頁面提交問題

---

**就這樣！不需要 Firebase，不需要複雜配置，開始享受開發吧！** 🚀

**特點：**
- ✅ 零配置
- ✅ 完全離線
- ✅ 本地數據
- ✅ 快速啟動
