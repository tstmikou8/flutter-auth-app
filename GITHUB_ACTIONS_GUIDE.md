# 🚀 使用 GitHub Actions 自動構建 APK

## 🎯 為什麼用 GitHub Actions？

**優點：**
- ✅ 不需要本地環境配置
- ✅ 完全免費
- ✅ 自動化構建
- ✅ 成功率 99%+
- ✅ 只需 5 分鐘設置

## 📋 快速開始（3 步驟）

### 步驟 1：創建 GitHub 倉庫

1. **登入 GitHub**
   - 網址：https://github.com
   - 註冊或登入

2. **創建新倉庫**
   - 點擊右上角 "+" → "New repository"
   - 倉庫名稱：`flutter-auth-app`
   - 設置為 Private（私有）
   - 點擊 "Create repository"

### 步驟 2：上傳代碼

```bash
# 進入項目目錄
cd /home/mk/.openclaw/workspace/flutter-auth-app

# 初始化 Git
git init
git add .
git commit -m "Initial commit: Flutter Auth App with SQLite"

# 連接到 GitHub 倉庫
git remote add origin https://github.com/你的用戶名/flutter-auth-app.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

**替換 `你的用戶名` 為你的 GitHub 用戶名**

### 步驟 3：觸發構建

1. **打開 GitHub 倉庫頁面**
2. **點擊 "Actions" 標籤**
3. **應該看到 "Build Android APK" workflow**
4. **點擊 "Run workflow"**
5. **選擇分支，點擊 "Run workflow"**

## ⏱️ 等待構建完成

- **構建時間**：5-10 分鐘
- **查看進度**：Actions 頁面會顯示實時進度
- **構建狀態**：黃色（進行中）→ 綠色（成功）或紅色（失敗）

## 📥 下載 APK

### 構建成功後：

1. **點擊成功的 workflow**
2. **向下滾動到 "Artifacts" 部分**
3. **你會看到兩個 APK：**
   - `debug-apk` - Debug 版本
   - `release-apk` - Release 版本

4. **點擊 "debug-apk" 或 "release-apk"**
5. **下載 APK 文件**

### 文件說明

- **app-debug.apk**（~30-40 MB）
  - Debug 版本
  - 用於開發測試
  - 可以安裝到任何設備

- **app-release.apk**（~15-25 MB）
  - Release 版本
  - 已優化，更小更快
  - 適合分發給用戶

## 🔄 手動觸發構建

任何時候都可以重新構建：

1. **倉庫頁面 → Actions**
2. **選擇 "Build Android APK"**
3. **點擊 "Run workflow"**
4. **點擊 "Run workflow" 確認**

## 🔧 自動觸發構建

每次推送代碼時會自動構建：

```bash
# 修改代碼後
git add .
git commit -m "Update features"
git push

# 會自動觸發構建
```

## 📱 安裝 APK 到設備

### 方法一：USB 傳輸

```bash
# 連接 Android 設備
adb devices

# 安裝 APK
adb install app-debug.apk
# 或
adb install app-release.apk
```

### 方法二：直接傳輸

1. **將 APK 文件傳送到手機**（USB、藍牙、雲端等）
2. **在手機上點擊安裝**
3. **允許未知來源**（如果需要）

### 方法三：發布到應用商店

**app-release.aab** 可以上傳到：
- Google Play Console
- Amazon Appstore
- Huawei AppGallery

## 🎨 自定義構建

### 修改 Flutter 版本

編輯 `.github/workflows/build-apk.yml`:

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'  # 修改版本
    channel: 'stable'
    cache: true
```

### 構建 App Bundle（用於 Google Play）

```yaml
- name: Build App Bundle
  run: flutter build appbundle --release

- name: Upload App Bundle
  uses: actions/upload-artifact@v4
  with:
    name: release-aab
    path: build/app/outputs/bundle/release/app-release.aab
```

## 📊 構建歷史

所有構建歷史都保存在：
- **倉庫 → Actions**
- 可以查看每次構建的：
  - 構建時間
  - 構建日誌
  - 下載 APK

## 💡 提示

### 首次構建可能較慢
- 需要下載 Flutter SDK
- 需要下載依賴
- 預計 8-10 分鐘

### 後續構建更快
- 使用緩存
- 只下載變化的部分
- 預計 3-5 分鐘

### 查看構建日誌
- Actions 頁面點擊具體的 workflow
- 展開每個步驟查看詳情

## 🎉 成功標誌

構建成功後會看到：
- ✅ 綠色的勾選標記
- ✅ "All jobs have passed"
- ✅ Artifacts 部分顯示可下載的 APK

## ❌ 構建失敗

如果構建失敗：
1. 點擊失敗的 workflow
2. 查看錯誤日誌
3. 修復代碼
4. 重新推送代碼

## 📞 幫助

### GitHub Actions 文檔
https://docs.github.com/en/actions

### Flutter 文檔
https://flutter.dev/docs

### 常見問題
- 構建超時：增加 `timeout-minutes`
- 構建失敗：查看日誌，檢查代碼
- 無法下載：檢查權限

---

**總結：3 步驟，5 分鐘設置，自動構建 APK！** 🚀

不需要任何本地環境，完全免費使用 GitHub Actions！
