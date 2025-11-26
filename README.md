# Relay42 Flutter Tracking SDK

A lightweight Flutter/Dart SDK for sending **Engagements**, **Facts**, and **Mappings** to the Relay42 **tracking API** (`https://t.svtrd.com`) directly from a mobile app—no authentication required.

This SDK is safe for client-side usage because it relies only on public Relay42 tracking endpoints (no Basic/Bearer API keys needed).

---

## 🚀 Features

- ✔ Track **Engagements**
- ✔ Track **Facts**
- ✔ Send **ID Mappings**
- ✔ No secrets or tokens required
- ✔ 100% mobile-safe
- ✔ Works in Flutter for iOS & Android

---

## 📦 Installation

### Option A — Use from GitHub (recommended)

Add this to your app’s `pubspec.yaml`:

```yaml
dependencies:
  relay42_flutter_sdk:
    git:
      url: https://github.com/relay42-solutions/Relay42-Flutter-SDK.git
      ref: main
```

Then:

```bash
flutter pub get
```

---

### Option B — Use locally during development

If the SDK folder is next to your Flutter app:

```yaml
dependencies:
  relay42_flutter_sdk:
    path: ../Relay42-Flutter-SDK
```

Run:

```bash
flutter pub get
```

---

## 🧱 SDK Structure

```
lib/
 ├── relay42_flutter_sdk.dart      # Export entrypoint
 └── src/
     └── client.dart               # Main Tracking API client
pubspec.yaml
README.md
```

---

## 🎯 Usage

### 1. Import the SDK

```dart
import 'package:relay42_flutter_sdk/relay42_flutter_sdk.dart';

final client = Relay42TrackingClient(siteId: '1232');
```

---

## ✴️ Engagements

Example request:
```
https://t.svtrd.com/t-1232?i=UUID&e=true&et=ProductView&cup=productId%3A1630&cb=...
```

Flutter example:

```dart
final response = await client.trackEngagement(
  uuid: '522a5323-b3ff-44df-8624-a22edf8d2800',
  engagementType: 'ProductView',
  properties: {
    'productId': '1630',
    'categoryId': '249',
  },
);

print(response.statusCode);
print(response.body);
```

---

## 📘 Facts

Example tracking URL:
```
https://t.svtrd.com/t-1232?i=UUID&f=true&ft=LastProduct&fttl=157784630&cup=LastProduct%3A1630
```

Flutter example:

```dart
final response = await client.trackFact(
  uuid: '30154a8e-67ec-4437-8fde-d673c93090b5',
  factName: 'LastProduct',
  ttlSecs: 86400,
  properties: {
    'LastProduct': '1630',
    'SecondProduct': '1631',
  },
);
```

---

## 🔄 Mappings

Example mapping URL:
```
https://t.svtrd.com/syncResponse?ca_site=1232&ca_partner=2001&ca_cookie=UUID&pid=12345
```

Flutter example:

```dart
final response = await client.sendMapping(
  uuid: '30154a8e-67ec-4437-8fde-d673c93090b5',
  partnerType: '2001',
  externalId: 'ABC123',
  merge: true,
);
```

---

## 🔒 Security

This SDK uses *only* the Relay42 Tracking API:

- No authentication  
- No secrets  
- No customer IDs beyond UUIDs  
- Endpoints designed for client/mobile usage  

For Relay42 REST API operations (facts/mappings requiring Basic/Bearer auth), use a **backend proxy** like Firebase Cloud Functions.

---

## 🧪 Testing

You can test events in:

- Browser devtools (Network tab)
- Charles Proxy
- Backend journey streams in Relay42

---

## 📄 License

MIT (or update according to your organisation’s policy).

---

## 💬 Support

For improvements, issues, or PRs, contact the maintainer or submit issues on GitHub.
