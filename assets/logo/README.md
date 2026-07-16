# assets/logo/

Place app logo files here. Already mapped in pubspec.yaml
(`assets/logo/`), so anything dropped in this folder is available
immediately after `flutter pub get` — no pubspec edit needed.

## Action needed: add `app_logo.png`

The project is wired to use **`assets/logo/app_logo.png`** as the
official app logo (see `core/constants/asset_paths.dart`,
`flutter_launcher_icons`, and `flutter_native_splash` config in
`pubspec.yaml`), sourced from:

https://i.postimg.cc/Y0wcY1Zf/Picsart-26-07-07-21-55-46-168.png

This sandbox has no network access, so the file could not be downloaded
into the project automatically. Download it yourself and save it as:

```
assets/logo/app_logo.png
```

A square PNG with a transparent or solid background, at least 512×512,
works best for both the app icon and adaptive icon generation. Once the
file is in place, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

This generates the Android app icon and native splash screen from that
one source image — no redesign, no manual per-density asset work.

The logo is also referenced by `AssetPaths.appLogo` for use directly in
widgets (auth screens, drawer header, about screen) once those are
built in a later phase.
