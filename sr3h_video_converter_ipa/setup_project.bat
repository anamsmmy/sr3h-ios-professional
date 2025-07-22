@echo off
echo Setting up SR3H Video Converter Project...
echo.

echo Step 1: Checking Flutter installation...
flutter doctor

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Creating necessary directories...
if not exist "assets\images" mkdir "assets\images"
if not exist "assets\icons" mkdir "assets\icons"
if not exist "assets\fonts" mkdir "assets\fonts"

echo.
echo Step 4: Checking Android setup...
flutter doctor --android-licenses

echo.
echo Setup completed!
echo.
echo Next steps:
echo 1. Copy your logo.png to assets\images\
echo 2. Copy your icon.ico to assets\icons\
echo 3. Run 'run_dev.bat' to start development
echo 4. Run 'build_apk.bat' to build release APK
echo.
pause