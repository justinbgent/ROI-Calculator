# ROI-Calculator
ROI calculator for window replacements.

## Saved scenarios (Firebase)

The app can save and sync scenarios to Firestore so you can restore them later or on another device.

### Setup

1. Create a project in [Firebase Console](https://console.firebase.google.com/) and enable **Authentication** (Anonymous sign-in) and **Firestore**.
2. Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) and run from the project root:
   ```bash
   dart run flutterfire_cli configure
   ```
   This generates `lib/firebase_options.dart` with your project config (replacing the placeholder).
3. Deploy Firestore security rules so only the signed-in user can read/write their scenarios:
   ```bash
   firebase deploy --only firestore
   ```
   (If you use the Firebase CLI, add a `firebase.json` that points `firestore.rules` to `firestore.rules` in this repo.)
4. Run the app; it will sign in anonymously and use Firestore for saved scenarios.
