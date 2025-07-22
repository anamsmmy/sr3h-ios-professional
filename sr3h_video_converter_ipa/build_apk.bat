@echo off
echo Building SR3H Video Converter APK...
echo.

echo Step 1: Cleaning previous builds...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building APK (Release)...
flutter build apk --release

echo.
echo Step 4: Building APK (Debug) for testing...
flutter build apk --debug

echo.
echo Build completed!
echo.
echo Release APK location: build\app\outputs\flutter-apk\app-release.apk
echo Debug APK location: build\app\outputs\flutter-apk\app-debug.apk
echo.
pause