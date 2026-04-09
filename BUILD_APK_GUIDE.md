# APK 構建指南 - Flutter Auth App

## 📱 生成 Android APK

### 前置要求

要構建 Android APK，需要以下組件：

1. **Android SDK** - Android 軟件開發工具包
2. **Java JDK** - Java 開發工具包
3. **Android Build Tools** - Android 構建工具

### 方法一：使用 Android Studio（推薦）

#### 安裝步驟

1. **下載 Android Studio**
   ```bash
   # 下載最新的 Android Studio for Linux
   wget https://dl.google.com/dl/android/studio/ide-zips/2023.3.1.18/linux/android-studio-2023.3.1.18-linux.tar.gz

   # 解壓縮
   tar -xzf android-studio-2023.3.1.18-linux.tar.gz
   ```

2. **啟動 Android Studio**
   ```bash
   cd android-studio/bin
   ./studio.sh
   ```

3. **完成初始設置**
   - 選擇 "Standard" 安裝
   - 等待下載 SDK 和其他組件
   - 完成後，Android Studio 會自動配置環境

4. **驗證安裝**
   ```bash
   flutter doctor
   # 應該顯示 [✓] Android toolchain
   ```

5. **構建 APK**
   ```bash
   cd /home/mk/.openclaw/workspace/flutter-auth-app
   flutter build apk
   ```

### 方法二：使用命令行工具（較輕量）

#### 安裝步驟

1. **安裝 Java JDK**
   ```bash
   echo 'mk' | sudo -S apt update
   echo 'mk' | sudo -S apt install -y openjdk-17-jdk
   ```

2. **設置 JAVA_HOME**
   ```bash
   echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
   echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **下載 Android SDK 命令行工具**
   ```bash
   cd ~
   wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip

   # 創建 SDK 目錄
   mkdir -p Android/cmdline-tools
   unzip commandlinetools-linux-9477386_latest.zip -d Android/cmdline-tools
   cd Android/cmdline-tools
   mv cmdline-tools latest
   ```

4. **設置 ANDROID_HOME**
   ```bash
   echo 'export ANDROID_HOME=$HOME/Android' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools' >> ~/.bashrc
   source ~/.bashrc
   ```

5. **接受 SDK 條款**
   ```bash
   sdkmanager --licenses
   # 輸入 'y' 接受所有條款
   ```

6. **安裝必要的 SDK 組件**
   ```bash
   sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
   ```

7. **配置 Flutter 使用 Android SDK**
   ```bash
   flutter config --android-sdk $HOME/Android
   ```

8. **驗證安裝**
   ```bash
   flutter doctor
   # 應該顯示 [✓] Android toolchain
   ```

### 構建 APK

#### Debug APK（用於測試）
```bash
cd /home/mk/.openclaw/workspace/flutter-auth-app
flutter build apk
```

**輸出位置**: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK（用於發布）
```bash
flutter build apk --release
```

**輸出位置**: `build/app/outputs/flutter-apk/app-release.apk`

#### App Bundle（推薦用於 Google Play）
```bash
flutter build appbundle --release
```

**輸出位置**: `build/app/outputs/bundle/release/app-release.aab`

### APK 配置

#### 修改應用名稱

編輯 `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="你的應用名稱"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

#### 修改應用圖標

1. 準備圖標（1024x1024 PNG）
2. 使用 Android Asset Studio: https://image.asset.studio/
3. 生成的圖標替換 `android/app/src/main/res/mipmap-*` 中的文件

#### 修改包名（應用 ID）

編輯 `android/app/build.gradle`:
```gradle
android {
    namespace "com.yourcompany.yourapp"  // 修改這裡
    // ...
}
```

同時編輯 `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.yourapp">  // 修改這裡
```

### 簽名 APK（Release）

#### 1. 生成簽名密鑰

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**重要**: 記住密碼，不要提交 keystore 文件到版本控制。

#### 2. 配置簽名

創建 `android/key.properties`:
```properties
storePassword=你的密碼
keyPassword=你的密碼
keyAlias=upload
storeFile=/home/mk/upload-keystore.jks
```

編輯 `android/app/build.gradle`:
```gradle
...
// 在文件開頭添加
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            ...
            signingConfig signingConfigs.release
        }
    }
}
```

