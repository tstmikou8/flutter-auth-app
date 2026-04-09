# Flutter Auth App - SQLite 版本

一個完整的 Flutter 跨平台登入應用程式，支援 iOS 和 Android，使用 **本地 SQLite 數據庫**進行用戶認證，**完全離線運行**！

## ✨ 功能特色

- 🔐 **用戶註冊** - 使用 email 註冊新帳號
- 🔑 **用戶登入** - 使用 email 和密碼登入
- 🔒 **忘記密碼** - 模擬發送密碼重設連結
- ✉️ **Email 驗證** - 本地驗證機制（可擴展為真實郵件驗證）
- 🚪 **登出功能** - 安全登出並清除會話
- 🔐 **修改密碼** - 登入後可修改密碼
- 📊 **用戶統計** - 查看總用戶數和驗證狀態
- 📱 **跨平台** - 同時支援 iOS 和 Android
- 🎨 **現代化 UI** - Material Design 3 設計
- 🔔 **即時通知** - 使用 FlutterToast 顯示操作結果
- 💾 **完全離線** - 不需要網絡連接
- 🔒 **密碼加密** - 使用 SHA-256 哈希加密

## 🛠️ 技術棧

- **Flutter** - 跨平台 UI 框架
- **SQLite** - 本地關係型數據庫
- **Provider** - 狀態管理
- **SharedPreferences** - 本地會話存儲
- **Crypto (SHA-256)** - 密碼加密
- **FlutterToast** - 提示訊息

## 📋 前置需求

1. **Flutter SDK** (3.0.0 或更高版本)
   ```bash
   # 檢查 Flutter 安裝
   flutter --version
   ```

2. **Android Studio** (開發 Android)
   - 安裝 Android SDK
   - 設置 Android 模擬器或連接真機

3. **Xcode** (開發 iOS，僅 macOS)
   - 安裝 Xcode Command Line Tools
   - 設置 iOS 模擬器

## 🚀 快速開始

### 1. 安裝依賴

```bash
cd flutter-auth-app
flutter pub get
```

### 2. 運行應用

#### Android
```bash
flutter run
```

#### iOS (僅 macOS)
```bash
flutter run
```

## 📁 專案結構

```
lib/
├── main.dart                 # 應用程式入口
├── screens/                  # 頁面
│   ├── login_screen.dart     # 登入頁面
│   ├── register_screen.dart  # 註冊頁面
│   ├── forgot_password_screen.dart  # 忘記密碼頁面
│   └── home_screen.dart      # 主頁面（登入後）
└── services/
    └── auth_service.dart     # 認證服務 + SQLite 操作
```

## 🗄️ 數據庫結構

