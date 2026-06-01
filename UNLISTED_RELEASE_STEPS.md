# Codemagic + App Store Unlisted Release Steps

This project now uses Codemagic to build, sign, upload, and submit the iOS app to App Store Review instead of submitting it to TestFlight.

## 1. Apple Developer setup

In App Store Connect, create or confirm the app record:

- Bundle ID: `com.jausips92.ipadpos`
- Platform: iOS
- Distribution method: Public
- App privacy, screenshots, description, category, age rating, pricing, and availability completed

For an unlisted app, Apple requires the app to be public first. After approval, Apple can change the app to Unlisted.

## 2. Codemagic environment variables

In Codemagic, keep these variables in the environment group named `a`:

- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `CERTIFICATE_PRIVATE_KEY`

The App Store Connect API key should have App Manager access.

## 3. Codemagic workflow behavior

The root `codemagic.yaml` workflow:

- installs Flutter packages
- runs Flutter tests
- fetches App Store signing files
- builds a signed release IPA
- uploads the IPA to App Store Connect
- submits the build to App Store Review
- uses manual release after approval

Manual release is intentional. It lets you wait for Apple to approve the unlisted request before making the app available through the App Store link.

## 4. Review note to Apple

In the App Review notes, include a short note like:

```text
This app is intended for unlisted App Store distribution. It is for a limited audience using the restaurant POS system and should only be discoverable by direct link.
```

Also include any demo account, setup instructions, or explanation needed for Apple to review the app.

## 5. Request the unlisted link

After the app is submitted to App Review, submit Apple's unlisted app request form:

https://developer.apple.com/contact/request/unlisted-app/

Apple can reject the unlisted request if the app is still beta, prerelease, or not submitted to App Review.

## 6. If the first Codemagic submission fails

The most common first-run issue is missing App Store Connect metadata, not the build itself. Finish the required screenshots, privacy, category, pricing, and review fields in App Store Connect, then run Codemagic again.
