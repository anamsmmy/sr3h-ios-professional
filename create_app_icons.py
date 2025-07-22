from PIL import Image
import os

def create_app_icons():
    source_image = "800x800.png"
    
    if not os.path.exists(source_image):
        print(f"❌ Source image not found: {source_image}")
        return
    
    img = Image.open(source_image)
    
    android_sizes = [
        (192, "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"),
        (144, "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"),
        (96, "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"),
        (72, "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"),
        (48, "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"),
    ]
    
    for size, path in android_sizes:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(path)
        print(f"✅ Created: {path} ({size}x{size})")
    
    ios_sizes = [
        (180, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png"),
        (120, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png"),
        (120, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png"),
        (80, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png"),
        (40, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png"),
        (87, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png"),
        (58, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png"),
        (29, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png"),
        (60, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png"),
        (40, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png"),
        (20, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png"),
        (152, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png"),
        (76, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png"),
        (167, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png"),
        (1024, "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"),
    ]
    
    for size, path in ios_sizes:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(path)
        print(f"✅ Created: {path} ({size}x{size})")
    
    print("\n🎉 All app icons created successfully!")

if __name__ == "__main__":
    create_app_icons()
