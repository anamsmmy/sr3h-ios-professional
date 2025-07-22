from PIL import Image
import os

# Source image
source = '800x800.png'

# iOS icon sizes
sizes = [
    (1024, 'Icon-App-1024x1024@1x.png'),
    (180, 'Icon-App-60x60@3x.png'),
    (120, 'Icon-App-60x60@2x.png'),
    (120, 'Icon-App-40x40@3x.png'),
    (87, 'Icon-App-29x29@3x.png'),
    (80, 'Icon-App-40x40@2x.png'),
    (76, 'Icon-App-76x76@1x.png'),
    (60, 'Icon-App-20x20@3x.png'),
    (58, 'Icon-App-29x29@2x.png'),
    (40, 'Icon-App-40x40@1x.png'),
    (40, 'Icon-App-20x20@2x.png'),
    (29, 'Icon-App-29x29@1x.png'),
    (20, 'Icon-App-20x20@1x.png'),
    (167, 'Icon-App-83.5x83.5@2x.png'),
    (152, 'Icon-App-76x76@2x.png')
]

# Output directory
output_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'

try:
    with Image.open(source) as img:
        print(f'Source: {source} ({img.size})')
        
        for size, filename in sizes:
            resized = img.resize((size, size), Image.Resampling.LANCZOS)
            output_path = os.path.join(output_dir, filename)
            resized.save(output_path, 'PNG', optimize=True)
            print(f'Created: {filename} ({size}x{size})')
        
        print(f'Successfully created {len(sizes)} icons!')
        
except Exception as e:
    print(f'Error: {e}')
