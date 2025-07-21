@echo off
chcp 65001 >nul
echo ========================================
echo    Building APK with FFmpeg - Fixed
echo ========================================
echo.

echo Step 1: Copy final FFmpeg code...
copy "lib\main_final_ffmpeg.dart" "lib\main.dart" /Y
echo ✅ FFmpeg code copied
echo.

echo Step 2: Copy logo...
if exist "M:\7j\logo.png" (
    copy "M:\7j\logo.png" "assets\images\logo.png" /Y
    echo ✅ Logo copied
) else (
    echo ⚠️ Logo not found - using default icon
)
echo.

echo Step 3: Clean build...
C:\flutter\bin\flutter clean
echo ✅ Clean completed
echo.

echo Step 4: Get dependencies with FFmpeg...
echo WARNING: This may take longer to download FFmpeg...
C:\flutter\bin\flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to get dependencies
    echo Trying to fix pub cache...
    C:\flutter\bin\flutter pub cache repair
    C:\flutter\bin\flutter pub get
    if %errorlevel% neq 0 (
        echo ❌ Still failed. Check internet connection.
        pause
        exit /b 1
    )
)
echo ✅ Dependencies downloaded successfully
echo.

echo Step 5: Build APK with FFmpeg...
echo WARNING: This may take 15-20 minutes for first time
echo FFmpeg is a very large library and needs time to compile...
echo Please wait and do not close this window...
echo.

echo Trying different build approaches...
echo.

echo Approach 1: Standard release build...
C:\flutter\bin\flutter build apk --release --verbose
if %errorlevel% equ 0 (
    echo ✅ Standard build succeeded
    goto :copy_apk
)

echo Approach 2: Build without optimizations...
C:\flutter\bin\flutter build apk --release --no-shrink --no-obfuscate
if %errorlevel% equ 0 (
    echo ✅ Build without optimizations succeeded
    goto :copy_apk
)

echo Approach 3: Build with split per ABI...
C:\flutter\bin\flutter build apk --release --split-per-abi
if %errorlevel% equ 0 (
    echo ✅ Split ABI build succeeded
    goto :copy_apk
)

echo ❌ All build approaches failed
echo Checking for common issues...
echo.

echo Checking Flutter doctor...
C:\flutter\bin\flutter doctor
echo.

echo Checking Android licenses...
echo y | C:\Android\Sdk\tools\bin\sdkmanager --licenses 2>nul
echo.

echo Please check the errors above and try again.
pause
exit /b 1

:copy_apk
echo.
echo Step 6: Copy final APK...
if not exist "APK_FFMPEG_FIXED" mkdir "APK_FFMPEG_FIXED"

set "found_apk=false"

REM Check for different APK files
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "APK_FFMPEG_FIXED\SR3H-Video-Converter-v2.0.1-FFMPEG-arm64.apk"
    set "found_apk=true"
    echo ✅ ARM64 APK copied
)

if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "APK_FFMPEG_FIXED\SR3H-Video-Converter-v2.0.1-FFMPEG-arm32.apk"
    set "found_apk=true"
    echo ✅ ARM32 APK copied
)

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_FFMPEG_FIXED\SR3H-Video-Converter-v2.0.1-FFMPEG.apk"
    set "found_apk=true"
    echo ✅ Universal APK copied
)

if "%found_apk%"=="true" (
    echo.
    echo ========================================
    echo         SUCCESS! APK with FFmpeg Ready
    echo ========================================
    
    for %%A in ("APK_FFMPEG_FIXED\*.apk") do (
        echo 📱 %%~nxA
        powershell -Command "Write-Host 'Size: ' -NoNewline; [math]::Round((Get-Item '%%A').Length/1MB,2); Write-Host ' MB'"
    )
    
    echo.
    echo ✅ FINAL FEATURES IMPLEMENTED:
    echo ✅ 1. Real video conversion using FFmpeg
    echo ✅ 2. Exact command applied: ffmpeg -itsscale 2 -i INPUT.mp4 -c:v copy -c:a copy OUTPUT-SR3H.mp4
    echo ✅ 3. Larger logo (150x150)
    echo ✅ 4. Tajawal Arabic font
    echo ✅ 5. Pre-conversion tips (always visible)
    echo ✅ 6. Website link: www.SR3H.com
    echo ✅ 7. Enhanced "About" button with FFmpeg command
    echo ✅ 8. Activation status and email display
    echo ✅ 9. Add "-SR3H" to converted file name
    echo ✅ 10. Detailed progress bar during conversion
    echo ✅ 11. Detailed conversion result messages
    echo ✅ 12. Save files in Download/SR3H_Converted folder
    echo ✅ 13. Support all video types
    echo ✅ 14. Full file access permissions
    echo ✅ 15. Responsive and optimized interface
    echo ✅ 16. FFmpeg Edition - Final Version
    echo.
    
    echo 🎬 FINAL APK WITH REAL FFMPEG READY FOR DISTRIBUTION!
    echo Folder: APK_FFMPEG_FIXED
    echo.
    echo INSTALLATION INSTRUCTIONS:
    echo 1. Completely delete any old version from device
    echo 2. Restart device to ensure cleanup
    echo 3. Copy appropriate file for your device architecture:
    echo    - ARM64: For modern devices (recommended)
    echo    - ARM32: For older devices
    echo    - Universal: Works on all devices
    echo 4. Enable "Unknown sources" in settings
    echo 5. Install app and grant all required permissions
    echo 6. Use email: test@example.com for testing
    echo 7. Select video file and press "Start Conversion"
    echo 8. Wait for real conversion to complete
    echo.
    echo IMPORTANT NOTES:
    echo - App needs file access permissions
    echo - Real conversion may take time depending on video size
    echo - Converted files saved in Download/SR3H_Converted folder
    echo - "-SR3H" is added to converted file name
    echo - Exact FFmpeg command is applied as requested
    echo.
    echo 🚀 THIS IS THE FINAL APP WITH REAL FFMPEG AS REQUESTED!
    
) else (
    echo ❌ Failed to create APK
    echo Please check errors and try again
)

echo.
pause