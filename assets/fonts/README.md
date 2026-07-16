# assets/fonts/

Not used in Phase 1. The app currently loads Poppins at runtime via the
`google_fonts` package (fetched over the network on first use, then
cached on-device).

To bundle Poppins statically instead (recommended before a production
release, so the app works offline on first launch):

1. Download the Poppins static `.ttf` files (Regular, Medium, SemiBold,
   Bold, etc.) from Google Fonts.
2. Place them in this folder.
3. Add a `fonts:` section to `pubspec.yaml`'s `flutter:` block, e.g.:

   ```yaml
   fonts:
     - family: Poppins
       fonts:
         - asset: assets/fonts/Poppins-Regular.ttf
         - asset: assets/fonts/Poppins-Medium.ttf
           weight: 500
         - asset: assets/fonts/Poppins-SemiBold.ttf
           weight: 600
         - asset: assets/fonts/Poppins-Bold.ttf
           weight: 700
   ```

4. In `core/theme/app_typography.dart`, swap
   `GoogleFonts.poppinsTextTheme(_base)` for
   `_base.apply(fontFamily: 'Poppins')` so it reads the bundled font
   instead of fetching it.
