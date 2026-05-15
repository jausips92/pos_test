# Android 平板 APK 打包步驟

此版本適合「平板自己跑」，不需要 Apple Developer Program，也不需要每年重簽。

## 1. 安裝工具

在 Windows 安裝：

- Flutter
- Android Studio

打開 Android Studio 一次，依照提示安裝 Android SDK、Platform Tools、Android SDK Command-line Tools。

完成後在 PowerShell 檢查：

```powershell
C:\Users\jausi\OneDrive\Desktop\flutter\bin\flutter.bat doctor -v
```

`Android toolchain` 要變成打勾。

## 2. 打包 APK

進入專案資料夾：

```powershell
cd "C:\Users\jausi\OneDrive\Desktop\restaurant_pos\ipad_pos_app"
C:\Users\jausi\OneDrive\Desktop\flutter\bin\flutter.bat pub get
C:\Users\jausi\OneDrive\Desktop\flutter\bin\flutter.bat build apk --release
```

完成後 APK 會在：

```text
build\app\outputs\flutter-apk\app-release.apk
```

若剛修改過 Android 設定或 Dart 程式，必須重新執行 `build apk --release`，既有 APK 不會自動更新。

## 3. 安裝到 Android 平板

簡單方式：

1. 把 `app-release.apk` 傳到 Android 平板。
2. 在平板點 APK 安裝。
3. 若跳出安全提示，允許「安裝未知來源 App」。

USB 方式：

1. Android 平板開啟開發人員選項與 USB 偵錯。
2. 接到電腦。
3. 執行：

```powershell
C:\Users\jausi\OneDrive\Desktop\flutter\bin\flutter.bat install
```

## 4. 出單機

App 內設定出單機 IP 與 Port。常見網路熱感機 Port 是 `9100`。

若列印中文亂碼，表示出單機不接受目前的 UTF-8 文字，需要依型號改成 ESC/POS 編碼或 Big5/CP950。
