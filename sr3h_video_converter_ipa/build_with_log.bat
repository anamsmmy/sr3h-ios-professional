@echo off
echo Starting build process...
cd /d "m:\APK _‏‏SR3H\sr3h_video_converter"

echo Running flutter clean...
C:\flutter\bin\flutter clean > build_log.txt 2>&1

echo Running flutter pub get...
C:\flutter\bin\flutter pub get >> build_log.txt 2>&1

echo Running flutter build apk...
C:\flutter\bin\flutter build apk --release >> build_log.txt 2>&1

echo Build process completed. Check build_log.txt for details.
echo.
echo Checking for APK files...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo APK found: app-release.apk
    dir "build\app\outputs\flutter-apk\*.apk"
) else (
    echo No APK files found.
    echo Check build_log.txt for errors.
)

pause