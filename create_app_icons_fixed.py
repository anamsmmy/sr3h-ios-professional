#!/usr/bin/env python3
"""
Script to create iOS app icons from a source image
"""

import os
from PIL import Image
import sys

def create_ios_icons(source_image_path, output_dir):
    """Create iOS app icons from source image"""
    
    # iOS icon sizes (width, height, filename)
    ios_sizes = [
        (20, 20, "Icon-App-20x20@1x.png"),
        (40, 40, "Icon-App-20x20@2x.png"),
        (60, 60, "Icon-App-20x20@3x.png"),
        (29, 29, "Icon-App-29x29@1x.png"),
        (58, 58, "Icon-App-29x29@2x.png"),
        (87, 87, "Icon-App-29x29@3x.png"),
        (40, 40, "Icon-App-40x40@1x.png"),
        (80, 80, "Icon-App-40x40@2x.png"),
        (120, 120, "Icon-App-40x40@3x.png"),
        (60, 60, "Icon-App-60x60@1x.png"),
        (120, 120, "Icon-App-60x60@2x.png"),
        (180, 180, "Icon-App-60x60@3x.png"),
        (76, 76, "Icon-App-76x76@1x.png"),
        (152, 152, "Icon-App-76x76@2x.png"),
        (167, 167, "Icon-App-83.5x83.5@2x.png"),
        (1024, 1024, "Icon-App-1024x1024@1x.png"),
    ]
    
    try:
        # Open source image
        with Image.open(source_image_path) as img:
            print(f"✅ Source image loaded: {img.size}")
            
            # Convert to RGBA if needed
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            # Create output directory if it doesn't exist
            os.makedirs(output_dir, exist_ok=True)
            
            # Generate each icon size
            for width, height, filename in ios_sizes:
                # Resize image
                resized = img.resize((width, height), Image.Resampling.LANCZOS)
                
                # Save as PNG
                output_path = os.path.join(output_dir, filename)
                resized.save(output_path, 'PNG', optimize=True)
                print(f"✅ Created: {filename} ({width}x{height})")
            
            print(f"\n🎉 Successfully created {len(ios_sizes)} iOS icons in: {output_dir}")
            return True
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    # Paths
    source_image = "c:/SR3H_IPA_BUILD/800x800.png"
    output_directory = "c:/SR3H_IPA_BUILD/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    print("🚀 Creating iOS App Icons...")
    print(f"📁 Source: {source_image}")
    print(f"📁 Output: {output_directory}")
    print("-" * 50)
    
    if not os.path.exists(source_image):
        print(f"❌ Source image not found: {source_image}")
        return False
    
    success = create_ios_icons(source_image, output_directory)
    
    if success:
        print("\n✅ Icon creation completed successfully!")
        print("📱 Icons are ready for iOS app")
    else:
        print("\n❌ Icon creation failed!")
    
    return success

if __name__ == "__main__":
    main()