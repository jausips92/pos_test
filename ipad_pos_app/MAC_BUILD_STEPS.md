# Mac 打包 iPad 安裝步驟

在 Mac 上先安裝 Xcode 與 Flutter，然後解壓 `ipad_pos_app_source_for_mac.zip`。

```bash
cd ipad_pos_app
flutter pub get
flutter doctor -v
open ios/Runner.xcworkspace
```

在 Xcode：

1. 選 `Runner` target。
2. 到 `Signing & Capabilities` 選你的 Apple 帳號與 Team。
3. Bundle Identifier 改成唯一值，例如 `com.yourshop.ipadpos`。
4. 接上 iPad，選擇裝置後按 Run。

若要產生安裝檔：

```bash
flutter build ipa
```

Windows 無法執行 `flutter build ipa`，因為 iOS 簽名與封裝需要 macOS + Xcode。

## 出單機列印

iOS 版與 Android APK 使用同一份 Flutter 程式，已改成 80mm 熱感紙寬的圖片列印模式，避免中文亂碼並保留文字大小、置中與自動裁切。

若修改過列印格式，必須重新在 Mac 上 Run 或重新打包 IPA，已安裝在 iPad 上的舊 App 不會自動更新。
