@echo off
echo Starting Flutter build...
cd /d "m:\APK _‏‏SR3H\sr3h_video_converter"
echo Current directory: %CD%

echo Step 1: Flutter clean
C:\flutter\bin\flutter clean

echo Step 2: Flutter pub get
C:\flutter\bin\flutter pub get

echo Step 3: Flutter build APK
C:\flutter\bin\flutter build apk --release

echo Build completed!
pause