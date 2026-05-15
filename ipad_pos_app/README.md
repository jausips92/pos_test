# Android / iPad 單機點餐 APP

這個資料夾是 Flutter 原生 App 源碼。設計目標是單台平板自己跑，不需要電腦開著。

## 功能方向

- 類別與商品存在 iPad 本機 SQLite。
- 單號存在 iPad 本機，每天從 `YYMMDD0001` 開始。
- 結帳時產生列印單，格式依 `20260509_152051.jpg`：單號、分隔線、品項/數量/單價、列印時間。
- 可設定出單機 IP 與 Port。
- 列印以 TCP Socket 傳送文字版列印單，後續可依出單機型號補 ESC/POS 指令。

## Android 平板

請看：

`ANDROID_BUILD_STEPS.md`

Android 可產生 APK 後直接安裝到平板，不需要 Apple Developer Program。

## iPad

請看：

`MAC_BUILD_STEPS.md`

## 出單機

先確認出單機：

- IP，例如 `192.168.1.100`
- Port，常見 ESC/POS 網路熱感機是 `9100`
- 是否接受純文字列印，或必須使用 ESC/POS 指令

如果必須 ESC/POS，下一步會在 `ReceiptPrinter` 補上初始化、字型大小、切紙等 byte 指令。