#### 3. 構建已簽名的 Release APK
```bash
flutter build apk --release
```

### 測試 APK

#### 在模擬器上測試
```bash
# 啟動模擬器
flutter emulators --launch <emulator_id>

# 安裝 APK
flutter install

# 或直接運行
flutter run
```

#### 在真機上測試
```bash
# 連接設備並啟用 USB 調試
adb devices

# 安裝 APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 發布 APK

#### 直接分發
1. 分發 APK 文件給用戶
2. 用戶下載並安裝（需要啟用「未知來源」）

#### Google Play
1. 使用 App Bundle (AAB) 而非 APK
2. 構建 AAB: `flutter build appbundle --release`
3. 上傳到 Google Play Console

#### 第三方應用商店
- Amazon Appstore
- Huawei AppGallery
- Samsung Galaxy Store
- 其他區域性應用商店

### 常見問題

#### Q: 構建失敗，提示 "Unable to locate Android SDK"
A: 確保已安裝 Android SDK 並設置正確的環境變量。

#### Q: 構建緩慢
A:
- 首次構建會較慢（需要下載依賴）
- 使用 `flutter build apk --split-per-abi` 可以加速

#### Q: APK 文件過大
A: 使用 ProGuard 優化和資源壓縮：
```gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### Q: 無法在設備上安裝
A: 確保：
- 設備已啟用「USB 調試」
- 設備已連接並授權電腦
- APK 簽名正確（Release 版本）

### 構建選項

#### Debug vs Release

| 特性 | Debug | Release |
|------|-------|---------|
| 大小 | 較大 | 較小 |
| 性能 | 未優化 | 已優化 |
| 調試 | 可調試 | 不可調試 |
| 簽名 | Debug 簽名 | Release 簽名 |
| 用途 | 開發測試 | 發布用戶 |

#### 構建變體

```bash
# 構建所有架構的 APK（較大）
flutter build apk

# 按架構分離構建（較小）
flutter build apk --split-per-abi

# 構建特定架構
flutter build apk --target-platform android-arm64
flutter build apk --target-platform android-arm
flutter build apk --target-platform android-x64

# 構建 App Bundle（推薦）
flutter build appbundle
```

### 性能優化

#### 1. 代碼混淆
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
    }
}
```

#### 2. 資源壓縮
```gradle
android {
    aaptOptions {
        cruncherEnabled false
    }
}
```

#### 3. 壓縮 Native Libraries
```gradle
android {
    ndk {
        abiFilters 'arm64-v8a', 'armeabi-v7a', 'x86_64'
    }
}
```

### 自動化構建

#### 使用腳本自動構建

創建 `build-apk.sh`:
```bash
#!/bin/bash

# 設置變量
APP_NAME="flutter_auth_app"
BUILD_TYPE="release"
OUTPUT_DIR="build/apk"

# 清理舊構建
flutter clean

# 構建 APK
flutter build apk --${BUILD_TYPE}

# 複製到輸出目錄
mkdir -p $OUTPUT_DIR
cp build/app/outputs/flutter-apk/app-${BUILD_TYPE}.apk $OUTPUT_DIR/${APP_NAME}-${BUILD_TYPE}.apk

echo "APK 構建完成: $OUTPUT_DIR/${APP_NAME}-${BUILD_TYPE}.apk"
```

使用:
```bash
chmod +x build-apk.sh
./build-apk.sh
```

### 文檔和資源

#### 官方文檔
- [Flutter Android 構建](https://flutter.dev/docs/deployment/android)
- [Android SDK 下載](https://developer.android.com/studio)
- [Google Play Console](https://play.google.com/console)

#### 有用工具
- [Android Asset Studio](https://image.asset.studio/) - 圖標生成
- [APK Analyzer](https://developer.android.com/studio/build/apk-analyzer) - APK 分析
- [Bundletool](https://developer.android.com/studio/command-line/bundletool) - AAB 工具

---

**準備發布！** 🚀

構建 APK 後，你可以：
- 測試 APK 在真實設備上
- 分發給測試用戶
- 發布到應用商店

**注意**: 確保已添加 `android/key.properties` 和 `*.jks` 到 `.gitignore`！