### users 表
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,        -- SHA-256 哈希
  emailVerified INTEGER DEFAULT 0,
  createdAt INTEGER NOT NULL,
  lastLoginAt INTEGER
)
```

### sessions 表（預留擴展）
```sql
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId INTEGER NOT NULL,
  token TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  expiresAt INTEGER NOT NULL,
  FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
)
```

## 🎯 使用說明

### 註冊新帳號
1. 啟動應用後，點擊「立即註冊」
2. 輸入有效的 email 地址
3. 設置密碼（至少 6 個字元）
4. 確認密碼
5. 點擊「註冊」
6. 帳號創建成功（默認未驗證）

### 登入
1. 輸入已註冊的 email
2. 輸入密碼
3. 點擊「登入」
4. 登入成功後進入主頁

### 驗證 Email
1. 登入後，在主頁點擊「驗證信箱」按鈕
2. 系統會模擬驗證成功
3. 狀態更新為「信箱已驗證」

### 修改密碼
1. 登入後，點擊「修改密碼」
2. 輸入舊密碼
3. 輸入新密碼
4. 確認新密碼
5. 點擊「確認修改」

### 忘記密碼
1. 在登入頁面點擊「忘記密碼？」
2. 輸入您的 email
3. 點擊「發送重設連結」
4. 系統會模擬發送重設連結

### 登出
1. 點擊右上角的登出圖標
2. 或在主頁面點擊「登出」按鈕
3. 確認登出

## 🔒 安全性

### 密碼加密
- ✅ 使用 **SHA-256** 哈希加密
- ✅ 密碼不以明文存儲
- ✅ 哈希不可逆轉

### 數據安全
- ✅ 密碼最小長度：6 個字元
- ✅ Email 格式驗證
- ✅ Email 唯一性約束
- ✅ 本地數據庫，不傳輸到外部

### 會話管理
- ✅ 使用 SharedPreferences 存儲會話
- ✅ 應用重啟後自動登入
- ✅ 登出時清除會話

## 🆚 SQLite vs Firebase

| 特性 | SQLite 版本 | Firebase 版本 |
|------|------------|---------------|
| 需要網絡 | ❌ 不需要 | ✅ 需要 |
| 離線使用 | ✅ 完全離線 | ❌ 需要聯網 |
| 設置複雜度 | ✅ 簡單 | ❌ 複雜 |
| 實時同步 | ❌ 不支援 | ✅ 支援 |
| 跨設備同步 | ❌ 不支援 | ✅ 支援 |
| 數據備份 | 需手動 | 自動 |
| 成本 | ✅ 免費 | ✅ 免費額度 |
| 適用場景 | 本地應用、工具類 | 需要同步的應用 |

## 🔧 配置說明

### Android 配置

不需要額外配置！應用會自動在設備上創建數據庫。

### iOS 配置

不需要額外配置！應用會自動在設備上創建數據庫。

## 🐛 故障排除

### 應用無法啟動
- 確認 Flutter SDK 已正確安裝
- 運行 `flutter doctor` 檢查環境

### 無法註冊或登入
- 檢查 email 格式是否正確
- 確認密碼符合要求（至少 6 個字元）
- 查看 console 日誌中的錯誤信息

### 數據庫錯誤
- 刪除應用並重新安裝（清除舊數據庫）
- 檢查設備存儲空間

## 📝 自定義

### 修改應用名稱和圖標
- **Android**：修改 `android/app/src/main/AndroidManifest.xml` 中的 `android:label`
- **iOS**：修改 `ios/Runner/Info.plist` 中的 `CFBundleDisplayName`

### 修改主題顏色
在 `lib/main.dart` 中修改 `ColorScheme.fromSeed` 的 `seedColor` 參數。

### 添加新功能
1. 在 `lib/screens/` 中創建新的頁面
2. 在 `lib/services/auth_service.dart` 中添加相應的業務邏輯
3. 在現有頁面中添加導航到新頁面的按鈕

### 自定義數據庫表結構
編輯 `lib/services/auth_service.dart` 中的 `_initDatabase` 方法。

## 🔮 未來擴展建議

### 功能擴展
- [ ] 真實的 Email 驗證（整合郵件服務）
- [ ] 手機號碼登入
- [ ] 用戶資料編輯（姓名、頭像等）
- [ ] 頭像上傳
- [ ] 雙重認證（2FA）
- [ ] 生物識別登入（Face ID/Touch ID）
- [ ] 數據備份和恢復
- [ ] 多語言支援

### 數據庫擴展
- [ ] 用戶資料表
- [ ] 設置表
- [ ] 活動日誌表
- [ ] 數據導出功能

### 網絡功能（可選）
- [ ] 雲端同步（Firebase / AWS / 自建後端）
- [ ] 推送通知
- [ ] 數據分析

## 📄 授權

此專案僅供學習和個人使用。

## 🤝 貢獻

歡迎提交問題和改進建議！

## 📞 支援

如有問題，請：
1. 查看故障排除部分
2. 檢查 console 日誌
3. 提交 Issue

---

**開發者：mkz** 🤖❤️
**框架：Flutter + SQLite**
**平台：iOS + Android**
**特點：完全離線運行**
