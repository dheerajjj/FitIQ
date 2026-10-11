# FitIQ — Flutter + Python fitness companion

**Status:** early prototype, not Play Store ready. Free, offline-first, manual activity tracking.

## Current features
- Flutter Android UI with Today, Train, Nutrition, Progress and Profile
- Manual workout repetitions, calories, protein and water logging
- Local preferences persistence; edit profile and delete logged activity
- Separate Python deterministic coaching algorithm and localhost-only proof-of-concept API
- GitHub Actions for Python unit tests and Flutter analysis, widget tests and Android debug APK build

## Run Android
Install Flutter SDK and Android SDK, then run:
```bash
flutter create --platforms=android .
flutter pub get
flutter analyze
flutter test
flutter run
```

## Run Python tests
```bash
python -m unittest discover -s intelligence/tests -v
python -m intelligence.api
```

Development-only POST `http://127.0.0.1:8765/v1/next-session` with JSON:
```json
{"completed_reps":12,"target_reps":12,"effort":6,"soreness":2,"weight_kg":20}
```

## Security and quality limitations
- No secrets or API keys required; .gitignore excludes common credential files.
- Python HTTP server binds to 127.0.0.1; do **not** deploy it publicly without authentication, HTTPS and rate limiting.
- Flutter does **not** yet call Python; integration remains pending.
- This is not medical advice or a clinically validated fitness recommendation system.
- No cloud data transfer or account login in the current Flutter prototype.
- Debug APK build and automated CI tests must pass before claiming Android readiness.
- Real-device end-to-end, accessibility, privacy-policy, signing and Play Store checks are pending.
