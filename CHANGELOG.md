# 變更日誌 - Firebase → SQLite 遷移

## 📅 變更日期
2026-04-08

## 🔄 主要變更

### 從 Firebase 遷移到本地 SQLite 數據庫

**變更原因：**
- 完全離線運行，不需要網絡連接
- 零配置，開箱即用
- 更好的隱私保護（數據不離開設備）
- 無需 API 密鑰或雲端服務帳號
- 更快的響應速度（本地操作）

---

## 📦 依賴包變更

### 移除的依賴
```yaml
- firebase_core: ^2.24.2      # Firebase 核心庫
- firebase_auth: ^4.16.0      # Firebase 認證
```

### 新增的依賴
```yaml
+ sqflite: ^2.3.0             # SQLite 數據庫
+ path: ^1.8.3                # 路徑操作
+ crypto: ^3.0.3              # 密碼加密（SHA-256）
```

### 保留的依賴
```yaml
provider: ^6.1.1              # 狀態管理（不變）
shared_preferences: ^2.2.2    # 會話存儲（不變）
fluttertoast: ^8.2.4          # 提示訊息（不變）
```

---

## 🔧 代碼變更

### 1. pubspec.yaml
**變更：** 移除 Firebase 依賴，添加 SQLite 相關依賴

### 2. lib/main.dart
**變更：**
- ❌ 移除 `await Firebase.initializeApp()`
- ❌ 移除 Firebase 相關導入
- ✅ 應用啟動不再需要初始化外部服務

**變更前：**
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // ❌ 移除
  runApp(const MyApp());
}
```

**變更後：**
```dart
void main() {
  runApp(const MyApp());  // ✅ 直接運行
}
```

### 3. lib/services/auth_service.dart
**重大重寫：** 完全重寫認證服務

#### 主要變更

**數據庫初始化：**
- ❌ 移除 `FirebaseAuth` 實例
- ✅ 添加本地 SQLite 數據庫初始化
- ✅ 自動創建數據庫和表

**用戶管理：**
- ❌ 移除 `FirebaseAuth.User`
- ✅ 使用 `Map<String, dynamic>` 存儲用戶信息
- ✅ 直接操作 SQLite 數據庫

**密碼處理：**
- ✅ 新增 SHA-256 密碼哈希加密
- ✅ 密碼不以明文存儲
- ❌ 不再依賴 Firebase 的密碼處理

**認證流程：**
- ❌ 移除 Firebase 的 `signInWithEmailAndPassword`
- ❌ 移除 Firebase 的 `createUserWithEmailAndPassword`
- ❌ 移除 Firebase 的 `sendPasswordResetEmail`
- ✅ 實現本地註冊、登入、密碼重設邏輯
- ✅ 使用 SQLite 查詢和更新操作

**會話管理：**
- ✅ 使用 `SharedPreferences` 存儲用戶 ID
- ✅ 應用重啟時自動恢復登入狀態
- ❌ 不再依賴 Firebase 的會話管理

**新增功能：**
- ✅ `verifyEmail()` - 本地驗證 email
- ✅ `changePassword()` - 修改密碼
- ✅ `deleteAccount()` - 刪除帳號
- ✅ `getUserStats()` - 獲取用戶統計信息
- ✅ `cleanExpiredSessions()` - 清理過期會話

### 4. lib/screens/home_screen.dart
**增強功能：**
- ✅ 添加「修改密碼」對話框
- ✅ 添加「用戶統計」對話框
- ✅ 添加「應用信息」對話框
- ✅ Email 驗證按鈕（從模擬改為本地實際操作）

**變更前：**
```dart
// 驗證按鈕點擊重新發送驗證信
if (!authService.isEmailVerified) {
  authService.sendEmailVerification();
}
```

**變更後：**
```dart
// 驗證按鈕直接驗證 email
onPressed: () async {
  final success = await authService.verifyEmail();
  if (success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('信箱驗證成功！')),
    );
  }
},
```

### 5. 其他頁面（login_screen.dart, register_screen.dart, forgot_password_screen.dart）
**無需變更：**
- UI 代碼保持不變
- 認證服務接口保持兼容
- 用戶體驗一致

---

## 🗄️ 數據庫結構

### 新增數據庫

**數據庫名稱：** `auth_app.db`

#### users 表
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

#### sessions 表（預留擴展）
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

---

## 📝 文檔更新

### 更新的文檔
1. ✅ **README.md** - 完全重寫，反映 SQLite 版本
2. ✅ **SETUP_GUIDE.md** - 移除 Firebase 設置步驟，簡化為 3 步
3. ✅ **QUICK_REFERENCE.md** - 更新為 SQLite 相關內容
4. ✅ **PROJECT_SUMMARY.md** - 完全重寫，詳細說明 SQLite 架構
5. ✅ **CHANGELOG.md** - 新增本文件

### 主要文檔變更

**README.md：**
- ❌ 移除 Firebase 設置說明
- ✅ 添加 SQLite 數據庫說明
- ✅ 添加密碼加密說明
- ✅ 更新功能列表
- ✅ 添加 SQLite vs Firebase 比較表

**SETUP_GUIDE.md：**
- ❌ 移除「設置 Firebase」步驟（原第二步）
- ✅ 簡化為 3 步：安裝 Flutter → 安裝依賴 → 運行
- ✅ 添加數據庫管理說明
- ✅ 更新常見問題

**QUICK_REFERENCE.md：**
- ❌ 移除 Firebase 配置檢查清單
- ✅ 添加數據庫操作速查
- ✅ 添加數據庫位置說明
- ✅ 更新常見錯誤

---

## 🎯 功能對比

### Firebase 版本 vs SQLite 版本

| 功能 | Firebase 版本 | SQLite 版本 | 變更 |
|------|--------------|------------|------|
| 用戶註冊 | ✅ | ✅ | 本地存儲 |
| 用戶登入 | ✅ | ✅ | 本地驗證 |
| 用戶登出 | ✅ | ✅ | 清除本地會話 |
| Email 驗證 | ✅（真實郵件） | ✅（本地模擬） | 模擬驗證 |
| 忘記密碼 | ✅（發送郵件） | ✅（模擬發送） | 模擬發送 |
| 自動登入 | ✅ | ✅ | 本地實現 |
| 修改密碼 | ❌ | ✅ | 新增功能 |
| 刪除帳號 | ❌ | ✅ | 新增功能 |
| 用戶統計 | ❌ | ✅ | 新增功能 |
| 需要網絡 | ✅ | ❌ | 離線運行 |
| 需要配置 | ✅ | ❌ | 零配置 |
| 跨設備同步 | ✅ | ❌ | 本地獨立 |

---

## 🔒 安全性變更

### 改進
- ✅ 密碼使用 SHA-256 加密（與 Firebase 相同）
- ✅ 密碼不以明文存儲
- ✅ 數據不離開設備（更隱私）

### 注意
- ⚠️ 數據庫文件可能被設備訪問（需要 root 或越獄）
- ⚠️ 建議生產環境使用 SQLCipher 加密數據庫
- ⚠️ Email 驗證是模擬的（不是真實郵件驗證）

---

## 🚀 部署變更

### Firebase 版本
```bash
# 需要先設置 Firebase
1. 創建 Firebase 專案
2. 添加 Android/iOS 應用
3. 下載配置文件
4. 啟用 Email/Password 登入
5. 然後才能運行應用
```

### SQLite 版本
```bash
# 直接運行，無需任何配置
flutter pub get
flutter run
```

---

## ⚠️ 破壞性變更

### 向後不兼容
- ❌ 舊版 Firebase 帳號無法遷移到 SQLite 版本
- ❌ 需要重新註冊帳號

### 數據遷移
如果需要從 Firebase 遷移數據到 SQLite：
1. 在 Firebase 版本中導出用戶數據
2. 在 SQLite 版本中導入用戶數據
3. 重新設置密碼（因為哈希方式可能不同）

---

## 📊 性能影響

### 改進
- ✅ 網絡請求延遲消除
- ✅ 更快的登入/註冊響應
- ✅ 離線運行能力

### 考慮
- ⚠️ 大量用戶時可能需要數據庫優化
- ⚠️ 複雜查詢需要索引優化

---

## 🎓 學習曲線

### Firebase 版本
- 需要學習 Firebase 概念和 API
- 需要了解 Firebase Console 操作
- 需要理解雲端架構

### SQLite 版本
- 需要學習 SQL 語言
- 需要了解數據庫設計
- 更容易理解和調試

---

## 🔮 未來擴展

### SQLite 版本可以擴展為：
- ✅ 添加真實 Email 驗證（整合郵件服務）
- ✅ 添加雲端同步（整合後端服務）
- ✅ 添加數據備份（整合雲存儲）
- ✅ 添加多用戶支持（添加角色表）

### 可以遷移回 Firebase：
- ✅ 保留當前 UI 代碼
- ✅ 修改 `auth_service.dart` 使用 Firebase
- ✅ 數據需要遷移

---

## ✅ 遷移檢查清單

### 已完成
- [x] 更新 pubspec.yaml 依賴
- [x] 重寫 auth_service.dart
- [x] 更新 main.dart
- [x] 增強 home_screen.dart
- [x] 更新所有文檔
- [x] 測試基本功能
- [x] 驗證離線運行

### 建議後續
- [ ] 編寫單元測試
- [ ] 編寫集成測試
- [ ] 添加數據庫加密（SQLCipher）
- [ ] 添加數據備份功能
- [ ] 性能測試和優化

---

## 📞 問題排查

### 常見問題

**Q: 數據庫在哪裡？**
A: 
- Android: `/data/data/com.example.flutter_auth_app/databases/auth_app.db`
- iOS: 應用沙盒的 Documents 目錄

**Q: 如何清除數據庫？**
A: 刪除應用並重新安裝，或在設備設置中清除應用數據。

**Q: 可以遷移舊帳號嗎？**
A: 目前不支持自動遷移，需要重新註冊。

**Q: 數據安全嗎？**
A: 密碼使用 SHA-256 加密，但數據庫文件本身未加密。生產環境建議使用 SQLCipher。

---

## 🎉 總結

從 Firebase 遷移到 SQLite 是一個成功的改進：

### 優點
- ✅ 完全離線運行
- ✅ 零配置，開箱即用
- ✅ 更好的隱私保護
- ✅ 更快的響應速度
- ✅ 無需 API 密鑰
- ✅ 完全免費

### 權衡
- ⚠️ 失去跨設備同步
- ⚠️ Email 驗證是模擬的
- ⚠️ 數據僅在本地

### 適用場景
- ✅ 本地工具類應用
- ✅ 個人筆記應用
- ✅ 離線遊戲
- ✅ 需要隱私的應用

---

**遷移完成！現在擁有一個完全離線、零配置的認證系統！** 🚀
